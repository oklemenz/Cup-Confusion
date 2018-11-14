//
//  GameView.h
//  CupConfusion
//
//  Created by Oliver on 22.01.12.
//  Copyright (c) 2012 Oliver Klemenz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import <iAd/iAd.h>
#import "AppDelegate.h"

#define kStatusInit       0
#define kStatusPlaceBet   1
#define kStatusShuffleCup 2
#define kStatusChooseCup  3
#define kStatusWonTap     4
#define kStatusLostTap    5
#define kStatusResumeGame 6
#define kStatusGameOver   7
#define kStatusResult     8

#define kStartPool 1000
#define kDifficultyRatio 0.04

#define kMinTurns 5
#define kMinTurnVariance 4
#define kMaxTurns 8
#define kMaxTurnVariance 14
#define kMinAbsTurns 2

#define kTimeMoveMin 0.16
#define kTimeMoveMinVariance 0.15
#define kTimeMoveMax 0.8
#define kTimeMoveMaxVariance 0.15
#define kTimeMoveAbsMin 0.13

#define kTimeWaitMin 0.2
#define kTimeWaitMinVariance 0.2
#define kTimeWaitMax 0.4
#define kTimeWaitMaxVariance 0.1
#define kTimeWaitAbsMin 0.0

#define kTimeFactor 1.0

#define kMoveHeight_iPhone   48
#define kMoveHeight_iPad     115
#define kMoveOffset_iPhone   60
#define kMoveOffset_iPad     140
#define kDeltaOffsetX_iPhone 283
#define kDeltaOffsetX_iPad   617

#define kBallPositionLeft   0
#define kBallPositionMiddle 1
#define kBallPositionRight  2

@interface GameView : UIView <UIAlertViewDelegate, ApplicationEvents, CAAnimationDelegate> {
    BOOL stopped;
    AVAudioPlayer *button1Sound;
    AVAudioPlayer *button2Sound;
    AVAudioPlayer *woosh1Sound1;
    AVAudioPlayer *woosh1Sound2;    
    AVAudioPlayer *woosh1Sound3;
    AVAudioPlayer *woosh2Sound;
    NSArray *woosh1Sounds;
    NSTimer *buyCoinTimer;
    CGFloat buyCoinAngle;
}

@property BOOL stopped;

@property (strong, nonatomic) IBOutlet UIImageView *cup1;
@property (strong, nonatomic) IBOutlet UIImageView *cup2;
@property (strong, nonatomic) IBOutlet UIImageView *cup3;
@property (strong, nonatomic) IBOutlet UIImageView *cup1s;
@property (strong, nonatomic) IBOutlet UIImageView *cup2s;
@property (strong, nonatomic) IBOutlet UIImageView *cup3s;

@property (strong, nonatomic) IBOutlet UIImageView *ball;
@property (strong, nonatomic) IBOutlet UIImageView *ballShadow;

@property (strong, nonatomic) IBOutlet UILabel *poolLabel;
@property (strong, nonatomic) IBOutlet UILabel *betLabel;
@property (strong, nonatomic) IBOutlet UILabel *deltaLabel;

@property (strong, nonatomic) IBOutlet UIButton *buyPoolButton; // Not used anymore
@property (strong, nonatomic) IBOutlet UIButton *showGameCenterButton;

@property (strong, nonatomic) IBOutlet UIImageView *arrow;
@property (strong, nonatomic) IBOutlet UISlider *betSlider;
@property (strong, nonatomic) IBOutlet UILabel *statusText;
@property (strong, nonatomic) IBOutlet UIImageView *buyCoin;  // Not used anymore

- (IBAction)buyPool:(id)sender;  // Not used anymore
- (void)showGameCenter:(UIViewController *)controller;
- (IBAction)betSliderChanged:(id)sender;

- (void)gameSetup;
- (void)gameStart;
- (void)roundSetup:(BOOL)start;
- (void)checkStatus;

- (void)play;
- (void)start;
- (void)placeBall;
- (void)calcTimes;
- (void)shuffle;
- (void)wait:(float)time atEndCall:(SEL)selector;
- (void)move:(int)first andCup:(int)second inTime:(float)time atEndCall:(SEL)selector;
- (void)select:(int)selectedPos;

- (void)addPointsToPool:(long long)points;
- (void)notifyPoolBought:(long long)points;

- (void)startRotatingCoin;
- (void)stopRotatingCoin;

@end
