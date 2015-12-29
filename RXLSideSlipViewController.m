//
//  RXLSideSlipViewController.m
//  SideslipArchitecture
//
//  Created by renxiaolin on 14/11/10.
//  Copyright (c) 2014年 https://github.com/RenXLin/. All rights reserved.

/*侧滑架构核心：自定义一个SideMenu视图控制器，在视图控制器中持有左右菜单控制器、主视图控制器
 将以上三个视图控制器加入到sidemenu视图控制器的childViewController。
 在自定义视图中添加 菜单视图和内容视图，将左右视图控制器的视图加入到菜单视图，将主视图控制器的
 视图加入到内容视图：
 给sideMenu视图控制器的视图添加pan手势：
 
 
 */

#import "RXLSideSlipViewController.h"
//#import "UIViewController+RESideMenu.h"
//#import "RECommonFunctions.h"



@interface RXLSideSlipViewController ()
@property (strong, readwrite, nonatomic) UIImageView *backgroundImageView;
@property (assign, readwrite, nonatomic) BOOL visible;
@property (assign, readwrite, nonatomic) BOOL leftMenuVisible;
@property (assign, readwrite, nonatomic) BOOL rightMenuVisible;
@property (assign, readwrite, nonatomic) CGPoint originalPoint;

//点击弹出主视图：
@property (strong, readwrite, nonatomic) UIButton *contentButton;
@property (strong, readwrite, nonatomic) UIView *menuViewContainer;
@property (strong, readwrite, nonatomic) UIView *contentViewContainer;
@property (assign, readwrite, nonatomic) BOOL didNotifyDelegate;


@end

@implementation RXLSideSlipViewController

