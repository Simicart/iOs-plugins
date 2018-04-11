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
- (void)searchStoreLocatorWithCountryName:(NSString*)countryName countryCode:(NSString*)countryCode city:(NSString*)city state:(NSString*)state zipcode:(NSString*)zipcode tag:(NSString*)tag;
- (void)cacheDataWithstoreLocatorModelCollection:(SimiStoreLocatorModelCollection*) collection simiTagModelCollection:(SimiTagModelCollection*)tagModelCollection tagChoise:(NSString*)tagString;
@end


@interface SimiStoreLocatorSearchViewController : SimiViewController<UITextFieldDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate>

@property (nonatomic, strong) NSArray *simiAddressStoreLocatorModelCollection;
@property (nonatomic, strong) SimiStoreLocatorModelCollection *sLModelCollection;
@property (nonatomic, strong) SimiTagModelCollection * tagModelCollection;
@property (nonatomic, strong) NSString *tagChoise;

@property (nonatomic) float currentLatitube;
@property (nonatomic) float currentLongitube;
@property (nonatomic, strong) NSString *stringCountrySearchCode;
@property (nonatomic, strong) NSString *stringCountrySearchName;
@property (nonatomic, strong) NSString *stringCitySearch;
@property (nonatomic, strong) NSString *stringStateSearch;
@property (nonatomic, strong) NSString *stringZipCodeSearch;
@property (nonatomic, strong) NSString *stringTagSearch;
@property (nonatomic, weak) id<SimiStoreLocatorSearchViewControllerDelegate> delegate;


@property (nonatomic, strong)  UIScrollView *scrView;

@property (nonatomic, strong)  UILabel *lblSearchByArea;
@property (nonatomic, strong)  UIButton *btnClearAll;

@property (nonatomic, strong)  UIControl *viewSearchByCountry;
@property (nonatomic, strong)  UITableView *tblViewCountry;
@property (nonatomic, strong)  UILabel *lblContentCountry;
@property (nonatomic, strong)  UILabel *lblCountry;
@property (nonatomic, strong)  UIImageView *imgCountry;
@property (nonatomic, strong)  UIButton *btnCountry;

@property (nonatomic, strong)  UIControl *viewSearchByCity;
@property (nonatomic, strong)  UIImageView *imgCity;
@property (nonatomic, strong)  UITextField *txtCitySearch;
@property (nonatomic, strong)  UILabel *lblCity;

@property (nonatomic, strong)  UIControl *viewSearchByState;
@property (nonatomic, strong)  UITextField *txtStateSearch;
@property (nonatomic, strong)  UILabel *lblState;
@property (nonatomic, strong)  UIImageView *imgState;

@property (nonatomic, strong)  UIControl *viewSearchByZipcode;
@property (nonatomic, strong)  UITextField *txtZipCode;
@property (nonatomic, strong)  UILabel *lblZipcode;
@property (nonatomic, strong)  UIImageView *imgZipCode;

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
