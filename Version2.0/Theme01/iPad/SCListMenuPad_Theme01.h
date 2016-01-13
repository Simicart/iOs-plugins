//
//  SCListMenuPad_Theme01.h
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
#import <SimiCartBundle/SimiTable.h>
//  Liam UPDATE 150324
#import <SimiCartBundle/ILTranslucentView.h>
//  End
#import "SimiGlobalVar+Theme01.h"

static NSString *THEME01_LISTMENU_SECTION_MAIN = @"THEME01_LISTMENU_SECTION_MAIN";
static NSString *THEME01_LISTMENU_SECTION_MYACCOUNT = @"THEME01_LISTMENU_SECTION_MYACCOUNT";
static NSString *THEME01_LISTMENU_SECTION_MORE = @"THEME01_LISTMENU_SECTION_MORE";
static NSString *THEME01_LISTMENU_SECTION_SETTING = @"THEME01_LISTMENU_SECTION_SETTING";

static NSString *THEME01_LISTMENU_ROW_MAIN = @"THEME01_LISTMENU_ROW_MAIN";
static NSString *THEME01_LISTMENU_ROW_SIGNIN = @"THEME01_LISTMENU_ROW_SIGNIN";
static NSString *THEME01_LISTMENU_ROW_ADDRESS = @"THEME01_LISTMENU_ROW_ADDRESS";
static NSString *THEME01_LISTMENU_ROW_PROFILE = @"THEME01_LISTMENU_ROW_PROFILE";
static NSString *THEME01_LISTMENU_ROW_ORDERHISTORY = @"THEME01_LISTMENU_ROW_ORDERHISTORY";
static NSString *THEME01_LISTMENU_ROW_CMS = @"THEME01_LISTMENU_ROW_CMS";
static NSString *THEME01_LISTMENU_ROW_SETTING = @"THEME01_LISTMENU_ROW_SETTING";

@class SCListMenuPad_Theme01;

@protocol SCListMenuPad_Theme01Delegate <NSObject>
@optional
- (void)menu:(SCListMenuPad_Theme01 *)menu didClickShowButonWithShow:(BOOL)show;
- (void)menu:(SCListMenuPad_Theme01 *)menu didSelectRow:(SimiRow *)row withIndexPath:(NSIndexPath*)indexPath;
- (void)didClickStoreButton;
- (void)didClickHomeButton;
- (void)didClickCategoryButton;
- (void)getOutToCartWhenDidLogout;
- (void)backToHomeWhenLogin;
@end

@interface SCListMenuPad_Theme01 : SimiView<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) id<SCListMenuPad_Theme01Delegate> delegate;
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

- (void)didClickShow;
- (void)didClickHide;
@end
