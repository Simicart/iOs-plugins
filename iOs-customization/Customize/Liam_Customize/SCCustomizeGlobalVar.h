//
//  SCCustomizeGlobalVar.h
//  SimiCartPluginFW
//
//  Created by Liam on 4/25/18.
//  Copyright © 2018 Trueplus. All rights reserved.
//

#import <Foundation/Foundation.h>

#define CUSGLOBALVAR [SCCustomizeGlobalVar sharedInstance]

@interface SCCustomizeGlobalVar : NSObject
@property (nonatomic, strong) NSMutableDictionary *searchCache;
+ (instancetype)sharedInstance;
@end