- (id)init
{
    self = [super init];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super initWithCoder:decoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

#if __IPHONE_8_0
- (void)awakeFromNib
{
//    if (self.contentViewStoryboardID) {
//        self.contentViewController = [self.storyboard instantiateViewControllerWithIdentifier:self.contentViewStoryboardID];
//    }
//    if (self.leftMenuViewStoryboardID) {
//        self.leftMenuViewController = [self.storyboard instantiateViewControllerWithIdentifier:self.leftMenuViewStoryboardID];
//    }
//    if (self.rightMenuViewStoryboardID) {
//        self.rightMenuViewController = [self.storyboard instantiateViewControllerWithIdentifier:self.rightMenuViewStoryboardID];
//    }
}
#endif

- (void)commonInit
{
    _menuViewContainer = [[UIView alloc] init];
    _contentViewContainer = [[UIView alloc] init];
    
    //动画时间
    _animationDuration = 0.35f;
    
    _interactivePopGestureRecognizerEnabled = YES;
    
    //菜单试图变大动画设置：
    _menuViewControllerTransformation = CGAffineTransformMakeScale(1.5f, 1.5f);
    self.menuPrefersStatusBarHidden = NO;
    self.contentPrefersStatusBarHidden = YES;
    self.menuPreferredStatusBarStyle = UIStatusBarStyleLightContent;

    //缩放主视图：
    _scaleContentView = YES;
    //缩放背景视图：
    _scaleBackgroundImageView = NO;
    //缩放菜单视图：
    _scaleMenuView = YES;
    //淡入淡出菜单视图：
    _fadeMenuView = YES;
    
    //运动视觉效果（iOS7 以上设备支持）（当设备随着空间移动时，视图也将跟着移动）：
    _parallaxEnabled = YES;
    _parallaxMenuMinimumRelativeValue = -20;
    _parallaxMenuMaximumRelativeValue = 20;
    _parallaxContentMinimumRelativeValue = -15;
    _parallaxContentMaximumRelativeValue = 15;
    
    //开启弹性效果
    _bouncesHorizontally = YES;
    
    //开启滑动手指
    _panGestureEnabled = YES;
    //是否仅支持边沿滑动手势：
    _panFromEdge = YES;
    //滑动后切换页面的阈值：
    _panMinimumOpenThreshold = 80.0;
    
    //主视图显示阴影：
    _contentViewShadowEnabled = YES;
    _contentViewShadowColor = [UIColor blackColor];
    _contentViewShadowOffset = CGSizeMake(10, 10);
    _contentViewShadowOpacity = 0.4f;
    _contentViewShadowRadius = 8.0f;
    _contentViewFadeOutAlpha = 0.7f;
    _contentViewInLandscapeOffsetCenterX = 5.0f;
    _contentViewInPortraitOffsetCenterX  = 30.f;
    _contentViewScaleValue = 0.7f;
}

- (id)initWithContentViewController:(UIViewController *)contentViewController leftMenuViewController:(UIViewController *)leftMenuViewController rightMenuViewController:(UIViewController *)rightMenuViewController
{
    self = [self init];
    if (self) {
        _contentViewController = contentViewController;
        _leftMenuViewController = leftMenuViewController;
        _rightMenuViewController = rightMenuViewController;
    }
    return self;
}










- (void)presentLeftMenuViewController
{
    [self presentMenuViewContainerWithMenuViewController:self.leftMenuViewController];
    [self showLeftMenuViewController];
}

- (void)presentRightMenuViewController
{
    [self presentMenuViewContainerWithMenuViewController:self.rightMenuViewController];
    [self showRightMenuViewController];
}

- (void)hideMenuViewController
{
    [self hideMenuViewControllerAnimated:YES];
}

- (void)setContentViewController:(UIViewController *)contentViewController animated:(BOOL)animated
{
    if (_contentViewController == contentViewController)
    {
        return;
    }
    
    if (!animated) {
        [self setContentViewController:contentViewController];
    } else {
        [self addChildViewController:contentViewController];
        contentViewController.view.alpha = 0;
        contentViewController.view.frame = self.contentViewContainer.bounds;
        [self.contentViewContainer addSubview:contentViewController.view];
        [UIView animateWithDuration:self.animationDuration animations:^{
            contentViewController.view.alpha = 1;
        } completion:^(BOOL finished) {
            [self hideViewController:self.contentViewController];
            [contentViewController didMoveToParentViewController:self];
            _contentViewController = contentViewController;
            
            [self statusBarNeedsAppearanceUpdate];
            [self updateContentViewShadow];
            
            if (self.visible) {
                [self addContentViewControllerMotionEffects];
            }
        }];
    }
}

#pragma mark View life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.backgroundImageView = ({
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
        imageView.image = self.backgroundImage;
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        imageView;
    });
    
    self.contentButton = ({
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectNull];
        [button addTarget:self action:@selector(hideMenuViewController) forControlEvents:UIControlEventTouchUpInside];
        button;
    });
    
    [self.view addSubview:self.backgroundImageView];
    [self.view addSubview:self.menuViewContainer];
    [self.view addSubview:self.contentViewContainer];
    
    //1设置menuViewContainer frame：并加入菜单控制器视图：
    self.menuViewContainer.frame = self.view.bounds;
    self.menuViewContainer.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    if (self.leftMenuViewController) {
        [self addChildViewController:self.leftMenuViewController];
        self.leftMenuViewController.view.frame = self.view.bounds;
        self.leftMenuViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.menuViewContainer addSubview:self.leftMenuViewController.view];
        //当我们向我们的视图控制器容器中添加（或者删除）子视图控制器后，必须调用该方法，告诉iOS，已经完成添加（或删除）子控制器的操作
        //removeFromParentViewController 方法会自动调用了该方法，所以，删除子控制器后，不需要在显示的调用该方法了.
        [self.leftMenuViewController didMoveToParentViewController:self];
    }
    
    if (self.rightMenuViewController) {
        [self addChildViewController:self.rightMenuViewController];
        self.rightMenuViewController.view.frame = self.view.bounds;
        self.rightMenuViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.menuViewContainer addSubview:self.rightMenuViewController.view];
        [self.rightMenuViewController didMoveToParentViewController:self];
    }
    
    //2设置contentView frame：并加入主控制器视图：
    self.contentViewContainer.frame = self.view.bounds;
    self.contentViewContainer.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addChildViewController:self.contentViewController];
    self.contentViewController.view.frame = self.view.bounds;
    [self.contentViewContainer addSubview:self.contentViewController.view];
    [self.contentViewController didMoveToParentViewController:self];
    
    self.menuViewContainer.alpha = !self.fadeMenuView ?: 0;
    if (self.scaleBackgroundImageView)
        self.backgroundImageView.transform = CGAffineTransformMakeScale(1.7f, 1.7f);
    
    //3.菜单视图加入运动视觉效果：
    [self addMenuViewControllerMotionEffects];
    
    //4.加入pan滑动手势：
    if (self.panGestureEnabled) {
        self.view.multipleTouchEnabled = NO;
        UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognized:)];
        panGestureRecognizer.delegate = self;
        [self.view addGestureRecognizer:panGestureRecognizer];
    }
    
    //5.设置shadow
    [self updateContentViewShadow];
}

