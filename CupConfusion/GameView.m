//
//  GameView.m
//  CupConfusion
//
//  Created by Oliver on 22.01.12.
//  Copyright (c) 2012 Oliver Klemenz. All rights reserved.
//

#import "GameView.h"
#import "GameHelper.h"
#import "GameData.h"
#import "GameCenterClient.h"
#import "StoreClient.h"

@implementation GameView {
    BOOL move;
    NSArray *cups;
    NSArray *cupsShadow;
    CGFloat cupTopPosition;
    CGFloat cupBottomPosition;
    CGFloat deltaLabelPosition;
}

@synthesize stopped;

@synthesize cup1;
@synthesize cup2;
@synthesize cup3;
@synthesize cup1s;
@synthesize cup2s;
@synthesize cup3s;
@synthesize ball;
@synthesize ballShadow;
@synthesize poolLabel;
@synthesize betLabel;
@synthesize deltaLabel;
@synthesize buyPoolButton;
@synthesize showGameCenterButton;
@synthesize arrow;
@synthesize betSlider;
@synthesize statusText;
@synthesize buyCoin;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    button1Sound = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"button1" ofType:@"caf"]] error:nil];
    button2Sound = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"button2" ofType:@"caf"]] error:nil];
    woosh1Sound1 = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"woosh1" ofType:@"caf"]] error:nil];
    woosh1Sound2 = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"woosh1" ofType:@"caf"]] error:nil];
    woosh1Sound3 = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"woosh1" ofType:@"caf"]] error:nil];
    woosh2Sound = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"woosh2" ofType:@"caf"]] error:nil];
    woosh1Sounds = [NSArray arrayWithObjects:woosh1Sound1, woosh1Sound2, woosh1Sound3, nil];
    cups = [NSArray arrayWithObjects:cup1, cup2, cup3, nil];
    cupsShadow = [NSArray arrayWithObjects:cup1s, cup2s, cup3s, nil];
    buyPoolButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    buyPoolButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    cupTopPosition = cup1.center.y;
    cupBottomPosition = cup1.center.y + ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone ? kMoveHeight_iPhone : kMoveHeight_iPad);
    deltaLabelPosition = self.deltaLabel.frame.origin.x;
    [self gameSetup];
}

- (void)gameSetup {
    betSlider.enabled = NO;
    if (![StoreClient instance].isStoreAvailable) {
        buyPoolButton.hidden = YES;
    }
    if (buyPoolButton.hidden) {
        showGameCenterButton.frame = CGRectMake(buyPoolButton.frame.origin.x, buyPoolButton.frame.origin.y, 
                                                showGameCenterButton.frame.size.width, showGameCenterButton.frame.size.height);
    }
    if ([GameData instance].status == kStatusInit) {
        [statusText setText:@""];
        arrow.alpha = 0.0;
        betSlider.alpha = 0.0;
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"WELCOME", nil) message:[NSString stringWithFormat:NSLocalizedString(@"START", nil), kStartPool] delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
        alert.tag = 99;
        [alert show];
    } else {
        arrow.alpha = [GameData instance].status == kStatusPlaceBet && [GameData instance].pool > 0 ? 1.0 : 0.0;
        betSlider.alpha = [GameData instance].status == kStatusPlaceBet && [GameData instance].pool > 0 ? 1.0 : 0.0;
        [self gameStart];
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 99) {
        deltaLabel.alpha = 0.0;
        deltaLabel.textColor = [UIColor greenColor];
        deltaLabel.center = alertView.center;
        [deltaLabel setText:[NSString stringWithFormat:@"+%i", kStartPool]];
        [woosh2Sound play];
        [UIView animateWithDuration:1.0 animations:^{
            self->deltaLabel.alpha = 1.0;
            self->deltaLabel.frame = CGRectMake(self->deltaLabelPosition, self->poolLabel.frame.origin.y, self->deltaLabel.frame.size.width, self->deltaLabel.frame.size.height);
        } completion:^(BOOL finished) {
            [self addPointsToPool:kStartPool];
            [UIView animateWithDuration:0.5 animations:^{
                self->deltaLabel.alpha = 0.0;
            }];
            [self gameStart]; 
        }];
    } else {
        if ([[alertView title] isEqualToString:NSLocalizedString(@"SELECT_POOL", nil)]) {
            NSArray *products = [[StoreClient instance] getStoreProducts];
            if (buttonIndex == 0) {
                return;
            }
            buttonIndex--;
            if (buttonIndex >= 0 && buttonIndex < [products count]) {
                [self startRotatingCoin];
                [[StoreClient instance] purchaseProductAtIndex:(int)buttonIndex];
            }
        }
    }
}

