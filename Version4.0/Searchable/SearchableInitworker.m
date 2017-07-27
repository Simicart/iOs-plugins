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
#import <SimiCartBundle/SCProductViewControllerPad.h>
#import <SimiCartBundle/SCProductSecondDesignViewControllerPad.h>

#import <FirebaseCore/FirebaseCore.h>
#import <FirebaseDynamicLinks/FirebaseDynamicLinks.h>
#import <SimiCartBundle/SimiCMSModel.h>

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

@interface SearchableInitworker()
@property (strong, nonatomic) NSArray* productList;
@end

@implementation SearchableInitworker

-(id) init{
    if(self == [super init]){
        if (![SimiGlobalVar sharedInstance].isFirebaseInited) {
            //Init Firebase configure
            [FIRApp configure];
            [SimiGlobalVar sharedInstance].isFirebaseInited = YES;
        }
        if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"9")){
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetProducts:) name:@"DidGetProductCollection" object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(openSearchableItem:) name:@"DidInit" object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(openSearchableItem:) name:@"ContinueUserActivity" object:nil];
        }
        //Dynamic Links
        [FIROptions defaultOptions].deepLinkURLScheme = [[NSBundle mainBundle] bundleIdentifier];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationOpenURL:) name:@"ApplicationOpenURL" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(continueUserActivity:) name:@"ContinueUserActivity" object:nil];
    }
    return self;
}

