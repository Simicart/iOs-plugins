//
//  SCHomeViewControlleriPad_Theme01.m
//  SimiCartPluginFW
//
//  Created by Nghieply91 on 9/9/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import "SCHomeViewControllerPad_Theme01.h"
#import <SimiCartBundle/UIImage+SimiCustom.h>

#import "SimiThemeWorker.h"
#import "SimiViewController+Theme01.h"

@interface SCHomeViewControllerPad_Theme01 ()
{
    NSMutableArray *arrTemp01;
    NSMutableArray *arrTemp02;
}
@end

static NSString *HOME_CATEGORY_CELL = @"HomeCellCategory";

@implementation SCHomeViewControllerPad_Theme01
@synthesize imageViewLogo, tableViewHome, bannerCollection,spotProductCollection, cateCollection;
@synthesize cells = _cells, viewCate01 = _viewCate01, viewCate02 = _viewCate02, viewCate03 = _viewCate03, viewAllCate = _viewAllCate;
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
    if (SIMI_SYSTEM_IOS >= 7.0) {
        self.automaticallyAdjustsScrollViewInsets = NO;
        self.edgesForExtendedLayout = UIRectEdgeBottom;
        self.navigationController.navigationBar.barTintColor = [UIColor redColor];
    }
    if (self.isDiscontinue) {
        self.isDiscontinue = NO;
        return;
    }
    // Do any additional setup after loading the view.
    [self setToSimiView];
    tableViewHome = [[SimiTableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
    tableViewHome.dataSource = self;
    tableViewHome.delegate = self;
    tableViewHome.scrollEnabled = NO;
    tableViewHome.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    tableViewHome.showsVerticalScrollIndicator = NO;
    tableViewHome.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:tableViewHome];
    
    [self setCells:nil];
    [self getBanners];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"ApplicationWillResignActive" object:nil];
    [self setNavigationBarOnViewDidLoadForTheme01];
}

- (void)viewWillAppearBefore:(BOOL)animated
{
    [self setNavigationBarOnViewWillAppearForTheme01];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    [self.navigationController.view addSubview:[[[SimiThemeWorker sharedInstance] navigationBarPad] listMenuView]];
}

- (void)setCells:(NSMutableArray *)cells
{
    if (cells) {
        _cells = cells;
    }else{
        _cells = [[NSMutableArray alloc] init];
        SimiSection *section = [[SimiSection alloc] init];
        //  Liam UPDATE 150319
        /*
        if (bannerCollection.count > 0) {
            SimiRow *row01 = [[SimiRow alloc]initWithIdentifier:HOME_BANNER_CELL height:356];
            [section addObject:row01];
        }
        
        if (cateCollection.count > 0) {
            SimiRow *row02 = [[SimiRow alloc]initWithIdentifier:HOME_CATEGORY_CELL height:166];
            [section addObject:row02];
        }
        
        if (spotProductCollection > 0) {
            SimiRow *row03  = [[SimiRow alloc]initWithIdentifier:HOME_SPOT_CELL height:186];
            [section addObject:row03];
        }
        
        if (!(bannerCollection.count > 0 && cateCollection.count > 0 && spotProductCollection.count > 0)) {
            SimiRow *row04 = [[SimiRow alloc]initWithIdentifier:HOME_LOADING_CELL height:100];
            [section addObject:row04];
        }
        [_cells addObject:section];
         */
        if (self.isDidGetBanner) {
            SimiRow *row01 = [[SimiRow alloc]initWithIdentifier:HOME_BANNER_CELL height:356];
            [section addObject:row01];
        }
        
        if (cateCollection.count > 0) {
            SimiRow *row02 = [[SimiRow alloc]initWithIdentifier:HOME_CATEGORY_CELL height:166];
            [section addObject:row02];
        }
        
        if (spotProductCollection > 0) {
            SimiRow *row03  = [[SimiRow alloc]initWithIdentifier:HOME_SPOT_CELL height:186];
            [section addObject:row03];
        }
        
        if (!(self.isDidGetBanner && self.isDidGetCategory && self.isDidGetSpotProduct)) {
            SimiRow *row04 = [[SimiRow alloc]initWithIdentifier:HOME_LOADING_CELL height:100];
            [section addObject:row04];
        }
        [_cells addObject:section];
        [tableViewHome reloadData];
    }
}

