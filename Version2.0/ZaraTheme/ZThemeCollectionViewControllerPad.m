//
//  ZThemeCollectionViewControllerPad.m
//  SimiCartPluginFW
//
//  Created by Cody Nguyen on 5/14/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import "ZThemeCollectionViewControllerPad.h"

#import <SimiCartBundle/UILabelDynamicSize.h>

#import "ZThemeCollectionViewCell.h"

@interface ZThemeCollectionViewControllerPad ()

@end

@implementation ZThemeCollectionViewControllerPad

#pragma mark Init Functions

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    SimiProductModel *product = [self.productCollection objectAtIndex:[indexPath row]];
    NSString *stringCell = [NSString stringWithFormat:@"CELL_ID%@",[product valueForKey:@"product_id"]];
    [collectionView registerClass:[ZThemeCollectionViewCell class] forCellWithReuseIdentifier:stringCell];
    ZThemeCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:stringCell forIndexPath:indexPath];
    if (cell.isShowOnlyImage != self.isShowOnlyImage) {
        cell.isShowOnlyImage = self.isShowOnlyImage;
        cell.isChangeLayOut = YES;
    }else
    {
        cell.isChangeLayOut = NO;
        
    }
    [cell cusSetProductModel:product];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"InitializedCollectionViewCellAtIndexPath-After" object:cell userInfo:@{@"indexPath": indexPath}];
    [self applyCellPadStyle:cell];
    return cell;
}
#pragma mark Actions

- (void)applyCellPadStyle: (ZThemeCollectionViewCell *)cell
{
    if (cell.isShowOnlyImage) {
        [cell.imageProduct setFrame:CGRectMake(0, 0, 158, 197)];
    }else
    {
        [cell.imageProduct setFrame:CGRectMake(0, 10, 460, 573)];
        [cell.lblNameProduct setFrame:CGRectMake(0, 588, 460, 20)];
        [cell.lblNameProduct setTextAlignment:NSTextAlignmentCenter];
        //  Liam Update RTL
        if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
            [self labelPositionChanging:cell.viewLine:176];
            [self labelPositionChanging:cell.lblIncl:156];
            [self labelPositionChanging:cell.lblInclPrice:136];
            [self labelPositionChanging:cell.lblExcl:196];
            [self labelPositionChanging:cell.lblExclPrice:176];
        }else
        {
            [self labelPositionChanging:cell.viewLine:146];
            [self labelPositionChanging:cell.lblIncl:166];
            [self labelPositionChanging:cell.lblInclPrice:176];
            [self labelPositionChanging:cell.lblExcl:146];
            [self labelPositionChanging:cell.lblExclPrice:156];
        }
        //  End RTL
    }
    
    [cell.imageFog setFrame:CGRectMake(0, cell.imageProduct.frame.origin.y, cell.imageProduct.frame.size.width, cell.imageProduct.frame.size.height)];
}

- (void)labelPositionChanging: (UIView *)label :(CGFloat)xValueChange
{
    CGRect frame = label.frame;
    frame.size.width += 10;
    frame.origin.x += xValueChange;
    frame.origin.y += 400;
    if ((frame.origin.x <= label.superview.frame.size.width) && (frame.origin.y <= label.superview.frame.size.height)) {
        [label setFrame:frame];
    }
}

