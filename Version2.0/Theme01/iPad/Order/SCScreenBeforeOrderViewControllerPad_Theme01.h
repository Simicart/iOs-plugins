//
//  SCScreenBeforeOrderViewControllerPad_Theme01.h
//  SimiCartPluginFW
//
//  Created by Nghieply91 on 10/2/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import <SimiCartBundle/SimiCartBundle.h>
#import <SimiCartBundle/SimiViewController_Theme.h>
#import <SimiCartBundle/SCAddressViewController.h>
#import "SCLoginViewController_Theme01.h"
@protocol SCScreenBeforeOrderViewControllerPad_Theme01_Delegate<NSObject>
- (void)didCancelCheckout;
- (void)reloadCartDetail;
- (void)didGetAddressModelForCheckOut:(SimiAddressModel*)addressModel andIsNewCustomer:(BOOL)isNewCus;
@end

@interface SCScreenBeforeOrderViewControllerPad_Theme01 : SimiViewController_Theme<UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate, SCNewAddressDelegate, SCLoginViewController_Theme01_Delegate, SCAddressDelegate>
@property (nonatomic, weak) id<SCScreenBeforeOrderViewControllerPad_Theme01_Delegate> delegate;
@property (nonatomic, strong) UITableView *tblViewOrder;
@property (nonatomic) BOOL isNewCustomer;

@end
