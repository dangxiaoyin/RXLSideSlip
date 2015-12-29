//
//  UIViewController+RXLSideMenu.h
//  SideslipArchitecture
//
//  Created by renxiaolin on 14/11/10.
//  Copyright (c) 2014年 https://github.com/RenXLin/. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RXLSideSlipViewController.h"

@interface UIViewController (RXLSideMenu)


@property (strong, readonly, nonatomic) RXLSideSlipViewController *sideSlipVC;

// IB Action Helper methods

-(void)presentLeftMenuViewController;
-(void)presentRightMenuViewController;


@end
