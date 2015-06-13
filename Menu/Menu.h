//
//  Menu.h
//  
//
//  Created by Brian Olencki on 6/11/15.
//
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@protocol MenuDelegate <NSObject>
@optional
- (void)menuDidOpen;
- (void)menuDidClose;
@end

@interface Menu : NSObject {
    UIWindow *overlay;
    UIVisualEffectView *background;
    
    id <MenuDelegate> __weak _delegate;
    BOOL _onScreen;
    BOOL _leftSide;
    UIBlurEffectStyle _blur;
}
#define SCREEN ([UIScreen mainScreen].bounds)
#define ANIMATION_DURATION (0.5)
@property (nonatomic, weak) id <MenuDelegate> delegate;
@property (readonly) BOOL onScreen;
@property (nonatomic, assign) BOOL leftSide; /*default YES, NO moves to right side of screen*/
@property (nonatomic, assign) UIBlurEffectStyle blur;
+ (Menu*)sharedInstance;
- (void)addSwipeGestureToView:(UIView*)view;
- (void)openMenuAnimate:(BOOL)animation;
- (void)closeMenuAnimate:(BOOL)animation;
- (void)addSubview:(UIView*)view;
- (void)create;
@end
