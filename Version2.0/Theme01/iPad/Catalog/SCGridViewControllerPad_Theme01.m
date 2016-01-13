//
//  SCGridViewControllerPad_Theme01.m
//  SimiCartPluginFW
//
//  Created by Nghieply91 on 9/12/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//
#import <SimiCartBundle/UIImage+SimiCustom.h>
#import <SimiCartBundle/SimiCategoryModelCollection.h>

#import "SimiThemeWorker.h"
#import "SCGridViewControllerPad_Theme01.h"
#import "SimiViewController+Theme01.h"

@interface SCGridViewControllerPad_Theme01 ()

@property (strong, nonatomic) NSString *keySearchProduct;
@property (strong, nonatomic) UIPopoverController *popController;
@property (strong, nonatomic) UILabel *lblNumberProduct;
@property (strong, nonatomic) ILTranslucentView *viewToolBar;
@property (strong, nonatomic) SCMenuSort_Theme01 *menuSort;
@property (strong, nonatomic) UIButton *btnCategory;

@property (strong, nonatomic) SCMenuCategory_Theme01 *scMenuCategory;
@property (strong, nonatomic) SCMenuCategory_v2 *scMenuCategory_v2;
@property (strong, nonatomic) SimiCategoryModelCollection *categoryCollection;
@end


@implementation SCGridViewControllerPad_Theme01
{
    BOOL isFirstLoad; // Check the first load
}
@synthesize viewToolBar, scCollectionView, categoryId = _categoryId;

//  Liam ADD 150326
@synthesize btnSort, btnFilter, filterViewController, filterParam, isFiltering;
@synthesize categoryName, btnCategory;
//  End

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
    isFirstLoad = YES;
    // Do any additional setup after loading the view.
    [self setToSimiView];
    [self viewToolBar];
    self.view.backgroundColor = [UIColor whiteColor];
    
    UICollectionViewLayout* stackLayout = [[UICollectionViewLayout alloc] init];
    scCollectionView = [[SCCollectionViewControllerPad_Theme01 alloc]initWithCollectionViewLayout:stackLayout];
    [scCollectionView.collectionView setFrame:CGRectMake(0, 50, self.view.frame.size.width, self.view.frame.size.height - viewToolBar.frame.size.height)];
    scCollectionView.scCollectionGetProductType = _scCollectionGetProductType;
    if (_spotKey) {
        scCollectionView.spotKey = [_spotKey copy];
    }
    if (_categoryId) {
        scCollectionView.categoryId = [_categoryId copy];
    }
    scCollectionView.delegate = self;
    if (_keySearchProduct) {
        scCollectionView.searchProduct = [_keySearchProduct copy];
    }
    [self.view addSubview:scCollectionView.collectionView];
    [self.view addSubview:viewToolBar];
    switch (_scCollectionGetProductType) {
        case SCCollectionGetProductTypeFromCategory:
        {
            NSString *strHaveAllProDuct = [NSString stringWithFormat:@"%@",[[[[SimiGlobalVar sharedInstance]store] valueForKey:@"store_config"]valueForKey:@"is_show_link_all_product"]];
            if ([_categoryId isEqualToString:@"-1"]|| _categoryId == nil || [_categoryId isEqualToString:@""]) {
                if ([strHaveAllProDuct isEqualToString:@"1"]) {
                    [scCollectionView getProducts];
                }else
                {
                    [self getCategories];
                }
            }else
            {
                [scCollectionView getProducts];
            }
        }
            break;
        default:
            [self.scCollectionView getProducts];
            break;
    }
    [self setNavigationBarOnViewDidLoadForTheme01];
}

- (void)viewWillAppearAfter:(BOOL)animated
{
    [self setNavigationBarOnViewWillAppearForTheme01];
    if (_scCollectionGetProductType == SCCollectionGetProductTypeFromSearch) {
        [[NSNotificationCenter defaultCenter]postNotificationName:@"SCSearchViewControllerPad-ViewDidAppear" object:nil];
    }
}

