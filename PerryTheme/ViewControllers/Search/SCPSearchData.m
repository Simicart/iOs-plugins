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
    NSMutableArray *searchValues = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"searchValues"]];
    if(searchValues){
        for(NSString *searchValue in searchValues){
            if([searchValue isEqualToString:value]){
                [searchValues removeObject:searchValue];
                break;
            }
        }
        [searchHistory addObjectsFromArray:searchValues];
        [searchHistory insertObject:value atIndex:0];
    }else{
        [searchHistory insertObject:value atIndex:0];
    }
    NSMutableArray *resultsBeSaved = [NSMutableArray new];
    for(NSString *searchString in searchHistory){
        if([searchHistory indexOfObject:searchString] == 3){
            break;
        }
        [resultsBeSaved addObject:searchString];
    }
    [[NSUserDefaults standardUserDefaults] setObject:resultsBeSaved forKey:@"searchValues"];
}
@end
