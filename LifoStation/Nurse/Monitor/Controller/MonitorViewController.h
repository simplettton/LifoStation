//
//  MonitorViewController.h
//  LifoStation
//
//  Created by Binger Zeng on 2019/1/9.
//  Copyright © 2019年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef  NS_ENUM(NSInteger,ShowViewType){
    SingleViewType = 1000,
    TwoViewsType,
    FourViewsType,
    NineViewsType
};


@interface MonitorViewController : UIViewController<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UITableViewDelegate,UITableViewDataSource>

@end

