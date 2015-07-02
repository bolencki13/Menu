//
//  ViewController.m
//  Menu
//
//  Created by Brian Olencki on 6/12/15.
//  Copyright (c) 2015 bolencki13. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor redColor];
    self.view.frame = CGRectMake(SCREEN.size.width-225, 0, 225, SCREEN.size.height);

    [Menu sharedInstance].delegate = self;
    [Menu sharedInstance].leftSide = NO;
    [Menu sharedInstance].useSubMenu = YES;
    [Menu sharedInstance].blur = UIBlurEffectStyleDark;
    [[Menu sharedInstance] addSwipeGestureToView:self.view addTapGestureToView:self.view];
}

#pragma mark - Menu Delegate
- (void)menuDidOpen {
    
}
@end
