//
//  ZThemeHomeViewController.m
//  SimiCartPluginFW
//
//  Created by Nghieply91 on 4/14/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import "ZThemeHomeViewController.h"

#import <SimiCartBundle/UIImageView+WebCache.h>

#import "ZThemeWorker.h"

static float HEIGHTBANNER = 218;
static float WIDTH_TABLEVIEW = 320;

@interface ZThemeHomeViewController ()

@end

@implementation ZThemeHomeViewController
@synthesize tableViewHome, imageViewLogo;

#pragma mark Main Method
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoadBefore
{
    self.edgesForExtendedLayout = UIRectEdgeBottom;
    [self setNavigationBarOnViewDidLoadForZTheme];
    [self setToSimiView];
    
    imageViewLogo = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 160, 44)];
    imageViewLogo.image = [UIImage imageNamed:@"logo.png"];
    imageViewLogo.contentMode = UIViewContentModeScaleAspectFill;
    [imageViewLogo setBackgroundColor:[UIColor clearColor]];
    [self.navigationItem setTitleView:imageViewLogo];
    
    CGRect frame = self.view.frame;
    tableViewHome = [[SimiTableView alloc] initWithFrame:frame style:UITableViewStyleGrouped];
    tableViewHome.dataSource = self;
    tableViewHome.delegate = self;
    [tableViewHome setBackgroundColor:[UIColor clearColor]];
    [tableViewHome setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    tableViewHome.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    tableViewHome.showsVerticalScrollIndicator = NO;
    [tableViewHome setContentInset:UIEdgeInsetsMake(30, 0, 0, 0)];
    [self.view addSubview:tableViewHome];
    
    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 6, WIDTH_TABLEVIEW, 25)];
    searchBar.simiObjectName = @"SearchBarOnHome";
    searchBar.placeholder = SCLocalizedString(@"Search");
    searchBar.searchBarStyle = UISearchBarStyleMinimal;
    searchBar.userInteractionEnabled = NO;
    searchBar.translucent = YES;
    searchBar.barTintColor = [UIColor clearColor];
    searchBar.tintColor = [UIColor darkGrayColor];
    [searchBar setBackgroundColor:[UIColor clearColor]];
    
    searchBar.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:searchBar];
    
    _searchImage = [[UIImageView alloc]initWithFrame:CGRectMake(6, 6, WIDTH_TABLEVIEW - 12, 30)];
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didTouchSearchImage:)];
    _searchImage.userInteractionEnabled = YES;
    [_searchImage addGestureRecognizer:gestureRecognizer];
    [_searchImage setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:_searchImage];
    
    self.homeModelCollection = [[ZThemeHomeModelCollection alloc]init];
    [self getListCategories];
    [tableViewHome setHidden:YES];
    
    [[SimiGlobalVar sharedInstance] addObserver:self forKeyPath:@"isLogin" options:NSKeyValueObservingOptionNew context:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"ApplicationWillResignActive" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didLoginLogout:) name:@"PushLoginNormal" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didLoginLogout:) name:@"PushLogout" object:nil];
}

- (void)viewWillAppearBefore:(BOOL)animated{
    [self setNavigationBarOnViewWillAppearForZTheme:YES isShowRightItems:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    [tableViewHome setFrame:self.view.bounds];
    [self.navigationController.view addSubview:[[[ZThemeWorker sharedInstance]navigationBar] zThemeLeftMenu]];
}

#pragma mark Did Get List Categories
-(void)getListCategories
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetListCategories:) name:@"ZTheme-GetListCategories" object:self.homeModelCollection];
    [self.homeModelCollection getListCategoryWithParams:@{}];
}

- (void)didGetListCategories:(NSNotification*)noti
{
    [[NSNotificationCenter defaultCenter]removeObserverForNotification:noti];
    SimiResponder *responder = [noti.userInfo valueForKey:@"responder"];
    if ([responder.status isEqualToString:@"SUCCESS"]) {
        [self setCellTables:nil];
        [tableViewHome setHidden:NO];
    }else
    {
        [self getListCategories];
    }
}

