//
//  ZThemeScreenBeforeOrderViewControllerPad.h
//  SimiCartPluginFW
//
//  Created by Cody Nguyen on 6/1/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import <SimiCartBundle/SimiCartBundle.h>
#import <SimiCartBundle/SimiViewController_Theme.h>
#import <SimiCartBundle/SCAddressViewController.h>

#import "ZThemeLoginViewController.h"
@protocol ZThemeScreenBeforeOrderViewControllerPad_Delegate<NSObject>
- (void)didCancelCheckout;
- (void)reloadCartDetail;
- (void)didGetAddressModelForCheckOut:(SimiAddressModel*)addressModel andIsNewCustomer:(BOOL)isNewCus;
@end


@interface ZThemeScreenBeforeOrderViewControllerPad : SimiViewController<UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate, SCNewAddressDelegate, ZThemeLoginViewController_Delegate, SCAddressDelegate>

@property (nonatomic, weak) id<ZThemeScreenBeforeOrderViewControllerPad_Delegate> delegate;
@property (nonatomic, strong) UITableView *tblViewOrder;
@property (nonatomic) BOOL isNewCustomer;

@end
