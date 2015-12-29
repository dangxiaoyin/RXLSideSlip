//
//  RXLSideSlipViewController.h
//  SideslipArchitecture
//
//  Created by renxiaolin on 14/11/10.
//  Copyright (c) 2014年 https://github.com/RenXLin/. All rights reserved.
//

#import <UIKit/UIKit.h>


#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_6_1

#define IF_IOS7_OR_GREATER(...) \
if (kCFCoreFoundationVersionNumber > kCFCoreFoundationVersionNumber_iOS_6_1) \
{ \
__VA_ARGS__ \
}

#else

#define IF_IOS7_OR_GREATER(...)

#endif



@class RXLSideSlipViewController;

@protocol RXLSideMenuDelegate <NSObject>

@optional

- (void)sideMenu:(RXLSideSlipViewController *)sideMenu didRecognizePanGesture:(UIPanGestureRecognizer *)recognizer;

- (void)sideMenu:(RXLSideSlipViewController *)sideMenu willShowMenuViewController:(UIViewController *)menuViewController;

- (void)sideMenu:(RXLSideSlipViewController *)sideMenu didShowMenuViewController:(UIViewController *)menuViewController;

- (void)sideMenu:(RXLSideSlipViewController *)sideMenu willHideMenuViewController:(UIViewController *)menuViewController;

- (void)sideMenu:(RXLSideSlipViewController *)sideMenu didHideMenuViewController:(UIViewController *)menuViewController;

@end


@interface RXLSideSlipViewController : UIViewController<UIGestureRecognizerDelegate>


@property (strong, readwrite, nonatomic) UIViewController *contentViewController;
@property (strong, readwrite, nonatomic) UIViewController *leftMenuViewController;
@property (strong, readwrite, nonatomic) UIViewController *rightMenuViewController;
@property (weak, readwrite, nonatomic) id<RXLSideMenuDelegate> delegate;


//手势时间：
@property (assign, readwrite, nonatomic) NSTimeInterval animationDuration;
//背景图片：
@property (strong, readwrite, nonatomic) UIImage *backgroundImage;
//开启手势：
@property (assign, readwrite, nonatomic) BOOL panGestureEnabled;
//边缘检测手势：
@property (assign, readwrite, nonatomic) BOOL panFromEdge;
//滑动的阈值：
@property (assign, readwrite, nonatomic) NSUInteger panMinimumOpenThreshold;
//手势交互开启：
@property (assign, readwrite, nonatomic) IBInspectable BOOL interactivePopGestureRecognizerEnabled;

//菜单视图是否淡入淡出：
@property (assign, readwrite, nonatomic) IBInspectable BOOL fadeMenuView;
//滑动时是否缩放主视图：
@property (assign, readwrite, nonatomic) IBInspectable BOOL scaleContentView;
//是否缩放背景视图：
@property (assign, readwrite, nonatomic) IBInspectable BOOL scaleBackgroundImageView;
//是否缩放菜单视图：
@property (assign, readwrite, nonatomic) IBInspectable BOOL scaleMenuView;

@property (assign, readwrite, nonatomic) IBInspectable BOOL contentViewShadowEnabled;
@property (strong, readwrite, nonatomic) IBInspectable UIColor *contentViewShadowColor;
@property (assign, readwrite, nonatomic) IBInspectable CGSize contentViewShadowOffset;
@property (assign, readwrite, nonatomic) IBInspectable CGFloat contentViewShadowOpacity;
@property (assign, readwrite, nonatomic) IBInspectable CGFloat contentViewShadowRadius;
@property (assign, readwrite, nonatomic) IBInspectable CGFloat contentViewFadeOutAlpha;
@property (assign, readwrite, nonatomic) IBInspectable CGFloat contentViewScaleValue;

//横纵屏区分：
@property (assign, readwrite, nonatomic) IBInspectable CGFloat contentViewInLandscapeOffsetCenterX;
@property (assign, readwrite, nonatomic) IBInspectable CGFloat contentViewInPortraitOffsetCenterX;

//动作视图时的参数设置（iOS7以后有效）
@property (assign, readwrite, nonatomic) IBInspectable CGFloat parallaxMenuMinimumRelativeValue;
@property (assign, readwrite, nonatomic) IBInspectable CGFloat parallaxMenuMaximumRelativeValue;
@property (assign, readwrite, nonatomic) IBInspectable CGFloat parallaxContentMinimumRelativeValue;
@property (assign, readwrite, nonatomic) IBInspectable CGFloat parallaxContentMaximumRelativeValue;

@property (assign, readwrite, nonatomic) CGAffineTransform menuViewControllerTransformation;
@property (assign, readwrite, nonatomic) IBInspectable BOOL parallaxEnabled;
@property (assign, readwrite, nonatomic) IBInspectable BOOL bouncesHorizontally;

//当菜单打开后状态条statusBar的显示状态：
@property (assign, readwrite, nonatomic) UIStatusBarStyle menuPreferredStatusBarStyle;
@property (assign, readwrite, nonatomic) IBInspectable BOOL menuPrefersStatusBarHidden;
//是否隐藏主视图的状态条：
@property (assign, readwrite, nonatomic) IBInspectable BOOL contentPrefersStatusBarHidden;


- (id)initWithContentViewController:(UIViewController *)contentViewController
             leftMenuViewController:(UIViewController *)leftMenuViewController
            rightMenuViewController:(UIViewController *)rightMenuViewController;

- (void)presentLeftMenuViewController;

- (void)presentRightMenuViewController;

- (void)hideMenuViewController;

- (void)setContentViewController:(UIViewController *)contentViewController animated:(BOOL)animated;

@end
