//
//  Menu.m
//  
//
//  Created by Brian Olencki on 6/11/15.
//
//

#import "Menu.h"

static CGRect overlayFrame;

@implementation Menu
@synthesize delegate = _delegate, onScreen = _onScreen, leftSide = _leftSide, blur = _blur, windowLevel = _windowLevel, subMenuOnScreen = _subMenuOnScreen, useSubMenu = _useSubMenu;
+ (Menu*)sharedInstance {
    static dispatch_once_t p = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&p, ^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}
- (id)init {
    if (self == [super init]) {
        _leftSide = YES;
        _blur = UIBlurEffectStyleExtraLight;
        _onScreen = NO;
        _windowLevel = 1030.0;
        _useSubMenu = NO;
        
        _delegate = nil;
    }
    return self;
}
- (void)create {
    overlay.hidden = YES;
    if (_leftSide == YES) {
        overlayFrame = CGRectMake(0, 0, 225, SCREEN.size.height);
    } else {
        overlayFrame = CGRectMake(SCREEN.size.width-225, 0, 225, SCREEN.size.height);
    }
    overlay = [[UIWindow alloc] initWithFrame:overlayFrame];
    overlay.backgroundColor = [UIColor clearColor];
    overlay.windowLevel = _windowLevel;
    [overlay makeKeyAndVisible];
    
    background = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:_blur]];
    background.frame = CGRectMake(0, 0, 225, SCREEN.size.height);
    [overlay addSubview:background];
    
    UIPanGestureRecognizer *pgrSlideView = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [background addGestureRecognizer:pgrSlideView];
    [self closeMenuAnimate:NO];
    
    if (_useSubMenu == YES) {
        [self createSubMenu];
    }
}
- (void)createSubMenu {
    dropDown = [[UIView alloc] initWithFrame:CGRectMake(0, 0, background.frame.size.width, background.frame.size.height+20)];
    dropDown.backgroundColor = [UIColor clearColor];
    [overlay addSubview:dropDown];
    
    subMenu = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:_blur]];
    subMenu.frame = CGRectMake(0, 0, background.frame.size.width, background.frame.size.height);
    [dropDown addSubview:subMenu];
    
    grabber = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 40, 7.5)];
    grabber.alpha = 0.5;
    grabber.userInteractionEnabled = YES;
    if (_blur == UIBlurEffectStyleDark) {
        grabber.backgroundColor = [UIColor whiteColor];
    } else {
        grabber.backgroundColor = [UIColor darkGrayColor];
    }
    grabber.layer.cornerRadius = 7.5/2;
    grabber.layer.masksToBounds = YES;
    grabber.center = CGPointMake(dropDown.center.x, dropDown.frame.size.height-5);
    [dropDown addSubview:grabber];
    
    UITapGestureRecognizer *tgrGrabberSM = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    tgrGrabberSM.numberOfTapsRequired = 1;
    [grabber addGestureRecognizer:tgrGrabberSM];
    
    UIPanGestureRecognizer *pgrGrabberSM = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [dropDown addGestureRecognizer:pgrGrabberSM];
    
    [self closeSubMenuAnimate:NO];
}
- (void)addSwipeGestureToView:(UIView *)SlideView addTapGestureToView:(UIView*)TapView{
    [self create];
    
    UIScreenEdgePanGestureRecognizer *sgrSlideIn = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(handeEdgePan:)];
    if (_leftSide == YES) {
        sgrSlideIn.edges = UIRectEdgeLeft;
    } else {
        sgrSlideIn.edges = UIRectEdgeRight;
    }
    [SlideView addGestureRecognizer:sgrSlideIn];
    
    UITapGestureRecognizer *tgrCloseView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    tgrCloseView.numberOfTapsRequired = 1;
    [TapView addGestureRecognizer:tgrCloseView];
}

#pragma mark - Opening & Closing
- (void)openMenuAnimate:(BOOL)animation {
    _onScreen = YES;
    
    if (animation == YES) {
        [UIView animateWithDuration:ANIMATION_DURATION animations:^{
            [overlay setFrame:overlayFrame];
        }];
    } else {
        [overlay setFrame:overlayFrame];
    }
    
    if (_delegate != nil) {
        [_delegate menuDidOpen];
    }
}
- (void)closeMenuAnimate:(BOOL)animation {
    _onScreen = NO;
    
    if (_leftSide == YES) {
        if (animation == YES) {
            [UIView animateWithDuration:ANIMATION_DURATION animations:^{
                [overlay setFrame:CGRectMake(-overlayFrame.size.width, overlayFrame.origin.y, overlayFrame.size.width, overlayFrame.size.height)];
                [self closeSubMenuAnimate:YES];
            }];
        } else {
            [self closeSubMenuAnimate:NO];
            [overlay setFrame:CGRectMake(-overlayFrame.size.width, overlayFrame.origin.y, overlayFrame.size.width, overlayFrame.size.height)];
        }
    } else {
        if (animation == YES) {
            [UIView animateWithDuration:ANIMATION_DURATION animations:^{
                [overlay setFrame:CGRectMake(SCREEN.size.width, overlayFrame.origin.y, overlayFrame.size.width, overlayFrame.size.height)];
                [self closeSubMenuAnimate:YES];
            }];
        } else {
            [overlay setFrame:CGRectMake(SCREEN.size.width, overlayFrame.origin.y, overlayFrame.size.width, overlayFrame.size.height)];
            [self closeSubMenuAnimate:NO];
        }
    }

    if (_delegate != nil) {
        [_delegate menuDidClose];
    }
}
- (void)openSubMenuAnimate:(BOOL)animation {
    if (animation == YES) {
        [UIView animateWithDuration:ANIMATION_DURATION animations:^{
            [dropDown setFrame:CGRectMake(0, -1, background.frame.size.width, background.frame.size.height+20)];
            [grabber setCenter:CGPointMake(dropDown.center.x, dropDown.frame.size.height-35)];
        }];
    } else {
        [dropDown setFrame:CGRectMake(0, -1, background.frame.size.width, background.frame.size.height+20)];
        [grabber setCenter:CGPointMake(dropDown.center.x, dropDown.frame.size.height-35)];
    }
    
    if (_delegate != nil) {
        [_delegate subMenuDidOpen];
    }
    _subMenuOnScreen = YES;
}
- (void)closeSubMenuAnimate:(BOOL)animation {
    if (animation == YES) {
        [UIView animateWithDuration:ANIMATION_DURATION animations:^{
            [dropDown setFrame:CGRectMake(0, -SCREEN.size.height, background.frame.size.width, background.frame.size.height+20)];
            [grabber setCenter:CGPointMake(dropDown.center.x, dropDown.frame.size.height-5)];
        }];
    } else {
        [dropDown setFrame:CGRectMake(0, -SCREEN.size.height, background.frame.size.width, background.frame.size.height+20)];
        [grabber setCenter:CGPointMake(dropDown.center.x, dropDown.frame.size.height-5)];
    }
    
    if (_delegate != nil) {
        [_delegate subMenuDidClose];
    }
    _subMenuOnScreen = NO;
}

