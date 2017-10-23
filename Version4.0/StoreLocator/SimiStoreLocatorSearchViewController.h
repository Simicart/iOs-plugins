//
//  SimiStoreLocatorSearchViewController.h
//  SimiCartPluginFW
//
//  Created by NghiepLy on 7/9/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <SimiCartBundle/SimiCartBundle.h>
#import <SimiCartBundle/SimiViewController.h>
#import <SimiCartBundle/UIScrollView+SVInfiniteScrolling.h>
#import <SimiCartBundle/SimiAddressModelCollection.h>
#import <SimiCartBundle/ActionSheetPicker.h>

#import "SimiStoreLocatorModelCollection.h"
#import "SimiTagModelCollection.h"
#import "SimiTagCollectionCell.h"

@protocol SimiStoreLocatorSearchViewControllerDelegate  <NSObject>
@optional
- (void)searchStoreLocatorWithCountry:(NSDictionary *)country state:(NSDictionary *)state city:(NSDictionary *)city storeName:(NSString *)storeName tag:(NSString*)tag;
- (void)cacheDataWithstoreLocatorModelCollection:(SimiStoreLocatorModelCollection*) collection simiTagModelCollection:(SimiTagModelCollection*)tagModelCollection tagChoise:(NSString*)tagString;
@end


@interface SimiStoreLocatorSearchViewController : SimiViewController<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate>

@property (nonatomic, strong) SimiAddressModelCollection *simiAddressStoreLocatorModelCollection;
@property (nonatomic, strong) SimiStoreLocatorModelCollection *sLModelCollection;
@property (nonatomic, strong) SimiTagModelCollection * tagModelCollection;
@property (nonatomic, strong) NSString *tagChoise;

@property (nonatomic) float currentLatitube;
@property (nonatomic) float currentLongitube;
@property (nonatomic, strong) NSString *stringTagSearch;
@property (nonatomic, strong) NSDictionary *currentCountry;
@property (nonatomic, strong) NSDictionary *currentCity;
@property (nonatomic, strong) NSDictionary *currentState;
@property (nonatomic, strong) NSString *tag;
@property (nonatomic, strong) NSString *storeName;

@property (nonatomic, weak) id<SimiStoreLocatorSearchViewControllerDelegate> delegate;


@property (nonatomic, strong)  UIScrollView *scrView;

@property (nonatomic, strong)  UILabel *lblSearchByArea;
@property (nonatomic, strong)  UIButton *btnClearAll;

@property (nonatomic, strong)  UIControl *viewSearchByCountry;
@property (nonatomic, strong)  UITableView *tblViewCountry;
@property (nonatomic, strong)  UILabel *lblCountry;
@property (nonatomic, strong)  UIImageView *imgCountry;
@property (nonatomic, strong)  UIButton *btnCountry;

@property (nonatomic, strong)  UIControl *viewSearchByCity;
@property (nonatomic, strong)  UILabel *lblCity;
@property (nonatomic, strong)  UIImageView *imgCity;
@property (nonatomic, strong)  UIButton *btnCity;

@property (nonatomic, strong)  UIControl *viewSearchByState;
@property (nonatomic, strong)  UILabel *lblState;
@property (nonatomic, strong)  UIImageView *imgState;
@property (nonatomic, strong)  UIButton *btnState;

@property (nonatomic, strong)  UIControl *viewSearchByStoreName;
@property (nonatomic, strong)  UITextField *txtStoreName;
@property (nonatomic, strong)  UILabel *lblStoreName;
@property (nonatomic, strong)  UIImageView *imgStoreName;

@property (nonatomic, strong)  UIView *viewSearch;
@property (nonatomic, strong)  UIButton *btnSearch;

@property (nonatomic, strong)  UIView *viewSearchByTag;
@property (nonatomic, strong)  UILabel *lblSearchByTag;
@property (nonatomic, strong)  UICollectionView * collectionViewTagContent;

- (void)btnDropDownList_Click:(id)sender;
- (void)btnSearch_Click:(id)sender;
- (void)btnTouchOutLayer_Click:(id)sender;
- (void)btnClear:(id)sender;
@end
