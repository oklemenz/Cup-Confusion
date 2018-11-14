//
//  ViewController.m
//  CupConfusion
//
//  Created by Oliver on 22.01.12.
//  Copyright (c) 2012 Oliver Klemenz. All rights reserved.
//

#import "ViewController_iphone.h"
#import "GameCenterClient.h"
#import "GameView.h"

@implementation ViewController_iphone

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

- (void)pauseGame {
    [((GameView *)self.view) pauseGame];
}

- (void)resumeGame {
    [((GameView *)self.view) resumeGame];    
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
}

- (IBAction)showGameCenter:(id)sender {
    [((GameView *)self.view) showGameCenter:self]; 
}

@end
