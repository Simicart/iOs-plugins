//
//  ZThemeCollectionViewController.m
//  SimiCartPluginFW
//
//  Created by Nghieply91 on 4/7/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import "ZThemeCollectionViewController.h"

#import <SimiCartBundle/UILabelDynamicSize.h>

#import "ZThemeCollectionViewCell.h"

@interface ZThemeCollectionViewController ()

@end

@implementation ZThemeCollectionViewController

static NSString * const reuseIdentifier = @"CellTable";

@synthesize productCollection, categoryId, sortType, lbNotFound;
@synthesize isShowOnlyImage;

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
        lbNotFound = [[UILabel alloc] initWithFrame:CGRectMake(0, 50, self.collectionView.frame.size.width - 20, 40)];
    }else{
        lbNotFound = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, self.collectionView.frame.size.width - 20, 160)];
    }
    [lbNotFound setText:SCLocalizedString(@"There are no products matching the selection.")];
    [lbNotFound setFont:[UIFont fontWithName:THEME_FONT_NAME size:THEME_FONT_SIZE]];
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
    
    self.gesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(didReceivePinchGesture:)];
    [self.collectionView addGestureRecognizer:self.gesture];
    self.animatedZooming = YES;
    self.scale = 1;
    self.lastContentOffset = 0;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [self viewWillAppearAfter];
}

- (void)viewWillAppearAfter
{
    
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark UICollectionView Data Source

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    SimiProductModel *product = [productCollection objectAtIndex:[indexPath row]];
    NSString *stringCell = [NSString stringWithFormat:@"CELL_ID%@",[product valueForKey:@"product_id"]];
    [collectionView registerClass:[ZThemeCollectionViewCell class] forCellWithReuseIdentifier:stringCell];
    ZThemeCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:stringCell forIndexPath:indexPath];
    if (cell.isShowOnlyImage != isShowOnlyImage) {
        cell.isShowOnlyImage = isShowOnlyImage;
        cell.isChangeLayOut = YES;
    }else
    {
        cell.isChangeLayOut = NO;
    }
    [cell cusSetProductModel:product];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"InitializedCollectionViewCellAtIndexPath-After" object:cell userInfo:@{@"indexPath": indexPath}];
    return cell;
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
    if (self.productCollection == nil) {
        self.productCollection = [[ZThemeProductModelCollection alloc] init];
    }
    
    NSInteger offset = self.productCollection.count;
    if (offset == self.totalNumberProduct && offset > 0) {
        [self.collectionView.infiniteScrollingView stopAnimating];
        return;
    }
    [self.delegate startGetProductModelCollection];
    [self.lbNotFound setHidden:YES];
    if (self.filterParam == nil) {
        self.filterParam = [[NSMutableDictionary alloc]initWithDictionary:@{}];
    }
    switch (self.collectionGetProductType) {
        case ZThemeCollectioViewGetProductTypeFromSearch:
        {
            if (self.searchProduct && ![self.searchProduct isEqualToString:@""] ) {
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetProducts:) name:@"DidSearchProducts" object:self.productCollection];
                if (!self.categoryId) {
                    [self.productCollection searchProductsWithKey:self.searchProduct offset:offset limit:24 categoryId:@"" sortType:self.sortType otherParams:@{@"width": @"300", @"height": @"375", @"filter":self.filterParam}];
                }else{
                    [self.productCollection searchProductsWithKey:self.searchProduct offset:offset limit:24 categoryId:categoryId sortType:self.sortType otherParams:@{@"width": @"300", @"height": @"375", @"filter":self.filterParam}];
                }
            }
        }
            break;
        case ZThemeCollectioViewGetProductTypeFromCategory:
        {
            if (![self.categoryId boolValue]) {
                //Get All Product
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetProducts:) name:@"DidGetAllProducts" object:self.productCollection];
                [self.productCollection getAllProductsWithOffset:offset limit:24 sortType:self.sortType otherParams:@{@"width": @"300", @"height": @"375", @"filter":self.filterParam}];
            }else{
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetProducts:) name:@"DidGetProductCollectionWithCategoryId" object:self.productCollection];
                [self.productCollection getProductCollectionWithCategoryId:self.categoryId offset:offset limit:24 sortType:self.sortType otherParams:@{@"width": @"300", @"height": @"375", @"filter":self.filterParam}];
            }
        }
            break;
        case ZThemeCollectioViewGetProductTypeFromSpot:
        {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetProducts:) name:@"SCTheme01-DidGetSpotProducts" object:self.productCollection];
            NSString *stringOffet = [NSString stringWithFormat:@"%d",(int)offset];
            [self.productCollection getSpotProductsWithKey:self.spot_ID limit:@"24" ofset:stringOffet width:@"300" height:@"375" sortOption:self.sortType];
        }
            break;
        default:
            break;
    }
    [self.collectionView.infiniteScrollingView startAnimating];
}


