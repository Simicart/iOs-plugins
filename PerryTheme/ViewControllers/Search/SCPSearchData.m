//
//  SCPSearchData.m
//  SimiCartPluginFW
//
//  Created by Hoang Van Trung on 4/27/18.
//  Copyright © 2018 Trueplus. All rights reserved.
//

#import "SCPSearchData.h"

@implementation SCPSearchData
+ (instancetype)sharedInstance{
    static SCPSearchData *_sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[SCPSearchData alloc] init];
    });
    return _sharedInstance;
}
- (NSArray *)searchHistory{
    NSArray *searchValues = [[NSUserDefaults standardUserDefaults] objectForKey:@"searchValues"];
    if(searchValues){
        return searchValues;
    }else{
        return [NSArray new];
    }
}
- (void)addValueToSearchHistory:(NSString *)value{
    NSMutableArray *searchHistory = [NSMutableArray new];
    NSArray *searchValues = [[NSUserDefaults standardUserDefaults] objectForKey:@"searchValues"];
    if(searchValues){
        [searchHistory addObjectsFromArray:searchValues];
    }
    [searchHistory insertObject:value atIndex:0];
    [[NSUserDefaults standardUserDefaults] setObject:searchHistory forKey:@"searchValues"];
}
@end
