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
- (void)menuDidOpen;
- (void)menuDidClose;
- (void)subMenuDidOpen;
- (void)subMenuDidClose;
@end

@interface Menu : NSObject {
    UIWindow *overlay;
    UIVisualEffectView *background;
    UIView *dropDown;
    UIVisualEffectView *subMenu;
    UIView *grabber;
    
    id <MenuDelegate> __weak _delegate;
    BOOL _onScreen;
    BOOL _leftSide;
    UIBlurEffectStyle _blur;
    float _windowLevel;
    BOOL _useSubMenu;
    BOOL _subMenuOnScreen;
}
#define SCREEN ([UIScreen mainScreen].bounds)
#define ANIMATION_DURATION (0.5)
@property (nonatomic, weak) id <MenuDelegate> delegate;
@property (readonly) BOOL onScreen;
@property (nonatomic, assign) BOOL leftSide; /*default YES, NO moves to right side of screen*/
@property (nonatomic, assign) UIBlurEffectStyle blur;
@property (nonatomic, assign) float windowLevel; /*default 1030*/
@property (nonatomic, assign) BOOL useSubMenu; /*default NO, YES creates a drop down submenu within the menu*/
@property (readonly) BOOL subMenuOnScreen;
+ (Menu*)sharedInstance;
- (void)addSwipeGestureToView:(UIView*)SlideView addTapGestureToView:(UIView*)TapView;
- (void)openMenuAnimate:(BOOL)animation;
- (void)closeMenuAnimate:(BOOL)animation;
- (void)openSubMenuAnimate:(BOOL)animation;
- (void)closeSubMenuAnimate:(BOOL)animation;
- (void)addSubview:(UIView*)view;
- (void)addSubviewToSubMenu:(UIView*)view;
@end
