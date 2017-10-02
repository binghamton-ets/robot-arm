//
//  SecondViewController.h
//  Robot-Arm-App
//
//  Created by Joe Kim on 9/13/17.
//  Copyright © 2017 Joe Kim. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Command.h"

@interface AdvancedViewController : UIViewController <UITableViewDelegate,
    UITableViewDataSource,
    UIPickerViewDelegate,
    UIPickerViewDataSource,
    NSNetServiceBrowserDelegate>

@property (weak, nonatomic) IBOutlet UITableView *commandsTable;
@property (weak, nonatomic) IBOutlet UIButton *LitButton;
@property (weak, nonatomic) IBOutlet UIPickerView *commandPicker;
@property (weak, nonatomic) IBOutlet UIButton *addCommandButton;

@end

