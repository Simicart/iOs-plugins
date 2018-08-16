//
//  SCCustomizeSearchProductTableViewCell.h
//  SimiCartPluginFW
//
//  Created by Liam on 4/26/18.
//  Copyright © 2018 Trueplus. All rights reserved.
//

#import <SimiCartBundle/SimiTableViewCell.h>

@interface SCCustomizeSearchProductTableViewCell : SimiTableViewCell
@property (strong, nonatomic) NSDictionary *productData;
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier productData:(NSDictionary *)data;
@end
