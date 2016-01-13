//
//  SCHomeViewController_ThemeOne.m
//  SimiCartPluginFW
//
//  Created by Nghieply91 on 8/8/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import <SimiCartBundle/SimiGlobalVar.h>
#import <SimiCartBundle/UIImage+SimiCustom.h>

#import "SCHomeViewController_Theme01.h"
#import "SCGridViewController_Theme01.h"
#import "SCCategoryViewController_Theme01.h"
#import "SimiThemeWorker.h"
#import "SimiViewController+Theme01.h"
@interface SCHomeViewController_Theme01 ()

@end
static NSString *HOME_CATEGORY_CELL = @"HomeCellCategory";

@implementation SCHomeViewController_Theme01
@synthesize imageViewLogo, tableViewHome, bannerCollection, themeBannerSlider,spotProductCollection, cateCollection, cells = _cells;
//  Liam ADD 150319
@synthesize isDidGetBanner, isDidGetCategory, isDidGetSpotProduct;
//  End 150319


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
    [self setToSimiView];
    imageViewLogo = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 30)];
    imageViewLogo.image = [UIImage imageNamed:@"logo"];
    imageViewLogo.backgroundColor = [UIColor clearColor];
    [self.navigationItem setTitleView:imageViewLogo];
    
    tableViewHome = [[SimiTableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
    tableViewHome.dataSource = self;
    tableViewHome.delegate = self;
    tableViewHome.bounces = YES;
    [tableViewHome setContentInset:UIEdgeInsetsMake(0, 0, 5, 0)];
    if (SCREEN_HEIGHT == 568) {
        tableViewHome.scrollEnabled = NO;
    }
    tableViewHome.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    tableViewHome.showsVerticalScrollIndicator = NO;
    tableViewHome.separatorStyle = UITableViewCellSeparatorStyleNone;
    [tableViewHome setContentSize:CGSizeMake(320, 495)];
    [self.view addSubview:tableViewHome];
    
    [self setCells:nil];
    [self getBanners];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"ApplicationWillResignActive" object:nil];
    [self setNavigationBarOnViewDidLoadForTheme01];
}

- (void)viewWillAppearBefore:(BOOL)animated
{
    [self setNavigationBarOnViewWillAppearForTheme01];
    [[[[SimiThemeWorker sharedInstance]navigationBar] virtualHomeView] removeFromSuperview];
    self.navigationItem.leftBarButtonItems = [[[SimiThemeWorker sharedInstance] navigationBar] leftButtonItems];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    [self.navigationController.view addSubview:[[[SimiThemeWorker sharedInstance]navigationBar] listMenuView]];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setCells:(NSMutableArray *)cells
{
    if (cells) {
        _cells = cells;
    }else{
        _cells = [[NSMutableArray alloc] init];
        SimiSection *section = [[SimiSection alloc] init];
        
        if (bannerCollection.count > 0 || isDidGetBanner) {
            SimiRow *row01 = [[SimiRow alloc]initWithIdentifier:HOME_BANNER_CELL height:170];
            [section addObject:row01];
        }
        
        if (cateCollection.count > 0) {
            SimiRow *row02 = [[SimiRow alloc]initWithIdentifier:HOME_CATEGORY_CELL height:220];
            [section addObject:row02];
        }
        
        if (spotProductCollection > 0) {
            SimiRow *row03  = [[SimiRow alloc]initWithIdentifier:HOME_SPOT_CELL height:105];
            [section addObject:row03];
        }
        
        //  Liam UPDATE 150319
        /*
        if (!(bannerCollection.count > 0 && cateCollection.count > 0 && spotProductCollection.count > 0)) {
            SimiRow *row04 = [[SimiRow alloc]initWithIdentifier:HOME_LOADING_CELL height:100];
            [section addObject:row04];
        }
         */
        if (!(isDidGetBanner && isDidGetCategory && isDidGetSpotProduct)) {
            SimiRow *row04 = [[SimiRow alloc]initWithIdentifier:HOME_LOADING_CELL height:100];
            [section addObject:row04];
        }
        [_cells addObject:section];
        [tableViewHome reloadData];
        //  End 150319
    }
}

#pragma mark getData
- (void)getBanners
{
    if (self.bannerCollection == nil) {
        self.bannerCollection = [[SimiBannerModelCollection alloc] init];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"DidGetBanner" object:self.bannerCollection];
        [self.bannerCollection getBannerCollection];
    }
}

