#A slide in menu build as a base for iOS.

######To impliment add the files Menu.h & Menu.m into your project and #import "Menu.h". For the delegate add <MenuDelegate> to your .h file

Menu is a base template for adding a sliding in Menu on top of all views. Menu also comes with a delegate to alert the user of core functions:

    - (void)menuDidOpen;
    - (void)menuDidClose;


In order to invoke Menu first assign the delegate if needed and then call as follows (Invoked by UIScreenEdgeSlideInGesture):

    [Menu sharedInstance].delegate = self;
    [Menu sharedInstance].leftSide = (BOOL for left or right side of screen);
    [Menu sharedInstance].blur = (UIBlurEffectStyle you wish to choose);
    [[Menu sharedInstance] addSwipeGestureToView:(UIView*)];

By calling - (void)addSwipeGestureToView:(UIView*)view; Menu is then built. If for any reasion you need to change the settigns of Menu call this function to update accordingly.

Menu can also be called by UIButtion with (Dismissed with a simular function see .h file):

    - (void)openMenuAnimate:(BOOL)animation;


Menu is dismissed by dragging the View off the screen of tapping on the part of the screen that isn't Menu.