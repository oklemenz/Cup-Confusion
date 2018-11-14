//
//  GameData.h
//  CupConfusion
//
//  Created by Oliver on 25.03.12.
//  Copyright (c) 2012 Oliver Klemenz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GameData : NSObject {
    int status;
    int round;
    double difficultyRound;
    int roundTurns;
    int roundCurrentTurn;
    int roundBallPos;
    int selectedPos;
    
    long long bet;
    long long pool;
    long long boughtPool;
    long long maxPool;
    
    double difficulty;
    double timeMoveMin;
    double timeMoveMinVariance;
    double timeMoveMax;
    double timeMoveMaxVariance;
    double timeWaitMin;
    double timeWaitMinVariance;
    double timeWaitMax;
    double timeWaitMaxVariance;
    
    BOOL showAd;    
}

@property int status;
@property int round;
@property double difficultyRound;
@property int roundTurns;
@property int roundCurrentTurn;
@property int roundBallPos;
@property int selectedPos;

@property long long bet;
@property long long result;
@property long long pool;
@property long long boughtPool;
@property long long maxPool;

@property double difficulty;
@property double timeMoveMin;
@property double timeMoveMinVariance;
@property double timeMoveMax;
@property double timeMoveMaxVariance;
@property double timeWaitMin;
@property double timeWaitMinVariance;
@property double timeWaitMax;
@property double timeWaitMaxVariance;

@property BOOL showAd;

- (id)init;

+ (GameData *)instance;
+ (BOOL)isFirstStart;

- (void)store;
- (void)load;

- (BOOL)updatePoolWith:(long long)deltaPool;
- (BOOL)updateBoughtPoolWith:(long long)deltaPool;

@end
