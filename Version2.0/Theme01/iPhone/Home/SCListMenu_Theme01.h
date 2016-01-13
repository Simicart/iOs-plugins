//
//  SCListMenu_Theme01.h
//  SimiCartPluginFW
//
//  Created by Nghieply91 on 8/12/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import <SimiCartBundle/SimiCartBundle.h>
#import <SimiCartBundle/SimiView.h>
#import <SimiCartBundle/SimiSection.h>
#import <SimiCartBundle/SimiRow.h>
#import <SimiCartBundle/SimiStoreModelCollection.h>
#import <SimiCartBundle/SimiModelCollection+CMS.h>
//  Liam UPDATE 150324
#import <SimiCartBundle/ILTranslucentView.h>
//  End
#import "SCListMenuPad_Theme01.h" //Use static string

@class SCListMenu_Theme01;
@protocol SCListMenu_Theme01_Delegate <NSObject, UISearchBarDelegate>
@optional
- (void)menu:(SCListMenu_Theme01 *)menu didClickShowButonWithShow:(BOOL)show;
- (void)menu:(SCListMenu_Theme01 *)menu didSelectRow:(SimiRow *)row withIndexPath:(NSIndexPath*)indexPath;
- (void)didSearchButtonClicked:(NSString *)searchText;
- (void)didClickStoreButton;
- (void)didClickHomeButton;
- (void)didClickCategoryButton;
- (void)getOutToCartWhenDidLogout;
@end

@interface SCListMenu_Theme01 : SimiView<UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>

@property (nonatomic, strong) id<SCListMenu_Theme01_Delegate> delegate;
@property (strong, nonatomic) SimiStoreModelCollection *stores;
@property (strong, nonatomic) SimiModelCollection *cmsPages;

@property (nonatomic, strong) UIImageView *imgHome;
@property (nonatomic, strong) UIImageView *imgCate;
@property (nonatomic, strong) UIImageView *imgStoreView;
@property (nonatomic, strong) UIImageView *imgListMenu;
@property (nonatomic, strong) UILabel *lblHome;
@property (nonatomic, strong) UILabel *lblCate;
@property (nonatomic, strong) UILabel *lblStoreView;

@property (nonatomic, strong) UITableView *tableViewMenu;
@property (nonatomic, strong) SimiTable *cells;
@property (nonatomic, strong) UIViewController *selfController;
@property (nonatomic, strong) UISearchBar *searchBar;

- (void)didClickShow;
- (void)didClickHide;
- (void)setSelfController:(UIViewController *)selfController_;
@end
