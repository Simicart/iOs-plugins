//
//  SCCollectionViewController_Theme01.m
//  SimiCartPluginFW
//
//  Created by Nghieply91 on 12/18/14.
//  Copyright (c) 2014 Trueplus. All rights reserved.
//

#import <SimiCartBundle/UILabelDynamicSize.h>
#import "SCCollectionViewController_Theme01.h"
#import "SCProductViewController_Theme01.h"
#import "SimiThemeWorker.h"

#define CELL_ID @"Cell_Table"

@interface SCCollectionViewController_Theme01 ()
@end

@implementation SCCollectionViewController_Theme01
@synthesize productCollection, categoryId, sortType, lbNotFound, isTax;

#pragma mark Main Method
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self viewDidLoadAfter];
}

- (void)viewDidLoadAfter
{
    [self setLayout];
    sortType = ProductCollectionSortNone;
    if (SIMI_SYSTEM_IOS >= 7.0) {
        lbNotFound = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, self.collectionView.frame.size.width - 20, 40)];
    }else{
        lbNotFound = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, self.collectionView.frame.size.width - 20, 160)];
    }
    [lbNotFound setText:SCLocalizedString(@"There are no products matching the selection.")];
    [lbNotFound setFont:[UIFont fontWithName:THEME01_FONT_NAME_REGULAR size:THEME_FONT_SIZE]];
    [lbNotFound setTextColor:THEME_COLOR];
    [lbNotFound resizLabelToFit];
    [lbNotFound setTextAlignment:NSTextAlignmentCenter];
    [lbNotFound setHidden:YES];
    [self.collectionView addSubview:lbNotFound];
    
    __block __weak id weakSelf = self;
    [self.collectionView addInfiniteScrollingWithActionHandler:^{
        [weakSelf getProducts];
    }];
    
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleWidth;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [self viewWillAppearAfter];
}

- (void)viewWillAppearAfter
{
    self.navigationItem.rightBarButtonItems = [[[SimiThemeWorker sharedInstance]navigationBar] rightButtonItems];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark UICollectionView Data Source

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    //  Liam UPDATE 150327
    SimiProductModel *product = [productCollection objectAtIndex:[indexPath row]];
    NSString *stringCell = [NSString stringWithFormat:@"CELL_ID%@",[product valueForKey:@"product_id"]];
    /*
    UINib *nib = [UINib nibWithNibName:@"SCCollectionViewCell_Theme01" bundle:nil];
    [collectionView registerNib:nib forCellWithReuseIdentifier:stringCell];
     */
    [collectionView registerClass:[SCCollectionViewCell_Theme01 class] forCellWithReuseIdentifier:stringCell];
    SCCollectionViewCell_Theme01 *cell = [collectionView dequeueReusableCellWithReuseIdentifier:stringCell forIndexPath:indexPath];
    [cell cusSetProductModel:product];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"InitializedCollectionViewCellAtIndexPath-After" object:cell userInfo:@{@"indexPath": indexPath}];
    return cell;
    //  End
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.productCollection ? [self.productCollection count] : 0;
}


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    [collectionView.collectionViewLayout invalidateLayout];
    return 1;
}

#pragma mark -
#pragma mark UICollectionView Delegate
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DidSelectProductListCellAtIndexPath" object:collectionView userInfo:@{@"indexPath": indexPath}];
    if (self.isDiscontinue) {
        self.isDiscontinue = NO;
        return;
    }
    
    SimiProductModel *product = [productCollection objectAtIndex:indexPath.row];
    [self.delegate selectedProduct:[product valueForKey:@"product_id"]];
}