-(void) indexSearchableItems{
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

-(void) didGetProducts: (NSNotification*) noti{
    if([noti.object isKindOfClass:[NSArray class]]){
        _productList = noti.object;
        [NSThread detachNewThreadSelector: @selector(indexSearchableItems) toTarget:self withObject:NULL];
    }
}
-(void) openSearchableItem:(NSNotification*) noti{
    NSUserActivity* searchableUserActivity = [SimiGlobalVar sharedInstance].searchableUserActivity;
    if(searchableUserActivity && [searchableUserActivity.userInfo objectForKey:@"kCSSearchableItemActivityIdentifier"]){
        NSString* productID = [searchableUserActivity.userInfo objectForKey:@"kCSSearchableItemActivityIdentifier"];
        [[[SimiGlobalVar sharedInstance] currentlyNavigationController] popToRootViewControllerAnimated:NO];
        if (PHONEDEVICE) {
            switch ([SimiGlobalVar sharedInstance].productStyleUsing) {
                case ProductShowCherry:
                {
                    SCProductSecondDesignViewController *nextController = [SCProductSecondDesignViewController new];
                    [nextController setProductId:productID];
                    [[[SimiGlobalVar sharedInstance] currentlyNavigationController] pushViewController:nextController animated:YES];
                }
                    break;
                default:
                {
                    SCProductViewController *productViewController = [SCProductViewController new];
                    productViewController.firstProductID = productID;
                    [[[SimiGlobalVar sharedInstance] currentlyNavigationController] pushViewController:productViewController animated:YES];
                }
                    break;
            }
        }else
        {
            switch ([SimiGlobalVar sharedInstance].productStyleUsing) {
                case ProductShowCherry:
                {
                    SCProductSecondDesignViewControllerPad *nextController = [SCProductSecondDesignViewControllerPad new];
                    [nextController setProductId:productID];
                    [[[SimiGlobalVar sharedInstance] currentlyNavigationController] pushViewController:nextController animated:YES];
                }
                    break;
                default:
                {
                    SCProductViewControllerPad *productViewController = [SCProductViewControllerPad new];
                    productViewController.firstProductID = productID;
                    [[[SimiGlobalVar sharedInstance] currentlyNavigationController] pushViewController:productViewController animated:YES];
                }
                    break;
            }
        }
        searchableUserActivity = nil;
    }
}


#pragma mark Dynamic Links
-(void) applicationOpenURL:(NSNotification*) noti{
    NSURL* url = [noti.userInfo objectForKey:@"url"];
    NSNumber* number = noti.object;
    FIRDynamicLink *dynamicLink = [[FIRDynamicLinks dynamicLinks] dynamicLinkFromCustomSchemeURL:url];
    
    if (dynamicLink) {
        // Handle the deep link. For example, show the deep-linked content or
        // apply a promotional offer to the user's account.
        // ...
        number = [NSNumber numberWithBool:YES];
    }else{
        number = [NSNumber numberWithBool:NO];
    }
}

-(void) continueUserActivity:(NSNotification*) noti{
    NSUserActivity* userActivity = [noti.userInfo objectForKey:@"userActivity"];
    NSNumber* handledNumber = [noti.userInfo objectForKey:@"handled"];
    BOOL handled = [[FIRDynamicLinks dynamicLinks] handleUniversalLink:userActivity.webpageURL
                                                            completion:^(FIRDynamicLink * _Nullable dynamicLink,
                                                                         NSError * _Nullable error) {
        if(!error) {
            NSString *dynamicLinkURL = dynamicLink.url.absoluteString;
            NSString *deepLinkPath = [[dynamicLinkURL componentsSeparatedByString:@"?"] objectAtIndex:1];
            NSDictionary *deepLinkValues = [self convertFromDeeplinkPath:deepLinkPath];
            if([deepLinkValues objectForKey:@"simi_product_id"]){
                NSString *productID = [deepLinkValues objectForKey:@"simi_product_id"];
                [[[SimiGlobalVar sharedInstance] currentlyNavigationController] popToRootViewControllerAnimated:NO];
                [SimiGlobalVar pushProductDetailWithNavigationController:[[SimiGlobalVar sharedInstance] currentlyNavigationController] andProductID:productID andProductIDs:@[productID]];
            } else if([deepLinkValues objectForKey:@"simi_cate_name"] && [deepLinkValues objectForKey:@"simi_has_child"] && [deepLinkValues objectForKey:@"simi_cate_name"]) {
                NSString *categoryID = [deepLinkValues objectForKey:@"simi_cate_name"];
                BOOL hasChild = [[deepLinkValues objectForKey:@"simi_has_child"] boolValue];
                NSString *categoryName = [deepLinkValues objectForKey:@"simi_cate_name"];
                if(PHONEDEVICE) {
                    if(hasChild) {
                        SCCategoryViewController *nextController = [[SCCategoryViewController alloc]init];
                        nextController.openFrom = CategoryOpenFromParentCategory;
                        [nextController setCategoryId:categoryID];
                        [nextController setCategoryRealName:categoryName];
                        [[[SimiGlobalVar sharedInstance] currentlyNavigationController] popToRootViewControllerAnimated:NO];
                        [[[SimiGlobalVar sharedInstance] currentlyNavigationController] pushViewController:nextController animated:YES];
                    }else {
                        SCProductListViewController *nextController = [[SCProductListViewController alloc]init];;
                        [nextController setCategoryID: categoryID];
                        nextController.nameOfProductList = categoryName;
                        [[[SimiGlobalVar sharedInstance] currentlyNavigationController] popToRootViewControllerAnimated:NO];
                        [[[SimiGlobalVar sharedInstance] currentlyNavigationController] pushViewController:nextController animated:YES];
                    }
                }else {
                    
                }
            } else if([deepLinkValues objectForKey:@"simi_cms_id"]) {
                NSString *cmsID = [deepLinkValues objectForKey:@"simi_cms_id"];
                [[[SimiGlobalVar sharedInstance] currentlyNavigationController] popToRootViewControllerAnimated:NO];
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetCMSPage:) name:DidGetCMSPage object:nil];
                [[SimiCMSModel new] getCMSPageWithID:cmsID];
                [((SimiViewController *)[[SimiGlobalVar sharedInstance] currentlyNavigationController].viewControllers.lastObject) startLoadingData];
            }
        }
    }];
    handledNumber = [NSNumber numberWithBool:handled];
}

- (void)didGetCMSPage: (NSNotification *)noti {
    SimiCMSModel *cmsModel = noti.object;
    [((SimiViewController *)[[SimiGlobalVar sharedInstance] currentlyNavigationController].viewControllers.lastObject) stopLoadingData];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DidGetCMSPage object:nil];
        SCWebViewController *webViewController = [[SCWebViewController alloc] init];
    webViewController.title = [cmsModel objectForKey:@"cms_title"];
    webViewController.content = [cmsModel valueForKey:@"cms_content"];
    [[[SimiGlobalVar sharedInstance] currentlyNavigationController] pushViewController:webViewController animated:YES];
}

- (NSDictionary *)convertFromDeeplinkPath:(NSString *)deeplinkPath {
    NSArray *deepLinkItems = [deeplinkPath componentsSeparatedByString:@"&"];
    NSMutableDictionary *deeplinkValues = [NSMutableDictionary new];
    for(NSString *deepLinkItem in deepLinkItems) {
        NSArray *deepLinkItemValue = [deepLinkItem componentsSeparatedByString:@"="];
        [deeplinkValues setValue:[deepLinkItemValue objectAtIndex:1] forKey:[deepLinkItemValue objectAtIndex:0]];
    }
    return deeplinkValues;
}

@end
