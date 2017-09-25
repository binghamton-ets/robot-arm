//
//  BasicViewControllers
//  ArmController
//
//  Created by Joe Kim on 9/8/17.
//  Copyright © 2017 Joe Kim. All rights reserved.
//

#import "BasicViewControllers.h"

@interface BasicViewControllers ()

@end

@implementation BasicViewControllers

- (void)viewDidLoad
{
    [super viewDidLoad];
    //set actions for when buttons are pressed and released
    [_ArmUpButton addTarget:self action:@selector(armUpButtonAction) forControlEvents:UIControlEventTouchDown];
    [_ArmUpButton addTarget:self action:@selector(armBaseStop) forControlEvents:UIControlEventTouchUpInside];
    [_ArmDownButton addTarget:self action:@selector(armDownButtonAction) forControlEvents:UIControlEventTouchDown];
    [_ArmDownButton addTarget:self action:@selector(armBaseStop) forControlEvents:UIControlEventTouchUpInside];
    [_ArmLeftButton addTarget:self action:@selector(armLeftButtonAction) forControlEvents:UIControlEventTouchDown];
    [_ArmLeftButton addTarget:self action:@selector(armShoulderStop) forControlEvents:UIControlEventTouchUpInside];
    [_ArmRightButton addTarget:self action:@selector(armRightButtonAction) forControlEvents:UIControlEventTouchDown];
    [_ArmRightButton addTarget:self action:@selector(armShoulderStop) forControlEvents:UIControlEventTouchUpInside];
    [_ArmForwardButton addTarget:self action:@selector(armForwardButtonAction) forControlEvents:UIControlEventTouchDown];
    [_ArmForwardButton addTarget:self action:@selector(armElbowStop) forControlEvents:UIControlEventTouchUpInside];
    [_ArmBackButton addTarget:self action:@selector(armBackButtonAction) forControlEvents:UIControlEventTouchDown];
    [_ArmBackButton addTarget:self action:@selector(armElbowStop) forControlEvents:UIControlEventTouchUpInside];
    [_ClawOpenButton addTarget:self action:@selector(clawOpenButtonAction) forControlEvents:UIControlEventTouchDown];
    [_ClawOpenButton addTarget:self action:@selector(clawStop) forControlEvents:UIControlEventTouchUpInside];
    [_ClawCloseButton addTarget:self action:@selector(clawCloseButtonAction) forControlEvents:UIControlEventTouchDown];
    [_ClawCloseButton addTarget:self action:@selector(clawStop) forControlEvents:UIControlEventTouchUpInside];
}

// UP
- (void) armUpButtonAction
{
    [self setStatus:@"ARM MOVING UP"];
    [self sendMessageToMotor:@"SHOULDER" direction:@"UP"];
}
// DOWN
- (void) armDownButtonAction
{
    [self setStatus:@"ARM MOVING DOWN"];
        [self sendMessageToMotor:@"SHOULDER" direction:@"DOWN"];
}
// UP/DOWN stop
-(void) armBaseStop
{
    [self setStatus:@"IDLE"];
    [self sendMessageToMotor:@"SHOULDER" direction:@"STOP"];
}

// LEFT
- (void) armLeftButtonAction
{
    [self setStatus:@"ARM MOVING LEFT"];
        [self sendMessageToMotor:@"ROTATION" direction:@"LEFT"];
}
// RIGHT
- (void) armRightButtonAction
{
    [self setStatus:@"ARM MOVING RIGHT"];
        [self sendMessageToMotor:@"ROTATION" direction:@"RIGHT"];
}
// LEFT/RIGHT STOP
-(void) armShoulderStop
{
    [self setStatus:@"IDLE"];
    [self sendMessageToMotor:@"ROTATION" direction:@"STOP"];
}

// FORWARD
- (void) armForwardButtonAction
{
    [self setStatus:@"ARM MOVING FORWARD"];
        [self sendMessageToMotor:@"ELBOW" direction:@"FORWARD"];
}
// BACK
- (void) armBackButtonAction
{
    [self setStatus:@"ARM MOVING BACK"];
        [self sendMessageToMotor:@"ELBOW" direction:@"BACK"];
}
// FORWARD/BACK STOP
-(void) armElbowStop
{
    [self setStatus:@"IDLE"];
    [self sendMessageToMotor:@"ELBOW" direction:@"STOP"];
}

// OPEN
- (void) clawOpenButtonAction
{
    [self setStatus:@"CLOW OPENING"];
        [self sendMessageToMotor:@"HAND" direction:@"OPEN"];
}
//CLOSE
- (void) clawCloseButtonAction
{
    [self setStatus:@"CLAW CLOSING"];
        [self sendMessageToMotor:@"HAND" direction:@"CLOSE"];
}
// OPEN/CLOSE STOP
-(void) clawStop
{
    [self setStatus:@"IDLE"];
    [self sendMessageToMotor:@"HAND" direction:@"STOP"];
}


- (void) sendMessageToMotor: (NSString*) motorName
                  direction: (NSString*) direction
{
    //send a JSON message with the command
    NSError *error;
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration
                                                          delegate:self
                                                     delegateQueue:nil];
    NSURL *url = [NSURL URLWithString:@"UNKNOWN"];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:60.0];
    
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    [request setHTTPMethod:@"POST"];
    NSArray *objects=[[NSArray alloc]initWithObjects:motorName, direction, nil];
    
    NSArray *keys=[[NSArray alloc]initWithObjects:@"motorName", @"direction",nil];
    NSDictionary *dict=[NSDictionary dictionaryWithObjects:objects forKeys:keys];
    
    NSData *postData = [NSJSONSerialization dataWithJSONObject:dict
                                                       options:0
                                                         error:&error];//[msg dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:postData];
    
    NSURLSessionDataTask *postDataTask =
    [session dataTaskWithRequest:request
               completionHandler:^(
                                   NSData *data, NSURLResponse *response, NSError *error
                                   )
    {}];
}

- (void) setStatus: (NSString*) str
{
    _statusLabel.text = str;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
