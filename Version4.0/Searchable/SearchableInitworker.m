//
//  SearchableInitworker.m
//  SimiCartPluginFW
//
//  Created by Hoang Van Trung on 12/1/16.
//  Copyright © 2016 Trueplus. All rights reserved.
//

#import "SearchableInitworker.h"
#import <CoreSpotlight/CoreSpotlight.h>
#import <SimiCartBundle/SCThemeWorker.h>
#import <SimiCartBundle/SCProductViewController.h>

@implementation SearchableInitworker

-(id) init{
    if(self == [super init]){
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetProducts:) name:@"DidGetProductCollection" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(openSearchableItem:) name:@"DidInit" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(openSearchableItem:) name:@"ContinueUserActivity" object:nil];
    }
    return self;
}

-(void) didGetProducts: (NSNotification*) noti{
    NSArray* productList = noti.object;
    if(productList.count > 0){
        NSMutableArray* searchableItems = [[NSMutableArray alloc] initWithCapacity:0];
        for(NSDictionary* product in productList){
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
            [[CSSearchableIndex defaultSearchableIndex] indexSearchableItems:searchableItems completionHandler:^(NSError * _Nullable error) {
                if(error != nil){
                    NSLog(@"%@",error.localizedDescription);
                }
            }];
        }
    }
}
-(void) openSearchableItem:(NSNotification*) noti{
    NSUserActivity* searchableUserActivity = [SimiGlobalVar sharedInstance].searchableUserActivity;
    if(searchableUserActivity && [searchableUserActivity.userInfo objectForKey:@"kCSSearchableItemActivityIdentifier"]){
        SCProductViewController* productVC = [SCProductViewController new];
        productVC.productId = [searchableUserActivity.userInfo objectForKey:@"kCSSearchableItemActivityIdentifier"];
        [[[SimiGlobalVar sharedInstance] currentlyNavigationController] popToRootViewControllerAnimated:NO];
        [[[SimiGlobalVar sharedInstance] currentlyNavigationController] pushViewController:productVC animated:YES];
        searchableUserActivity = nil;
    }
}

@end
