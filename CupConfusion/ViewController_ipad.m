//
//  ViewController_ipad.m
//  CupConfusion
//
//  Created by Oliver on 02.05.12.
//  Copyright (c) 2012 Oliver Klemenz. All rights reserved.
//

#import "ViewController_ipad.h"
#import "GameCenterClient.h"
#import "GameView.h"

@interface ViewController_ipad ()

@end

@implementation ViewController_ipad

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
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
    // Do any additional setup after loading the view from its nib.
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