#pragma mark - Gesture Handling
- (void)handeEdgePan:(UIScreenEdgePanGestureRecognizer*)recognizer {
    CGPoint translation = [recognizer translationInView:recognizer.view];

    if (_leftSide == YES) {
        if (recognizer.state == UIGestureRecognizerStateBegan || recognizer.state == UIGestureRecognizerStateChanged) {
            if (translation.x < overlayFrame.size.width) {
                [overlay setFrame:CGRectMake(translation.x-overlayFrame.size.width, overlayFrame.origin.y, overlayFrame.size.width, overlayFrame.size.height)];
            } else {
                [self openMenuAnimate:NO];
            }
        } else if (recognizer.state == UIGestureRecognizerStateEnded) {
            if (translation.x > overlay.frame.size.width/2) {
                [self openMenuAnimate:YES];
            } else {
                [self closeMenuAnimate:YES];
            }
        } else {
            [self closeMenuAnimate:YES];
        }
    } else {
        if (recognizer.state == UIGestureRecognizerStateBegan || recognizer.state == UIGestureRecognizerStateChanged) {
            if (ABS(translation.x) < overlayFrame.size.width) {
                [overlay setFrame:CGRectMake(SCREEN.size.width-ABS(translation.x), overlayFrame.origin.y, overlayFrame.size.width, overlayFrame.size.height)];
            } else {
                [self openMenuAnimate:NO];
            }
        } else if (recognizer.state == UIGestureRecognizerStateEnded) {
            if (translation.x < overlay.frame.size.width/2) {
                [self openMenuAnimate:YES];
            } else {
                [self closeMenuAnimate:YES];
            }
        } else {
            [self closeMenuAnimate:YES];
        }
    }
}
- (void)handlePan:(UIPanGestureRecognizer*)recognizer {
    CGPoint translation = [recognizer translationInView:recognizer.view.superview];

    if (recognizer.view == dropDown) {
        if (recognizer.state == UIGestureRecognizerStateChanged) {
            if (recognizer.view.frame.origin.y <= -1) {
                [dropDown setFrame:CGRectMake(0, translation.y, dropDown.frame.size.width, dropDown.frame.size.width)];
            }
        } else if (recognizer.state == UIGestureRecognizerStateEnded) {
            if (_subMenuOnScreen == NO) {
                [self openSubMenuAnimate:YES];
            } else {
                [self closeSubMenuAnimate:YES];
            }
        }
    } else {
        if (_leftSide == YES) {
            if (recognizer.state == UIGestureRecognizerStateChanged) {
                if (translation.x < 0) {
                    [overlay setFrame:CGRectMake(translation.x, overlayFrame.origin.y, overlayFrame.size.width, overlayFrame.size.height)];
                }
            } else if (recognizer.state == UIGestureRecognizerStateEnded) {
                if (translation.x > overlay.frame.size.width/2) {
                    [self openMenuAnimate:YES];
                } else {
                    [self closeMenuAnimate:YES];
                }
            }
        } else {
            if (recognizer.state == UIGestureRecognizerStateChanged) {
                if (translation.x > 0) {
                    [overlay setFrame:CGRectMake(translation.x+overlayFrame.size.width/2, overlayFrame.origin.y, overlayFrame.size.width, overlayFrame.size.height)];
                }
            } else if (recognizer.state == UIGestureRecognizerStateEnded) {
                if (translation.x < overlay.frame.size.width/2) {
                    [self openMenuAnimate:YES];
                } else {
                    [self closeMenuAnimate:YES];
                }
            }
        }
    }
}
- (void)handleTap:(UITapGestureRecognizer*)recognizer {

    if (recognizer.view == grabber) {
        if (_subMenuOnScreen == YES) {
            [self closeSubMenuAnimate:YES];
        } else {
            [self openSubMenuAnimate:YES];
        }
    } else {
        if (_onScreen == YES) {
            [self closeMenuAnimate:YES];
        }
    }
}

#pragma mark - Subviews
- (void)addSubview:(UIView*)view {
    [background addSubview:view];
}
- (void)addSubviewToSubMenu:(UIView *)view {
    [subMenu addSubview:view];
}
@end