#pragma mark -
#pragma mark Private methods

- (void)presentMenuViewContainerWithMenuViewController:(UIViewController *)menuViewController
{
    self.menuViewContainer.transform = CGAffineTransformIdentity;
    if (self.scaleBackgroundImageView) {
        self.backgroundImageView.transform = CGAffineTransformIdentity;
        self.backgroundImageView.frame = self.view.bounds;
    }
    self.menuViewContainer.frame = self.view.bounds;
    if (self.scaleMenuView) {
        self.menuViewContainer.transform = self.menuViewControllerTransformation;
    }
    self.menuViewContainer.alpha = !self.fadeMenuView ?: 0;
    if (self.scaleBackgroundImageView)
        self.backgroundImageView.transform = CGAffineTransformMakeScale(1.7f, 1.7f);
    
    if ([self.delegate conformsToProtocol:@protocol(RXLSideMenuDelegate)] && [self.delegate respondsToSelector:@selector(sideMenu:willShowMenuViewController:)]) {
        [self.delegate sideMenu:self willShowMenuViewController:menuViewController];
    }
}

- (void)showLeftMenuViewController
{
    if (!self.leftMenuViewController) {
        return;
    }
    self.leftMenuViewController.view.hidden = NO;
    self.rightMenuViewController.view.hidden = YES;
    [self.view.window endEditing:YES];
    [self addContentButton];
    [self updateContentViewShadow];
    [self resetContentViewScale];
    
    [UIView animateWithDuration:self.animationDuration animations:^{
        if (self.scaleContentView) {
            self.contentViewContainer.transform = CGAffineTransformMakeScale(self.contentViewScaleValue, self.contentViewScaleValue);
        } else {
            self.contentViewContainer.transform = CGAffineTransformIdentity;
        }
        
        if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_7_1) {
            self.contentViewContainer.center = CGPointMake((UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]) ? self.contentViewInLandscapeOffsetCenterX + CGRectGetWidth(self.view.frame) : self.contentViewInPortraitOffsetCenterX + CGRectGetWidth(self.view.frame)), self.contentViewContainer.center.y);
        } else {
            self.contentViewContainer.center = CGPointMake((UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]) ? self.contentViewInLandscapeOffsetCenterX + CGRectGetHeight(self.view.frame) : self.contentViewInPortraitOffsetCenterX + CGRectGetWidth(self.view.frame)), self.contentViewContainer.center.y);
        }
        
        self.menuViewContainer.alpha = !self.fadeMenuView ?: 1.0f;
        self.contentViewContainer.alpha = self.contentViewFadeOutAlpha;
        self.menuViewContainer.transform = CGAffineTransformIdentity;
        if (self.scaleBackgroundImageView)
            self.backgroundImageView.transform = CGAffineTransformIdentity;
        
    } completion:^(BOOL finished) {
        [self addContentViewControllerMotionEffects];
        
        if (!self.visible && [self.delegate conformsToProtocol:@protocol(RXLSideMenuDelegate)] && [self.delegate respondsToSelector:@selector(sideMenu:didShowMenuViewController:)]) {
            [self.delegate sideMenu:self didShowMenuViewController:self.leftMenuViewController];
        }
        
        self.visible = YES;
        self.leftMenuVisible = YES;
    }];
    
    [self statusBarNeedsAppearanceUpdate];
}

