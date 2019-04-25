//
//  SputumExcretionModel.h
//  LifoStation
//
//  Created by Binger Zeng on 2019/4/24.
//  Copyright © 2019年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONModel.h"
typedef NS_ENUM(NSInteger,OutPhlegmMode) {
    OutPhlegm_Standard = 0,
    OutPhlegm_Gradient = 1,
    OutPhlegm_Circle = 2,
    OutPhlegm_UserDefined = 3
};
/** 排痰 */
@interface SputumExcretionModel : JSONModel
@property (nonatomic, strong) NSString *state;
@property (nonatomic, assign) NSInteger outPhlemState;//排痰状态
@property (nonatomic, assign) NSInteger fuzzyState;//雾化状态
@property (nonatomic, assign) NSInteger attractState;//吸痰状态

@property (nonatomic, strong) NSString *treatTime;//排痰时间 min
@property (nonatomic, strong) NSString *showTime;
@property (nonatomic, strong) NSString *outPhlemShowTime;//排痰显示时间s
@property (nonatomic, strong) NSString *fuzzyShowTime;//雾化显示时间s

@property (nonatomic, assign) BOOL isInFuzzy;   //是否雾化
@property (nonatomic, strong) NSString *fuzzyLevel;//雾化等级

@property (nonatomic, assign) NSInteger mode;//模式
@property (nonatomic, strong) NSString *pressure;//压力
@property (nonatomic, strong) NSString *SetFrequency;//设置频率
@property (nonatomic, strong) NSString *frequency;//当前实时压力
@property (nonatomic, strong) NSString *standOrUserDefinedFrequency; // 标准或自定义当前频率
@property (nonatomic, assign) NSInteger gradientOrCircleFrequencyindex;// 梯度或循环模式频率索引
- (NSArray *)getParameterArray:(SputumExcretionModel *)treatParameter;
- (NSString *)getGifName;
@end
