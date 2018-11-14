//
//  AppDelegate.m
//  CupConfusion
//
//  Created by Oliver on 22.01.12.
//  Copyright (c) 2012 Oliver Klemenz. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController_iphone.h"
#import "ViewController_ipad.h"
#import "GameData.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize viewController = _viewController;
@synthesize stopped;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    CGRect bounds = [UIScreen mainScreen].bounds;
    self.window = [[UIWindow alloc] initWithFrame:bounds];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        _viewController = [[ViewController_iphone alloc] initWithNibName:@"ViewController_iphone" bundle:nil];
        // Scale iPhone
        CGFloat scaleX = bounds.size.width / _viewController.view.bounds.size.width;
        CGFloat scaleY = bounds.size.height / _viewController.view.bounds.size.height;
        _viewController.view.transform = CGAffineTransformMakeScale(scaleX, scaleY);
        _viewController.view.center = CGPointMake(bounds.size.width / 2, bounds.size.height / 2);
    } else {
        _viewController = [[ViewController_ipad alloc] initWithNibName:@"ViewController_ipad" bundle:nil];
    }
    
    UIViewController *rootViewController = [[UIViewController alloc] init];
    [rootViewController.view addSubview:_viewController.view];
    [rootViewController addChildViewController:_viewController];
    [_viewController didMoveToParentViewController:rootViewController];
    [self.window setRootViewController:rootViewController];
    
    [self.window makeKeyAndVisible];
    [[GameData instance] load];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
    stopped = YES;
    [((AppDelegate<ApplicationEvents> *)_viewController) pauseGame];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
    [[GameData instance] store];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
    [((AppDelegate<ApplicationEvents> *)_viewController) resumeGame];
    stopped = NO;
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
    [[GameData instance] store];
}

+ (AppDelegate *)instance {
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

@end