- (void)viewWillDisappearAfter:(BOOL)animated
{
    [self deleteBackItemForTheme01];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - viewToolBar
- (UIView*)viewToolBar
{
    CGRect frame = self.view.frame;
    
    frame.origin.y = 0;
    frame.size.height = 50;
    viewToolBar = [[ILTranslucentView alloc] initWithFrame:frame];
    viewToolBar.backgroundColor = [UIColor clearColor];
    viewToolBar.translucentTintColor = [UIColor clearColor];
    viewToolBar.alpha = 1;
    viewToolBar.translucentStyle = UIBarStyleDefault;
    viewToolBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    if (SIMI_SYSTEM_IOS < 7.0) {
        viewToolBar.backgroundColor = [UIColor whiteColor];
    }
    
    _lblNumberProduct = [[UILabel alloc]initWithFrame:CGRectMake(450, 0, 40, 50)];
    [_lblNumberProduct setFont:[UIFont fontWithName:THEME01_FONT_NAME_REGULAR size:22]];
    [_lblNumberProduct setTextColor:[UIColor orangeColor]];
    [_lblNumberProduct setText:@"0"];
    [_lblNumberProduct setTextAlignment:NSTextAlignmentRight];

    
    UILabel *lblProduct = [[UILabel alloc]initWithFrame:CGRectMake(500, 0, 150, 50)];
    [lblProduct setFont:[UIFont fontWithName:THEME01_FONT_NAME_LIGHT size:22]];
    [lblProduct setText:SCLocalizedString(@"PRODUCTS")];

    UIImageView *imgSort = [[UIImageView alloc]initWithFrame:CGRectMake(SCREEN_WIDTH - 110, 14, 16, 22)];
    [imgSort setImage:[UIImage imageNamed:@"theme01_icon_sort_ipad"]];
    
    UILabel *lblSort = [[UILabel alloc]initWithFrame:CGRectMake(imgSort.frame.origin.x + imgSort.frame.size.width, 5, 90, 40)];
    [lblSort setFont:[UIFont fontWithName:THEME01_FONT_NAME_LIGHT size:24]];
    [lblSort setText:SCLocalizedString(@"Sort")];
    
    
    if (!btnSort) {
        btnSort=[UIButton buttonWithType:UIButtonTypeCustom ];
    }
    [btnSort setFrame:CGRectMake(imgSort.frame.origin.x, 5, 110, 40)];
    [btnSort addTarget:self action:@selector(btnSort:) forControlEvents:UIControlEventTouchUpInside];
    btnSort.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
    
    if (viewToolBar) {
        UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, viewToolBar.frame.size.height-1, SCREEN_WIDTH, 1)];
        [v setBackgroundColor:[UIColor lightGrayColor]];
        v.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [viewToolBar addSubview:v];
        [viewToolBar addSubview:imgSort];
        [viewToolBar addSubview:lblSort];
        [viewToolBar addSubview:btnSort];
        [viewToolBar addSubview:lblProduct];
        [viewToolBar addSubview:_lblNumberProduct];
    }
    int x = 10;
    int y = 5;
    if (_isCategory) {
        if (!btnCategory) {
            btnCategory=[UIButton buttonWithType:UIButtonTypeCustom ];
        }
        [btnCategory setFrame:CGRectMake(x, y, 150, 40)];
        x += 150;
        [btnCategory setImage:[UIImage imageNamed:@"theme1_btncategory"]forState:UIControlStateNormal];
        [btnCategory setTitle:SCLocalizedString(@"Category") forState:UIControlStateNormal];
        [btnCategory setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btnCategory.titleLabel setFont:[UIFont fontWithName:THEME01_FONT_NAME_LIGHT size:24]];
        [btnCategory addTarget:self action:@selector(btnCategory:) forControlEvents:UIControlEventTouchUpInside];
        btnCategory.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
        [viewToolBar addSubview:btnCategory];
    }
    
    //  Liam ADD 150326
    if (btnFilter == nil) {
        btnFilter = [UIButton buttonWithType:UIButtonTypeCustom];
    }
    [btnFilter setFrame:CGRectMake(x, y, 100, CGRectGetHeight(viewToolBar.frame)- 2*y)];
    [btnFilter setBackgroundColor:[UIColor clearColor]];
    [btnFilter setImage:[UIImage imageNamed:@"theme01_filter"] forState:UIControlStateNormal];
    [btnFilter setTitle:SCLocalizedString(@"Filter") forState:UIControlStateNormal];
    [btnFilter.titleLabel setFont:[UIFont fontWithName:THEME01_FONT_NAME_LIGHT size:24]];
    [btnFilter setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btnFilter addTarget:self action:@selector(filter) forControlEvents:UIControlEventTouchUpInside];
    [btnFilter setHidden:YES];
    [viewToolBar addSubview:btnFilter];
    //  End
    return viewToolBar;
}

