//
//  Command.h
//  Robot-Arm-App
//
//  Created by Joe Kim on 9/14/17.
//  Copyright © 2017 Joe Kim. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface Command : NSObject

@property (nonatomic) NSString* motorName;
@property (nonatomic) NSInteger angle;
@property (nonatomic) NSString* direction;

- (void) setMotorName:(NSString *)motorName;
- (void) setAngle:(NSInteger)angle;
- (void) setMoveDirection:(NSString *)direction;

- (NSString*) getMotorName;
- (NSInteger) getAngle;
- (NSString*) getDirection;
@end
