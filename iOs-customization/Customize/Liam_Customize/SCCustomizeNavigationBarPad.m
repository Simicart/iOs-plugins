//
//  SCCustomizeNavigationBarPad.m
//  SimiCartPluginFW
//
//  Created by Liam on 4/26/18.
//  Copyright © 2018 Trueplus. All rights reserved.
//

#import "SCCustomizeNavigationBarPad.h"
#import "SCCustomizeSearchViewController.h"

@implementation SCCustomizeNavigationBarPad
- (void)didSelectSearchButton:(id)sender{
    NSArray *viewControllers = GLOBALVAR.currentlyNavigationController.viewControllers;
    for (SimiViewController *viewController in viewControllers) {
        if ([viewController isKindOfClass:[SCCustomizeSearchViewController class]]) {
            [GLOBALVAR.currentlyNavigationController popToViewController:viewController animated:YES];
            return;
        }
    }
    SCCustomizeSearchViewController *searchViewController = [SCCustomizeSearchViewController new];
    [GLOBALVAR.currentlyNavigationController pushViewController:searchViewController animated:YES];
}
@end
