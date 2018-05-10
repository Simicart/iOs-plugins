//
//  SCPCategoryModelCollection.m
//  SimiCartPluginFW
//
//  Created by Hoang Van Trung on 4/24/18.
//  Copyright © 2018 Trueplus. All rights reserved.
//

#import "SCPCategoryModelCollection.h"

@implementation SCPCategoryModelCollection
- (void)getRootCategories{
    notificationName = Simi_DidGetCategoryCollection;
    self.parseKey = @"categories";
    self.resource = @"categories";
    [self addOffsetToParams:@"0"];
    [self addLimitToParams:@"100"];
    [self.params addEntriesFromDictionary:@{@"get_child_cat":@"2"}];
    self.method = MethodGet;
    [self request];
}
@end