- (void)pauseGame {
    stopped = YES;
    [self checkStatus];
}

- (void)resumeGame {
    if (stopped) {
        stopped = NO;
        [[GameCenterClient instance] authenticateLocalPlayer:NO];
        showGameCenterButton.hidden = ![GameCenterClient instance].isGameCenterAvailable;
        if ([GameData instance].status == kStatusShuffleCup) {
            [GameData instance].status = kStatusResumeGame;
        }
        if ([GameData instance].status != kStatusInit) {
            [self checkStatus];
        }
    }
}

- (void)gameStart {
    [[GameCenterClient instance] authenticateLocalPlayer:NO];
    showGameCenterButton.hidden = ![GameCenterClient instance].isGameCenterAvailable;
    if ([GameData instance].status == kStatusShuffleCup) {
        [GameData instance].status = kStatusResumeGame;
    }
    if ([GameData instance].status == kStatusResult) {
        [self addResultToPool:NO];
    } else {
        [self checkStatus];
    }
    [self roundSetup:YES];
}

- (void)roundSetup:(BOOL)start {
    [poolLabel setText:[GameHelper formatScore:[GameData instance].pool]];
    betSlider.minimumValue = 0;
    betSlider.maximumValue = [GameData instance].pool;
    if ([GameData instance].status == kStatusPlaceBet) {
        if ([GameData instance].pool > 0) {
            if (start) {
                betSlider.value = [GameData instance].bet;
            } else {
                [UIView animateWithDuration:0.75 animations:^{
                    self->arrow.alpha = 1.0;
                    self->betSlider.alpha = 1.0;
                    self->betSlider.value = 0;
                }];
            }
        }      
        [self betSliderChanged:betSlider];
    } else {
        [self placeBall];
        if ([GameData instance].status == kStatusShuffleCup || [GameData instance].status == kStatusChooseCup || 
            [GameData instance].status == kStatusResumeGame) {
            for (UIImageView *cup in cups) {
                cup.center = CGPointMake(cup.center.x, cupBottomPosition);
            }
            ball.alpha = 0.0;
            ballShadow.alpha = 0.0;
        } else if ([GameData instance].status == kStatusWonTap || [GameData instance].status == kStatusLostTap) {
            for (UIImageView *cup in cups) {
                cup.center = CGPointMake(cup.center.x, cupBottomPosition);
            }
            UIImageView *cup = [cups objectAtIndex:[GameData instance].selectedPos];
            cup.center = CGPointMake(cup.center.x, cupTopPosition);
            ball.alpha = [GameData instance].status == kStatusWonTap ? 1.0 : 0.0;
            ballShadow.alpha = [GameData instance].status == kStatusWonTap ? 1.0 : 0.0;
        }
        betSlider.value = [GameData instance].bet;
        [betLabel setText:[GameHelper formatScore:[GameData instance].bet]];
    }
}

