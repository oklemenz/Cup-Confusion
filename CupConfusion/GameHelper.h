//
//  GameHelper.h
//  CupConfusion
//
//  Created by Oliver on 22.01.12.
//  Copyright (c) 2012 Oliver Klemenz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GameHelper : NSObject {   
}

+ (double)getTimestamp;

+ (int)getRandom:(int)max;
+ (int)getRandomIncl:(int)max;

+ (double)getDoubleRandom;
+ (double)getDoubleHalfRandom;
+ (double)getDoubleRandom:(double)max;
+ (double)getDoubleRandomWithMin:(double)min andMax:(double)max;

+ (BOOL)getBoolRandom;
+ (int)getZeroOneRandom;

+ (int)getRandomWithMin:(int)min andMax:(int)max;
+ (int)getRandomWithMin:(int)min inclMax:(int)max;

+ (NSString *)getTimeString:(double)time;
+ (double)getRoundedTime:(double)time;

+ (NSString *)formatScore:(long long)score;

@end