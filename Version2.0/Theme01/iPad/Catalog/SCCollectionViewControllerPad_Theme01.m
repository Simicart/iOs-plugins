//
//  SCCollectionViewControllerPad_Theme01.m
//  SimiCartPluginFW
//
//  Created by Nghieply91 on 9/11/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import "SCCollectionViewControllerPad_Theme01.h"
#define CELL_ID @"Cell_Table"

@implementation SCCollectionViewControllerPad_Theme01
@synthesize isRelatedProduct = _isRelatedProduct, productCollection, lbNotFound;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoadAfter
{
    [self setLayout];
    self.sortType = ProductCollectionSortNone;
    if (SIMI_SYSTEM_IOS >= 7.0) {
        lbNotFound = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, self.collectionView.frame.size.width, 40)];
    }else{
        lbNotFound = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, self.collectionView.frame.size.width, 160)];
    }
    lbNotFound.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleWidth;
    [lbNotFound setText:SCLocalizedString(@"There are no products matching the selection")];
    [lbNotFound setFont:[UIFont fontWithName:THEME01_FONT_NAME_REGULAR size:THEME_FONT_SIZE]];
    [lbNotFound setTextColor:THEME_COLOR];
    [lbNotFound setTextAlignment:NSTextAlignmentCenter];
    [lbNotFound setHidden:YES];
    [self.collectionView addSubview:lbNotFound];
    if (productCollection == nil) {
        __block __weak id weakSelf = self;
        [self.collectionView addInfiniteScrollingWithActionHandler:^{
            [weakSelf getProducts];
        }];
    }
    
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleWidth;
}

- (void)viewWillAppearAfter
{
    
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
    if (_isRelatedProduct) {
        SimiProductModel *product = [productCollection objectAtIndex:[indexPath row]];
        NSString *stringCell = [NSString stringWithFormat:@"CELL_ID%@",[product valueForKey:@"product_id"]];
        UINib *nib = [UINib nibWithNibName:@"SCCollectionViewRelatedCellPad_Theme01" bundle:nil];
        [collectionView registerNib:nib forCellWithReuseIdentifier:stringCell];
        SCCollectionViewRelatedCellPad_Theme01 * cell = [collectionView dequeueReusableCellWithReuseIdentifier:stringCell forIndexPath:indexPath];
        [cell cusSetProductModel:product];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"InitializedCollectionViewCellAtIndexPath-After" object:cell userInfo:@{@"indexPath": indexPath}];
        return cell;
    }else
    {
        SimiProductModel *product = [productCollection objectAtIndex:[indexPath row]];
        NSString *stringCell = [NSString stringWithFormat:@"CELL_ID%@",[product valueForKey:@"product_id"]];
        UINib *nib = [UINib nibWithNibName:@"SCCollectionViewCellPad_Theme01" bundle:nil];
        [collectionView registerNib:nib forCellWithReuseIdentifier:stringCell];
        SCCollectionViewCellPad_Theme01 * cell = [collectionView dequeueReusableCellWithReuseIdentifier:stringCell forIndexPath:indexPath];
        [cell cusSetProductModel:product];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"InitializedCollectionViewCellAtIndexPath-After" object:cell userInfo:@{@"indexPath": indexPath}];
        return cell;
    }
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
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DidSelectCollectionViewCellAtIndexPath" object:collectionView userInfo:@{@"indexPath": indexPath}];
    if (self.isDiscontinue) {
        self.isDiscontinue = NO;
        return;
    }
    SimiProductModel *product = [productCollection objectAtIndex:indexPath.row];
    [self.delegate selectedProduct:[product valueForKey:@"product_id"]];
}

#pragma mark setLayOut
- (void)setLayout
{
    if (_isRelatedProduct) {
        UICollectionViewFlowLayout *grid = [[UICollectionViewFlowLayout alloc]init];
        grid.itemSize = CGSizeMake(200, 200);
        grid.minimumInteritemSpacing = 0;
        grid.minimumLineSpacing = 20;
        [self.collectionView setCollectionViewLayout:grid];
        [self.collectionView setContentInset:UIEdgeInsetsMake(60, 15, 30, 0)];
        self.collectionView.showsVerticalScrollIndicator = NO;
    }else
    {
        UICollectionViewFlowLayout *grid = [[UICollectionViewFlowLayout alloc]init];
        grid.itemSize = CGSizeMake(212, 212);
        grid.minimumInteritemSpacing = 35;
        grid.minimumLineSpacing = 35;
        [self.collectionView setCollectionViewLayout:grid];
        [self.collectionView setContentInset:UIEdgeInsetsMake(35, 35, 0, 35)];
        self.collectionView.showsVerticalScrollIndicator = NO;
    }
    
}
@end
