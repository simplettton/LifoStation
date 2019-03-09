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

@property (weak, nonatomic) IBOutlet UIView *bodyContentView;
@property (weak, nonatomic) IBOutlet UIButton *patientButton;
@property (weak, nonatomic) IBOutlet UIView *parameterView;
@property (weak, nonatomic) IBOutlet UIView *focusView;

@property (nonatomic, strong) AirWaveView * bodyView;
- (void)configureWithAirBagType:(AirBagType)type;
@end
