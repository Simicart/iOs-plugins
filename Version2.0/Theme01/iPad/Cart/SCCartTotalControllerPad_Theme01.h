//
//  SCCartTotalControllerPad_Theme01.h
//  SimiCartPluginFW
//
//  Created by Tan Hoang on 2/11/14.
//  Copyright (c) 2014 SimiTeam. All rights reserved.
//

#import "SCCartViewController_Theme01.h"
@protocol SCCartTotalControllerPad_Theme01_Delegate <NSObject>
- (void)didClickCheckOut;
@end

@interface SCCartTotalControllerPad_Theme01 : SCCartViewController_Theme01
@property (nonatomic, weak) id<SCCartTotalControllerPad_Theme01_Delegate> delegate;

- (void)checkout;
- (void) setIsCheckoutable:(BOOL)isCheckoutable_;

@end
