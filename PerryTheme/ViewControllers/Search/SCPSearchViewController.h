//
//  SCPSearchViewController.h
//  SimiCartPluginFW
//
//  Created by Axe on 4/27/18.
//  Copyright © 2018 Trueplus. All rights reserved.
//

#import "SCPViewController.h"
#import "SCPSearchData.h"

#define SCP_SEARCH_DATA [SCPSearchData sharedInstance]

@interface SCPSearchViewController : SCPViewController<UITextFieldDelegate>

@end