- (void)getCategorys:(NSDictionary *)param
{
    if (self.cateCollection == nil) {
        self.cateCollection = [[SCTheme01CategoryModelCollection alloc]init];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"SCTheme01-DidGetOrderCategory" object:self.cateCollection];
        [self.cateCollection getOrderCategoryWithParams:param];
    }
}


- (void)getOrderSpots:(NSDictionary *)param
{
    if (self.spotProductCollection == nil) {
        self.spotProductCollection = [[SCTheme01SpotProductModelCollection alloc]init];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"SCTheme01-DidGetOrderSpots" object:self.spotProductCollection];
        [self.spotProductCollection getOrderSpotsWithParams:param];
    }
}

#pragma mark Set Interface
- (void)setViewCategory
{
    if (cateCollection.count > 0) {
        
        _viewCate01 = [[SCCategoryProductCell_Theme01 alloc]initWithFrame:CGRectMake(0, 5, 105, 105) isAllCate:NO];
        [_viewCate01 cusSetCateModel:[cateCollection objectAtIndex:0]];
        _viewCate01.delegate =self;
        
        _viewCate02 = [[SCCategoryProductCell_Theme01 alloc]initWithFrame:CGRectMake(110, 5, 210, 105) isAllCate:NO];
        [_viewCate02 cusSetCateModel:[cateCollection objectAtIndex:1]];
        _viewCate02.delegate =self;
        
        _viewCate03 = [[SCCategoryProductCell_Theme01 alloc]initWithFrame:CGRectMake(0, 115, 210, 105) isAllCate:NO];
        [_viewCate03 cusSetCateModel:[cateCollection objectAtIndex:2]];
        _viewCate03.delegate =self;
        
        _viewAllCate = [[SCCategoryProductCell_Theme01 alloc]initWithFrame:CGRectMake(215, 115, 105, 105) isAllCate:YES];
        [_viewAllCate cusSetCateModel:[cateCollection objectAtIndex:3]];
        _viewAllCate.delegate =self;
    }
}

#pragma mark Recieve Data
//  Liam Update 150319
- (void)didReceiveNotification:(NSNotification*)noti
{
    SimiResponder *responder = [noti.userInfo valueForKey:@"responder"];
    /*
    if ([responder.status isEqualToString:@"SUCCESS"]) {
        if ([noti.name isEqualToString:@"SCTheme01-DidGetOrderSpots"]) {
            [self setCells:nil];
            [tableViewHome reloadData];
            [self removeObserverForNotification:noti];
        }else if ([noti.name isEqualToString:@"DidGetBanner"]) {
            [self removeObserverForNotification:noti];
            [self getCategorys:@{}];
        } else if ([noti.name isEqualToString:@"SCTheme01-DidGetOrderCategory"])
        {
            [self setCells:nil];
            [tableViewHome reloadData];
            [self getOrderSpots:@{}];
            [self removeObserverForNotification:noti];
        }else if ([noti.name isEqualToString:@"ApplicationWillResignActive"]) {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"ApplicationDidBecomeActive" object:nil];
            return;
        } else if ([noti.name isEqualToString:@"ApplicationDidBecomeActive"]) {
            [[NSNotificationCenter defaultCenter] removeObserver:self name:@"ApplicationDidBecomeActive" object:nil];
            [self getBanners];
            return;
        }
    }
     */
    if ([responder.status isEqualToString:@"SUCCESS"]) {
        if ([noti.name isEqualToString:@"SCTheme01-DidGetOrderSpots"]) {
            isDidGetSpotProduct = YES;
            [self setCells:nil];
            [self removeObserverForNotification:noti];
        }else if ([noti.name isEqualToString:@"DidGetBanner"]) {
            isDidGetBanner = YES;
            [self removeObserverForNotification:noti];
            [self getCategorys:@{}];
        } else if ([noti.name isEqualToString:@"SCTheme01-DidGetOrderCategory"])
        {
            isDidGetCategory = YES;
            [self setCells:nil];
            [self getOrderSpots:@{}];
            [self removeObserverForNotification:noti];
        }else if ([noti.name isEqualToString:@"ApplicationWillResignActive"]) {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"ApplicationDidBecomeActive" object:nil];
            return;
        } else if ([noti.name isEqualToString:@"ApplicationDidBecomeActive"]) {
            [[NSNotificationCenter defaultCenter] removeObserver:self name:@"ApplicationDidBecomeActive" object:nil];
            [self getBanners];
            return;
        }
    }else
    {
        if ([noti.name isEqualToString:@"DidGetBanner"]) {
            isDidGetBanner = YES;
            [self removeObserverForNotification:noti];
            [self getCategorys:@{}];
        }else if ([noti.name isEqualToString:@"SCTheme01-DidGetOrderCategory"])
        {
            isDidGetCategory = YES;
            [self setCells:nil];
            [self getOrderSpots:@{}];
            [self removeObserverForNotification:noti];
        }else if ([noti.name isEqualToString:@"SCTheme01-DidGetOrderSpots"])
        {
            isDidGetSpotProduct = YES;
            [self setCells:nil];
            [self removeObserverForNotification:noti];
        }
    }
    //  End
}

