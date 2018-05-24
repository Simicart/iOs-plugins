//
//  SCPLeftMenuViewController.h
//  SimiCartPluginFW
//
//  Created by Hoang Van Trung on 5/14/18.
//  Copyright © 2018 Trueplus. All rights reserved.
//

#import <SimiCartBundle/SimiCartBundle.h>
#import <SimiCartBundle/SCLeftMenuViewController.h>

#define SCP_LEFTMENU_ROW_ACCOUNT @"SCP_LEFTMENU_ROW_ACCOUNT"

#define SCP_LEFT_MENU_CELL_HEIGHT 35

@interface SCPLeftMenuViewController : SCLeftMenuViewController

@end

@interface SCPLeftMenuAccountCell: SimiTableViewCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier width:(CGFloat)width;
@property (strong, nonatomic) SimiCustomerModel *customer;
@end

@interface SCPLeftMenuCell: SCLeftMenuCell

@end