- (void)checkStatus {
    if (stopped) {
        if ([GameData instance].status == kStatusShuffleCup) {
            [statusText setText:NSLocalizedString(@"GAME_PAUSED", nil)];
        }
    } else {
        if ([GameData instance].status == kStatusInit) {
            [statusText setText:@""];
            [GameData instance].status = kStatusPlaceBet;
            [[GameData instance] store];
            [self checkStatus];
        } else if ([GameData instance].status == kStatusPlaceBet) {
            if ([GameData instance].pool > 0) {
                if ([GameData instance].bet == 0) {
                    [statusText setText:NSLocalizedString(@"PLACE_BET", nil)];
                    [UIView animateWithDuration:0.75 animations:^{
                        self->arrow.alpha = 1.0;
                        self->betSlider.alpha = 1.0;
                    }];
                } else {
                    [statusText setText:NSLocalizedString(@"TAP_CUP", nil)];
                }
                betSlider.enabled = YES;
            } else {
                [UIView animateWithDuration:0.75 animations:^{
                    self->arrow.alpha = 0.0;
                    self->betSlider.alpha = 0.0;
                    self->betSlider.value = 0;
                }];
                /*if (!buyPoolButton.hidden) {
                    [statusText setText:NSLocalizedString(@"BUY_POOL", nil)];
                }*/
                [GameData instance].status = kStatusGameOver;
                [self checkStatus];
            }
        } else if ([GameData instance].status == kStatusShuffleCup) {
            [statusText setText:NSLocalizedString(@"FOLLOW_BALL", nil)];
            betSlider.enabled = NO;
        } else if ([GameData instance].status == kStatusChooseCup) {
            [statusText setText:NSLocalizedString(@"CHOOSE_CUP", nil)];
        } else if ([GameData instance].status == kStatusLostTap) {
            [statusText setText:NSLocalizedString(@"YOU_LOST_MSG", nil)];
        } else if ([GameData instance].status == kStatusWonTap) {
            [statusText setText:NSLocalizedString(@"YOU_WON_MSG", nil)];        
        } else if ([GameData instance].status == kStatusResumeGame) {
            [statusText setText:NSLocalizedString(@"GAME_PAUSED", nil)];
        } else if ([GameData instance].status == kStatusGameOver) {
            [statusText setText:NSLocalizedString(@"GAME_OVER", nil)];        
        }
    }
    [[GameData instance] store];
}

- (IBAction)betSliderChanged:(id)sender {
    if ([GameData instance].status == kStatusPlaceBet) {
        [GameData instance].bet = betSlider.value;
        [betLabel setText:[GameHelper formatScore:[GameData instance].bet]];
        [self checkStatus];
    }
}

- (void)play {    
    [button2Sound play];
    statusText.text = @"";
    [GameData instance].round++;
    [GameData instance].difficultyRound++;
    [GameData instance].status = kStatusShuffleCup;
    [UIView animateWithDuration:0.75 animations:^{
        self->arrow.alpha = 0.0;
        self->betSlider.alpha = 0.0;
        for (UIImageView *cup in self->cups) {
            cup.center = CGPointMake(cup.center.x, self->cupBottomPosition);
        }
        self->ballShadow.alpha = 0.0;
    } completion:^(BOOL finished) {
        [self checkStatus];
        [self start];
    }];
}

- (void)calcTimes {
    [GameData instance].difficulty = pow(((((1.0 * sqrt([GameData instance].pool) * [GameData instance].pool) / 
                                            (kStartPool + [GameData instance].boughtPool)) + 
                                           ((1.0 * [GameData instance].pool) / (1.0 + ([GameData instance].pool - [GameData instance].bet)))) * 
                                            [GameData instance].difficultyRound), kDifficultyRatio);
#ifdef DEBUG
    NSLog(@"Difficulty %f", [GameData instance].difficulty);
#endif
    [GameData instance].roundTurns = [GameHelper getDoubleRandomWithMin:kMinTurns * [GameData instance].difficulty +
                                       [GameHelper getDoubleRandomWithMin:-kMinTurnVariance / [GameData instance].difficulty andMax:kMinTurnVariance * [GameData instance].difficulty] 
                                                                 andMax:kMaxTurns * [GameData instance].difficulty +
                                       [GameHelper getDoubleRandomWithMin:-kMaxTurnVariance / [GameData instance].difficulty andMax:kMaxTurnVariance * [GameData instance].difficulty]];
    if ([GameData instance].roundTurns < kMinAbsTurns) {
        [GameData instance].roundTurns = kMinAbsTurns;
    }        
#ifdef DEBUG
    NSLog(@"Turns %i", [GameData instance].roundTurns);
#endif
}

- (void)start {
    ball.alpha = 0.0;
    [GameData instance].roundCurrentTurn = 0;
    [self calcTimes];
    move = YES;
    [self wait:1.0 atEndCall:@selector(shuffle)];
}

- (void)placeBall {
    float pos = ((UIImageView* )[cups objectAtIndex:[GameData instance].roundBallPos]).center.x;
    ball.center = CGPointMake(pos, ball.center.y);
    ballShadow.center = CGPointMake(pos, ballShadow.center.y);
}

