//
//  SecondViewController.m
//  Robot-Arm-App
//
//  Created by Joe Kim on 9/13/17.
//  Copyright © 2017 Joe Kim. All rights reserved.
//

#import "AdvancedViewController.h"

@interface AdvancedViewController ()
{
    NSMutableArray * commandsArray;
    
    NSMutableArray * motorNamePickerArray;
    NSMutableArray * anglePickerArray;
    NSMutableArray * directionPickerArray;
}

@end

@implementation AdvancedViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.commandsTable.dataSource = self;
    self.commandsTable.delegate = self;
    
    self.motorNamePicker.dataSource = self;
    self.motorAnglePicker.dataSource = self;
    self.motorDirectionPicker.dataSource = self;
    
    self.motorNamePicker.delegate = self;
    self.motorAnglePicker.delegate = self;
    self.motorDirectionPicker.delegate = self;
    
    _commandsTable.layer.borderColor = [UIColor brownColor].CGColor;
    _commandsTable.layer.borderWidth = 2.5f;
    
    commandsArray = [[NSMutableArray alloc] init];
    motorNamePickerArray = [[NSMutableArray alloc] initWithArray:[NSArray arrayWithObjects:@"Elbow", @"Hand", @"Base", @"Rotation", @"Shoulder", nil]];
    directionPickerArray = [[NSMutableArray alloc] initWithArray:[NSArray arrayWithObjects:@"Up", @"Down", nil]];
    anglePickerArray = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < 3; i++)
    {
        Command * c = [Command alloc];
        [c setAngle:i];
        [commandsArray addObject:c];
    }
    
    [_LitButton addTarget:self action:@selector(litButtonAction) forControlEvents:UIControlEventTouchDown];
    
    for (NSInteger i = 1; i <= 180; i++)
    {
        [anglePickerArray addObject:[NSNumber numberWithInteger:i]];
    }
    
    [[commandsArray objectAtIndex:0] setMotorName:@"motor1"];
    [[commandsArray objectAtIndex:1] setMotorName:@"motor2"];
    [[commandsArray objectAtIndex:2] setMotorName:@"motor3"];
    
    [[commandsArray objectAtIndex:0] setMoveDirection:@"up"];
    [[commandsArray objectAtIndex:1] setMoveDirection:@"right"];
    [[commandsArray objectAtIndex:2] setMoveDirection:@"close"];
}

- (void) viewWillAppear: (BOOL)animated
{
    [_commandsTable reloadData];
}

- (void) litButtonAction
{
//    [_commandsTable reloadData];
}

-(NSInteger)    tableView:(UITableView *)tableView
    numberOfRowsInSection:(NSInteger)section
{
    return [commandsArray count];
}

- (UITableViewCell *) tableView:(UITableView *)tableView
          cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //create cells for store items
    static NSString *simpleTableIdentifier = @"SimpleTableItem";
    UITableViewCell *cell;
    Command * c = [commandsArray objectAtIndex:indexPath.row];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:simpleTableIdentifier];
    }
    
    cell.textLabel.text = [c getMotorName];
    NSMutableString * rightText = [NSMutableString stringWithString:[c getDirection]];
    
    [rightText appendString:@" "];
    [rightText appendString:[NSString stringWithFormat:@"%ld ", (long)[c getAngle]]];
    [rightText appendString:@" degrees"];
    
    cell.detailTextLabel.text = rightText;
    
    return cell;
}

- (void)            tableView:(UITableView *)tableView
      didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //display alert controller to confirm or cancel deletion
    NSString * prompt =
    [NSString stringWithFormat:@"Delete this command?"];
    
    UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:@"Delete"
                                 message:prompt
                                 preferredStyle:UIAlertControllerStyleAlert];
    
    //Confirm delete, send message to main screen
    UIAlertAction* deleteButton = [UIAlertAction
                                actionWithTitle:@"Delete"
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action) {
                                    [commandsArray removeObjectAtIndex:indexPath.row];
                                    [_commandsTable deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
                                }];
    
    UIAlertAction * cancelButton = [UIAlertAction actionWithTitle:@"Cancel"
                                                            style:UIAlertActionStyleCancel
                                                          handler:nil];
    
    [alert addAction:deleteButton];
    [alert addAction:cancelButton];
    
    [self presentViewController:alert animated:YES completion:nil];
}


- (NSInteger)pickerView:(UIPickerView *)pickerView
numberOfRowsInComponent:(NSInteger)component
{
    if (pickerView == _motorNamePicker)
    {
        return [motorNamePickerArray count];
    }
    
    if (pickerView == _motorAnglePicker)
    {
        return [anglePickerArray count];
    }
    
    if (pickerView == _motorDirectionPicker)
    {
        return [directionPickerArray count];
    }
    return 0;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 3;//3 components - name, angle, and direction
}

- (NSString *) pickerView:(UIPickerView *)pickerView
              titleForRow:(NSInteger)row
             forComponent:(NSInteger)component
{
    if (component == 0)
    {
        return [motorNamePickerArray objectAtIndex:row];
    }
    if (component == 1)
    {
        return [directionPickerArray objectAtIndex:row];
    }
        
    return [NSString stringWithFormat:@"%@",[anglePickerArray objectAtIndex:row]];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
