//
//  SimiMAWorker.h
//  SimiCartPluginFW
//
//  Created by Nghieply91 on 7/23/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SimiMAModel.h"
#import "GAI.h"
#import "GAIFields.h"
#import "GAITracker.h"
#import "GAIDictionaryBuilder.h"
#import "GAIEcommerceFields.h"
@interface SimiMAWorker : NSObject
{
    SimiMAModel *maModel;
    NSString *stringGoogleAnalyticsID;
    id<GAITracker> tracker;
}
@end
