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
@synthesize delegate = _delegate, onScreen = _onScreen, leftSide = _leftSide, blur = _blur;
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
    overlay.windowLevel = 2000;
    [overlay makeKeyAndVisible];
    
    background = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:_blur]];
    background.frame = CGRectMake(0, 0, 225, SCREEN.size.height);
    [overlay addSubview:background];
    
    UIPanGestureRecognizer *pgrSlideView = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [background addGestureRecognizer:pgrSlideView];
    [self closeMenuAnimate:NO];
}
- (void)addSwipeGestureToView:(UIView *)view {
    [self create];
    
    UIScreenEdgePanGestureRecognizer *sgrSlideIn = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(handeEdgePan:)];
    if (_leftSide == YES) {
        sgrSlideIn.edges = UIRectEdgeLeft;
    } else {
        sgrSlideIn.edges = UIRectEdgeRight;
    }
    [view addGestureRecognizer:sgrSlideIn];
    
    UITapGestureRecognizer *tgrCloseView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    tgrCloseView.numberOfTapsRequired = 1;
    [view addGestureRecognizer:tgrCloseView];
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
    
    [_delegate menuDidOpen];
}
- (void)closeMenuAnimate:(BOOL)animation {
    _onScreen = NO;
    
    if (_leftSide == YES) {
        if (animation == YES) {
            [UIView animateWithDuration:ANIMATION_DURATION animations:^{
                [overlay setFrame:CGRectMake(-overlayFrame.size.width, overlayFrame.origin.y, overlayFrame.size.width, overlayFrame.size.height)];
            }];
        } else {
            [overlay setFrame:CGRectMake(-overlayFrame.size.width, overlayFrame.origin.y, overlayFrame.size.width, overlayFrame.size.height)];
        }
    } else {
        if (animation == YES) {
            [UIView animateWithDuration:ANIMATION_DURATION animations:^{
                [overlay setFrame:CGRectMake(SCREEN.size.width, overlayFrame.origin.y, overlayFrame.size.width, overlayFrame.size.height)];
            }];
        } else {
            [overlay setFrame:CGRectMake(SCREEN.size.width, overlayFrame.origin.y, overlayFrame.size.width, overlayFrame.size.height)];
        }
    }

    
    [_delegate menuDidClose];
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
- (void)handleTap:(UITapGestureRecognizer*)recognizer {
    if (_onScreen == YES) {
        [self closeMenuAnimate:YES];
    }
}

#pragma mark - Subviews
- (void)addSubview:(UIView*)view {
    [background addSubview:view];
}
@end