- (void)showRightMenuViewController
{
    if (!self.rightMenuViewController) {
        return;
    }
    self.leftMenuViewController.view.hidden = YES;
    self.rightMenuViewController.view.hidden = NO;
    [self.view.window endEditing:YES];
    [self addContentButton];
    [self updateContentViewShadow];
    [self resetContentViewScale];
    
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    [UIView animateWithDuration:self.animationDuration animations:^{
        if (self.scaleContentView) {
            self.contentViewContainer.transform = CGAffineTransformMakeScale(self.contentViewScaleValue, self.contentViewScaleValue);
        } else {
            self.contentViewContainer.transform = CGAffineTransformIdentity;
        }
        self.contentViewContainer.center = CGPointMake((UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]) ? -self.contentViewInLandscapeOffsetCenterX : -self.contentViewInPortraitOffsetCenterX), self.contentViewContainer.center.y);
        
        self.menuViewContainer.alpha = !self.fadeMenuView ?: 1.0f;
        self.contentViewContainer.alpha = self.contentViewFadeOutAlpha;
        self.menuViewContainer.transform = CGAffineTransformIdentity;
        if (self.scaleBackgroundImageView)
            self.backgroundImageView.transform = CGAffineTransformIdentity;
        
    } completion:^(BOOL finished) {
        if (!self.rightMenuVisible && [self.delegate conformsToProtocol:@protocol(RXLSideMenuDelegate)] && [self.delegate respondsToSelector:@selector(sideMenu:didShowMenuViewController:)]) {
            [self.delegate sideMenu:self didShowMenuViewController:self.rightMenuViewController];
        }
        
        self.visible = !(self.contentViewContainer.frame.size.width == self.view.bounds.size.width && self.contentViewContainer.frame.size.height == self.view.bounds.size.height && self.contentViewContainer.frame.origin.x == 0 && self.contentViewContainer.frame.origin.y == 0);
        self.rightMenuVisible = self.visible;
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        [self addContentViewControllerMotionEffects];
    }];
    
    [self statusBarNeedsAppearanceUpdate];
}

- (void)hideViewController:(UIViewController *)viewController
{
    [viewController willMoveToParentViewController:nil];
    [viewController.view removeFromSuperview];
    [viewController removeFromParentViewController];
}

- (void)hideMenuViewControllerAnimated:(BOOL)animated
{
    BOOL rightMenuVisible = self.rightMenuVisible;
    if ([self.delegate conformsToProtocol:@protocol(RXLSideMenuDelegate)] && [self.delegate respondsToSelector:@selector(sideMenu:willHideMenuViewController:)]) {
        [self.delegate sideMenu:self willHideMenuViewController:rightMenuVisible ? self.rightMenuViewController : self.leftMenuViewController];
    }
    
    self.visible = NO;
    self.leftMenuVisible = NO;
    self.rightMenuVisible = NO;
    [self.contentButton removeFromSuperview];
    
    __typeof (self) __weak weakSelf = self;
    void (^animationBlock)(void) = ^{
        __typeof (weakSelf) __strong strongSelf = weakSelf;
        if (!strongSelf) {
            return;
        }
        strongSelf.contentViewContainer.transform = CGAffineTransformIdentity;
        strongSelf.contentViewContainer.frame = strongSelf.view.bounds;
        if (strongSelf.scaleMenuView) {
            strongSelf.menuViewContainer.transform = strongSelf.menuViewControllerTransformation;
        }
        strongSelf.menuViewContainer.alpha = !self.fadeMenuView ?: 0;
        strongSelf.contentViewContainer.alpha = 1;
        
        if (strongSelf.scaleBackgroundImageView) {
            strongSelf.backgroundImageView.transform = CGAffineTransformMakeScale(1.7f, 1.7f);
        }
        if (strongSelf.parallaxEnabled) {
            IF_IOS7_OR_GREATER(
                               for (UIMotionEffect *effect in strongSelf.contentViewContainer.motionEffects) {
                                   [strongSelf.contentViewContainer removeMotionEffect:effect];
                               }
                               );
        }
    };
    void (^completionBlock)(void) = ^{
        __typeof (weakSelf) __strong strongSelf = weakSelf;
        if (!strongSelf) {
            return;
        }
        if (!strongSelf.visible && [strongSelf.delegate conformsToProtocol:@protocol(RXLSideMenuDelegate)] && [strongSelf.delegate respondsToSelector:@selector(sideMenu:didHideMenuViewController:)]) {
            [strongSelf.delegate sideMenu:strongSelf didHideMenuViewController:rightMenuVisible ? strongSelf.rightMenuViewController : strongSelf.leftMenuViewController];
        }
    };
    
    if (animated) {
        [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
        [UIView animateWithDuration:self.animationDuration animations:^{
            animationBlock();
        } completion:^(BOOL finished) {
            [[UIApplication sharedApplication] endIgnoringInteractionEvents];
            completionBlock();
        }];
    } else {
        animationBlock();
        completionBlock();
    }
    [self statusBarNeedsAppearanceUpdate];
}

- (void)addContentButton
{
    if (self.contentButton.superview)
        return;
    
    self.contentButton.autoresizingMask = UIViewAutoresizingNone;
    self.contentButton.frame = self.contentViewContainer.bounds;
    self.contentButton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.contentViewContainer addSubview:self.contentButton];
}

- (void)statusBarNeedsAppearanceUpdate
{
    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
        [UIView animateWithDuration:0.3f animations:^{
            [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
        }];
    }
}