#pragma mark Action
- (void)btnSort:(id)sender
{
    UIButton* senderButton = (UIButton*)sender;
    if ( _menuSort== nil) {
        //Create the ColorPickerViewController.
        _menuSort = [[SCMenuSort_Theme01 alloc] initWithStyle:UITableViewStylePlain];
        _menuSort.tableView.showsVerticalScrollIndicator = NO;
        //Set this VC as the delegate.
        _menuSort.delegate = self;
    }
    if (_popController == nil) {
        //The color picker popover is not showing. Show it.
        _popController = [[UIPopoverController alloc] initWithContentViewController:_menuSort];
        if(SIMI_SYSTEM_IOS >= 7.0)
            [_popController setBackgroundColor:[UIColor whiteColor]];
        [_popController setDelegate:self];
        [_popController presentPopoverFromRect:senderButton.bounds inView:senderButton permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    } else {
        //The color picker popover is showing. Hide it.
        [_popController dismissPopoverAnimated:YES];
        _popController = nil;
    }
}

- (void)btnCategory:(id)sender
{
    UIButton* senderButton = (UIButton*)sender;
    if (_scMenuCategory == nil) {
        //Create the ColorPickerViewController.
        _scMenuCategory = [[SCMenuCategory_Theme01 alloc] initWithStyle:UITableViewStylePlain];
        //Set this VC as the delegate.
        _scMenuCategory.delegate = self;
        _scMenuCategory.categoryId = _categoryId;
    }
    if (_scMenuCategory_v2 == nil) {
        _scMenuCategory_v2 = [[SCMenuCategory_v2 alloc]initWithStyle:UITableViewStylePlain];
        _scMenuCategory_v2.delegate = self;
        _scMenuCategory_v2.categoryId = _categoryId;
    }
    
    if (_popController == nil) {
        //The color picker popover is not showing. Show it.
        NSString *strHaveAllProDuct = [NSString stringWithFormat:@"%@",[[[[SimiGlobalVar sharedInstance]store] valueForKey:@"store_config"]valueForKey:@"is_show_link_all_product"]];
        if ([strHaveAllProDuct isEqualToString:@"1"]) {
            _popController = [[UIPopoverController alloc] initWithContentViewController:_scMenuCategory];
        }else
        {
            _popController = [[UIPopoverController alloc] initWithContentViewController:_scMenuCategory_v2];
        }
        
        if (SIMI_SYSTEM_IOS >= 7.0)
            [_popController setBackgroundColor:[UIColor whiteColor]];
        _popController.delegate = self;
        [_popController presentPopoverFromRect:senderButton.bounds inView:senderButton permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    } else {
        //The color picker popover is showing. Hide it.
        [_popController dismissPopoverAnimated:YES];
        _popController = nil;
    }
}

#pragma mark MenuSort Delegate
-(void)selectedMenuSort:(ProductCollectionSortType)categoryId rowSelect:(int)rowSelect;
{
    scCollectionView.sortType = categoryId;
    [scCollectionView.productCollection removeAllObjects];
    [scCollectionView.collectionView reloadData];
    [scCollectionView getProducts];
    [_popController dismissPopoverAnimated:YES];
}

#pragma mark UIPopoverController Delegate

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    if (_popController) {
        _popController = nil;
    }
    if (_popControllerFilter) {
        _popControllerFilter = nil;
    }
}

#pragma mark - searchProduct

-(void)searchProductWithKey:(NSString *)key{
    if (scCollectionView) {
        if ([key isEqualToString:_keySearchProduct]) {
            return;
        }
        _keySearchProduct = key;
        scCollectionView.searchProduct = key;
        [scCollectionView.productCollection removeAllObjects];
        [scCollectionView.collectionView reloadData];
        [scCollectionView getProducts];
    }else{
        _keySearchProduct = key;
    }
}

#pragma mark CollectionView Delegate
- (void)selectedProduct:(NSString *)productId_
{
    SCProductViewControllerPad_Theme01 *productController = [[SCProductViewControllerPad_Theme01 alloc]init];
    productController.productId = [productId_ copy];
    
    UIViewController *currentVC = [(UITabBarController *)[[(SCAppDelegate *)[[UIApplication sharedApplication]delegate] window] rootViewController] selectedViewController];
    UIViewController *viewController = [[(UINavigationController *)currentVC viewControllers] lastObject];
    [viewController.navigationController pushViewController:productController animated:NO];
}

- (void)numberProductChange:(int)numberProduct;
{
    [_lblNumberProduct setText:[NSString stringWithFormat:@"%d",numberProduct]];
}

#pragma mark Menu Categroy Delegate
- (void)selectedIDMenu:(NSString *)categoryId
{
    //  Liam ADD 150327
    filterParam = @{};
    //  End
    self.categoryId = categoryId;
    self.scCollectionView.categoryId = categoryId;
    self.scCollectionView.productCollection = nil;
    [self.scCollectionView getProducts];
}

-(void)selectedIDMenu:(NSString*)categoryId categoryName:(NSString*)categoryName
{
    //  Liam ADD 150327
    filterParam = @{};
    //  End
    self.categoryId = categoryId;
    self.scCollectionView.categoryId = categoryId;
    self.scCollectionView.productCollection = nil;
    [self.scCollectionView getProducts];
}

#pragma mark getFirstCategory ID

- (void)getCategories
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetCategories:) name:@"DidGetCategoryCollection" object:_categoryCollection];
    if (_categoryCollection == nil) {
        _categoryCollection = [[SimiCategoryModelCollection alloc]init];
    }
    [_categoryCollection getCategoryCollectionWithParentId:@""];
    
}
- (void)didGetCategories:(NSNotification *)noti
{
    if (isFirstLoad) {
        isFirstLoad = NO;
        SimiResponder *responder = (SimiResponder *)[noti.userInfo valueForKey:@"responder"];
        if ([[responder.status uppercaseString] isEqualToString:@"SUCCESS"]){
            SimiCategoryModel *cateModel = [_categoryCollection objectAtIndex:0];
            scCollectionView.categoryId = [cateModel valueForKey:@"category_id"];
            [scCollectionView getProducts];
        }
        [self removeObserverForNotification:noti];
    }
}


