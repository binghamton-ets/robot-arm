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
    
    self.commandPicker.dataSource = self;
    self.commandPicker.delegate = self;
    
    _commandsTable.layer.borderColor = [UIColor brownColor].CGColor;
    _commandsTable.layer.borderWidth = 2.5f;
    
    commandsArray = [[NSMutableArray alloc] init];
    motorNamePickerArray = [[NSMutableArray alloc] initWithArray:[NSArray arrayWithObjects:@"Elbow", @"Hand", @"Rotation", @"Shoulder", nil]];
    directionPickerArray = [[NSMutableArray alloc] initWithArray:[NSArray   arrayWithObjects:@"FORWARD", @"BACK", @"STOP", nil]];
    anglePickerArray = [[NSMutableArray alloc] init];
    
    [_LitButton addTarget:self action:@selector(litButtonAction) forControlEvents:UIControlEventTouchDown];
    
    [_addCommandButton addTarget:self action:@selector(addCommandButtonAction) forControlEvents:UIControlEventTouchDown];
    
    for (NSInteger i = 1; i <= 180; i++)
    {
        [anglePickerArray addObject:[NSNumber numberWithInteger:i]];
    }
}

- (void) viewWillAppear: (BOOL)animated
{
    [_commandsTable reloadData];
}

- (void) litButtonAction
{
//    [_commandsTable reloadData];
}

- (void) addCommandButtonAction
{
    NSInteger row = [_commandPicker selectedRowInComponent:0];
    NSString * motorName = [motorNamePickerArray objectAtIndex:row];
    
    row = [_commandPicker selectedRowInComponent:1];
    NSString * motorDirection = [directionPickerArray objectAtIndex:row];
    
    row = [_commandPicker selectedRowInComponent:2];
    NSNumber * motorAngle = [anglePickerArray objectAtIndex:row];
    
    Command * c = [[Command alloc] init];
    [c initWithMotorName:motorName
                   angle:motorAngle
               direction:motorDirection];
    
    [commandsArray addObject:c];
    
    [_commandsTable reloadData];
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
    [rightText appendString:[NSString stringWithFormat:@"%@ ", [c getAngle]]];
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
    if (component == 0)
    {
        return [motorNamePickerArray count];
    }
    
    if (component == 1)
    {
        return [directionPickerArray count];
    }
    
    if (component == 2)
    {
        return [anglePickerArray count];
    }
    
    
    return 0;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 3; //3 components - name, angle, and direction
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
        return [NSString stringWithFormat:@"%@",
                [directionPickerArray objectAtIndex:row]];
    }
    
    if (component == 2)
    {
        return [NSString stringWithFormat:@"%@",
                [anglePickerArray objectAtIndex:row]];
    }
    
    return @"ERROR";
}

- (void) pickerView: (UIPickerView *)pickerView
       didSelectRow: (NSInteger)row
        inComponent: (NSInteger)component
{
    if (component == 0)
    {
        [directionPickerArray removeAllObjects];
        switch (row)
        {
            case 0:
                //elbow values
                [directionPickerArray addObjectsFromArray:[NSArray   arrayWithObjects:@"FORWARD", @"BACK", @"STOP", nil]];
                break;
                
            case 1:
                //hand values
                [directionPickerArray addObjectsFromArray:[NSArray arrayWithObjects:@"OPEN", @"CLOSE", @"STOP", nil]];
                break;
                
            case 2:
                //rotation values
                [directionPickerArray addObjectsFromArray:[NSArray arrayWithObjects:@"LEFT", @"RIGHT", @"STOP", nil]];
                break;
                
            case 3:
                //shoulder values
                [directionPickerArray addObjectsFromArray:[NSArray arrayWithObjects:@"UP", @"DOWN", @"STOP", nil]];
                break;
        }
    }
    
    [pickerView reloadComponent:1];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