- (void)shuffle {
    if (stopped) {
        return;
    }
    if ([GameData instance].roundCurrentTurn < [GameData instance].roundTurns) {
        if (move) {
            double timeMove = [GameHelper getDoubleRandomWithMin:kTimeMoveMin / [GameData instance].difficulty +
                               [GameHelper getDoubleRandomWithMin:-kTimeMoveMinVariance * [GameData instance].difficulty andMax:kTimeMoveMinVariance / [GameData instance].difficulty] 
                                                          andMax:kTimeMoveMax / [GameData instance].difficulty +
                               [GameHelper getDoubleRandomWithMin:-kTimeMoveMaxVariance * [GameData instance].difficulty andMax:kTimeMoveMaxVariance / [GameData instance].difficulty]] * kTimeFactor;
            if (timeMove < kTimeMoveAbsMin) {
                timeMove = kTimeMoveAbsMin;
            }
#ifdef DEBUG
                NSLog(@"Move Time %f", timeMove);
#endif            
            int first = [GameHelper getRandomWithMin:0 andMax:3];
            int second = first;
            while (second == first) {
                second = [GameHelper getRandomWithMin:0 andMax:3];
            }
            move = NO;
            [self move:first andCup:second inTime:timeMove atEndCall:@selector(shuffle)];
        } else {
            double timeWait = [GameHelper getDoubleRandomWithMin:kTimeWaitMin / [GameData instance].difficulty +
                               [GameHelper getDoubleRandomWithMin:-kTimeWaitMinVariance * [GameData instance].difficulty andMax:kTimeWaitMinVariance / [GameData instance].difficulty] 
                                                          andMax:kTimeWaitMax / [GameData instance].difficulty +
                               [GameHelper getDoubleRandomWithMin:-kTimeWaitMaxVariance * [GameData instance].difficulty andMax:kTimeWaitMaxVariance / [GameData instance].difficulty]];
            if (timeWait < kTimeWaitAbsMin) {
                timeWait = kTimeWaitAbsMin;
            }                
#ifdef DEBUG
            NSLog(@"Wait Time %f", timeWait);
#endif
            move = YES;
            [self wait:timeWait atEndCall:@selector(shuffle)];  
        }
    } else {
        [GameData instance].status = kStatusChooseCup;
        [self checkStatus];
    }
}

- (void)wait:(float)time atEndCall:(SEL)selector {
    if (stopped) {
        return;
    }
    [NSTimer scheduledTimerWithTimeInterval:time target:self selector:selector userInfo:nil repeats:NO];
}