- (void)updateContentViewShadow
{
    if (self.contentViewShadowEnabled) {
        CALayer *layer = self.contentViewContainer.layer;
        UIBezierPath *path = [UIBezierPath bezierPathWithRect:layer.bounds];
        layer.shadowPath = path.CGPath;
        layer.shadowColor = self.contentViewShadowColor.CGColor;
        layer.shadowOffset = self.contentViewShadowOffset;
        layer.shadowOpacity = self.contentViewShadowOpacity;
        layer.shadowRadius = self.contentViewShadowRadius;
    }
}

- (void)resetContentViewScale
{
    CGAffineTransform t = self.contentViewContainer.transform;
    CGFloat scale = sqrt(t.a * t.a + t.c * t.c);
    CGRect frame = self.contentViewContainer.frame;
    self.contentViewContainer.transform = CGAffineTransformIdentity;
    self.contentViewContainer.transform = CGAffineTransformMakeScale(scale, scale);
    self.contentViewContainer.frame = frame;
}

#pragma mark -
#pragma mark iOS 7 Motion Effects (Private)

- (void)addMenuViewControllerMotionEffects
{
    //ios7以上设备加入运动视觉效果（当设备随着空间移动时，视图也将跟着移动）
    if (self.parallaxEnabled) {
        IF_IOS7_OR_GREATER(
                           for (UIMotionEffect *effect in self.menuViewContainer.motionEffects) {
                               [self.menuViewContainer removeMotionEffect:effect];
                           }
                           UIInterpolatingMotionEffect *interpolationHorizontal = [[UIInterpolatingMotionEffect alloc]initWithKeyPath:@"center.x" type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
                           interpolationHorizontal.minimumRelativeValue = @(self.parallaxMenuMinimumRelativeValue);
                           interpolationHorizontal.maximumRelativeValue = @(self.parallaxMenuMaximumRelativeValue);
                           
                           UIInterpolatingMotionEffect *interpolationVertical = [[UIInterpolatingMotionEffect alloc]initWithKeyPath:@"center.y" type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
                           interpolationVertical.minimumRelativeValue = @(self.parallaxMenuMinimumRelativeValue);
                           interpolationVertical.maximumRelativeValue = @(self.parallaxMenuMaximumRelativeValue);
                           
                           
                           [self.menuViewContainer addMotionEffect:interpolationHorizontal];
                           [self.menuViewContainer addMotionEffect:interpolationVertical];
                           );
    }
}

- (void)addContentViewControllerMotionEffects
{
    if (self.parallaxEnabled) {
        IF_IOS7_OR_GREATER(
                           for (UIMotionEffect *effect in self.contentViewContainer.motionEffects) {
                               [self.contentViewContainer removeMotionEffect:effect];
                           }
                           [UIView animateWithDuration:0.2 animations:^{
            UIInterpolatingMotionEffect *interpolationHorizontal = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.x" type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
            interpolationHorizontal.minimumRelativeValue = @(self.parallaxContentMinimumRelativeValue);
            interpolationHorizontal.maximumRelativeValue = @(self.parallaxContentMaximumRelativeValue);
            
            UIInterpolatingMotionEffect *interpolationVertical = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.y" type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
            interpolationVertical.minimumRelativeValue = @(self.parallaxContentMinimumRelativeValue);
            interpolationVertical.maximumRelativeValue = @(self.parallaxContentMaximumRelativeValue);
            
            [self.contentViewContainer addMotionEffect:interpolationHorizontal];
            [self.contentViewContainer addMotionEffect:interpolationVertical];
        }];
                           );
    }
}

#pragma mark -
#pragma mark UIGestureRecognizer Delegate (Private) pan手势代理
//当主视图为导航控制器，且有其他视图控制器退出时，关闭pan手势：
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    IF_IOS7_OR_GREATER(
                       //此处待改动：if([self.contentViewController isKindOfClass:[UINavigationController class]])
                       if (self.interactivePopGestureRecognizerEnabled && [self.contentViewController isKindOfClass:[UINavigationController class]]) {
                           UINavigationController *navigationController = (UINavigationController *)self.contentViewController;
                           if (navigationController.viewControllers.count > 1 && navigationController.interactivePopGestureRecognizer.enabled) {
                               return NO;
                           }
                       }
                       );
    
    if (self.panFromEdge && [gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]] && !self.visible) {
        CGPoint point = [touch locationInView:gestureRecognizer.view];
        /**  滑动手势范围 */
        if (point.x < 150.0 || point.x > self.view.frame.size.width - 150.0) {
            return YES;
        } else {
            return NO;
        }
    }
    
    return YES;
}

