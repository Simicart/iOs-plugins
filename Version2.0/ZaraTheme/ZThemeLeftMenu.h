//
//  ZThemeLeftMenu.h
//  SimiCartPluginFW
//
//  Created by Nghieply91 on 5/12/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import <SimiCartBundle/SimiCartBundle.h>
#import <SimiCartBundle/SimiView.h>
#import <SimiCartBundle/SimiSection.h>
#import <SimiCartBundle/SimiRow.h>
#import <SimiCartBundle/SimiStoreModelCollection.h>
#import <SimiCartBundle/SimiModelCollection+CMS.h>
#import <SimiCartBundle/ILTranslucentView.h>
#import <SimiCartBundle/SimiTable.h>

#import "SimiGlobalVar+ZTheme.h"


static NSString *ZTHEME_SECTION_MAIN = @"ZTHEME_SECTION_MAIN";
static NSString *ZTHEME_SECTION_MYACCOUNT = @"ZTHEME_SECTION_MYACCOUNT";
static NSString *ZTHEME_SECTION_MORE = @"ZTHEME_SECTION_MORE";
static NSString *ZTHEME_SECTION_SETTING = @"ZTHEME_SECTION_SETTING";

static NSString *ZTHEME_ROW_HOME = @"ZTHEME_ROW_HOME";
static NSString *ZTHEME_ROW_CATEGORY = @"ZTHEME_ROW_CATEGORY";
static NSString *ZTHEME_ROW_STOREVIEW = @"ZTHEME_ROW_STOREVIEW";
static NSString *ZTHEME_ROW_PROFILE = @"ZTHEME_ROW_PROFILE";
static NSString *ZTHEME_ROW_ADDRESSBOOK = @"ZTHEME_ROW_ADDRESSBOOK";
static NSString *ZTHEME_ROW_ORDERHISTORY = @"ZTHEME_ROW_ORDERHISTORY";
static NSString *ZTHEME_ROW_CMS = @"ZTHEME_ROW_CMS";
static NSString *ZTHEME_ROW_SETTINGAPP = @"ZTHEME_ROW_SETTINGAPP";

#define ZTHEME_LEFTMENU_ROWHEIGT UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone?45:55


@class ZThemeLeftMenu;
@protocol ZThemeLeftMenu_Delegate <NSObject>
@optional
- (void)menu:(ZThemeLeftMenu *)menu didClickShowButonWithShow:(BOOL)show;
- (void)menu:(ZThemeLeftMenu *)menu didSelectRow:(SimiRow *)row withIndexPath:(NSIndexPath*)indexPath;
- (void)didSelectRecentProductWithProductModel:(NSMutableDictionary*)productModel;
- (void)didTouchSignInButton;
@end

@interface ZThemeLeftMenu : SimiView<UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate>
{
    float tableWidth;
    float recentHeight;
    float recentTilteHeight;
    float loginHeight;
    float sizeIcon;
}
@property (nonatomic, strong) id<ZThemeLeftMenu_Delegate> delegate;
@property (strong, nonatomic) SimiStoreModelCollection *stores;
@property (strong, nonatomic) SimiModelCollection *cmsPages;
@property (nonatomic, strong) UIImageView *imgListMenu;

@property (nonatomic, strong) UITableView *tableViewMenu;
@property (nonatomic, strong) SimiTable *cells;

@property (nonatomic, strong) UICollectionView *collectionRecentView;
@property (nonatomic, strong) NSMutableArray *arrayRecentProducts;
@property (nonatomic, strong) UIButton *btnLogin;
@property (nonatomic, strong) UILabel *lblRecent;
@property (nonatomic) BOOL haveRecentProducts;

@property (nonatomic) BOOL isFirstShow;

- (void)didClickShow;
- (void)didClickHide;
- (void)getCMSPages;
- (void)cusSetCells:(SimiTable *)cells;
- (void)didReceiveNotification:(NSNotification *)noti;
- (UIView*)setTableCell:(SimiRow *)row;
@end


@interface ZThemeLeftMenuCollectionViewCell : UICollectionViewCell
@property (strong, nonatomic) SimiProductModel *productModel;
@property (strong, nonatomic) UIImageView *productImage;

- (void)cusSetProductModel:(SimiProductModel*)productModel_;
@end

