//
//  SCPTableViewController.h
//  SimiCartPluginFW
//
//  Created by Hoang Van Trung on 5/2/18.
//  Copyright © 2018 Trueplus. All rights reserved.
//

#import <SimiCartBundle/SimiCartBundle.h>

@interface SCPTableViewController : SimiTableViewController
@property (nonatomic, strong) NSMutableArray *leftButtonItems, *rightButtonItems;
@property (nonatomic, strong) UIBarButtonItem *leftMenuItem, *cartItem;
@property (nonatomic, strong) BBBadgeBarButtonItem *cartBadge;
@end
