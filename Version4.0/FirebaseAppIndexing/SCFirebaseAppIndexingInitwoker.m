//
//  SCFirebaseAppIndexingInitwoker.m
//  SimiCartPluginFW
//
//  Created by Liam on 7/28/17.
//  Copyright © 2017 Trueplus. All rights reserved.
//

#import "SCFirebaseAppIndexingInitwoker.h"
#import <CoreSpotlight/CoreSpotlight.h>

@implementation SCFirebaseAppIndexingInitwoker
- (id)init{
    if(self == [super init]){
        if(SIMI_SYSTEM_IOS >= 9){
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetProducts:) name:@"DidGetProductCollection" object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(openSearchableItem:) name:@"DidInit" object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(openSearchableItem:) name:@"ContinueUserActivity" object:nil];
        }
    }
    return self;
}

- (void)indexSearchableItems{
    if(_productList.count > 0){
        NSMutableArray* searchableItems = [[NSMutableArray alloc] initWithCapacity:0];
        for(NSDictionary* product in _productList){
            NSUserActivity* userActivity = [[NSUserActivity alloc] initWithActivityType:[NSString stringWithFormat:@"%@.%@",[[NSBundle mainBundle] bundleIdentifier],[product objectForKey:@"entity_id"]]];
            userActivity.title = [product objectForKey:@"name"];
            userActivity.userInfo = @{@"id":[product objectForKey:@"entity_id"]};
            userActivity.eligibleForSearch = YES;
            CSSearchableItemAttributeSet* searchableItemAttributeSet = [[CSSearchableItemAttributeSet alloc] initWithItemContentType:@"product"];
            NSArray* images = [product objectForKey:@"images"];
            if(images.count > 0)
                searchableItemAttributeSet.thumbnailData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[[images objectAtIndex:0] objectForKey:@"url"]]];
            searchableItemAttributeSet.title = [product objectForKey:@"name"];
            searchableItemAttributeSet.contentDescription = [product objectForKey:@"short_description"];
            id item = [[CSSearchableItem alloc]initWithUniqueIdentifier:[product objectForKey:@"entity_id"] domainIdentifier:[NSString stringWithFormat:@"%@.searchAPIs.product",[[NSBundle mainBundle] bundleIdentifier]] attributeSet:searchableItemAttributeSet];
            [searchableItems addObject:item];
            userActivity.contentAttributeSet = searchableItemAttributeSet;
            [[CSSearchableIndex defaultSearchableIndex] indexSearchableItems:[NSArray arrayWithArray:searchableItems] completionHandler:^(NSError * _Nullable error) {
                if(error != nil){
                    NSLog(@"IndexSearchableItem Error: %@",error.localizedDescription);
                }
            }];
        }
    }
}

- (void)didGetProducts: (NSNotification*) noti{
    if([noti.object isKindOfClass:[NSArray class]]){
        _productList = noti.object;
        [NSThread detachNewThreadSelector: @selector(indexSearchableItems) toTarget:self withObject:NULL];
    }
}
- (void)openSearchableItem:(NSNotification*) noti{
    NSUserActivity* searchableUserActivity = [SimiGlobalVar sharedInstance].searchableUserActivity;
    if(searchableUserActivity && [searchableUserActivity.userInfo objectForKey:@"kCSSearchableItemActivityIdentifier"]){
        NSString* productID = [searchableUserActivity.userInfo objectForKey:@"kCSSearchableItemActivityIdentifier"];
        [[[SimiGlobalVar sharedInstance] currentlyNavigationController] popToRootViewControllerAnimated:NO];
        [SimiGlobalVar pushProductDetailWithNavigationController:[[SimiGlobalVar sharedInstance] currentlyNavigationController] andProductID:productID andProductIDs:nil];
        searchableUserActivity = nil;
    }
}
@end
