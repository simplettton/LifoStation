//
//  TwoViewsAirWaveCell.h
//  
//
//  Created by Binger Zeng on 2019/1/17.
//

#import <UIKit/UIKit.h>
#import "AirWaveView.h"
@interface TwoViewsAirWaveCell : UICollectionViewCell
@property (nonatomic, assign) AirBagType type;

@property (weak, nonatomic) IBOutlet UIView *bodyView;

@property (weak, nonatomic) IBOutlet UIView *bodyContentView;
@end