#pragma mark Set Interface
- (void)setViewCategory
{
    if (cateCollection.count > 0) {
        
        _viewCate01 = [[SCCategoryProductCellPad_Theme01 alloc]initWithFrame:CGRectMake(0, 0, 166, 166) isAllCate:NO];
        [_viewCate01 cusSetCateModel:[cateCollection objectAtIndex:0]];
        _viewCate01.delegate =self;
        
        _viewCate02 = [[SCCategoryProductCellPad_Theme01 alloc]initWithFrame:CGRectMake(175, 0, 332, 166) isAllCate:NO];
        [_viewCate02 cusSetCateModel:[cateCollection objectAtIndex:1]];
        _viewCate02.delegate =self;
        
        _viewCate03 = [[SCCategoryProductCellPad_Theme01 alloc]initWithFrame:CGRectMake(516, 0, 332, 166) isAllCate:NO];
        [_viewCate03 cusSetCateModel:[cateCollection objectAtIndex:2]];
        _viewCate03.delegate =self;
        
        _viewAllCate = [[SCCategoryProductCellPad_Theme01 alloc]initWithFrame:CGRectMake(857, 0, 167, 166) isAllCate:YES];
        [_viewAllCate cusSetCateModel:[cateCollection objectAtIndex:3]];
        _viewAllCate.delegate =self;
    }
}

#pragma mark Recieve Data