#pragma mark -
#pragma mark Pan gesture recognizer (Private)

- (void)panGestureRecognized:(UIPanGestureRecognizer *)recognizer
{
    if ([self.delegate conformsToProtocol:@protocol(RXLSideMenuDelegate)] && [self.delegate respondsToSelector:@selector(sideMenu:didRecognizePanGesture:)])
        [self.delegate sideMenu:self didRecognizePanGesture:recognizer];
    
    if (!self.panGestureEnabled) {
        return;
    }
    
    CGPoint point = [recognizer translationInView:self.view];
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        [self updateContentViewShadow];
        
        //获取当前contentView的original。
        self.originalPoint = CGPointMake(self.contentViewContainer.center.x - CGRectGetWidth(self.contentViewContainer.bounds) / 2.0,
                                         self.contentViewContainer.center.y - CGRectGetHeight(self.contentViewContainer.bounds) / 2.0);
        
        //将transform置为起始状态：否则每次变化将是以上一次变化为的坐标系统：
        self.menuViewContainer.transform = CGAffineTransformIdentity;
        if (self.scaleBackgroundImageView) {
            self.backgroundImageView.transform = CGAffineTransformIdentity;
            self.backgroundImageView.frame = self.view.bounds;
        }
        self.menuViewContainer.frame = self.view.bounds;
        [self addContentButton];
        //关闭textfield：
        [self.view.window endEditing:YES];
        self.didNotifyDelegate = NO;
    }
    
    if (recognizer.state == UIGestureRecognizerStateChanged) {
        CGFloat delta = 0;
        if (self.visible) {
            delta = self.originalPoint.x != 0 ? (point.x + self.originalPoint.x) / self.originalPoint.x : 0;
        } else {
            delta = point.x / self.view.frame.size.width;
        }
        delta = MIN(fabs(delta), 1.6);
        
        CGFloat contentViewScale = self.scaleContentView ? 1 - ((1 - self.contentViewScaleValue) * delta) : 1;
        
        CGFloat backgroundViewScale = 1.5f - (0.5f * delta);
        CGFloat menuViewScale = 1.5f - (0.5f * delta);
        
        if (!self.bouncesHorizontally) {
            contentViewScale = MAX(contentViewScale, self.contentViewScaleValue);
            backgroundViewScale = MAX(backgroundViewScale, 1.0);
            menuViewScale = MAX(menuViewScale, 1.0);
        }
        
        self.menuViewContainer.alpha = !self.fadeMenuView ?: delta;
        self.contentViewContainer.alpha = 1 - (1 - self.contentViewFadeOutAlpha) * delta;
        
        if (self.scaleBackgroundImageView) {
            self.backgroundImageView.transform = CGAffineTransformMakeScale(backgroundViewScale, backgroundViewScale);
        }
        
        if (self.scaleMenuView) {
            self.menuViewContainer.transform = CGAffineTransformMakeScale(menuViewScale, menuViewScale);
        }
        
        if (self.scaleBackgroundImageView) {
            if (backgroundViewScale < 1) {
                self.backgroundImageView.transform = CGAffineTransformIdentity;
            }
        }
        
        if (!self.bouncesHorizontally && self.visible) {
            if (self.contentViewContainer.frame.origin.x > self.contentViewContainer.frame.size.width / 2.0)
                point.x = MIN(0.0, point.x);
            
            if (self.contentViewContainer.frame.origin.x < -(self.contentViewContainer.frame.size.width / 2.0))
                point.x = MAX(0.0, point.x);
        }
        
        // Limit size
        //
        if (point.x < 0) {
            point.x = MAX(point.x, -[UIScreen mainScreen].bounds.size.height);
        } else {
            point.x = MIN(point.x, [UIScreen mainScreen].bounds.size.height);
        }
        [recognizer setTranslation:point inView:self.view];
        
        if (!self.didNotifyDelegate) {
            if (point.x > 0) {
                if (!self.visible && [self.delegate conformsToProtocol:@protocol(RXLSideMenuDelegate)] && [self.delegate respondsToSelector:@selector(sideMenu:willShowMenuViewController:)]) {
                    [self.delegate sideMenu:self willShowMenuViewController:self.leftMenuViewController];
                }
            }
            if (point.x < 0) {
                if (!self.visible && [self.delegate conformsToProtocol:@protocol(RXLSideMenuDelegate)] && [self.delegate respondsToSelector:@selector(sideMenu:willShowMenuViewController:)]) {
                    [self.delegate sideMenu:self willShowMenuViewController:self.rightMenuViewController];
                }
            }
            self.didNotifyDelegate = YES;
        }
        
        if (contentViewScale > 1) {
            CGFloat oppositeScale = (1 - (contentViewScale - 1));
            self.contentViewContainer.transform = CGAffineTransformMakeScale(oppositeScale, oppositeScale);
            self.contentViewContainer.transform = CGAffineTransformTranslate(self.contentViewContainer.transform, point.x, 0);
        } else {
            self.contentViewContainer.transform = CGAffineTransformMakeScale(contentViewScale, contentViewScale);
            self.contentViewContainer.transform = CGAffineTransformTranslate(self.contentViewContainer.transform, point.x, 0);
        }
        
        self.leftMenuViewController.view.hidden = self.contentViewContainer.frame.origin.x < 0;
        self.rightMenuViewController.view.hidden = self.contentViewContainer.frame.origin.x > 0;
        
        if (!self.leftMenuViewController && self.contentViewContainer.frame.origin.x > 0) {
            self.contentViewContainer.transform = CGAffineTransformIdentity;
            self.contentViewContainer.frame = self.view.bounds;
            self.visible = NO;
            self.leftMenuVisible = NO;
        } else  if (!self.rightMenuViewController && self.contentViewContainer.frame.origin.x < 0) {
            self.contentViewContainer.transform = CGAffineTransformIdentity;
            self.contentViewContainer.frame = self.view.bounds;
            self.visible = NO;
            self.rightMenuVisible = NO;
        }
        
        [self statusBarNeedsAppearanceUpdate];
    }
    
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        self.didNotifyDelegate = NO;
        if (self.panMinimumOpenThreshold > 0 && (
                                                 (self.contentViewContainer.frame.origin.x < 0 && self.contentViewContainer.frame.origin.x > -((NSInteger)self.panMinimumOpenThreshold)) ||
                                                 (self.contentViewContainer.frame.origin.x > 0 && self.contentViewContainer.frame.origin.x < self.panMinimumOpenThreshold))
            ) {
            [self hideMenuViewController];
        }
        else if (self.contentViewContainer.frame.origin.x == 0) {
            [self hideMenuViewControllerAnimated:NO];
        }
        else {
            if ([recognizer velocityInView:self.view].x > 0) {
                if (self.contentViewContainer.frame.origin.x < 0) {
                    [self hideMenuViewController];
                } else {
                    if (self.leftMenuViewController) {
                        [self showLeftMenuViewController];
                    }
                }
            } else {
                if (self.contentViewContainer.frame.origin.x < 20) {
                    if (self.rightMenuViewController) {
                        [self showRightMenuViewController];
                    }
                } else {
                    [self hideMenuViewController];
                }
            }
        }
    }
}

