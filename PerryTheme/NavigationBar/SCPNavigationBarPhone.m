//
//  SCPNavigationController.m
//  SimiCartPluginFW
//
//  Created by Hoang Van Trung on 4/18/18.
//  Copyright © 2018 Trueplus. All rights reserved.
//

#import "SCPNavigationBarPhone.h"
#import "SCPGlobalVars.h"

@implementation SCPNavigationBarPhone
@synthesize leftButtonItems = _leftButtonItems, rightButtonItems = _rightButtonItems;
- (NSMutableArray *)leftButtonItems{
    if (_leftButtonItems == nil) {
        _leftButtonItems = [[NSMutableArray alloc] init];
        
        UIButton *leftButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
        [leftButton setImage:[[UIImage imageNamed:@"ic_menu_perry"]imageWithColor:SCP_ICON_COLOR] forState:UIControlStateNormal];
        [leftButton addTarget:self action:@selector(openLeftMenu:) forControlEvents:UIControlEventTouchUpInside];
        [leftButton setAdjustsImageWhenHighlighted:YES];
        [leftButton setAdjustsImageWhenDisabled:YES];
        self.leftMenuItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
        self.leftMenuItem.sortOrder = navigationbar_phone_menu_sort_order;
        UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                           initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                           target:nil action:nil];
        negativeSpacer.width = -10;
        negativeSpacer.sortOrder = self.leftMenuItem.sortOrder - 10;
        [_leftButtonItems addObjectsFromArray:@[negativeSpacer, self.leftMenuItem]];
        [[NSNotificationCenter defaultCenter]postNotificationName:SCNavigationBarPhoneInitLeftItemsEnd object:self.leftButtonItems];
        _leftButtonItems = [[NSMutableArray alloc] initWithArray:[SimiGlobalFunction sortListItems:_leftButtonItems]];
    }
    return _leftButtonItems;
}

- (NSMutableArray *)rightButtonItems{
    if (_rightButtonItems == nil) {
        UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                           initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                           target:nil action:nil];
        negativeSpacer.width = -5;
        _rightButtonItems = [[NSMutableArray alloc] init];
        
        UIButton *cartButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
        [cartButton setImage:[[UIImage imageNamed:@"ic_cart_perry"] imageWithColor:SCP_ICON_COLOR] forState:UIControlStateNormal];
        [cartButton addTarget:self action:@selector(didSelectCartBarItem:) forControlEvents:UIControlEventTouchUpInside];
        
        self.cartItem = [[UIBarButtonItem alloc] initWithCustomView:cartButton];
        if (self.cartBadge == nil) {
            self.cartBadge = [[BBBadgeBarButtonItem alloc] initWithCustomUIButton:cartButton];
            self.cartBadge.shouldHideBadgeAtZero = YES;
            self.cartBadge.badgeValue = [NSString stringWithFormat:@"%ld",(long)GLOBALVAR.cart.total];
            self.cartBadge.badgeMinSize = 4;
            self.cartBadge.badgePadding = 4;
            self.cartBadge.badgeOriginX = cartButton.frame.size.width - 10;
            self.cartBadge.badgeOriginY = cartButton.frame.origin.y - 3;
            self.cartBadge.badgeFont = [UIFont fontWithName:THEME_FONT_NAME_REGULAR size:FONT_SIZE_SMALL];
            [self.cartBadge setTintColor:THEME_COLOR];
            self.cartBadge.badgeBGColor = THEME_NAVIGATION_ICON_COLOR;
            self.cartBadge.badgeTextColor = THEME_COLOR;
        }
        [_rightButtonItems addObjectsFromArray:@[negativeSpacer, self.cartItem]];
        self.cartItem.sortOrder = navigationbar_phone_cart_sort_order;
        negativeSpacer.sortOrder = self.cartItem.sortOrder - 10;
        [[NSNotificationCenter defaultCenter]postNotificationName:SCNavigationBarPhoneInitRightItemsEnd object:self.rightButtonItems userInfo:@{@"controller":self}];
        _rightButtonItems = [[NSMutableArray alloc] initWithArray:[SimiGlobalFunction sortListItems:_rightButtonItems]];
    }
    return _rightButtonItems;
}

#pragma mark Action
- (void)openLeftMenu:(id)sender{
    [kMainViewController showLeftViewAnimated:YES completionHandler:nil];
}

- (void)didSelectCartBarItem:(id)sender{
    UINavigationController *currentlyNavigationController = GLOBALVAR.currentlyNavigationController;
    [[SCAppController sharedInstance]openCartScreenWithNavigationController:currentlyNavigationController moreParams:@{}];
}

@end
