//
//  GameCenterClient.m
//  HotWire
//
//  Created by Oliver Klemenz on 11.02.11.
//  Copyright 2011 Oliver Klemenz. All rights reserved.
//
#import "GameCenterClient.h"
#import "AppDelegate.h"

@implementation GKLeaderboardViewController(Landscape)

- (BOOL)shouldAutorotate {
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscape;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationLandscapeLeft;
}

@end

@implementation GameCenterClient

@synthesize gameCenterAvailable, authenticated, authenticationErrors, gameCenterError, inAuthentication, playerAlias;

+ (GameCenterClient *)instance {
	static GameCenterClient *_instance;
	@synchronized(self) {
		if (!_instance) {
			_instance = [[GameCenterClient alloc] init];
		}
	}
	return _instance;
}

- (id)init {
	if ((self = [super init])) {
		poolReportErrors = [[NSMutableArray alloc] init];
		gameCenterError = NO;
	 	authenticated = NO;
		gameCenterAvailable = [self isGameCenterAvailable];
		if (gameCenterAvailable) {
			[self registerForAuthenticationNotification];
		}
	}
	return self;
}

- (BOOL)isGameCenterAvailable {
	Class gcClass = (NSClassFromString(@"GKLocalPlayer"));
	NSString *reqSysVer = @"4.1";
	NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
	BOOL osVersionSupported = ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending);
	return gcClass && osVersionSupported;
}

- (void)authenticateLocalPlayer:(BOOL)popup {
	if (gameCenterAvailable) {
		if (!authenticated && !inAuthentication && authenticationErrors < kAuthenticationErrorsMax) {
			inAuthentication = YES;
			[[GKLocalPlayer localPlayer] authenticateWithCompletionHandler:^(NSError *error) {
				if (error != nil) {
					if (popup) {
                        UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"GAME_CENTER", nil) message:NSLocalizedString(@"GAME_CENTER_ERROR", nil) preferredStyle:UIAlertControllerStyleAlert];
                        
                        [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK_BTN", nil)
                                                                  style:UIAlertActionStyleDefault
                                                                handler:^(UIAlertAction * action) {
                                                                }]];
                        
                        [[[[AppDelegate instance] window] rootViewController] presentViewController:alert animated:YES completion:nil];
					}
                    self->authenticationErrors++;
                    self->authenticated = NO;
                    self->gameCenterError = YES;
				} else {
                    self->authenticationErrors = 0;
                    self->authenticated = YES;
                    self->playerAlias = [GKLocalPlayer localPlayer].alias;
					[self handleReportErrors];
				}
                self->inAuthentication = NO;
			}];
		}
	}
}

- (void)registerForAuthenticationNotification {
	if (gameCenterAvailable) {
		NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
		[nc addObserver:self selector:@selector(authenticationChanged) name:GKPlayerAuthenticationDidChangeNotificationName object:nil];
	}
}

- (void)authenticationChanged {
	if (gameCenterAvailable) {
		if ([GKLocalPlayer localPlayer].isAuthenticated) {
			[self handleReportErrors];
			authenticated = YES;
			playerAlias = [GKLocalPlayer localPlayer].alias;
		} else {
			authenticated = NO;
			playerAlias = @"";
		}
	}
}

- (void)reportPool:(long long)pool {
	if (gameCenterAvailable) {
		[self handleReportErrors];
		NSString *category = @"HIGHSCORE";
		GKScore *poolReporter = [[GKScore alloc] initWithCategory:category];
		if (poolReporter) {
			poolReporter.value = pool;
			[poolReporter reportScoreWithCompletionHandler:^(NSError *error) {
				if (error != nil) {
                    [self->poolReportErrors addObject:poolReporter];
                    self->gameCenterError	= YES;
					return;
				}
			}];
		}
	}
}

- (void)showLeaderboard:(UIViewController *)vc {
	if (gameCenterAvailable) {
		if (authenticated) {
			[self handleReportErrors];
			GKLeaderboardViewController *leaderboardController = [[GKLeaderboardViewController alloc] init];
			if (leaderboardController) {
				leaderboardController.leaderboardDelegate = self;
				NSString *category = @"HIGHSCORE";
				leaderboardController.category = category;
				[vc presentViewController:leaderboardController animated:YES completion:nil];
			}
		} else {
			[self authenticateLocalPlayer:YES];
		}
	}
}

- (void)leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController {
	[viewController dismissViewControllerAnimated:YES completion:nil];
	[viewController.view removeFromSuperview];
}

- (void)handleReportErrors {
	if (gameCenterAvailable && authenticated) {
		if ([poolReportErrors count] > 0) {
			for (GKScore *pool in [NSMutableArray arrayWithArray:poolReportErrors]) {
				[pool reportScoreWithCompletionHandler:^(NSError *error) {
					if (error == nil) {
                        [self->poolReportErrors removeObject:pool];
					}
				}];
			}
		}
	}
}

@end
