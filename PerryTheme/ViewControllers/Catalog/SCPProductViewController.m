//
//  SCPProductViewController.m
//  SimiCartPluginFW
//
//  Created by Hoang Van Trung on 5/3/18.
//  Copyright © 2018 Trueplus. All rights reserved.
//

#import "SCPProductViewController.h"

@interface SCPProductViewController ()

@end

@implementation SCPProductViewController

- (void)viewDidLoadBefore {
    [super viewDidLoadBefore];
}

- (UITableViewCell *)createProductImageCell:(SimiRow *)row{
    return [super createProductImageCell:row];
}

- (UITableViewCell *)createNameCell:(SimiRow *)row{
    return [super createNameCell:row];
}

- (UITableViewCell *)createRelatedCell:(SimiRow *)row{
    return [super createRelatedCell:row];
}

- (UITableViewCell *)createDescriptionCell:(SimiRow *)row{
    return [super createDescriptionCell:row];
}

@end
