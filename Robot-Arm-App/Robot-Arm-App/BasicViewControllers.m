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
    NSString *post = [NSString stringWithFormat:@"motorName=%@&direction=%@",motorName,direction];
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:@"http://149.125.62.244"]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    if(conn)
    {
        NSLog(@"Connection Successful");
    } else
    {
        NSLog(@"Connection could not be made");
    }
}

// This method is used to receive the data which we get using post method.
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData*)data
{
    NSLog(@"RECEIVEDDATA");
}
// This method receives the error report in case of connection is not made to server.
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@" error => %@ ", [error localizedDescription] );
    NSLog(@"RECEIVEDDATA FAILED");
}
// This method is used to process the data after connection has made successfully.
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSLog(@"PROCESSDATA");
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