#pragma mark Set Cells
- (void)setCellTables:(SimiTable *)cellTables
{
    if (cellTables) {
        _cellTables = cellTables;
    }else
    {
        _cellTables = [[SimiTable alloc]init];
        if (self.homeModelCollection.count > 0) {
            for (int i = 0; i < self.homeModelCollection.count; i++) {
                SimiModel *homeModel = [self.homeModelCollection objectAtIndex:i];
                ZThemeSection *section = [[ZThemeSection alloc]initWithHeaderTitle:[homeModel valueForKey:@"category_name"] footerTitle:@""];
                if ([[homeModel valueForKey:@"type"] isEqualToString:@"cat"]) {
                    section.identifier = [NSString stringWithFormat:@"%@",[homeModel valueForKey:@"category_id"]];
                    section.isSelected = NO;
                    section.hasChild = [[homeModel valueForKey:@"has_child"] boolValue];
                    section.bannerCategoryURL = [homeModel valueForKey:@"category_image"];
                }else if([[homeModel valueForKey:@"type"] isEqualToString:@"spot"])
                {
                    section.identifier = [NSString stringWithFormat:@"%@",[homeModel valueForKey:@"spot_id"]];
                    section.isSelected = NO;
                    section.bannerCategoryURL = [homeModel valueForKey:@"spot_image"];
                }
                section.zThemeSectionContent = homeModel;
                if (section.hasChild) {
                    NSMutableArray *listCateChild = [[NSMutableArray alloc]initWithArray:[homeModel valueForKey:@"child_cat"]];
                    if (listCateChild.count > 0) {
                        NSString *strHaveAllProDuct = [NSString stringWithFormat:@"%@",[[[[SimiGlobalVar sharedInstance]store] valueForKey:@"store_config"]valueForKey:@"is_show_link_all_product"]];
                        if ([strHaveAllProDuct isEqualToString:@"1"]) {
                            ZThemeRow *simiRow = [[ZThemeRow alloc]initWithIdentifier:section.identifier  height:44];
                            simiRow.hasChild = NO;
                            simiRow.zThemeContentRow = [[NSMutableDictionary alloc]initWithDictionary:section.zThemeSectionContent];
                            [simiRow.zThemeContentRow setValue:[NSString stringWithFormat:@"%@",[simiRow.zThemeContentRow valueForKey:@"category_name"]] forKey:@"category_real_name"];
                            [simiRow.zThemeContentRow setValue:SCLocalizedString(@"All products") forKey:@"category_name"];
                            [section addObject:simiRow];
                        }
                        for (int j = 0; j < listCateChild.count; j++) {
                            NSDictionary *cateChild = [listCateChild objectAtIndex:j];
                            ZThemeRow *simiRow = [[ZThemeRow alloc]initWithIdentifier:[cateChild valueForKey:@"category_id"] height:44];
                            simiRow.hasChild = [[cateChild valueForKey:@"has_child"]boolValue];
                            simiRow.zThemeContentRow = [[NSMutableDictionary alloc]initWithDictionary: cateChild];
                            [section addObject:simiRow];
                        }
                    }
                }
                [_cellTables addObject:section];
            }
        }
        [tableViewHome reloadData];
    }
}

