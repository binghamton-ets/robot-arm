//
//  SecondViewController.h
//  Robot-Arm-App
//
//  Created by Joe Kim on 9/13/17.
//  Copyright © 2017 Joe Kim. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Command.h"

@interface AdvancedViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *commandsTable;
@property (weak, nonatomic) IBOutlet UIButton *LitButton;
@property (weak, nonatomic) IBOutlet UIPickerView *motorNamePicker;
@property (weak, nonatomic) IBOutlet UIPickerView *motorDirectionPicker;
@property (weak, nonatomic) IBOutlet UIPickerView *motorAnglePicker;

@end