- (void)didReceiveNotification:(NSNotification*)noti
{
    SimiResponder *responder = [noti.userInfo valueForKey:@"responder"];
    //  Liam ADD 150319
    /*
    if ([responder.status isEqualToString:@"SUCCESS"]) {
        if ([noti.name isEqualToString:@"SCTheme01-DidGetOrderSpots"]) {
            [self setCells:nil];
            [tableViewHome reloadData];
            [self removeObserverForNotification:noti];
            
            for (int i = 0; i < 10; i++) {
                for (int j = 0; j < arrTemp01.count; j++) {
                    UIImageView *imageView = (UIImageView*)[arrTemp01 objectAtIndex:j];
                    if (imageView.image != nil) {
                        [_arrayImageBanner addObject:imageView.image];
                        [_arrayBannerModel addObject:[arrTemp02 objectAtIndex:j]];
                    }
                }
            }
            [_carousel reloadData];
            [_carousel scrollToItemAtIndex:_arrayImageBanner.count/2 animated:NO];
        }else if ([noti.name isEqualToString:@"DidGetBanner"]) {
            [self removeObserverForNotification:noti];
            [self setCells:nil];
            [tableViewHome reloadData];
            [self getCategorys:@{@"phone_type":@"tablet"}];
        } else if ([noti.name isEqualToString:@"SCTheme01-DidGetOrderCategory"])
        {
            [self setCells:nil];
            [tableViewHome reloadData];
            [self getOrderSpots:@{@"phone_type":@"tablet"}];
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
            self.isDidGetSpotProduct = YES;
            [self setCells:nil];
            [self removeObserverForNotification:noti];
            
            for (int i = 0; i < 10; i++) {
                for (int j = 0; j < arrTemp01.count; j++) {
                    UIImageView *imageView = (UIImageView*)[arrTemp01 objectAtIndex:j];
                    if (imageView.image != nil) {
                        [_arrayImageBanner addObject:imageView.image];
                        [_arrayBannerModel addObject:[arrTemp02 objectAtIndex:j]];
                    }
                }
            }
            [_carousel reloadData];
            [_carousel scrollToItemAtIndex:_arrayImageBanner.count/2 animated:NO];
            //  Liam Update 150505 Nếu chỉ có 1 banner thì không cho scroll
            if (arrTemp01.count == 1) {
                _carousel.scrollEnabled = NO;
            }
            //  End 150505
        }else if ([noti.name isEqualToString:@"DidGetBanner"]) {
            self.isDidGetBanner = YES;
            [self removeObserverForNotification:noti];
            [self setCells:nil];
            [self getCategorys:@{@"phone_type":@"tablet"}];
        } else if ([noti.name isEqualToString:@"SCTheme01-DidGetOrderCategory"])
        {
            self.isDidGetCategory = YES;
            [self setCells:nil];
            [self getOrderSpots:@{@"phone_type":@"tablet"}];
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
            self.isDidGetBanner = YES;
            [self removeObserverForNotification:noti];
            [self setCells:nil];
            [self getCategorys:@{@"phone_type":@"tablet"}];
        } else if ([noti.name isEqualToString:@"SCTheme01-DidGetOrderCategory"])
        {
            self.isDidGetCategory = YES;
            [self setCells:nil];
            [self getOrderSpots:@{@"phone_type":@"tablet"}];
            [self removeObserverForNotification:noti];
        }else if([noti.name isEqualToString:@"SCTheme01-DidGetOrderSpots"])
        {
            self.isDidGetSpotProduct = YES;
            [self setCells:nil];
            [self removeObserverForNotification:noti];
            if (bannerCollection.count > 0) {
                for (int i = 0; i < 10; i++) {
                    for (int j = 0; j < arrTemp01.count; j++) {
                        UIImageView *imageView = (UIImageView*)[arrTemp01 objectAtIndex:j];
                        if (imageView.image != nil) {
                            [_arrayImageBanner addObject:imageView.image];
                            [_arrayBannerModel addObject:[arrTemp02 objectAtIndex:j]];
                        }
                    }
                }
                [_carousel reloadData];
                [_carousel scrollToItemAtIndex:_arrayImageBanner.count/2 animated:NO];
            }
        }
    }
    //  End
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
    //  Liam UPDATE 150319
    /*
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simiRow.identifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        if ([simiRow.identifier isEqualToString:HOME_BANNER_CELL]) {
            _arrayImageBanner = [[NSMutableArray alloc]init];
            _arrayBannerModel = [[NSMutableArray alloc]init];
            
            arrTemp01 = [[NSMutableArray alloc]init];
            arrTemp02 = [[NSMutableArray alloc]init];
            
            for (SimiModel *model in bannerCollection) {
                UIImageView *imageView = [[UIImageView alloc]init];
                [imageView sd_setImageWithURL:[model valueForKey:@"image_path"]];
                [arrTemp01 addObject:imageView];
                [arrTemp02 addObject:model];
            }
            _carousel = [[iCarousel alloc]initWithFrame:CGRectMake(0, 0, 1024, 356)];
            _carousel.type = iCarouselTypeCoverFlow2;
            _carousel.dataSource = self;
            _carousel.delegate = self;
            _carousel.scrollSpeed = 1;
            [cell addSubview:_carousel];
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
            UIScrollView *scrViewSpot = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 9, cell.frame.size.width, 168)];
            scrViewSpot.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin |UIViewAutoresizingFlexibleWidth;
            scrViewSpot.showsHorizontalScrollIndicator = NO;
            int widthDistanceTwoCell = 9;
            float sizeCell = 167.7;
            int widthScrollViewContent = 0;
            for (int i = 0; i < spotProductCollection.count; i++) {
                SCSpotProductCellPad_Theme01 *spotCell = [[SCSpotProductCellPad_Theme01 alloc]initWithFrame:CGRectMake(i*(sizeCell*2 + widthDistanceTwoCell), 0, sizeCell*2, sizeCell)];
                spotCell.delegate = self;
                [spotCell cusSetSpotModel:[spotProductCollection objectAtIndex:i]];
                widthScrollViewContent += (sizeCell*2 + widthDistanceTwoCell);
                [spotCell.slideShow start];
                [scrViewSpot addSubview:spotCell];
            }
            
            [scrViewSpot setContentSize:CGSizeMake(widthScrollViewContent, sizeCell)];
            [scrViewSpot setBackgroundColor:[UIColor clearColor]];
            [cell addSubview:scrViewSpot];
        }else if ([simiRow.identifier isEqualToString:HOME_LOADING_CELL])
        {
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, cell.frame.size.width/2 - 100, 320, 100)];
            imageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
            imageView.image = [UIImage imageNamed:@"logo"];
            [imageView setContentMode:UIViewContentModeScaleAspectFit];
            CGRect frame = imageView.frame;
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, frame.origin.y + frame.size.height - 30, frame.size.width, 30)];
            label.text = [NSString stringWithFormat:@"%@...", SCLocalizedString(@"Loading")];
            label.textColor = THEME_COLOR;
            label.textAlignment = NSTextAlignmentCenter;
            label.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
            [cell addSubview:imageView];
            [cell addSubview:label];
        }
    }
     */
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simiRow.identifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        if ([simiRow.identifier isEqualToString:HOME_BANNER_CELL]) {
            if (bannerCollection.count > 0) {
                _arrayImageBanner = [[NSMutableArray alloc]init];
                _arrayBannerModel = [[NSMutableArray alloc]init];
                
                arrTemp01 = [[NSMutableArray alloc]init];
                arrTemp02 = [[NSMutableArray alloc]init];
                
                for (SimiModel *model in bannerCollection) {
                    UIImageView *imageView = [[UIImageView alloc]init];
                    [imageView sd_setImageWithURL:[model valueForKey:@"image_path"]];
                    [arrTemp01 addObject:imageView];
                    [arrTemp02 addObject:model];
                }
                _carousel = [[iCarousel alloc]initWithFrame:CGRectMake(0, 0, 1024, 356)];
                _carousel.type = iCarouselTypeCoverFlow2;
                _carousel.dataSource = self;
                _carousel.delegate = self;
                _carousel.scrollSpeed = 1;
                [cell addSubview:_carousel];
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
            UIScrollView *scrViewSpot = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 9, cell.frame.size.width, 168)];
            scrViewSpot.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin |UIViewAutoresizingFlexibleWidth;
            scrViewSpot.showsHorizontalScrollIndicator = NO;
            int widthDistanceTwoCell = 9;
            float sizeCell = 167.7;
            int widthScrollViewContent = 0;
            for (int i = 0; i < spotProductCollection.count; i++) {
                SCSpotProductCellPad_Theme01 *spotCell = [[SCSpotProductCellPad_Theme01 alloc]initWithFrame:CGRectMake(i*(sizeCell*2 + widthDistanceTwoCell), 0, sizeCell*2, sizeCell)];
                spotCell.delegate = self;
                [spotCell cusSetSpotModel:[spotProductCollection objectAtIndex:i]];
                widthScrollViewContent += (sizeCell*2 + widthDistanceTwoCell);
                [spotCell.slideShow start];
                [scrViewSpot addSubview:spotCell];
            }
            
            [scrViewSpot setContentSize:CGSizeMake(widthScrollViewContent, sizeCell)];
            [scrViewSpot setBackgroundColor:[UIColor clearColor]];
            [cell addSubview:scrViewSpot];
        }else if ([simiRow.identifier isEqualToString:HOME_LOADING_CELL])
        {
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, cell.frame.size.width/2 - 100, 320, 100)];
            imageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
            imageView.image = [UIImage imageNamed:@"logo"];
            [imageView setContentMode:UIViewContentModeScaleAspectFit];
            CGRect frame = imageView.frame;
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, frame.origin.y + frame.size.height - 30, frame.size.width, 30)];
            label.text = [NSString stringWithFormat:@"%@...", SCLocalizedString(@"Loading")];
            label.textColor = THEME_COLOR;
            label.textAlignment = NSTextAlignmentCenter;
            label.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
            [cell addSubview:imageView];
            [cell addSubview:label];
        }
    }
    return cell;
}