- (void)move:(int)first andCup:(int)second inTime:(float)time atEndCall:(SEL)selector {
    if (stopped) {     
        return;
    }
    UIImageView *firstCup = [cups objectAtIndex:first];
    UIImageView *secondCup = [cups objectAtIndex:second];
    UIImageView *firstCupShadow = [cupsShadow objectAtIndex:first];
    UIImageView *secondCupShadow = [cupsShadow objectAtIndex:second];

    CGPoint start = firstCup.center;
    CGPoint end = secondCup.center;

    int other = 0;
    for (int i = 0; i < [cups count]; i++) {
        if (i != second && i != first) {
            other = i;
            break;
        }
    }
    UIImageView *otherCup = [cups objectAtIndex:other];    
    [self insertSubview:otherCup belowSubview:secondCup];
    [self insertSubview:firstCup belowSubview:otherCup];
    
    /*int j = 0;
    for (UIView *cup in cups) {
        NSLog(@"1. %i : %f - %i", j, cup.layer.position.x, [[self subviews] indexOfObject:cup]);
        j++;
    }
     
    if ([[self subviews] indexOfObject:[cups objectAtIndex:first]] > [[self subviews] indexOfObject:[cups objectAtIndex:second]]) {
        NSLog(@"Wrong Order");
    }
    if ([[self subviews] indexOfObject:[cups objectAtIndex:other]] > [[self subviews] indexOfObject:[cups objectAtIndex:second]]) {
        NSLog(@"Wrong Order");
    }
    if ([[self subviews] indexOfObject:[cups objectAtIndex:other]] < [[self subviews] indexOfObject:[cups objectAtIndex:first]]) {
        NSLog(@"Wrong Order");
    }*/
    
    [(AVAudioPlayer *)[woosh1Sounds objectAtIndex:[GameData instance].roundCurrentTurn % [woosh1Sounds count]] play];
    
    CGFloat moveOffset = [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone ? kMoveOffset_iPhone : kMoveOffset_iPad;
    
    CAKeyframeAnimation *pathAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    pathAnimation.calculationMode = kCAAnimationPaced;
    pathAnimation.fillMode = kCAFillModeForwards;
    pathAnimation.duration = time;
    pathAnimation.delegate = self;
    pathAnimation.removedOnCompletion = YES;
    CGMutablePathRef curvedPath = CGPathCreateMutable();
    CGPathMoveToPoint(curvedPath, NULL, start.x, start.y);
    CGPathAddQuadCurveToPoint(curvedPath, NULL, (start.x + end.x) / 2, start.y - moveOffset, end.x, end.y);
    pathAnimation.path = curvedPath;
    CGPathRelease(curvedPath);
    [firstCup.layer addAnimation:pathAnimation forKey:@"curveAnimation"];

    pathAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    pathAnimation.calculationMode = kCAAnimationPaced;
    pathAnimation.fillMode = kCAFillModeForwards;
    pathAnimation.duration = time;
    pathAnimation.removedOnCompletion = YES;
    curvedPath = CGPathCreateMutable();
    CGPathMoveToPoint(curvedPath, NULL, end.x, end.y);
    CGPathAddQuadCurveToPoint(curvedPath, NULL, (start.x + end.x) / 2, end.y + moveOffset, start.x, start.y);
    pathAnimation.path = curvedPath;
    CGPathRelease(curvedPath);
    [secondCup.layer addAnimation:pathAnimation forKey:@"curveAnimation"];
    
    CGPoint startShadow = firstCupShadow.center;
    CGPoint endShadow = secondCupShadow.center;
    
    pathAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    pathAnimation.calculationMode = kCAAnimationPaced;
    pathAnimation.fillMode = kCAFillModeForwards;
    pathAnimation.duration = time;
    pathAnimation.removedOnCompletion = YES;
    curvedPath = CGPathCreateMutable();
    CGPathMoveToPoint(curvedPath, NULL, startShadow.x, startShadow.y);
    CGPathAddQuadCurveToPoint(curvedPath, NULL, (startShadow.x + endShadow.x) / 2, startShadow.y - moveOffset, endShadow.x, endShadow.y);
    pathAnimation.path = curvedPath;
    CGPathRelease(curvedPath);
    [firstCupShadow.layer addAnimation:pathAnimation forKey:@"curveAnimation"];
    
    pathAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    pathAnimation.calculationMode = kCAAnimationPaced;
    pathAnimation.fillMode = kCAFillModeForwards;
    pathAnimation.duration = time;
    pathAnimation.removedOnCompletion = YES;
    curvedPath = CGPathCreateMutable();
    CGPathMoveToPoint(curvedPath, NULL, endShadow.x, endShadow.y);
    CGPathAddQuadCurveToPoint(curvedPath, NULL, (startShadow.x + endShadow.x) / 2, endShadow.y + moveOffset, startShadow.x, startShadow.y);
    pathAnimation.path = curvedPath;
    CGPathRelease(curvedPath);
    [secondCupShadow.layer addAnimation:pathAnimation forKey:@"curveAnimation"];
    
    if ([GameData instance].roundBallPos == first) {
        [GameData instance].roundBallPos = second;
    } else if ([GameData instance].roundBallPos == second) {
        [GameData instance].roundBallPos = first;
    }
    [GameData instance].roundCurrentTurn++;
}

- (void)animationDidStop:(CAKeyframeAnimation *)anim finished:(BOOL)flag {
    [self shuffle];
}

- (void)select:(int)selectedPos {
    [button2Sound play];
    [GameData instance].selectedPos = selectedPos;
    ball.alpha = 1.0;
    [self placeBall];
    
    [UIView animateWithDuration:0.75 animations:^{
        UIImageView *cup = [self->cups objectAtIndex:selectedPos];
        if (cup.center.y > self->cupTopPosition) {
            cup.center = CGPointMake(cup.center.x, self->cupTopPosition);
        }
        if (selectedPos == [GameData instance].roundBallPos) {
            self->ballShadow.alpha = 1.0;
        }
    }];
    
    if (selectedPos == [GameData instance].roundBallPos) {
        [GameData instance].status = kStatusWonTap;
    } else {
        [GameData instance].status = kStatusLostTap;
    }
    [self checkStatus];
}

- (void)showAllCups {
    ball.alpha = 1.0;
    [UIView animateWithDuration:0.75 animations:^{
        for (UIImageView *cup in self->cups) {
            if (cup.center.y > self->cupTopPosition) {
                cup.center = CGPointMake(cup.center.x, self->cupTopPosition);
            }
        }
        self->ballShadow.alpha = 1.0;
    }];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if ([[event allTouches] count] > 1) {
        return;
    }
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint point = [touch locationInView:self];
    if ([GameData instance].status == kStatusPlaceBet && [GameData instance].bet > 0) {
        for (UIImageView *cup in cups) {
            if (CGRectContainsPoint(cup.frame, point)) {
                [self play];
                break;
            }
        }
    } else if ([GameData instance].status == kStatusChooseCup) {
        int i = 0;
        for (UIImageView *cup in cups) {
            if (CGRectContainsPoint(cup.frame, point)) {
                [woosh2Sound play];
                [self select:i];
                break;
            }
            i++;
        }
    } else if ([GameData instance].status == kStatusWonTap || [GameData instance].status == kStatusLostTap) {
        [button2Sound play];
        [self showAllCups];
        [GameData instance].result = [GameData instance].status == kStatusWonTap ? [GameData instance].bet : -[GameData instance].bet;
        [GameData instance].bet = 0;
        if ([GameData instance].result != 0) {
            deltaLabel.alpha = 0.0;
            deltaLabel.textColor = [GameData instance].status == kStatusWonTap ? [UIColor greenColor] : [UIColor redColor];
            deltaLabel.frame = CGRectMake(deltaLabel.frame.origin.x, betLabel.frame.origin.y, deltaLabel.frame.size.width, deltaLabel.frame.size.height);
            [deltaLabel setText:[NSString stringWithFormat:@"%@%lld", [GameData instance].status == kStatusWonTap ? @"+" : @"", [GameData instance].result]];
            [woosh2Sound play];
            [GameData instance].status = kStatusResult;
            [self checkStatus];
            [UIView animateWithDuration:1.0 animations:^{
                self->statusText.text = @"";
                self->deltaLabel.alpha = 1.0;
                self->deltaLabel.frame = CGRectMake(self->deltaLabel.frame.origin.x, self->poolLabel.frame.origin.y, self->deltaLabel.frame.size.width, self->deltaLabel.frame.size.height);
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:0.5 animations:^{
                    self->deltaLabel.alpha = 0.0;
                }];
                [self addResultToPool:YES];
            }];
        } else {
            [GameData instance].status = kStatusPlaceBet;
            [self checkStatus];
            [self roundSetup:NO];
        }
    } else if ([GameData instance].status == kStatusResumeGame) {
        [button2Sound play];
        move = YES;
        [GameData instance].status = kStatusShuffleCup;
        [self checkStatus];
        [self wait:1.0 atEndCall:@selector(shuffle)];
    } else if ([GameData instance].status == kStatusGameOver) {
        [GameData instance].status = kStatusInit;
        [self gameSetup];
    }
}

