//
//  SCAnalyticWorker.h
//  SimiCartPluginFW
//
//  Created by Liam on 6/25/18.
//  Copyright © 2018 Trueplus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Reachability.h"
static NSString *section_id;
@interface SCAnalyticWorker : NSObject{
    NSMutableDictionary *commonProperties;
    NSMutableDictionary *commonData;
}
@end
