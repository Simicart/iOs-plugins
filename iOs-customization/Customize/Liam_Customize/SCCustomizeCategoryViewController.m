//
//  SCCustomizeCategoryViewController.m
//  SimiCartPluginFW
//
//  Created by Liam on 3/5/18.
//  Copyright © 2018 Trueplus. All rights reserved.
//

#import "SCCustomizeCategoryViewController.h"
#import "SCCustomizeProductCollectionViewCell.h"
#import "SCCustomizeSearchViewController.h"

@interface SCCustomizeCategoryViewController ()

@end

@implementation SCCustomizeCategoryViewController
- (void)viewDidLoadBefore{
    [super viewDidLoadBefore];
    [self.contentTableView setContentInset:UIEdgeInsetsMake(SCALEVALUE(38), 0, 0, 0)];
    self.searchBarHome = [[UISearchBar alloc] initWithFrame:SCALEFRAME(CGRectMake(5, 5, 310, 28))];
    self.searchBarHome.tintColor = THEME_SEARCH_TEXT_COLOR;
    self.searchBarHome.searchBarStyle = UIBarStyleBlackTranslucent;
    self.searchBarHome.placeholder = SCLocalizedString(@"Search");
    self.searchBarHome.layer.backgroundColor = [UIColor clearColor].CGColor;
    self.searchBarHome.layer.borderColor = [UIColor clearColor].CGColor;
    self.searchBarHome.layer.borderWidth = 1;
    [[NSClassFromString(@"UISearchBarTextField") appearanceWhenContainedIn:[UISearchBar class], nil] setBorderStyle:UITextBorderStyleNone];
    self.searchBarHome.delegate = self;
    for ( UIView * subview in [[self.searchBarHome.subviews objectAtIndex:0] subviews]){
        if ([subview isKindOfClass:NSClassFromString(@"UISearchBarTextField") ] ) {
            UITextField *searchTextField = (UITextField *)subview;
            [searchTextField setBorderStyle:UITextBorderStyleNone];
            [searchTextField.rightView setBackgroundColor:THEME_SEARCH_ICON_COLOR];
            searchTextField.textColor = THEME_SEARCH_TEXT_COLOR;
            [searchTextField setAttributedPlaceholder:[[NSAttributedString alloc] initWithString:SCLocalizedString(@"Search") attributes:@{NSForegroundColorAttributeName: THEME_SEARCH_TEXT_COLOR}]];
            [((UITextField *)searchTextField) setFont:[UIFont fontWithName:THEME_FONT_NAME size:FONT_SIZE_LARGE]];
            if ([GLOBALVAR isReverseLanguage]) {
                [searchTextField setTextAlignment:NSTextAlignmentRight];
            }
        }
    }
    [self.searchBarHome setBackgroundColor:[UIColor clearColor]];
    
    self.searchBarBackground = [[UIView alloc]initWithFrame:self.searchBarHome.frame];
    [self.searchBarBackground setBackgroundColor:THEME_SEARCH_BOX_BACKGROUND_COLOR];
    [self.searchBarBackground setAlpha:0.9f];
    
    [self.view addSubview:self.searchBarBackground];
    [self.view addSubview:self.searchBarHome];
}

#pragma mark Search Bar Delegate
/** Liam customize open Search Screen
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [searchBar resignFirstResponder];
    [self.imageFog removeFromSuperview];
    self.keySearch = searchBar.text;
    searchBar.text = @"";
    [[SCAppController sharedInstance]openProductListWithNavigationController:self.navigationController productsId:@"" productsName:@"" getProductsFrom:ProductListGetProductTypeFromSearch moreParams:@{KEYEVENT.PRODUCTLISTVIEWCONTROLLER.search_text:self.keySearch}];
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar{
    if (self.imageFog == nil) {
        self.imageFog = [[UIImageView alloc]initWithFrame:self.view.bounds];
        [self.imageFog setBackgroundColor:[UIColor colorWithWhite:1 alpha:0.5]];
        [self.imageFog setUserInteractionEnabled:YES];
        
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didTapImageFog)];
        [self.imageFog addGestureRecognizer:tapGestureRecognizer];
    }
    [self.view addSubview:self.imageFog];
    [self.view bringSubviewToFront:self.searchBarBackground];
    [self.view bringSubviewToFront:self.searchBarHome];
    return YES;
}

- (void)didTapImageFog{
    [self.searchBarHome resignFirstResponder];
    [self.imageFog removeFromSuperview];
    self.searchBarHome.text = @"";
}
 */
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar{
    SCCustomizeSearchViewController *searchViewController = [SCCustomizeSearchViewController new];
    [self.navigationController pushViewController:searchViewController animated:YES];
    return NO;
}
//Category Products
- (void)createCells{
    SimiSection *section = [[SimiSection alloc] initWithIdentifier:CATEGORY_MAIN_SECTION];
    if (self.productCollection.count > 0 && GLOBALVAR.isShowLinkAllProduct) {
        SimiRow *row = [[SimiRow alloc] init];
        row.identifier = CATEGORY_ROW_LIST_PRODUCT;
        float heightPrice = 0;
        for (int i = 0; i < self.productCollection.count; i++) {
            SimiProductModel *product = [self.productCollection objectAtIndex:i];
            float callHeight = 0;
            if([[product objectForKey:@"final_price"] floatValue] == 0 && product.productType != ProductTypeGrouped && GLOBALVAR.isLogin){
                callHeight = 44;
            }
            if ([product heightPriceOnGrid] + callHeight > heightPrice) {
                heightPrice = [product heightPriceOnGrid] + callHeight;
            }
        }
        row.height = itemWidth + heightTopCell + 20 + heightPrice;
        itemHeight = row.height - 60;
        [section addRow:row];
    }
    
    if (self.categoryCollection.count > 0) {
        for (int i = 0; i < self.categoryCollection.count; i++) {
            SimiCategoryModel *model = [self.categoryCollection objectAtIndex:i];
            SimiRow *row = [[SimiRow alloc] init];
            row.identifier = CATEGORY_ROW_CHILD;
            row.height = 45;
            row.model = model;
            [section addRow:row];
        }
    }
    [self.cells addObject:section];
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = ((SimiProductModel *)[self.productCollection.collectionData objectAtIndex:indexPath.row]).entityId;
    [collectionView registerClass:[SCCustomizeProductCollectionViewCell class] forCellWithReuseIdentifier:identifier];
    SCCustomizeProductCollectionViewCell *productViewCell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    productViewCell.isShowNameOneLine = YES;
    [productViewCell setProductModelForCell:[self.productCollection objectAtIndex:indexPath.row]];
    return productViewCell;
}

@end