- (void)addResultToPool:(BOOL)roundSetup {
    if ([GameData instance].status == kStatusResult) {
        [self addPointsToPool:[GameData instance].result];
        [GameData instance].result = 0;
        [GameData instance].status = kStatusPlaceBet;
        [self checkStatus];
        if (roundSetup) {
            [self roundSetup:NO];
        }
    }
}

- (void)addPointsToPool:(long long)points {
    if ([[GameData instance] updatePoolWith:points]) {
        [[GameCenterClient instance] reportPool:[GameData instance].pool];
    }
    [poolLabel setText:[GameHelper formatScore:[GameData instance].pool]];
    betSlider.maximumValue = [GameData instance].pool;
    if (points < 0) {
        [GameData instance].difficultyRound -= ((1.0f * -points) / (1.0f * [GameData instance].maxPool)) * [GameData instance].difficultyRound;
        if ([GameData instance].difficultyRound < 0) {
            [GameData instance].difficultyRound = 0;
        }
    }
}

- (void)notifyPoolBought:(long long)points {
    if ([GameData instance].pool == 0) {
        [GameData instance].difficultyRound = 0;
        [GameData instance].maxPool = 0;
    }
    deltaLabel.alpha = 0.0;
    deltaLabel.textColor = [UIColor greenColor];
    deltaLabel.frame = CGRectMake(deltaLabel.frame.origin.x, 10 - deltaLabel.frame.size.height, deltaLabel.frame.size.width, deltaLabel.frame.size.height);
    [deltaLabel setText:[NSString stringWithFormat:@"+%lld", points]];
    [woosh2Sound play];
    [UIView animateWithDuration:1.0 animations:^{
        self->deltaLabel.alpha = 1.0;
        self->deltaLabel.frame = CGRectMake(self->deltaLabel.frame.origin.x, self->poolLabel.frame.origin.y, self->deltaLabel.frame.size.width, self->deltaLabel.frame.size.height);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.5 animations:^{
            self->deltaLabel.alpha = 0.0;
        }];
        [self addPointsToPool:points];
        [self checkStatus];
    }];
}

