//
//  BasicViewControllers
//  ArmController
//
//  Created by Joe Kim on 9/8/17.
//  Copyright © 2017 Joe Kim. All rights reserved.
//

#import "BasicViewControllers.h"

@interface BasicViewControllers ()
{
    NSNetService * robotService;
    NSNetServiceBrowser *browser;
    BOOL foundPiServer;
}

@end

@implementation BasicViewControllers

- (void)viewDidLoad
{
    [super viewDidLoad];
    foundPiServer = false;
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
    
    browser = [[NSNetServiceBrowser alloc] init];
    browser.delegate = self;
    [browser searchForServicesOfType:@"_ssh._tcp."
                            inDomain:@"local."];
    [robotService resolveWithTimeout:5];
    NSLog(@"%@", [robotService addresses]);
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
    [self setStatus:@"CLAW OPENING"];
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
    //TODO send msg to server
}

-(void) setStatus: (NSString*) statusStr
{
    [_statusLabel setText: statusStr];
}

- (void) netServiceBrowserWillSearch: (NSNetServiceBrowser *)browser
{
    NSLog(@"WillSearch");
    //method notifies the delegate that a search is commencing
    //TODO make buttons unusable while search begins
}

- (void) netServiceBrowserDidStopSearch:(NSNetServiceBrowser *)browser
{
    NSLog(@"didStopSearch - done searching");
    //you can perform any necessary cleanup.
    //TODO (maybe) do some after-search cleanup, and make iphone usable
}
- (void) netServiceBrowser:(NSNetServiceBrowser *)browser
              didNotSearch:(NSDictionary<NSString *,NSNumber *> *)errorDict
{
    //the search failed for some reason
    NSLog(@"didNotSearch");
    NSLog(@"%@", [errorDict allKeys]);
    NSLog(@"%@", [errorDict allValues]);
}

- (void) netServiceBrowser:(NSNetServiceBrowser *)browser
            didFindService:(NSNetService *)service
                moreComing:(BOOL)moreComing
{
    //service has become available
    if (moreComing)
    {
        //if this parameter is YES , delay updatig any user interface elements until the method is called with a morecoming parameter of NO
        
    }
    
    if ([[service name] compare:@"RobotArm Access Point"])
    {
        NSLog(@"found [RobotArm Access Point] with hostname %@", [service hostName]);
        robotService = service;
        foundPiServer = true;
    }
}

- (void) netServiceBrowser:(NSNetServiceBrowser *)browser
          didRemoveService:(NSNetService *)service
                moreComing:(BOOL)moreComing
{
    //service has shutdown
    if (moreComing)
    {
        NSLog(@"\t done searching");
    }
    NSLog(@"didRemoveService: %@t%@", [service name], [service hostName]);
}

-(NSString* )IPAddressesFromData:(NSNetService *)service
{
    for (NSData *address in [service addresses])
    {
        struct sockaddr_in *socketAddress = (struct sockaddr_in *) [address bytes];
        //NSLog(@"Service name: %@ , ip: %s , port %i", [service name], inet_ntoa(socketAddress->sin_addr), [service port]);
        NSString *retString = [NSString stringWithFormat:@"%s",
                               inet_ntoa(socketAddress->sin_addr)];
        return retString;
    }
    return @"Unknown";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
