//
//  TaskParentViewController.m
//  LifoStation
//
//  Created by Binger Zeng on 2019/3/7.
//  Copyright © 2019年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "TaskParentViewController.h"
#import "SPPageMenu.h"

#import "WaitingTaskViewController.h"
#import "ProcessingTaskViewController.h"
#import "FinishedTaskViewController.h"

#define pageMenuH 51
#define NaviH (kScreenHeight >= 812 ? 88 : 64) // 812是iPhoneX的高度
#define scrollViewHeight (kScreenHeight-NaviH-pageMenuH)

@interface TaskParentViewController ()<SPPageMenuDelegate, UIScrollViewDelegate>
@property (nonatomic, strong) NSArray *dataArr;
@property (nonatomic, weak) SPPageMenu *pageMenu;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) NSMutableArray *myChildViewControllers;

@end

@implementation TaskParentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view adaptScreenWidthWithType:AdaptScreenWidthTypeConstraint exceptViews:nil];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"任务列表";
     UITextField * searchField = [_searchBar valueForKey:@"_searchField"];
    searchField.layer.borderColor = UIColorFromHex(0xcdcdcd).CGColor;
    searchField.layer.borderWidth = 1.0;
    searchField.layer.cornerRadius = 5.0f;
    _searchBar.returnKeyType = UIReturnKeySearch;
    _searchButton.layer.borderColor = UIColorFromHex(0xcdcdcd).CGColor;
    _searchButton.layer.borderWidth = 1.0;

    [self initPageMenu];
    [self.view addSubview:self.scrollView];
    NSArray *controllerClassNames = [NSArray arrayWithObjects:@"WaitingTaskViewController",@"ProcessingTaskViewController",@"FinishedTaskViewController",nil];
    UIStoryboard *mainStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    for (NSString *className in controllerClassNames) {
        UIViewController *vc = [mainStoryBoard instantiateViewControllerWithIdentifier:className];
        [self addChildViewController:vc];
        [self.myChildViewControllers addObject:vc];
    }
    // pageMenu.selectedItemIndex就是选中的item下标
    if (self.pageMenu.selectedItemIndex < self.myChildViewControllers.count) {
        UIViewController *vc = self.myChildViewControllers[self.pageMenu.selectedItemIndex];
        [self.scrollView addSubview:vc.view];
        vc.view.frame = CGRectMake(kScreenWidth*self.pageMenu.selectedItemIndex, 0, kScreenWidth, scrollViewHeight);
        self.scrollView .contentOffset = CGPointMake(kScreenWidth*self.pageMenu.selectedItemIndex, 0);
        self.scrollView .contentSize = CGSizeMake(self.dataArr.count*kScreenWidth, 0);
        [self.view bringSubviewToFront:self.pageMenu];
    }

}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationController.navigationBar.barTintColor = UIColorFromHex(0x3A87C7);
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
}
- (void)initPageMenu {
    self.dataArr = @[@"排队中",@"治疗中",@"已完成"];

    SPPageMenu *pageMenu = [SPPageMenu pageMenuWithFrame:CGRectMake(12, 19, kScreenWidth / 3, pageMenuH) trackerStyle:SPPageMenuTrackerStyleLineLongerThanItem];
    [pageMenu setItems:self.dataArr selectedItemIndex:0];
    // 设置代理
    pageMenu.delegate = self;
    pageMenu.selectedItemTitleColor = [UIColor colorWithRed:24.0/256 green:144.0/256 blue:255/255 alpha:1];
    pageMenu.tracker.backgroundColor = [UIColor colorWithRed:24.0/256 green:144.0/256 blue:255/255 alpha:1];
    pageMenu.unSelectedItemTitleColor = UIColorFromHex(0x5E5E5E);
    pageMenu.unSelectedItemTitleFont = [UIFont systemFontOfSize:16 weight:UIFontWeightRegular];
//    pageMenu.spacing = 40;
    //去掉风格线
    pageMenu.dividingLine.hidden = YES;
    // 给pageMenu传递外界的大scrollView，内部监听self.scrollView的滚动，从而实现让跟踪器跟随self.scrollView移动的效果
    pageMenu.bridgeScrollView = self.scrollView;
    [self.view addSubview:pageMenu];
    _pageMenu = pageMenu;
}
#pragma mark - SPPageMenu的代理方法

- (void)pageMenu:(SPPageMenu *)pageMenu itemSelectedAtIndex:(NSInteger)index {
    NSLog(@"%ld",(long)index);
}

- (void)pageMenu:(SPPageMenu *)pageMenu itemSelectedFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex {
    NSLog(@"%ld------->%ld",(long)fromIndex,(long)toIndex);

    //切换任务tab的时候隐藏键盘
    [self.searchBar resignFirstResponder];
    
    //切换任务tab的时候切换delegate

    self.searchBar.text = @"";
    if ([self.childViewControllers count] == 3) {
        WaitingTaskViewController *vc0 = self.childViewControllers[0];
        ProcessingTaskViewController *vc1 = self.childViewControllers[1];
        FinishedTaskViewController *vc2 = self.childViewControllers[2];
        switch (toIndex) {
            case 0:
                self.searchBar.delegate = vc0;
                [vc0 refresh];
                break;
            case 1:
                self.searchBar.delegate = vc1;
                [vc1 refresh];
                break;
            case 2:
                self.searchBar.delegate = vc2;
                [vc2 refresh];
                break;
            default:
                break;
        }
        
    }

    
    // 如果该代理方法是由拖拽self.scrollView而触发，说明self.scrollView已经在用户手指的拖拽下而发生偏移，此时不需要再用代码去设置偏移量，否则在跟踪模式为SPPageMenuTrackerFollowingModeHalf的情况下，滑到屏幕一半时会有闪跳现象。闪跳是因为外界设置的scrollView偏移和用户拖拽产生冲突
    if (!self.scrollView.isDragging) { // 判断用户是否在拖拽scrollView
        // 如果fromIndex与toIndex之差大于等于2,说明跨界面移动了,此时不动画.
        if (labs(toIndex - fromIndex) >= 2) {
            [self.scrollView setContentOffset:CGPointMake(kScreenWidth * toIndex, 0) animated:NO];
        } else {
            [self.scrollView setContentOffset:CGPointMake(kScreenWidth * toIndex, 0) animated:YES];
        }
    }
    
    if (self.myChildViewControllers.count <= toIndex) {return;}
    
    UIViewController *targetViewController = self.myChildViewControllers[toIndex];
    // 如果已经加载过，就不再加载
//    if ([targetViewController isViewLoaded]) return;
    
    targetViewController.view.frame = CGRectMake(kScreenWidth * toIndex, 0, kScreenWidth, scrollViewHeight);
    [_scrollView addSubview:targetViewController.view];
    
    [self.view bringSubviewToFront:self.pageMenu];
    
}

#pragma mark - getter
- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 77, kScreenWidth, scrollViewHeight)];
        _scrollView.delegate = self;
        _scrollView.pagingEnabled = YES;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        //禁止左右滑动
        _scrollView.scrollEnabled = NO;
    }
    return  _scrollView;
}
- (NSMutableArray *)myChildViewControllers {
    
    if (!_myChildViewControllers) {
        _myChildViewControllers = [NSMutableArray array];
        
    }
    return _myChildViewControllers;
}

- (void)dealloc {
    NSLog(@"父控制器被销毁了");
}
@end
