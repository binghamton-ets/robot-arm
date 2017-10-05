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
    
    //populate arrays for the pickerview
    commandsArray = [[NSMutableArray alloc] init];
    motorNamePickerArray = [[NSMutableArray alloc] initWithArray:[NSArray arrayWithObjects:@"Elbow", @"Hand", @"Rotation", @"Shoulder", nil]];
    directionPickerArray = [[NSMutableArray alloc] initWithArray:[NSArray   arrayWithObjects:@"FORWARD", @"BACK", @"STOP", nil]];
    anglePickerArray = [[NSMutableArray alloc] init];
    
    //add commands to button
    [_LitButton addTarget:self action:@selector(litButtonAction) forControlEvents:UIControlEventTouchDown];
    
    [_addCommandButton addTarget:self action:@selector(addCommandButtonAction) forControlEvents:UIControlEventTouchDown];
    
    //populate angle array with degees from 1 - 180
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
    //when user adds a command, which consists of motorname, angle,and direction, add to the uitableview
    
    //get motor name from motorname array
    NSInteger row = [_commandPicker selectedRowInComponent:0];
    NSString * motorName = [motorNamePickerArray objectAtIndex:row];
    
    //get direction from direcion array
    row = [_commandPicker selectedRowInComponent:1];
    NSString * motorDirection = [directionPickerArray objectAtIndex:row];
    
    //get angle from angle array
    row = [_commandPicker selectedRowInComponent:2];
    NSNumber * motorAngle = [anglePickerArray objectAtIndex:row];
    
    //create command with this information
    Command * c = [[Command alloc] init];
    [c initWithMotorName:motorName
                   angle:motorAngle
               direction:motorDirection];
    
    //add command to array
    [commandsArray addObject:c];
    
    //update table
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
    //create cells for table
    static NSString *simpleTableIdentifier = @"SimpleTableItem";
    UITableViewCell *cell;
    Command * c = [commandsArray objectAtIndex:indexPath.row];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:simpleTableIdentifier];
    }
    
    //populate cells with "<motorname> <direction> <angle> degrees"
    cell.textLabel.text = [c getMotorName];
    NSMutableString * rightText =
        [NSMutableString stringWithString:[c getDirection]];
    
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
                                    //remove ovject in the array and table
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
        //change the value of the direction component based on what motor is selected
        //ex - if elbow is selected, then the arm can go forward and back, but not upand down
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
