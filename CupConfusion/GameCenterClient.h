//
//  GameCenterClient.h
//  CupConfusion
//
//  Created by Oliver Klemenz on 11.02.11.
//  Copyright 2011 Oliver Klemenz. All rights reserved.
//

#define kAuthenticationErrorsMax 3

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>

@interface GameCenterClient : NSObject <UIApplicationDelegate, GKLeaderboardViewControllerDelegate> {

	NSMutableArray *poolReportErrors;
	NSMutableArray *achievementReportErrors;

	BOOL gameCenterAvailable;
	BOOL gameCenterAvailableFreeVersion;
	BOOL authenticated;
	int authenticationErrors;
	BOOL gameCenterError;
	BOOL inAuthentication;
	
	NSString *playerAlias;
}

@property BOOL gameCenterAvailable;
@property BOOL authenticated;
@property int authenticationErrors;
@property BOOL gameCenterError;
@property BOOL inAuthentication;

@property (nonatomic, retain, readonly) NSString *playerAlias;

+ (GameCenterClient *)instance;

- (BOOL)isGameCenterAvailable;
- (void)authenticateLocalPlayer:(BOOL)popup;
- (void)registerForAuthenticationNotification;
- (void)authenticationChanged;

- (void)reportPool:(long long)pool;
	
- (void)showLeaderboard:(UIViewController *)vc;
- (void)leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController;

- (void)handleReportErrors;

@end