- (NSString *)formatProduct:(SKProduct *)storeProduct {
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [numberFormatter setLocale:storeProduct.priceLocale];
    NSString *formattedPrice = [numberFormatter stringFromNumber:storeProduct.price];
    return [NSString stringWithFormat:@"%@ (%@)", storeProduct.localizedTitle, formattedPrice];
}

- (IBAction)buyPool:(id)sender {
    [button1Sound play];
    NSArray *products = [[StoreClient instance] getStoreProducts];
    if (products == nil || [products count] == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"IN_APP_PURCHASE", nil) message:NSLocalizedString(@"NO_PRODUCTS", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK_BTN", nil) otherButtonTitles:nil];
        [alert show];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"SELECT_POOL", nil) message:@"" delegate:self cancelButtonTitle:NSLocalizedString(@"CANCEL_BTN", nil) otherButtonTitles:nil];
        for (SKProduct *storeProduct in products) {
            [alert addButtonWithTitle:[self formatProduct:storeProduct]];
        };
        [alert show];
    }
}

- (void)showGameCenter:(UIViewController *)controller {
    [button1Sound play];
    [[GameCenterClient instance] showLeaderboard:controller];
}

- (void)willPresentAlertView:(UIAlertView *)alertView {
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        if ([[alertView title] isEqualToString:NSLocalizedString(@"SELECT_POOL", nil)]) {
            alertView.frame = CGRectMake(alertView.frame.origin.x, alertView.frame.origin.y-15, alertView.frame.size.width, alertView.frame.size.height+30);
            for (UIView *view in [alertView subviews]) {
                if ([view isKindOfClass:[UIButton class]]) {
                    view.frame = CGRectMake(view.frame.origin.x, view.frame.origin.y+30, view.frame.size.width, view.frame.size.height);
                }
            }
        }
    }
}

- (void)startRotatingCoin {
    [self stopRotatingCoin];
    buyPoolButton.enabled = NO;
    buyCoinTimer = [NSTimer scheduledTimerWithTimeInterval:0.05 target: self selector:@selector(updateRotatingCoin:) userInfo: nil repeats:YES];
}

-(void)updateRotatingCoin:(NSTimer *)timer {
    buyCoinAngle += 0.1;
	if (buyCoinAngle > M_PI * 2) { 
		buyCoinAngle = 0;
	}
	buyCoin.transform = CGAffineTransformMakeRotation(buyCoinAngle);
}

- (void)stopRotatingCoin {
    buyPoolButton.enabled = YES;
    [buyCoinTimer invalidate];
    buyCoinTimer = nil;
    buyCoinAngle = 0;
    [UIView animateWithDuration:0.5 animations:^{
        self->buyCoin.transform = CGAffineTransformIdentity; 
    }];
}

@end
