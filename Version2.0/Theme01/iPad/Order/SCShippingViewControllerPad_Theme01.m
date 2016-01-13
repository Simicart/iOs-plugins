//
//  SCShippingViewControllerPad_Theme01.m
//  SimiCartPluginFW
//
//  Created by Nghieply91 on 12/26/14.
//  Copyright (c) 2014 Trueplus. All rights reserved.
//

#import "SCShippingViewControllerPad_Theme01.h"

@implementation SCShippingViewControllerPad_Theme01
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
