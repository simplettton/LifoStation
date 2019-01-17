//
//  BaseSearchBar.m
//  LifoStation
//
//  Created by Binger Zeng on 2019/1/9.
//  Copyright © 2019年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "BaseSearchBar.h"

@implementation BaseSearchBar

- (void)awakeFromNib {
    [super awakeFromNib];
    self.backgroundImage = [[UIImage alloc]init];
    self.tintColor = UIColorFromHex(0x5E97FE);
    UITextField * searchField = [self valueForKey:@"_searchField"];
    [searchField setValue:[UIFont systemFontOfSize:15 weight:UIFontWeightLight] forKeyPath:@"_placeholderLabel.font"];
}

@end