#pragma mark Filter & SCCollectionView Delegate
- (void)startGetProductModelCollection
{
    btnSort.enabled = NO;
    btnFilter.enabled = NO;
    btnCategory.enabled = NO;
    btnSort.alpha = 0.5;
    [btnSort setBackgroundColor:[UIColor whiteColor]];
    btnFilter.alpha = 0.5;
    btnCategory.alpha = 0.5;
}
- (void)didGetProductModelCollection:(NSDictionary*)layerNavigation
{
    btnSort.enabled = YES;
    btnSort.alpha = 1.0;
    [btnSort setBackgroundColor:[UIColor clearColor]];
    btnCategory.enabled = YES;
    btnCategory.alpha = 1.0;;
    if (filterViewController == nil) {
        filterViewController = [SCFilterViewController new];
        filterViewController.delegate = self;
    }
    filterViewController.filterContent = layerNavigation;
    if ([(NSMutableArray*)[filterViewController.filterContent valueForKey:@"layer_state"] count] > 0 || [(NSMutableArray*)[filterViewController.filterContent valueForKey:@"layer_filter"] count] > 0) {
        btnFilter.enabled = YES;
        btnFilter.alpha = 1.0;
        [btnFilter setHidden:NO];
    }
}
- (void)filterWithParam:(NSMutableDictionary *)param
{
    [_popControllerFilter dismissPopoverAnimated:YES];
    [scCollectionView setFilterParam:param];
    [scCollectionView.productCollection removeAllObjects];
    [scCollectionView.collectionView reloadData];
    [scCollectionView getProducts];
}

- (void)filter
{
    if (_popControllerFilter == nil) {
        _popControllerFilter = [[UIPopoverController alloc]initWithContentViewController:filterViewController];
        _popControllerFilter.delegate = self;
        [_popControllerFilter setBackgroundColor:[UIColor whiteColor]];
        if (SIMI_SYSTEM_IOS > 7.0){
            [_popControllerFilter setBackgroundColor:[UIColor clearColor]];
        }
    }
    [_popControllerFilter presentPopoverFromRect:btnFilter.bounds inView:btnFilter permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
}
@end