- (void)didGetProducts:(NSNotification *)noti{
    responder = [noti.userInfo valueForKey:@"responder"];
    if ([responder.status isEqualToString:@"SUCCESS"]) {
        self.totalNumberProduct = [[responder.message objectAtIndex:0] intValue];
        [self.delegate numberProductChange:self.totalNumberProduct];
        [self.collectionView reloadData];
        self.arrayProductsID = (NSMutableArray*)[[responder.other objectAtIndex:0] valueForKey:@"product_id_array"];
    }
    [self.delegate didGetProductModelCollection:responder.layerNavigation];
    if ([self.productCollection count] == 0) {
        [self.lbNotFound setHidden:NO];
    }else{
        [self.lbNotFound setHidden:YES];
    }
    [self removeObserverForNotification:noti];
    [self.collectionView.infiniteScrollingView stopAnimating];
}
#pragma mark setLayOut
- (void)setLayout
{
    if (isShowOnlyImage) {
        UICollectionViewFlowLayout *grid = [[UICollectionViewFlowLayout alloc]init];
        grid.itemSize = CGSizeMake(71.25, 89);
        grid.minimumInteritemSpacing = 7;
        grid.minimumLineSpacing = 7;
        [self.collectionView setCollectionViewLayout:grid animated:YES];
        [self.collectionView setContentInset:UIEdgeInsetsMake(35, 7, 0, 7)];
        self.collectionView.showsVerticalScrollIndicator = NO;
    }else
    {
        UICollectionViewFlowLayout *grid = [[UICollectionViewFlowLayout alloc]init];
        grid.itemSize = CGSizeMake(149.5, 237);
        grid.minimumInteritemSpacing = 7;
        grid.minimumLineSpacing = 7;
        [self.collectionView setCollectionViewLayout:grid animated:YES];
        [self.collectionView setContentInset:UIEdgeInsetsMake(35, 7, 0, 7)];
        self.collectionView.showsVerticalScrollIndicator = NO;
    }
}

- (void)didReceivePinchGesture:(UIPinchGestureRecognizer*)gesture
{
    static CGFloat scaleStart;
    
    if (gesture.state == UIGestureRecognizerStateBegan)
    {
        // Take an snapshot of the initial scale
        scaleStart = self.scale;
        return;
    }
    if (gesture.state == UIGestureRecognizerStateEnded)
    {
        // Apply the scale of the gesture to get the new scale
        self.scale = scaleStart * gesture.scale;
        if (self.scale > scaleStart && isShowOnlyImage == YES ) {
            isShowOnlyImage = NO;
        }
        
        if (self.scale < scaleStart && isShowOnlyImage == NO) {
            isShowOnlyImage = YES;
            [self.delegate numberProductChange:self.totalNumberProduct];
        }
        [self setLayout];
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            
            // Reload the respective collection view row using the main thread.
            
            [self.collectionView reloadItemsAtIndexPaths:[self.collectionView
                                                          indexPathsForVisibleItems]];
            
        }];
    }
}

#pragma mark Scroll View Delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (self.lastContentOffset > scrollView.contentOffset.y)
    {
        [self.delegate setHideViewToolBar:NO];
    }
    else if (self.lastContentOffset < scrollView.contentOffset.y)
    {
        [self.delegate setHideViewToolBar:YES];
    }
    
    self.lastContentOffset = scrollView.contentOffset.y;
}
@end
