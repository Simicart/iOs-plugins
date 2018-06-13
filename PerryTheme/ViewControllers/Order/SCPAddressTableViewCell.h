//
//  SCPAdressTableViewCell.h
//  SimiCartPluginFW
//
//  Created by Hoang Van Trung on 6/12/18.
//  Copyright © 2018 Trueplus. All rights reserved.
//

#import <SimiCartBundle/SimiCartBundle.h>
#import <SimiCartBundle/SimiTableViewCell.h>

typedef enum : NSUInteger {
    SCPAddressTypeBilling,
    SCPAddressTypeShipping,
} SCPAddressType;

@interface SCPAddressTableViewCell : SimiTableViewCell
@property (nonatomic) SCPAddressType addressType;
@property (strong, nonatomic) SimiAddressModel *addressModel;
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier width:(CGFloat)width type:(SCPAddressType)type;
@end
