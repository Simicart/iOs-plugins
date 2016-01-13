//
//  ZThemeShippingViewControllerPad.m
//  SimiCartPluginFW
//
//  Created by Cody Nguyen on 6/1/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import "ZThemeShippingViewControllerPad.h"


@implementation ZThemeShippingViewControllerPad
#pragma mark Table View Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DidSelectShippingCellAtIndexPath" object:tableView userInfo:@{@"indexPath": indexPath}];
    if (self.isDiscontinue) {
        self.isDiscontinue = NO;
        return;
    }
    [self.delegate didSelectShippingMethodAtIndex:indexPath.row];
}

@end
