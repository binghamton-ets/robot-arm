//
//  Command.m
//  Robot-Arm-App
//
//  Created by Joe Kim on 9/14/17.
//  Copyright © 2017 Joe Kim. All rights reserved.
//

#import "Command.h"
@implementation Command

- (void) setMotorName:(NSString *)name
{
    _motorName = name;
}

- (void) setAngle:(NSNumber*)ang
{
    _angle = ang;
}

- (void) setMoveDirection:(NSString *)dir
{
    _direction = dir;
}

- (NSString*) getMotorName
{
    return _motorName;
}

- (NSNumber*) getAngle
{
    return _angle;
}

- (NSString*) getDirection
{
    return _direction;
}

- (void) initWithMotorName: (NSString*) name
                     angle: (NSNumber*) ang
                 direction: (NSString*) dir
{
    [self setMotorName:name];
    [self setAngle:ang];
    [self setDirection:dir];
}

- (void) printOut
{
    NSLog(@"name = %@, angle = %ld, direction = %@",
          _motorName, (long)_angle, _direction);
}
@end
