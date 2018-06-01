//
//  SCPViewController.m
//  SimiCartPluginFW
//
//  Created by Hoang Van Trung on 4/18/18.
//  Copyright © 2018 Trueplus. All rights reserved.
//

#import "SCPViewController.h"
#import "SCPGlobalVars.h"

@implementation SCPViewController
- (void)backToHomePage:(UIGestureRecognizer *)gesture{
    if(SCP_GLOBALVARS.rootController.viewControllers.count){
        [SCP_GLOBALVARS.rootController setSelectedViewController:SCP_GLOBALVARS.rootController.viewControllers.firstObject];
    }
}
@end
