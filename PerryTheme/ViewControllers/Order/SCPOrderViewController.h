//
//  SCPOrderViewController.h
//  SimiCartPluginFW
//
//  Created by Hoang Van Trung on 6/12/18.
//  Copyright © 2018 Trueplus. All rights reserved.
//

#import <SimiCartBundle/SimiCartBundle.h>
#import <SimiCartBundle/SCOrderViewController.h>
#import "SCPOrderAddressTableViewCell.h"
#import "SCPOrderMethodCell.h"
#import "SCPGlobalVars.h"
#import "SCPCartCell.h"
#import "SCPOrderFeeCell.h"
#import "SCPCreditCardViewController.h"

@interface SCPOrderViewController : SCOrderViewController{
    NSMutableArray *shipmentExpandIndexPaths;
    BOOL isExpandShipment;
}
- (SCPOrderAddressTableViewCell *)createSCPShippingAddressCellWithRow:(SimiRow *)row tableView:(UITableView *)tableView;
- (SCPOrderAddressTableViewCell *)createSCPBillingAddressCellWithRow:(SimiRow *)row tableView:(UITableView *)tableView;
@end