#pragma mark -
#pragma mark Setters

- (void)setBackgroundImage:(UIImage *)backgroundImage
{
    _backgroundImage = backgroundImage;
    if (self.backgroundImageView)
        self.backgroundImageView.image = backgroundImage;
}

- (void)setContentViewController:(UIViewController *)contentViewController
{
    if (!_contentViewController) {
        _contentViewController = contentViewController;
        return;
    }
    [self hideViewController:_contentViewController];
    _contentViewController = contentViewController;
    
    [self addChildViewController:self.contentViewController];
    self.contentViewController.view.frame = self.view.bounds;
    [self.contentViewContainer addSubview:self.contentViewController.view];
    [self.contentViewController didMoveToParentViewController:self];
    
    [self updateContentViewShadow];
    
    if (self.visible) {
        [self addContentViewControllerMotionEffects];
    }
}

- (void)setLeftMenuViewController:(UIViewController *)leftMenuViewController
{
    if (!_leftMenuViewController) {
        _leftMenuViewController = leftMenuViewController;
        return;
    }
    [self hideViewController:_leftMenuViewController];
    _leftMenuViewController = leftMenuViewController;
    
    [self addChildViewController:self.leftMenuViewController];
    self.leftMenuViewController.view.frame = self.view.bounds;
    self.leftMenuViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.menuViewContainer addSubview:self.leftMenuViewController.view];
    [self.leftMenuViewController didMoveToParentViewController:self];
    
    [self addMenuViewControllerMotionEffects];
    [self.view bringSubviewToFront:self.contentViewContainer];
}

