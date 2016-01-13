//
//  SCAppWishlistViewController.h
//  SimiCartPluginFW
//
//  Created by SimiCommerce on 11/10/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SimiCartBundle/SimiViewController.h>
#import <SimiCartBundle/SimiTableView.h>
#import <SimiCartBundle/SimiProductModelCollection.h>
#import <SimiCartBundle/SCRefineViewController.h>
#import <SimiCartBundle/UIScrollView+SVInfiniteScrolling.h>
#import <MessageUI/MessageUI.h>
#import "SCAppWishlistModelCollection.h"
#import "UIView+Toast.h"


@interface SCAppWishlistViewController : SimiViewController<UITableViewDataSource, UITableViewDelegate, RefineViewDelegate >


@property (strong, nonatomic) NSString *categoryId;

@property (strong, nonatomic) SimiTableView *tableViewProductCollection;
@property (strong, nonatomic) SCAppWishlistModelCollection *productCollection;
@property (strong, nonatomic) SCAppWishlistModelCollection *currentProductCollection;

@property (nonatomic) BOOL isDidClickRefine;
@property (nonatomic) ProductCollectionSortType sortType;

@property (strong, nonatomic) NSNumber *wishlistItemCount;

@property (strong, nonatomic) NSString * sharingMessage;
@property (strong, nonatomic) NSString * sharingUrl;
@property (nonatomic) NSInteger currentExpandingOption;

@property (nonatomic) BOOL needReloadWishlist;

@property (nonatomic) float sectionHeaderHeight;

@property (nonatomic) int selectedRow;

@property (strong, nonatomic) UILabel * listEmptyText;

- (void)getProducts;
- (void)didGetWishlistProducts:(NSNotification *)noti;
- (void)didRemoveProductFromWishlist: (NSNotification *)noti;

- (void)viewProductDetail:(NSIndexPath *)indexPath;
- (void)reloadWishlist;

- (void)updateWishlistQty;
- (UIView *)createHeader;


@end