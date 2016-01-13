//
//  ZThemeHomeViewControllerPad.m
//  SimiCartPluginFW
//
//  Created by Cody Nguyen on 5/7/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import "ZThemeHomeViewControllerPad.h"

#import <SimiCartBundle/UIImageView+WebCache.h>
#import <SimiCartBundle/SCCartViewController.h>

#import "ZThemeProductListViewControllerPad.h"
#import "ZThemeWorker.h"
#import "SimiViewController+ZTheme.h"


static float HEIGHTBANNER = 682;
static float WIDTH_TABLEVIEW = 1024;


@interface ZThemeHomeViewControllerPad ()

@end

@implementation ZThemeHomeViewControllerPad

@synthesize rightMenu;

- (void)viewDidLoadBefore {
    [super viewDidLoadBefore];
}

- (void)viewDidAppear:(BOOL)animated
{
    
    [super viewDidAppear:animated];
    for (UIView * subView in self.view.subviews) {
        if ([subView.simiObjectName isEqualToString:@"SearchBarOnHome"]) {
            [subView removeFromSuperview];
        }
    }
    [self.tableViewHome setFrame:self.view.bounds];
    [self.navigationController.view addSubview:[[[ZThemeWorker sharedInstance]navigationBarPad] zThemeLeftMenu]];
    self.navigationItem.rightBarButtonItems = [[[ZThemeWorker sharedInstance] navigationBarPad]rightButtonItems];
    [self.tableViewHome setFrame:CGRectMake(0, -32, 1024, 745)];
    self.currentSection = -1;
    if (rightMenu == nil) {
        rightMenu = [[ZThemeRightMenuPad alloc]initWithFrame:CGRectMake(624, 0, 400, self.view.frame.size.height)];
        [self.view addSubview:rightMenu];
    }
    [self addGestureRecognizer];
}


- (void)viewWillAppearBefore:(BOOL)animated{
    [rightMenu dismissView];
    self.navigationItem.leftBarButtonItems = [[[ZThemeWorker sharedInstance] navigationBarPad] leftButtonItems];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    ZThemeSection *zThemeSection = [self.cellTables objectAtIndex:section];
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, WIDTH_TABLEVIEW, HEIGHTBANNER)];
    
    
    UIImageView * imageBannerPlaceHolder = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"logo"]];
    [imageBannerPlaceHolder setFrame:CGRectMake(32,300,960,120)];
    [view addSubview: imageBannerPlaceHolder];
    
    UIImageView *imageBanner = [[UIImageView alloc]initWithFrame:CGRectMake(10, 3,WIDTH_TABLEVIEW - 20 , HEIGHTBANNER - 12)];
    [imageBanner sd_setImageWithURL:[NSURL URLWithString:zThemeSection.bannerCategoryURL]];
    imageBanner.contentMode = UIViewContentModeScaleToFill;
    
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

#pragma mark Did Get List Categories
-(void)getListCategories
{
    [self.homeModelCollection setValue:@"phone_type" forKey:@"phone_type"];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetListCategories:) name:@"ZTheme-GetListCategories" object:self.homeModelCollection];
    [self.homeModelCollection getListCategoryWithParams:@{}];
}

- (void)didGetListCategories:(NSNotification*)noti
{
    [self.tableViewHome setContentOffset:CGPointMake(0, -32)];
    [super didGetListCategories:noti];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return HEIGHTBANNER;
}


#pragma mark Did Touch Banner
- (void)didTouchBanner:(id)sender
{
    UIButton *btnBanner = (UIButton *)sender;
    int currentSection = (int)btnBanner.tag;
    ZThemeSection *zThemeSection = [self.cellTables objectAtIndex:currentSection];
    if (zThemeSection.hasChild) {
        if (currentSection == self.currentSection) {
            [rightMenu dismissView];
        }
        else
        {
            SimiCategoryModelCollection * categoryModelCollection = [[SimiCategoryModelCollection alloc] init];
            SimiCategoryModel * rootCategoryModel = [[SimiCategoryModel alloc]init];
            [rootCategoryModel setObject:zThemeSection.identifier forKey:@"category_id"];
            [rootCategoryModel setObject:@"NO" forKey:@"hasChild"];
            [rootCategoryModel setObject:@"All products" forKey:@"category_name"];
            [categoryModelCollection addObject:rootCategoryModel];
            for (NSDictionary * category in (NSArray *)[zThemeSection.zThemeSectionContent objectForKey:@"child_cat"]) {
                SimiCategoryModel * categoryModel = [[SimiCategoryModel alloc]initWithDictionary:category];
                [categoryModelCollection addObject:categoryModel];
            }
            [rightMenu updateCategory:categoryModelCollection :zThemeSection.identifier :[zThemeSection.zThemeSectionContent objectForKey:@"category_name"]];
        }
    }else
    {
        [rightMenu dismissView];
        ZThemeProductListViewControllerPad *productListViewController = [ZThemeProductListViewControllerPad new];
        productListViewController.categoryId = zThemeSection.identifier;
        NSString * type = (NSString *)[[zThemeSection zThemeSectionContent] objectForKey:@"type"];
        if ([type isEqualToString:@"cat"])
            productListViewController.isCategory = YES;
        else if ([type isEqualToString:@"spot"]) {
            productListViewController.zCollectionGetProductType = ZThemeCollectioViewGetProductTypeFromSpot;
            productListViewController.navigationItem.title = [zThemeSection.zThemeSectionContent valueForKey:@"spot_name"];
            productListViewController.spot_ID = [zThemeSection.zThemeSectionContent valueForKey:@"spot_key"];
        }
        [self.navigationController pushViewController:productListViewController animated:YES];
    }
    if (currentSection == self.currentSection)
        self.currentSection = -1;
    else
        self.currentSection = currentSection;
    
}

@end