#pragma mark GetProducts
- (void)getProducts{
    [self.delegate startGetProductModelCollection];
    [self.lbNotFound setHidden:YES];
    if (self.productCollection == nil) {
        self.productCollection = [[SCTheme01ProductModelCollection alloc] init];
    }
    
    NSInteger offset = self.productCollection.count;
    //  Liam UPDATE 150326
    if (self.filterParam == nil) {
        self.filterParam = [[NSMutableDictionary alloc]initWithDictionary:@{}];
    }
    switch (self.scCollectionGetProductType) {
        case SCCollectionGetProductTypeFromSearch:
        {
            if (self.searchProduct && ![self.searchProduct isEqualToString:@""] ) {
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetProducts:) name:@"DidSearchProducts" object:self.productCollection];
                if (!self.categoryId) {
                    [self.productCollection searchProductsWithKey:self.searchProduct offset:offset limit:12 categoryId:@"" sortType:self.sortType otherParams:@{@"width": @"424", @"height": @"424", @"filter":self.filterParam}];
                }else{
                    [self.productCollection searchProductsWithKey:self.searchProduct offset:offset limit:12 categoryId:categoryId sortType:self.sortType otherParams:@{@"width": @"424", @"height": @"424", @"filter":self.filterParam}];
                }
            }
        }
            break;
        case SCCollectionGetProductTypeFromCategory:
        {
            if (![self.categoryId boolValue]) {
                //Get All Product
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetProducts:) name:@"DidGetAllProducts" object:self.productCollection];
                [self.productCollection getAllProductsWithOffset:offset limit:12 sortType:self.sortType otherParams:@{@"width": @"424", @"height": @"424", @"filter":self.filterParam}];
            }else{
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetProducts:) name:@"DidGetProductCollectionWithCategoryId" object:self.productCollection];
                [self.productCollection getProductCollectionWithCategoryId:self.categoryId offset:offset limit:12 sortType:self.sortType otherParams:@{@"width": @"424", @"height": @"424", @"filter":self.filterParam}];
            }
        }
            break;
        case SCCollectionGetProductTypeFromSpotProduct:
        {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetProducts:) name:@"SCTheme01-DidGetSpotProducts" object:self.productCollection];
            NSString *stringOffet = [NSString stringWithFormat:@"%d",(int)offset];
            [self.productCollection getSpotProductsWithKey:self.spotKey limit:@"12" ofset:stringOffet width:@"424" height:@"424" sortOption:self.sortType];
        }
            break;
        default:
            break;
    }
    //  End
    [self.collectionView.infiniteScrollingView startAnimating];
}

- (void)didGetProducts:(NSNotification *)noti{
    responder = [noti.userInfo valueForKey:@"responder"];
    if ([(NSDictionary*)[responder.other objectAtIndex:0] valueForKey:@"is_show_both_tax"]) {
        if ([[NSString stringWithFormat:@"%@",[(NSDictionary*)[responder.other objectAtIndex:0] valueForKey:@"is_show_both_tax"]] isEqualToString:@"1"]) {
            isTax = YES;
        }
    }
    if ([responder.status isEqualToString:@"SUCCESS"]) {
        int temp = [[responder.message objectAtIndex:0] intValue];
        [self.delegate numberProductChange:temp];
        [self.collectionView reloadData];
    }
    //  Liam UPDATE 150325
    [self.delegate didGetProductModelCollection:responder.layerNavigation];
     if ([self.productCollection count] == 0) {
     [self.lbNotFound setHidden:NO];
     }else{
     [self.lbNotFound setHidden:YES];
     }
    //  End
    [self removeObserverForNotification:noti];
    [self.collectionView.infiniteScrollingView stopAnimating];
}

#pragma mark setLayOut
- (void)setLayout
{
    UICollectionViewFlowLayout *grid = [[UICollectionViewFlowLayout alloc]init];
    grid.itemSize = CGSizeMake(156, 156);
    grid.minimumInteritemSpacing = 6;
    grid.minimumLineSpacing = 6;
    [self.collectionView setCollectionViewLayout:grid];
    [self.collectionView setContentInset:UIEdgeInsetsZero];
    self.collectionView.showsVerticalScrollIndicator = NO;
}


@end
