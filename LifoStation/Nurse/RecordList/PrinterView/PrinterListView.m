//
//  PrinterListView.m
//  LifoStation
//
//  Created by Binger Zeng on 2019/4/29.
//  Copyright © 2019年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "PrinterListView.h"
#import "PrinterCell.h"
@interface PrinterListView()
@property (nonatomic, strong) NSMutableArray *datas;
@property (nonatomic, strong) NSString *selectedPrinterName;
@property (weak, nonatomic) IBOutlet UIView *noDataView;
@end
@implementation PrinterListView
- (instancetype)initWithData:(NSString *)taskId {
    if (self = [super init]) {
        PrinterListView *view = [PrinterListView createViewFromNib];
        view.taskId = taskId;
        return view;
    }
    return self;
}
- (void)layoutSubviews {
    [super layoutSubviews];
//    [self initAll];
}
- (void)awakeFromNib {
    [super awakeFromNib];
    [self initAll];
}
- (IBAction)cancelAction:(id)sender {
    [self hideView];
}
- (void)initAll {
    [self.tableView registerNib:[UINib nibWithNibName:@"PrinterCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"PrinterCell"];
    self.tableView.tableFooterView = [[UIView alloc]init];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.estimatedRowHeight = 60;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    [self initTableHeaderAndFooter];
    
//    [_datas addObject:@{@"name":@"HP LaserJet M506 PCL6"}];
//    [_datas addObject:@{@"name":@"NPIA013F9(HP LaserJet M506)"}];
//    [_datas addObject:@{@"name":@"NP IA01GR0(HP564)"}];
    
    
}
#pragma mark - refreshData
- (void)initTableHeaderAndFooter {
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(refresh)];
    [header setTitle:@"加载中..." forState:MJRefreshStateRefreshing];
    header.stateLabel.textColor =UIColorFromHex(0xABABAB);
    header.lastUpdatedTimeLabel.hidden = YES;
    self.tableView.mj_header = header;
    [self refresh];
    
}
- (void)refresh {
    [[NetWorkTool sharedNetWorkTool]POST:RequestUrl(@"api/ReportController/GetPrinterList")
                                  params:@{}
                                hasToken:YES
                                 success:^(HttpResponse *responseObject) {
                                     [self.tableView.mj_header endRefreshing];
                                     if ([responseObject.result integerValue] == 1) {
                                         
                                         if ([responseObject.content count] > 0) {
                                             self.selectedPrinterName = responseObject.content[0];
                                             for (NSString *printerName in responseObject.content) {
                                                 if (![self.datas containsObject:printerName]) {
                                                     [self.datas addObject:printerName];
                                                 }
                                             }
                                             self.noDataView.hidden = YES;
                                         } else {
                                             [self.datas removeAllObjects];
                                             self.noDataView.hidden = NO;
                                         }
                                         [self.tableView reloadData];
                                     }
                                 }
                                 failure:^(NSError *error) {
                                     [self.tableView.mj_header endRefreshing];
                                 }];

}
#pragma mark - TableView datasource
- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_datas count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* CellIdentifier = @"PrinterCell";
    PrinterCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    NSString *printerName = _datas[indexPath.row];
    cell.nameLabel.text = printerName;
    cell.selectionImageView.hidden = [self.selectedPrinterName isEqualToString:printerName] ? NO : YES;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.selectedPrinterName = _datas[indexPath.row];
    [tableView reloadData];
}
- (IBAction)print:(id)sender {
    if ([self.selectedPrinterName length] > 0) {
        [[NetWorkTool sharedNetWorkTool]POST:RequestUrl(@"api/ReportController/PrintTaskDocument") params:@{@"TaskId":self.taskId,@"PrinterName":self.selectedPrinterName} hasToken:YES success:^(HttpResponse *responseObject) {
            if ([responseObject.result integerValue] == 1) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [BEProgressHUD showMessage:@"打印任务已经提交到打印机"];
                });
                               
                
            }
            
        } failure:nil];
    }

}
- (NSMutableArray *)datas {
    if (!_datas) {
        _datas = [[NSMutableArray alloc]init];
    }
    return _datas;
}
- (NSString *)selectedPrinterName {
    if (!_selectedPrinterName) {
        _selectedPrinterName = [[NSString alloc]init];
    }
    return _selectedPrinterName;
}
@end
