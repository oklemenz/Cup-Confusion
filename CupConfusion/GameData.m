//
//  GameData.m
//  CupConfusion
//
//  Created by Oliver on 25.03.12.
//  Copyright (c) 2012 Oliver Klemenz. All rights reserved.
//

#import "GameData.h"
#import "GameView.h"

@implementation GameData 

@synthesize status;
@synthesize round;
@synthesize difficultyRound;
@synthesize roundTurns;
@synthesize roundCurrentTurn;
@synthesize roundBallPos;
@synthesize selectedPos;

@synthesize bet;
@synthesize result;
@synthesize pool;
@synthesize boughtPool;
@synthesize maxPool;

@synthesize difficulty;
@synthesize timeMoveMin;
@synthesize timeMoveMinVariance;
@synthesize timeMoveMax;
@synthesize timeMoveMaxVariance;
@synthesize timeWaitMin;
@synthesize timeWaitMinVariance;
@synthesize timeWaitMax;
@synthesize timeWaitMaxVariance;

@synthesize showAd;

- (id)init {
    if (self = [super init]) {
		[self load];
    }
    return self;
}

+ (GameData *)instance {
   	static GameData *_instance;
	@synchronized(self) {
		if (!_instance) {
			_instance = [[GameData alloc] init];
		}
	}
	return _instance; 
}

+ (BOOL)isFirstStart {
    return [[NSUserDefaults standardUserDefaults] integerForKey:@"init"] != 1;
}

- (void)store {
    NSUserDefaults *preferences = [NSUserDefaults standardUserDefaults];
	[preferences setInteger:1 forKey:@"init"];
	[preferences setValue:[NSNumber numberWithInt:status] forKey:@"status"];
	[preferences setValue:[NSNumber numberWithInt:round] forKey:@"round"];
	[preferences setValue:[NSNumber numberWithDouble:difficultyRound] forKey:@"difficultyRound"];
	[preferences setValue:[NSNumber numberWithInt:roundTurns] forKey:@"roundTurns"];
	[preferences setValue:[NSNumber numberWithInt:roundCurrentTurn] forKey:@"roundCurrentTurn"];    
	[preferences setValue:[NSNumber numberWithInt:roundBallPos] forKey:@"roundBallPos"];    
	[preferences setValue:[NSNumber numberWithInt:selectedPos] forKey:@"selectedPos"];

	[preferences setValue:[NSNumber numberWithLongLong:bet] forKey:@"bet"];
	[preferences setValue:[NSNumber numberWithLongLong:result] forKey:@"result"];
    [preferences setValue:[NSNumber numberWithLongLong:pool] forKey:@"pool"];
    [preferences setValue:[NSNumber numberWithLongLong:boughtPool] forKey:@"boughtPool"];
    [preferences setValue:[NSNumber numberWithLongLong:maxPool] forKey:@"maxPool"];

    [preferences setValue:[NSNumber numberWithDouble:difficulty] forKey:@"difficulty"];
    [preferences setValue:[NSNumber numberWithDouble:timeMoveMin] forKey:@"timeMoveMin"];
    [preferences setValue:[NSNumber numberWithDouble:timeMoveMinVariance] forKey:@"timeMoveMinVariance"];
    [preferences setValue:[NSNumber numberWithDouble:timeMoveMax] forKey:@"timeMoveMax"];
    [preferences setValue:[NSNumber numberWithDouble:timeMoveMaxVariance] forKey:@"timeMoveMaxVariance"];
    [preferences setValue:[NSNumber numberWithDouble:timeWaitMin] forKey:@"timeWaitMin"];
    [preferences setValue:[NSNumber numberWithDouble:timeWaitMinVariance] forKey:@"timeWaitMinVariance"];
    [preferences setValue:[NSNumber numberWithDouble:timeWaitMax] forKey:@"timeWaitMax"];
    [preferences setValue:[NSNumber numberWithDouble:timeWaitMaxVariance] forKey:@"timeWaitMaxVariance"];

    [preferences setValue:[NSNumber numberWithBool:showAd] forKey:@"showAd"];
	[preferences synchronize];
}

- (void)load {
    NSUserDefaults *preferences = [NSUserDefaults standardUserDefaults];
	if ([preferences integerForKey:@"init"] == 1) {
		status = [[preferences valueForKey:@"status"] intValue];
		round = [[preferences valueForKey:@"round"] intValue];
        if (![preferences valueForKey:@"difficultyRound"]) {
            difficultyRound = round;
        } else {
            difficultyRound = [[preferences valueForKey:@"difficultyRound"] doubleValue];
        }
		roundTurns = [[preferences valueForKey:@"roundTurns"] intValue];
		roundCurrentTurn = [[preferences valueForKey:@"roundCurrentTurn"] intValue];
		roundBallPos = [[preferences valueForKey:@"roundBallPos"] intValue];
		selectedPos = [[preferences valueForKey:@"selectedPos"] intValue];
        
        bet = [[preferences valueForKey:@"bet"] longLongValue];
        result = [[preferences valueForKey:@"result"] longLongValue];
        pool = [[preferences valueForKey:@"pool"] longLongValue];
        boughtPool = [[preferences valueForKey:@"boughtPool"] longLongValue];
        maxPool = [[preferences valueForKey:@"maxPool"] longLongValue];
        
        difficulty = [[preferences valueForKey:@"difficulty"] doubleValue];
        timeMoveMin = [[preferences valueForKey:@"timeMoveMin"] doubleValue];
        timeMoveMinVariance = [[preferences valueForKey:@"timeMoveMinVariance"] doubleValue];
        timeMoveMax = [[preferences valueForKey:@"timeMoveMax"] doubleValue];
        timeMoveMaxVariance = [[preferences valueForKey:@"timeMoveMaxVariance"] doubleValue];
        timeWaitMin = [[preferences valueForKey:@"timeWaitMin"] doubleValue];
        timeWaitMinVariance = [[preferences valueForKey:@"timeWaitMinVariance"] doubleValue];
        timeWaitMax = [[preferences valueForKey:@"timeWaitMax"] doubleValue];
        timeWaitMaxVariance = [[preferences valueForKey:@"timeWaitMaxVariance"] doubleValue];

        showAd = [[preferences valueForKey:@"showAd"] boolValue];
	} else {        
        status = kStatusInit;
        round = 0;
        difficultyRound = round;
        roundTurns = 0;
        roundCurrentTurn = 0;
        roundBallPos = kBallPositionMiddle;
        
        bet = 0;
        result = 0;
        pool = 0;
        boughtPool = 0;
        maxPool = pool;
        
        difficulty = 0.0;
        timeMoveMin = 0.0;
        timeMoveMinVariance = 0.0;
        timeMoveMax = 0.0;
        timeMoveMaxVariance = 0.0;
        timeWaitMin = 0.0;
        timeWaitMinVariance = 0.0;
        timeWaitMax = 0.0;
        timeWaitMaxVariance = 0.0;
        
        showAd = NO;
	}
}

- (BOOL)updatePoolWith:(long long)deltaPool {
    pool += deltaPool;
    if (pool < 0) {
        pool = 0;
    }
    BOOL newMax = NO;
    if (pool > maxPool) {
        maxPool = pool;
        newMax = YES;
    } else {
        newMax = NO;        
    }
    [self store];
    return newMax;
}

- (BOOL)updateBoughtPoolWith:(long long)deltaPool {
    boughtPool += deltaPool;
    return YES;
}

@end