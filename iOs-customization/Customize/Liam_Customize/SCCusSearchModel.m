//
//  SCCusSearchModel.m
//  SimiCartPluginFW
//
//  Created by Liam on 4/25/18.
//  Copyright © 2018 Trueplus. All rights reserved.
//

#import "SCCusSearchModel.h"

@implementation SCCusSearchModel
- (void)starSearchanise{
    notificationName = @"CompleteSearchanise";
    [self addParamsWithKey:@"q" value:self.searchKey];
    if ([[GLOBALVAR.storeView valueForKey:@"customize_search_params"]isKindOfClass:[NSDictionary class]]) {
        NSDictionary *customizeSearchParams = [GLOBALVAR.storeView valueForKey:@"customize_search_params"];
        [self.params addEntriesFromDictionary:customizeSearchParams];
    }else{
        [self addParamsWithKey:@"api_key" value:@"7H8z1s2p1W"];
        [self addParamsWithKey:@"restrictBy[status]" value:@"1"];
        [self addParamsWithKey:@"restrictBy[visibility]" value:@"3|4"];
        [self addParamsWithKey:@"maxResults" value:@"5"];
        [self addParamsWithKey:@"startIndex" value:@"0"];
        [self addParamsWithKey:@"items" value:@"true"];
        [self addParamsWithKey:@"pages" value:@"true"];
        [self addParamsWithKey:@"facets" value:@"false"];
        [self addParamsWithKey:@"categories" value:@"true"];
        [self addParamsWithKey:@"suggestions" value:@"true"];
        [self addParamsWithKey:@"pageStartIndex" value:@"0"];
        [self addParamsWithKey:@"pagesPerPage" value:@"2"];
        [self addParamsWithKey:@"categoryStartIndex" value:@"0"];
        [self addParamsWithKey:@"categoriesPerPage" value:@"2"];
        [self addParamsWithKey:@"suggestionsMaxResults" value:@"0"];
        [self addParamsWithKey:@"union[price][min]" value:@"se_price_0"];
    }
    [self addParamsWithKey:@"output" value:@"jsonp"];
    self.method = MethodGet;
    self.url = @"http://www.searchanise.com/getwidgets";
    [self requestWithMethod:self.method URL:self.url params:self.params body:self.body header:self.headers];
}

- (void)parseData {
    self.modelData = [[NSMutableDictionary alloc]initWithDictionary:self.data];
    if ([self.modelData valueForKey:@"totalItems"]) {
        self.totalItems = [[self.modelData valueForKey:@"totalItems"]intValue];
    }
    if ([[self.modelData valueForKey:@"categories"]isKindOfClass:[NSArray class]]) {
        self.categories = [self.modelData valueForKey:@"categories"];
    }
    if ([[self.modelData valueForKey:@"pages"]isKindOfClass:[NSArray class]]) {
        self.pages = [self.modelData valueForKey:@"pages"];
    }
    if ([[self.modelData valueForKey:@"items"]isKindOfClass:[NSArray class]]) {
        self.items = [self.modelData valueForKey:@"items"];
    }
}
@end