#pragma mark Banner Slider
- (void)tapInBanner:(UITapGestureRecognizer *)recognizer{
    if (bannerCollection.count > 0) {
        NSInteger offset = themeBannerSlider.currentIndex % bannerCollection.count;
        id banner = [bannerCollection objectAtIndex:offset];
        //king 150419
        if ([[banner valueForKey:@"type"] isEqualToString:@"2"]) {
            if ([[banner valueForKey:@"has_child"]boolValue]) {
                SCCategoryViewController_Theme01* nextController = [SCCategoryViewController_Theme01 new];
                nextController.categoryId = [banner valueForKey:@"categoryID"];
                nextController.navigationItem.title = [[banner valueForKey:@"categoryName"] uppercaseString];
                [self.navigationController pushViewController:nextController animated:YES];
            }else{
                SCGridViewController_Theme01 *nextController = [[SCGridViewController_Theme01 alloc]init];;
                nextController.categoryId = [banner valueForKey:@"categoryID"];
                nextController.scCollectionGetProductType = SCCollectionGetProductTypeFromCategory;
                nextController.navigationItem.title = [[banner valueForKey:@"categoryName"] uppercaseString];
                [self.navigationController pushViewController:nextController animated:YES];
            }
            
        }else if([[banner valueForKey:@"type"] isEqualToString:@"1"]){
            SCProductViewController_Theme01 *nextController = [SCProductViewController_Theme01 new];
            [nextController setProductId:[banner valueForKey:@"productID"]];
            [self.navigationController pushViewController:nextController animated:YES];
        }else{
            if (![[banner valueForKey:@"url"] isKindOfClass:[NSNull class]] && [banner valueForKey:@"url"] != nil){
                if ([[[banner valueForKey:@"url"] lowercaseString] rangeOfString:@"http"].location != NSNotFound) {
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[banner valueForKey:@"url"]]];
                }
            }
        }
    }
}