- (void)viewDidLoadAfter
{
    [self setLayout];
    self.sortType = ProductCollectionSortNone;
    if (SIMI_SYSTEM_IOS >= 7.0) {
        self.lbNotFound = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, self.collectionView.frame.size.width - 20, 40)];
    }else{
        self.lbNotFound = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, self.collectionView.frame.size.width - 20, 160)];
    }
    [self.lbNotFound setText:SCLocalizedString(@"There are no products matching the selection.")];
    [self.lbNotFound setFont:[UIFont fontWithName:THEME_FONT_NAME size:THEME_FONT_SIZE]];
    [self.lbNotFound setTextColor:THEME_COLOR];
    [self.lbNotFound resizLabelToFit];
    [self.lbNotFound setTextAlignment:NSTextAlignmentCenter];
    [self.lbNotFound setHidden:YES];
    [self.collectionView addSubview:self.lbNotFound];
    
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
                    [self.productCollection searchProductsWithKey:self.searchProduct offset:offset limit:24 categoryId:@"" sortType:self.sortType otherParams:@{@"width": @"600", @"height": @"750", @"filter":self.filterParam}];
                }else{
                    [self.productCollection searchProductsWithKey:self.searchProduct offset:offset limit:24 categoryId:self.categoryId sortType:self.sortType otherParams:@{@"width": @"600", @"height": @"750", @"filter":self.filterParam}];
                }
            }
        }
            break;
        case ZThemeCollectioViewGetProductTypeFromCategory:
        {
            if (![self.categoryId boolValue]) {
                //Get All Product
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetProducts:) name:@"DidGetAllProducts" object:self.productCollection];
                [self.productCollection getAllProductsWithOffset:offset limit:24 sortType:self.sortType otherParams:@{@"width": @"600", @"height": @"750", @"filter":self.filterParam}];
            }else{
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetProducts:) name:@"DidGetProductCollectionWithCategoryId" object:self.productCollection];
                [self.productCollection getProductCollectionWithCategoryId:self.categoryId offset:offset limit:24 sortType:self.sortType otherParams:@{@"width": @"600", @"height": @"750", @"filter":self.filterParam}];
            }
        }
            break;
        case ZThemeCollectioViewGetProductTypeFromSpot:
        {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetProducts:) name:@"SCTheme01-DidGetSpotProducts" object:self.productCollection];
            NSString *stringOffet = [NSString stringWithFormat:@"%d",(int)offset];
            [self.productCollection getSpotProductsWithKey:self.spot_ID limit:@"24" ofset:stringOffet width:@"600" height:@"750" sortOption:self.sortType];
        }
            break;
        default:
            break;
    }
    [self.collectionView.infiniteScrollingView startAnimating];
}


#pragma mark setLayOut

- (void)setLayout
{
    if (self.isShowOnlyImage) {
        UICollectionViewFlowLayout *grid = [[UICollectionViewFlowLayout alloc]init];
        grid.itemSize = CGSizeMake(158, 197);
        grid.minimumInteritemSpacing = 10;
        grid.minimumLineSpacing = 10;
        [self.collectionView setCollectionViewLayout:grid animated:YES];
        [self.collectionView setContentInset:UIEdgeInsetsMake(0, 10, 0, 10)];
        self.collectionView.showsVerticalScrollIndicator = NO;
    }else
    {
        UICollectionViewFlowLayout *grid = [[UICollectionViewFlowLayout alloc]init];
        grid.itemSize = CGSizeMake(460, 640);
        grid.minimumInteritemSpacing = 34.6;
        grid.minimumLineSpacing = 34.6;
        [self.collectionView setCollectionViewLayout:grid animated:YES];
        [self.collectionView setContentInset:UIEdgeInsetsMake(0, 34.6, 0, 34.6)];
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
        if (self.scale > scaleStart && self.isShowOnlyImage == YES ) {
            self.isShowOnlyImage = NO;
        }
        
        if (self.scale < scaleStart && self.isShowOnlyImage == NO) {
            self.isShowOnlyImage = YES;
        }
        [self setLayout];
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            
            // Reload the respective collection view row using the main thread.
            
            [self.collectionView reloadItemsAtIndexPaths:[self.collectionView
                                                          indexPathsForVisibleItems]];
            
        }];
    }
}

#pragma mark Events Handler
-(void) didGetProducts:(NSNotification *)noti
{
    responder = [noti.userInfo valueForKey:@"responder"];
    [super didGetProducts:noti];
    [self.delegate numberProductChange:[(NSNumber *)[responder.message objectAtIndex:0] intValue]];
}

@end