#pragma mark Table View DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _cellTables.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    ZThemeSection *simiSection = [_cellTables objectAtIndex:section];
    return simiSection.isSelected?simiSection.count:0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ZThemeSection *zThemeSection = [_cellTables objectAtIndex:indexPath.section];
    ZThemeRow *zThemeRow = (ZThemeRow*)[zThemeSection objectAtIndex:indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CELLDETAIL"];
    if (cell == nil) {
        cell = [UITableViewCell new];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryType = UITableViewCellAccessoryNone;
    [cell.textLabel setFont:[UIFont fontWithName:ZTHEME_FONT_NAME_LIGHT size:THEME_FONT_SIZE]];
    [cell.textLabel setText:[zThemeRow.zThemeContentRow valueForKey:@"category_name"]];
    //  Liam Update RTL
    if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
        [cell.textLabel setTextAlignment:NSTextAlignmentRight];
    }
    //  End RTL
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ZThemeSection *simiSection = [_cellTables objectAtIndex:indexPath.section];
    ZThemeRow *simiRow = (ZThemeRow*)[simiSection objectAtIndex:indexPath.row];
    return simiRow.height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return HEIGHTBANNER;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    ZThemeSection *zThemeSection = [_cellTables objectAtIndex:section];
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, WIDTH_TABLEVIEW, HEIGHTBANNER)];
    
    UIImageView *imageBanner = [[UIImageView alloc]initWithFrame:CGRectMake(6, 3,WIDTH_TABLEVIEW - 12 , HEIGHTBANNER - 6)];
    [imageBanner sd_setImageWithURL:[NSURL URLWithString:zThemeSection.bannerCategoryURL] placeholderImage:[UIImage imageNamed:@"logo"]];
    imageBanner.contentMode = UIViewContentModeScaleAspectFit;
    
    UIButton *btnBanner = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnBanner setFrame:imageBanner.bounds];
    [btnBanner setBackgroundColor:[UIColor clearColor]];
    [btnBanner addTarget:self action:@selector(didTouchBanner:) forControlEvents:UIControlEventTouchUpInside];
    [btnBanner setTag:section];
    
    [view addSubview:imageBanner];
    [view addSubview:btnBanner];
    NSString *bannerTitle = [NSString stringWithFormat:@"%@",[zThemeSection.zThemeSectionContent valueForKey:@"title"]];
    if (![bannerTitle isEqualToString:@""]) {
        UILabel *lblBanner = [[UILabel alloc]initWithFrame:CGRectMake(20,HEIGHTBANNER/2 - 6 - 10, 100,20)];
        [lblBanner setFont:[UIFont fontWithName:ZTHEME_FONT_NAME_REGULAR size:12]];
        [lblBanner setBackgroundColor:[UIColor colorWithWhite:1 alpha:0.7]];
        [lblBanner setText:bannerTitle];
        [lblBanner setTextAlignment:NSTextAlignmentCenter];
        float widthLabelBanner = [[lblBanner text] sizeWithAttributes:@{NSFontAttributeName:[lblBanner font]}].width;
        CGRect frame = lblBanner.frame;
        frame.size.width = widthLabelBanner + 6;
        [lblBanner setFrame:frame];
        
        [view addSubview:lblBanner];
    }
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01f;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return [[UIView alloc] initWithFrame:CGRectZero];
}

#pragma mark Table View Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ZThemeSection *zThemeSection = [_cellTables objectAtIndex:indexPath.section];
    ZThemeRow *zThemeRow = (ZThemeRow*)[zThemeSection objectAtIndex:indexPath.row];
    if (zThemeRow.hasChild) {
        ZThemeCategoryViewController *categoryViewController = [ZThemeCategoryViewController new];
        categoryViewController.navigationItem.title = [zThemeRow.zThemeContentRow valueForKey:@"catefory_name"];
        categoryViewController.categoryId = zThemeRow.identifier;
        categoryViewController.categoryRealName = [zThemeRow.zThemeContentRow valueForKey:@"category_name"];
        categoryViewController.navigationItem.title = [zThemeRow.zThemeContentRow valueForKey:@"category_name"];
        [self.navigationController pushViewController:categoryViewController animated:YES];
    }else
    {
        ZThemeProductListViewController *productListViewController = [ZThemeProductListViewController new];
        if ([zThemeRow.zThemeContentRow valueForKey:@"category_real_name"]) {
            productListViewController.navigationItem.title = [zThemeRow.zThemeContentRow valueForKey:@"category_real_name"];
        }else
        {
            productListViewController.navigationItem.title = [zThemeRow.zThemeContentRow valueForKey:@"category_name"];
        }
        productListViewController.categoryId = zThemeRow.identifier;
        productListViewController.categoryName = [zThemeRow.zThemeContentRow valueForKey:@"category_name"];
        [self.navigationController pushViewController:productListViewController animated:YES];
    }
}


