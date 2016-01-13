//
//  SCReviewViewControllerPad_Theme01.h
//  SimiCartPluginFW
//
//  Created by Nghieply91 on 9/24/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import <SimiCartBundle/SimiCartBundle.h>
#import <SimiCartBundle/SimiProductModel.h>
#import <SimiCartBundle/SimiReviewModelCollection.h>
#import <SimiCartBundle/CoreAPI_Key.h>

#import "SCTheme01_APIKey.h"
#import "SimiGlobalVar+Theme01.h"
#import "ShortReviewCellPad_Theme01.h"
#import "SCReviewDetailController_Theme01.h"

@interface SCReviewViewControllerPad_Theme01 : SCReviewDetailController_Theme01<UITableViewDataSource, UITableViewDelegate, ShortReviewCellPad_Theme01_Delegate>
@end
