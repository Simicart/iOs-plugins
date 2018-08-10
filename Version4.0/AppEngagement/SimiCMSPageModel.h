//
//  SimiCMSPageModel.h
//  SimiCartPluginFW
//
//  Created by Hoang Van Trung on 10/4/17.
//  Copyright © 2017 Trueplus. All rights reserved.
//

#import "SimiModel.h"

@interface SimiCMSPageModel : SimiModel
@property (strong, nonatomic) NSString *cmsTitle;
@property (strong, nonatomic) NSString *cmsImage;
@property (strong, nonatomic) NSString *cmsContent;
@property (nonatomic) int cmsStatus;
- (void)getCMSPageWithID:(NSString *)cmsID;
@end