#pragma mark TableView DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return _cells.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    SimiSection *simiSection = [_cells objectAtIndex:section];
    return simiSection.rows.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    SimiSection *simiSection = [_cells objectAtIndex:indexPath.section];
    SimiRow *simiRow = [simiSection.rows objectAtIndex:indexPath.row];
    return simiRow.height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    SimiSection *simiSection = [_cells objectAtIndex:indexPath.section];
    SimiRow *simiRow = [simiSection.rows objectAtIndex:indexPath.row];
    cell = [tableView dequeueReusableCellWithIdentifier:simiRow.identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simiRow.identifier];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        //  Liam UPDATE 150319
        /*
        if ([simiRow.identifier isEqualToString:HOME_BANNER_CELL]) {
            if (themeBannerSlider == nil) {
                themeBannerSlider = [[SCTheme01SlideShow alloc] initWithFrame:CGRectMake(0, cell.frame.origin.y, cell.frame.size.width, 169)];
                UITapGestureRecognizer *tapGestureRecog = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapInBanner:)];
                [themeBannerSlider addGestureRecognizer:tapGestureRecog];
                [themeBannerSlider setImagesContentMode:UIViewContentModeScaleAspectFill];
                [themeBannerSlider setDelay:3];
                [themeBannerSlider setTransitionDuration:0.5];
                [themeBannerSlider setTransitionType:SCTheme01SlideShowTransitionSlide];
                themeBannerSlider.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
                [cell addSubview:themeBannerSlider];
            }
        } else if ([simiRow.identifier isEqualToString:HOME_CATEGORY_CELL])
        {
            [self setViewCategory];
            [cell addSubview:_viewCate01];
            [cell addSubview:_viewCate02];
            [cell addSubview:_viewCate03];
            [cell addSubview:_viewAllCate];
            [_viewCate01.slideShow start];
            [_viewCate02.slideShow start];
            [_viewCate03.slideShow start];
            [_viewAllCate.slideShow start];
        } else if ([simiRow.identifier isEqualToString:HOME_SPOT_CELL])
        {
            UIScrollView *scrViewSpot = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 5, cell.frame.size.width, 104)];
            scrViewSpot.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin |UIViewAutoresizingFlexibleWidth;
            scrViewSpot.showsHorizontalScrollIndicator = NO;
            int widthDistanceTwoCell = 4;
            int sizeCell = 104;
            int widthScrollViewContent = 0;
            for (int i = 0; i < spotProductCollection.count; i++) {
                SCSpotProductCell_Theme01 *spotCell = [[SCSpotProductCell_Theme01 alloc]initWithFrame:CGRectMake(i*(sizeCell + widthDistanceTwoCell), 0, sizeCell, sizeCell)];
                spotCell.delegate = self;
                [spotCell cusSetSpotModel:[spotProductCollection objectAtIndex:i]];
                widthScrollViewContent += (sizeCell + widthDistanceTwoCell);
                [spotCell.slideShow start];
                [scrViewSpot addSubview:spotCell];
            }
            
            [scrViewSpot setContentSize:CGSizeMake(widthScrollViewContent, sizeCell)];
            [scrViewSpot setBackgroundColor:[UIColor clearColor]];
            [cell addSubview:scrViewSpot];
        }else if ([simiRow.identifier isEqualToString:HOME_LOADING_CELL])
        {
            if ([simiRow.identifier isEqualToString:HOME_LOADING_CELL]){
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, cell.frame.size.width/2 - 100, 320, 100)];
                imageView.image = [UIImage imageNamed:@"logo.png"];
                [imageView setContentMode:UIViewContentModeScaleAspectFit];
                CGRect frame = imageView.frame;
                UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, frame.origin.y + frame.size.height - 30, frame.size.width, 30)];
                label.text = [NSString stringWithFormat:@"%@...", SCLocalizedString(@"Loading")];
                label.textColor = THEME_COLOR;
                label.textAlignment = NSTextAlignmentCenter;
                [cell addSubview:imageView];
                [cell addSubview:label];
            }
        }
        */
        if ([simiRow.identifier isEqualToString:HOME_BANNER_CELL]) {
            if (bannerCollection.count > 0) {
                if (themeBannerSlider == nil) {
                    themeBannerSlider = [[SCTheme01SlideShow alloc] initWithFrame:CGRectMake(0, cell.frame.origin.y, cell.frame.size.width, 169)];
                    UITapGestureRecognizer *tapGestureRecog = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapInBanner:)];
                    [themeBannerSlider addGestureRecognizer:tapGestureRecog];
                    [themeBannerSlider setImagesContentMode:UIViewContentModeScaleAspectFill];
                    [themeBannerSlider setDelay:3];
                    [themeBannerSlider setTransitionDuration:0.5];
                    [themeBannerSlider setTransitionType:SCTheme01SlideShowTransitionSlide];
                    themeBannerSlider.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
                    [cell addSubview:themeBannerSlider];
                }
            }
        } else if ([simiRow.identifier isEqualToString:HOME_CATEGORY_CELL])
        {
            [self setViewCategory];
            [cell addSubview:_viewCate01];
            [cell addSubview:_viewCate02];
            [cell addSubview:_viewCate03];
            [cell addSubview:_viewAllCate];
            [_viewCate01.slideShow start];
            [_viewCate02.slideShow start];
            [_viewCate03.slideShow start];
            [_viewAllCate.slideShow start];
        } else if ([simiRow.identifier isEqualToString:HOME_SPOT_CELL])
        {
            UIScrollView *scrViewSpot = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 5, cell.frame.size.width, 104)];
            scrViewSpot.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin |UIViewAutoresizingFlexibleWidth;
            scrViewSpot.showsHorizontalScrollIndicator = NO;
            int widthDistanceTwoCell = 4;
            int sizeCell = 104;
            int widthScrollViewContent = 0;
            for (int i = 0; i < spotProductCollection.count; i++) {
                SCSpotProductCell_Theme01 *spotCell = [[SCSpotProductCell_Theme01 alloc]initWithFrame:CGRectMake(i*(sizeCell + widthDistanceTwoCell), 0, sizeCell, sizeCell)];
                spotCell.delegate = self;
                [spotCell cusSetSpotModel:[spotProductCollection objectAtIndex:i]];
                widthScrollViewContent += (sizeCell + widthDistanceTwoCell);
                [spotCell.slideShow start];
                [scrViewSpot addSubview:spotCell];
            }
            
            [scrViewSpot setContentSize:CGSizeMake(widthScrollViewContent, sizeCell)];
            [scrViewSpot setBackgroundColor:[UIColor clearColor]];
            [cell addSubview:scrViewSpot];
        }else if ([simiRow.identifier isEqualToString:HOME_LOADING_CELL])
        {
            if ([simiRow.identifier isEqualToString:HOME_LOADING_CELL]){
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, cell.frame.size.width/2 - 100, 320, 100)];
                imageView.image = [UIImage imageNamed:@"logo.png"];
                [imageView setContentMode:UIViewContentModeScaleAspectFit];
                CGRect frame = imageView.frame;
                UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, frame.origin.y + frame.size.height - 30, frame.size.width, 30)];
                label.text = [NSString stringWithFormat:@"%@...", SCLocalizedString(@"Loading")];
                label.textColor = THEME_COLOR;
                label.textAlignment = NSTextAlignmentCenter;
                [cell addSubview:imageView];
                [cell addSubview:label];
            }
        }
        // End 150319
    }
    if ([simiRow.identifier isEqualToString:HOME_BANNER_CELL] && bannerCollection.count > 0) {
        //  Liam UPDATE 150505 Có một banner thì không cho chạy và không vuốt sang ngang
        if (bannerCollection.count > 1) {
            [themeBannerSlider addGesture:SCTheme01SlideShowGestureSwipe];
        }
        for (SimiModel *model in bannerCollection) {
            [themeBannerSlider addImagePath:[model valueForKey:@"image_path"]];
        }
        if (bannerCollection.count > 1) {
            [themeBannerSlider start];
        }
        //  End 150505
    }
    return cell;
}

