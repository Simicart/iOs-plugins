//
//  SCPSearchViewController.h
//  SimiCartPluginFW
//
//  Created by Axe on 4/27/18.
//  Copyright © 2018 Trueplus. All rights reserved.
//

#import "SCPViewController.h"
#import "SCPSearchData.h"
#import "SCPGlobalVars.h"
#import "SCPLabel.h"
#import "SCPTextField.h"
#import "SCPProductListViewController.h"

#define SCP_SEARCH_DATA [SCPSearchData sharedInstance]

@interface SCPSearchViewController : SCPViewController<UITextFieldDelegate>
@property (strong, nonatomic) UIScrollView *mainScrollView;
@property (strong, nonatomic) SCPTextField *searchTextField;
@end