- (void)setRightMenuViewController:(UIViewController *)rightMenuViewController
{
    if (!_rightMenuViewController) {
        _rightMenuViewController = rightMenuViewController;
        return;
    }
    [self hideViewController:_rightMenuViewController];
    _rightMenuViewController = rightMenuViewController;
    
    [self addChildViewController:self.rightMenuViewController];
    self.rightMenuViewController.view.frame = self.view.bounds;
    self.rightMenuViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.menuViewContainer addSubview:self.rightMenuViewController.view];
    [self.rightMenuViewController didMoveToParentViewController:self];
    
    [self addMenuViewControllerMotionEffects];
    [self.view bringSubviewToFront:self.contentViewContainer];
}

#pragma mark -
#pragma mark View Controller Rotation handler

- (BOOL)shouldAutorotate
{
    return self.contentViewController.shouldAutorotate;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if (self.visible) {
        self.menuViewContainer.bounds = self.view.bounds;
        self.contentViewContainer.transform = CGAffineTransformIdentity;
        self.contentViewContainer.frame = self.view.bounds;
        
        if (self.scaleContentView) {
            self.contentViewContainer.transform = CGAffineTransformMakeScale(self.contentViewScaleValue, self.contentViewScaleValue);
        } else {
            self.contentViewContainer.transform = CGAffineTransformIdentity;
        }
        
        CGPoint center;
        if (self.leftMenuVisible) {
            if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_7_1) {
                center = CGPointMake((UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation) ? self.contentViewInLandscapeOffsetCenterX + CGRectGetWidth(self.view.frame) : self.contentViewInPortraitOffsetCenterX + CGRectGetWidth(self.view.frame)), self.contentViewContainer.center.y);
            } else {
                center = CGPointMake((UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation) ? self.contentViewInLandscapeOffsetCenterX + CGRectGetHeight(self.view.frame) : self.contentViewInPortraitOffsetCenterX + CGRectGetWidth(self.view.frame)), self.contentViewContainer.center.y);
            }
        } else {
            center = CGPointMake((UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation) ? -self.contentViewInLandscapeOffsetCenterX : -self.contentViewInPortraitOffsetCenterX), self.contentViewContainer.center.y);
        }
        
        self.contentViewContainer.center = center;
    }
    
    [self updateContentViewShadow];
}

#pragma mark -
#pragma mark Status Bar Appearance Management

- (UIStatusBarStyle)preferredStatusBarStyle
{
    UIStatusBarStyle statusBarStyle = UIStatusBarStyleDefault;
    IF_IOS7_OR_GREATER(
                       statusBarStyle = self.visible ? self.menuPreferredStatusBarStyle : self.contentViewController.preferredStatusBarStyle;
                       if (self.contentViewContainer.frame.origin.y > 10) {
                           statusBarStyle = self.menuPreferredStatusBarStyle;
                       } else {
                           statusBarStyle = self.contentViewController.preferredStatusBarStyle;
                       }
                       );
    return statusBarStyle;
}

- (BOOL)prefersStatusBarHidden
{
    BOOL statusBarHidden = NO;
    IF_IOS7_OR_GREATER(
    statusBarHidden = self.visible ? self.menuPrefersStatusBarHidden : self.contentViewController.prefersStatusBarHidden;
    if (self.contentViewContainer.frame.origin.y > 10) {
            statusBarHidden = self.menuPrefersStatusBarHidden;
        } else {
//            statusBarHidden = self.contentViewController.prefersStatusBarHidden;
            statusBarHidden = self.contentPrefersStatusBarHidden;
        }
    );
    return statusBarHidden;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation
{
    UIStatusBarAnimation statusBarAnimation = UIStatusBarAnimationNone;
    IF_IOS7_OR_GREATER(
                       statusBarAnimation = self.visible ? self.leftMenuViewController.preferredStatusBarUpdateAnimation : self.contentViewController.preferredStatusBarUpdateAnimation;
                       if (self.contentViewContainer.frame.origin.y > 10) {
                           statusBarAnimation = self.leftMenuViewController.preferredStatusBarUpdateAnimation;
                       } else {
                           statusBarAnimation = self.contentViewController.preferredStatusBarUpdateAnimation;
                       }
                       );
    return statusBarAnimation;
}




/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
