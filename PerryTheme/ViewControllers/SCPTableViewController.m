//
//  SCPTableViewController.m
//  SimiCartPluginFW
//
//  Created by Hoang Van Trung on 5/2/18.
//  Copyright © 2018 Trueplus. All rights reserved.
//

#import "SCPTableViewController.h"
#import "SCPGlobalVars.h"

@interface SCPTableViewController ()

@end

@implementation SCPTableViewController

- (void)configureNavigationBarOnViewWillAppear{
    if (PHONEDEVICE) {
        if (_leftButtonItems == nil) {
            _leftButtonItems = [[NSMutableArray alloc] init];
            [self addMenuButton];
            [[NSNotificationCenter defaultCenter]postNotificationName:SCNavigationBarPhoneInitLeftItemsEnd object:_leftButtonItems];
            _leftButtonItems = [[NSMutableArray alloc] initWithArray:[SimiGlobalFunction sortListItems:_leftButtonItems]];
        }
        [self addBackButton];
        [self.navigationItem setLeftBarButtonItems:_leftButtonItems];
        if (_rightButtonItems == nil) {
            _rightButtonItems = [[NSMutableArray alloc] init];
            [self addCartButton];
            [[NSNotificationCenter defaultCenter]postNotificationName:SCNavigationBarPhoneInitRightItemsEnd object:self.rightButtonItems userInfo:@{@"controller":self}];
            _rightButtonItems = [[NSMutableArray alloc] initWithArray:[SimiGlobalFunction sortListItems:_rightButtonItems]];
        }
        self.navigationItem.rightBarButtonItems = _rightButtonItems;
    }else
    {
        [self.navigationItem setLeftBarButtonItems:[[[SCAppController sharedInstance]navigationBarPad]leftButtonItems]];
        self.navigationItem.rightBarButtonItems = [[[SCAppController sharedInstance]navigationBarPad]rightButtonItems];
    }
}
- (void)addMenuButton{
    UIButton *leftButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
    [leftButton setImage:[[UIImage imageNamed:@"scp_ic_menu"]imageWithColor:SCP_ICON_COLOR] forState:UIControlStateNormal];
    [leftButton setImageEdgeInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
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
}

- (void)addBackButton{
    if (![self.navigationController.viewControllers.firstObject isEqual:self]) {
        UIBarButtonItem *firstItem = [_leftButtonItems objectAtIndex:1];
        if (![firstItem.simiObjectName isEqualToString:@"back_button"]) {
            UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 44)];
            backButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
            [backButton setImage:[[UIImage imageNamed:@"scp_ic_back"] imageWithColor:SCP_ICON_COLOR] forState:UIControlStateNormal];
            [backButton setImageEdgeInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
            [backButton addTarget:self action:@selector(didSelectBackBarItem:) forControlEvents:UIControlEventTouchUpInside];
            UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
            backItem.simiObjectName = @"back_button";
            [_leftButtonItems insertObject:backItem atIndex:1];
        }else
        {
            [_leftButtonItems removeObjectAtIndex:1];
            UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 44)];
            [backButton setImage:[[UIImage imageNamed:@"scp_ic_back"] imageWithColor:SCP_ICON_COLOR] forState:UIControlStateNormal];
            [backButton addTarget:self action:@selector(didSelectBackBarItem:) forControlEvents:UIControlEventTouchUpInside];
            UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
            backItem.simiObjectName = @"back_button";
            [_leftButtonItems insertObject:backItem atIndex:1];
        }
    }else
    {
        UIBarButtonItem *firstItem = [_leftButtonItems objectAtIndex:1];
        if ([firstItem.simiObjectName isEqualToString:@"back_button"]) {
            [_leftButtonItems removeObjectAtIndex:1];
        }
    }
}
- (void)addCartButton{
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                       target:nil action:nil];
    negativeSpacer.width = -5;
    
    UIButton *cartButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
    [cartButton setImage:[[UIImage imageNamed:@"scp_ic_cart"] imageWithColor:SCP_ICON_COLOR] forState:UIControlStateNormal];
    cartButton.imageEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5);
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
        self.cartBadge.badgeBGColor = SCP_ICON_COLOR;
        self.cartBadge.badgeTextColor = THEME_COLOR;
    }
    [self.rightButtonItems addObjectsFromArray:@[negativeSpacer, self.cartItem]];
    self.cartItem.sortOrder = navigationbar_phone_cart_sort_order;
    negativeSpacer.sortOrder = self.cartItem.sortOrder - 10;
}

- (void)didSelectBackBarItem:(UIButton*)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark Action
- (void)openLeftMenu:(id)sender{
    [kMainViewController showLeftViewAnimated:YES completionHandler:nil];
}

@end