#pragma mark Category Delegate
- (void)didSelectCateGoryWithCateModel:(SimiCategoryModel *)cateMode
{
    SCGridViewControllerPad_Theme01 *gridViewController = [[SCGridViewControllerPad_Theme01 alloc]init];
    gridViewController.scCollectionGetProductType = SCCollectionGetProductTypeFromCategory;
    gridViewController.isCategory = YES;
    NSString *stringCateId = @"";
    if (![[NSString stringWithFormat:@"%@",[cateMode valueForKey:@"category_id"]] isEqualToString:@"-1"])
    {
        stringCateId = [NSString stringWithFormat:@"%@",[cateMode valueForKey:@"category_id"]];
    }
    gridViewController.categoryId = stringCateId;
    [self.navigationController pushViewController:gridViewController animated:YES];
}

#pragma mark SpotProduct Delegate
- (void)didSelectedSpotProductWithSpotProductModel:(SimiModel *)spotModel
{
    SCGridViewControllerPad_Theme01 *gridViewController = [[SCGridViewControllerPad_Theme01 alloc]init];
    gridViewController.scCollectionGetProductType = SCCollectionGetProductTypeFromSpotProduct ;
    gridViewController.spotKey = [[NSString stringWithFormat:@"%@",[spotModel valueForKey:scTheme01_02_spot_key]] mutableCopy];
    
    UIViewController *currentVC = [(UITabBarController *)[[(SCAppDelegate *)[[UIApplication sharedApplication]delegate] window] rootViewController] selectedViewController];
    UIViewController *viewController = [[(UINavigationController *)currentVC viewControllers] lastObject];
    [viewController.navigationController pushViewController:gridViewController animated:NO];
}

