//
//  SimiMAModel.h
//  SimiCartPluginFW
//
//  Created by Nghieply91 on 7/23/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import <SimiCartBundle/SimiCartBundle.h>
#import <SimiCartBundle/SimiModel.h>

@interface SimiMAModel : SimiModel
- (void)getGoogleAnalyticsIDWithParams:(NSDictionary *)params;
@end
