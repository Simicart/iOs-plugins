//
//  SCPViewController.h
//  SimiCartPluginFW
//
//  Created by Hoang Van Trung on 4/18/18.
//  Copyright © 2018 Trueplus. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SCPViewController : SimiViewController
@property (nonatomic, strong) NSMutableArray *leftButtonItems, *rightButtonItems;
@property (nonatomic, strong) UIBarButtonItem *leftMenuItem, *cartItem;
@property (nonatomic, strong) BBBadgeBarButtonItem *cartBadge;
@end
