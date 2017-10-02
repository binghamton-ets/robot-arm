//
//  BasicViewControllers
//  ArmController
//
//  Created by Joe Kim on 9/8/17.
//  Copyright © 2017 Joe Kim. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BasicViewControllers : UIViewController <NSURLSessionDelegate>

@property (strong, nonatomic) IBOutlet UIButton * ArmUpButton;
@property (strong, nonatomic) IBOutlet UIButton * ArmDownButton;
@property (strong, nonatomic) IBOutlet UIButton * ArmLeftButton;
@property (strong, nonatomic) IBOutlet UIButton * ArmRightButton;
@property (strong, nonatomic) IBOutlet UIButton * ArmForwardButton;
@property (strong, nonatomic) IBOutlet UIButton * ArmBackButton;
@property (strong, nonatomic) IBOutlet UIButton * ClawOpenButton;
@property (strong, nonatomic) IBOutlet UIButton * ClawCloseButton;
@property (strong, nonatomic) IBOutlet UILabel * statusLabel;

@end
