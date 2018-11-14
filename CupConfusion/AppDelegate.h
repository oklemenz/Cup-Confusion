//
//  AppDelegate.h
//  CupConfusion
//
//  Created by Oliver on 22.01.12.
//  Copyright (c) 2012 Oliver Klemenz. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ApplicationEvents <NSObject>

- (void)pauseGame;
- (void)resumeGame;

@end

@interface AppDelegate : UIResponder <UIApplicationDelegate> {
    BOOL stopped;
}

@property BOOL stopped;

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UIViewController *viewController;

+ (AppDelegate *)instance;

@end
