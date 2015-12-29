//
//  UIViewController+RXLSideMenu.m
//  SideslipArchitecture
//
//  Created by renxiaolin on 14/11/10.
//  Copyright (c) 2014年 https://github.com/RenXLin/. All rights reserved.
//

#import "UIViewController+RXLSideMenu.h"

@implementation UIViewController (RXLSideMenu)

- (RXLSideSlipViewController *)sideSlipVC
{
    UIViewController *iter = self.parentViewController;
    while (iter) {
        if ([iter isKindOfClass:[RXLSideSlipViewController class]]) {
            return (RXLSideSlipViewController *)iter;
        } else if (iter.parentViewController && iter.parentViewController != iter) {
            iter = iter.parentViewController;
        } else {
            iter = nil;
        }
    }
    return nil;
}

#pragma mark -
#pragma mark IB Action Helper methods

- (void)presentLeftMenuViewController
{
    [self.sideSlipVC presentLeftMenuViewController];
}

- (void)presentRightMenuViewController
{
    [self.sideSlipVC presentRightMenuViewController];
}

@end