#pragma mark SpotProduct Delegate
- (void)didSelectedSpotProductWithSpotProductModel:(SimiModel *)spotModel
{
    SCGridViewController_Theme01 *gridViewController = [[SCGridViewController_Theme01 alloc]init];
    gridViewController.scCollectionGetProductType = SCCollectionGetProductTypeFromSpotProduct;
    gridViewController.spotKey = [NSString stringWithFormat:@"%@",[spotModel valueForKey:scTheme01_02_spot_key]];
    gridViewController.navigationItem.title = [[NSString stringWithFormat:@"%@",[spotModel valueForKey:scTheme01_02_spot_name]] uppercaseString];
    [self.navigationController pushViewController:gridViewController animated:YES];
}

#pragma mark Category Delegate
- (void)didSelectCateGoryWithCateModel:(SimiCategoryModel *)cateMode
{
    NSString *categoryId = [cateMode valueForKey:scTheme01_01_category_id];
    if([categoryId intValue] <= 0){
        SCCategoryViewController_Theme01 *categoryController = [[SCCategoryViewController_Theme01 alloc]init];
        [self.navigationController pushViewController:categoryController animated:YES];
    }else{
        SCGridViewController_Theme01 *gridViewController = [[SCGridViewController_Theme01 alloc]init];
        gridViewController.scCollectionGetProductType = SCCollectionGetProductTypeFromCategory;
        gridViewController.categoryId = categoryId;
        gridViewController.navigationItem.title = [[cateMode valueForKey:scTheme01_01_getOrderCategories_category_name] uppercaseString];
        [self.navigationController pushViewController:gridViewController animated:YES];
    }
}
@end