#pragma mark iCaroucel DataSource
- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view
{
    if (view == nil) {
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 60, 670, 336)];
        view = imageView;
    }
    
    [(UIImageView*)view setImage:[_arrayImageBanner objectAtIndex:index]];
    return view;
}

- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel
{
    return [_arrayImageBanner count];
}

#pragma mark iCaroucel Delegate
- (void)carousel:(iCarousel *)carousel didSelectItemAtIndex:(NSInteger)index
{
    id banner = [_arrayBannerModel objectAtIndex:index];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"DidClickBanner" object:banner];
    //king 150519
    if ([[banner valueForKey:@"type"] isEqualToString:@"2"]) {
        SCGridViewControllerPad_Theme01* nextController = [SCGridViewControllerPad_Theme01 new];
        nextController.scCollectionGetProductType = SCCollectionGetProductTypeFromCategory;
        nextController.isCategory = YES;
        nextController.categoryId = [banner valueForKey:@"categoryID"];
        [self.navigationController pushViewController:nextController animated:YES];
    }else if([[banner valueForKey:@"type"] isEqualToString:@"1"]){
        SCProductViewControllerPad_Theme01 *nextController = [SCProductViewControllerPad_Theme01 new];
        [nextController setProductId:[banner valueForKey:@"productID"]];
        [self.navigationController pushViewController:nextController animated:YES];
    }else{
        if (![[banner valueForKey:@"url"] isKindOfClass:[NSNull class]] && [banner valueForKey:@"url"] != nil){
            if ([[[banner valueForKey:@"url"] lowercaseString] rangeOfString:@"http"].location != NSNotFound) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[banner valueForKey:@"url"]]];
            }
        }
    }
//    if (![[banner valueForKey:@"url"] isKindOfClass:[NSNull class]] && [banner valueForKey:@"url"] != nil) {
//        [[NSNotificationCenter defaultCenter]postNotificationName:@"DidClickBanner" object:banner];
//        if ([[[banner valueForKey:@"url"] lowercaseString] rangeOfString:@"http"].location != NSNotFound) {
//            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[banner valueForKey:@"url"]]];
//        }
//    }
}
@end