#pragma mark DidLogin&Logout
- (void)didLoginLogout:(NSNotification*)noti
{
    
}

#pragma mark Did Touch Banner
- (void)didTouchBanner:(id)sender
{
    UIButton *btnBanner = (UIButton *)sender;
    int currentSection = (int)btnBanner.tag;
    
    // Change other section to unselect
    for (int i = 0; i < _cellTables.count; i++) {
        if (i != currentSection) {
            ZThemeSection *section = [_cellTables objectAtIndex:i];
            section.isSelected = NO;
        }
    }
    
    if (self.currentRowsAllow.count > 0) {
        NSIndexPath *indexPath = [self.currentRowsAllow objectAtIndex:0];
        if (indexPath.section != currentSection) {
            [self.tableViewHome beginUpdates];
            [self.tableViewHome deleteRowsAtIndexPaths:self.currentRowsAllow withRowAnimation:UITableViewRowAnimationFade];
            [self.tableViewHome endUpdates];
            [self.currentRowsAllow removeAllObjects];
        }
    }
    ZThemeSection *zThemeSection = [_cellTables objectAtIndex:currentSection];
    if (zThemeSection.hasChild) {
        //  if section has childs, it will be showed childs category
        zThemeSection.isSelected = !zThemeSection.isSelected;
        if (zThemeSection.isSelected) {
            self.currentRowsAllow = [NSMutableArray new];
            for (int i = 0; i < zThemeSection.count; i++) {
                NSIndexPath *path = [NSIndexPath indexPathForRow:i inSection:currentSection];
                [self.currentRowsAllow addObject:path];
            }
            [self.tableViewHome beginUpdates];
            [self.tableViewHome insertRowsAtIndexPaths:self.currentRowsAllow withRowAnimation:UITableViewRowAnimationFade];
            [self.tableViewHome endUpdates];
        }else
        {
            if (self.currentRowsAllow.count > 0) {
                [self.tableViewHome beginUpdates];
                [self.tableViewHome deleteRowsAtIndexPaths:self.currentRowsAllow withRowAnimation:UITableViewRowAnimationFade];
                [self.tableViewHome endUpdates];
                [self.currentRowsAllow removeAllObjects];
            }
        }
        [self.tableViewHome setContentOffset:CGPointMake(0, currentSection*HEIGHTBANNER - 39) animated:YES];
    }else
    {
        //  if section hasn't no child, it will be redirect list product screen
        ZThemeProductListViewController *productListViewController = [ZThemeProductListViewController new];
        if ([[zThemeSection.zThemeSectionContent valueForKey:@"type"] isEqualToString:@"cat"]) {
            productListViewController.zCollectionGetProductType = ZThemeCollectioViewGetProductTypeFromCategory;
            productListViewController.navigationItem.title = [zThemeSection.zThemeSectionContent valueForKey:@"category_name"];
            productListViewController.categoryId = zThemeSection.identifier;
        }else
        {
            productListViewController.zCollectionGetProductType = ZThemeCollectioViewGetProductTypeFromSpot;
            productListViewController.navigationItem.title = [zThemeSection.zThemeSectionContent valueForKey:@"spot_name"];
            productListViewController.spot_ID = [zThemeSection.zThemeSectionContent valueForKey:@"spot_key"];
        }
        
        [self.navigationController pushViewController:productListViewController animated:YES];
    }
}

#pragma mark Did Touch Search Bar
- (void)didTouchSearchImage:(UIGestureRecognizer*)gesture
{
    ZThemeProductListViewController *productListViewController = [ZThemeProductListViewController new];
    productListViewController.isOpenSearchFromHome = YES;
    productListViewController.zCollectionGetProductType = ZThemeCollectioViewGetProductTypeFromSearch;
    productListViewController.navigationItem.title = SCLocalizedString(@"Search");
    [self.navigationController pushViewController:productListViewController animated:YES];
}

@end
