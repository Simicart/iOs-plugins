//
//  AppWishlistiPadViewController.h
//  SimiCartPluginFW
//
//  Created by SimiCommerce on 12/9/14.
//  Copyright (c) 2014 Trueplus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCViewController_Pad.h"
#import "SCAppWishlistViewController_Pad.h"
#import "SCProductViewController_Pad.h"

@interface AppWishlistiPadViewController : SCViewController_Pad


@property (strong, nonatomic) SCAppWishlistViewController_Pad * appWishlistView;
@property (strong, nonatomic) SCProductViewController_Pad * productDetailView;
@property (strong, nonatomic) UIView * shareWishlistAnchor;
@property (strong, nonatomic) UIView *header;


- (void)didGetWishlist: (NSNotification *)noti;
- (void)createHeader;

@end
