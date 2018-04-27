//
//  SCPSearchData.h
//  SimiCartPluginFW
//
//  Created by Hoang Van Trung on 4/27/18.
//  Copyright © 2018 Trueplus. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SCPSearchData : NSObject
+ (instancetype)sharedInstance;
@property (nonatomic, strong) NSArray *searchHistory;
- (void)addValueToSearchHistory:(NSString *)value;
@end
