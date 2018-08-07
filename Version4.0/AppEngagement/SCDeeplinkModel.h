//
//  SCDeeplinkModel.h
//  SimiCartPluginFW
//
//  Created by Hoang Van Trung on 8/8/17.
//  Copyright © 2017 Trueplus. All rights reserved.
//

#import <SimiCartBundle/SimiCartBundle.h>

#define DidGetDeeplinkInformation @"DidGetDeeplinkInformation"

@interface SCDeeplinkModel : SimiModel
- (void)getDeeplinkInformation: (NSString *)deeplinkURL;
@end
