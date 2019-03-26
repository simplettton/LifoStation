//
//  ElectrotherapyView.m
//  LifoStation
//
//  Created by Binger Zeng on 2019/3/19.
//  Copyright © 2019年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "ElectrotherapyView.h"
#import "FLAnimatedImage.h"
@implementation ElectrotherapyView

- (instancetype)initWithWaveType:(NSString *)typeName {
    if (self = [super init]){
            [self showGifImageWithName:typeName];
    }
    return self;

}

-(void)showGifImageWithName:(NSString*)name {
    //GIF 转 NSData
    //Gif 路径
    NSString *pathForFile = [[NSBundle mainBundle] pathForResource: name ofType:@"gif"];
    //转成NSData
    NSData *dataOfGif = [NSData dataWithContentsOfFile: pathForFile];
    //初始化FLAnimatedImage对象
    FLAnimatedImage *image = [FLAnimatedImage animatedImageWithGIFData:dataOfGif];
    //初始化FLAnimatedImageView对象
    FLAnimatedImageView *imageView = [[FLAnimatedImageView alloc] init];
    //设置GIF图片
    imageView.animatedImage = image;
    imageView.frame = CGRectMake(523, 276, 170, 112);
    [self addSubview:imageView];

}
@end
