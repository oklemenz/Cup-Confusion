//
//  GameHelper.m
//  CupConfusion
//
//  Created by Oliver on 22.01.12.
//  Copyright (c) 2012 Oliver Klemenz. All rights reserved.
//

#import "GameHelper.h"

#define ARC4RANDOM_MAX 0x100000000

@implementation GameHelper {
}

+ (double)getTimestamp {
	return [[NSDate date] timeIntervalSince1970];
}

+ (int)getRandom:(int)max {
	return (arc4random() % max) + 1;
}

+ (int)getRandomIncl:(int)max {
	return arc4random() % (max+1);
}

+ (double)getDoubleRandom {
	return (double)arc4random() / (double)ARC4RANDOM_MAX;
}

+ (double)getDoubleHalfRandom {
	return [self getDoubleRandom] - 0.5;
}

+ (double)getDoubleRandom:(double)max {
	return [self getDoubleRandom] * max;	
}

+ (double)getDoubleRandomWithMin:(double)min andMax:(double)max {
	return min + [self getDoubleRandom] * (max-min);
}

+ (BOOL)getBoolRandom {
	return [self getDoubleRandomWithMin:0 andMax:1] >= 0.5;
}

+ (int)getZeroOneRandom {
	return [self getDoubleRandomWithMin:0 andMax:1] >= 0.5 ? 1 : 0;
}

+ (int)getRandomWithMin:(int)min andMax:(int)max {
	if (min == max) {
		return min;
	}
	return min + arc4random() % (max-min);
}

+ (int)getRandomWithMin:(int)min inclMax:(int)max {
	if (min == max) {
		return min;
	}
	return min + arc4random() % (max+1-min);
}

+ (NSString *)getTimeString:(double)time {
	int hour = time / 3600;
	int minute = (time - hour * 3600) / 60;
	int second = time - (hour * 3600 + minute * 60);
	int milli  = round((time - (hour * 3600 + minute * 60 + second)) * 100);
	return [NSString stringWithFormat:@"%02i:%02i:%02i.%02i", hour, minute, second, milli];
}

+ (double)getRoundedTime:(double)time {
	int hour = time / 3600;
	int minute = (time - hour * 3600) / 60;
	int second = time - (hour * 3600 + minute * 60);
	int milli  = round((time - (hour * 3600 + minute * 60 + second)) * 100);
	return hour * 3600 + minute * 60 + second + milli / 100.0;
}

+ (NSString *)formatScore:(long long)score {
    return [NSString stringWithFormat:@"%013lld", score];
}

@end
