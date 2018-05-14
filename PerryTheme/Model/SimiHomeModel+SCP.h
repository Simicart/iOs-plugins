//
//  SimiHomeModel+SCP.h
//  SimiCartPluginFW
//
//  Created by Hoang Van Trung on 5/9/18.
//  Copyright © 2018 Trueplus. All rights reserved.
//

#import <SimiCartBundle/SimiCartBundle.h>
#import <SimiCartBundle/SimiHomeModel.h>

@interface SimiHomeModel (SCP)
- (void)getHomeDataWithParams:(NSDictionary *)params;
@end
