//
//  SCCustomizeSearchViewController.m
//  SimiCartPluginFW
//
//  Created by Liam on 4/25/18.
//  Copyright © 2018 Trueplus. All rights reserved.
//

#import "SCCustomizeSearchViewController.h"
#import "SCCustomizeGlobalVar.h"
#import "SCCustomizeSearchProductCollectionViewCell.h"
#import "SCCustomizeSearchProductTableViewCell.h"

#define Search_Category_Section @"Search_Category_Section"
#define Search_Category_Row @"Search_Category_Row"
#define Search_Page_Section @"Search_Page_Section"
#define Search_Page_Row @"Search_Page_Row"
#define Search_Products_Section @"Search_Products_Section"
#define Search_Products_Row @"Search_Products_Row"
#define Search_Empty_Section @"Search_Empty_Section"


@interface SCCustomizeSearchViewController ()<UICollectionViewDelegate, UICollectionViewDataSource>{
    float tableWidth;
    UICollectionView *productsCollectionView;
    NSArray *currentProducts;
    float itemWidth;
    float itemHeight;
    SimiButton *viewAllItemsButton;
    SimiButton *secondViewAllButton;
    SimiLabel *emptyLabel;
}

@end

@implementation SCCustomizeSearchViewController
- (void)viewDidLoadBefore{
    [super viewDidLoadBefore];
    [self addContentTableView];
    [self addSearchBar];
    [self addViewAllItemsButton];
    tableWidth = SCREEN_WIDTH;
}

- (void)addContentTableView{
    self.contentTableView = [[SimiTableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    self.contentTableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    self.contentTableView.showsVerticalScrollIndicator = NO;
    [self.contentTableView setContentInset:UIEdgeInsetsMake(SCALEVALUE(38), 0, 50, 0)];
    [self.contentTableView setBackgroundColor:[UIColor clearColor]];
    [self.contentTableView setSeparatorColor:[SimiGlobalFunction colorWithHexString:@"#e8e8e8"]];
    self.contentTableView.delegate = self;
    self.contentTableView.dataSource = self;
    [self.view addSubview:self.contentTableView];
}

- (void)addSearchBar{
    self.customSearchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(10, 5, SCREEN_WIDTH - 20, 30)];
    self.customSearchBar.tintColor = THEME_SEARCH_TEXT_COLOR;
    self.customSearchBar.searchBarStyle = UIBarStyleBlackTranslucent;
    self.customSearchBar.placeholder = SCLocalizedString(@"Search");
    self.customSearchBar.layer.backgroundColor = [UIColor clearColor].CGColor;
    self.customSearchBar.layer.borderColor = [UIColor clearColor].CGColor;
    self.customSearchBar.layer.borderWidth = 1;
    [[NSClassFromString(@"UISearchBarTextField") appearanceWhenContainedIn:[UISearchBar class], nil] setBorderStyle:UITextBorderStyleNone];
    [[NSClassFromString(@"UISearchBarTextField") appearanceWhenContainedIn:[UISearchBar class], nil] setTintColor:THEME_BUTTON_BACKGROUND_COLOR];
    self.customSearchBar.delegate = self;
    for ( UIView * subview in [[self.customSearchBar.subviews objectAtIndex:0] subviews]){
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
    [self.customSearchBar setBackgroundColor:[UIColor clearColor]];
    
    secondViewAllButton = [[SimiButton alloc]initWithFrame:CGRectMake(0, 0, 250, 44) title:@"View all" titleFont:[UIFont fontWithName:THEME_FONT_NAME size:FONT_SIZE_LARGE] cornerRadius:2];
    [secondViewAllButton addTarget:self action:@selector(viewAllItems:) forControlEvents:UIControlEventTouchDown];
    [secondViewAllButton setHidden:YES];
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 44)];
    UIBarButtonItem *doneItem = [[UIBarButtonItem alloc]initWithTitle:SCLocalizedString(@"Done") style:UIBarButtonItemStylePlain target:self action:@selector(hideInputView)];
    UIBarButtonItem *viewAllButtonItem = [[UIBarButtonItem alloc]initWithCustomView:secondViewAllButton];
    viewAllButtonItem.width = 250;
    UIBarButtonItem *flexibleButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    toolbar.items = @[viewAllButtonItem,flexibleButton,doneItem];
    self.customSearchBar.inputAccessoryView = toolbar;
    
    self.searchBarBackground = [[UIView alloc]initWithFrame:self.customSearchBar.frame];
    [self.searchBarBackground setBackgroundColor:THEME_SEARCH_BOX_BACKGROUND_COLOR];
    [self.searchBarBackground setAlpha:0.9f];
    
    [self.view addSubview:self.searchBarBackground];
    [self.view addSubview:self.customSearchBar];
}

- (void)addViewAllItemsButton{
    viewAllItemsButton = [[SimiButton alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.frame) - 44, SCREEN_WIDTH, 44) title:@"View All Items" titleFont:[UIFont fontWithName:THEME_FONT_NAME size:FONT_SIZE_LARGE] cornerRadius:0 borderWidth:0 borderColor:[UIColor clearColor] shadowOffset:CGSizeMake(1, 1) shadowRadius:4 shadowOpacity:0.7f];
    viewAllItemsButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [viewAllItemsButton addTarget:self action:@selector(viewAllItems:) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:viewAllItemsButton];
    [viewAllItemsButton setHidden:YES];
}

- (void)viewWillAppearBefore:(BOOL)animated{
    [super viewWillAppearBefore:animated];
    if (PADDEVICE) {
        self.navigationItem.rightBarButtonItems =  nil;
        self.navigationItem.rightBarButtonItem = [SCAppController sharedInstance].navigationBarPad.cartItem;
    }
}

- (void)viewDidAppearAfter:(BOOL)animated{
    [super viewDidAppearAfter:animated];
    [self.customSearchBar becomeFirstResponder];
    if (self.keySearch != nil && ![self.keySearch isEqualToString:@""]) {
        self.customSearchBar.text = self.keySearch;
        self.keySearch = nil;
        [self searchWithKey:self.customSearchBar.text];
    }
}

- (void)searchWithKey:(NSString*)key{
    if ([CUSGLOBALVAR.searchCache valueForKey:key]) {
        [self initCells];
        return;
    }
    SCCusSearchModel *searchModel  = [SCCusSearchModel new];
    searchModel.searchKey = key;
    [searchModel starSearchanise];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(completeSearch:) name:@"CompleteSearchanise" object:searchModel];
}

- (void)completeSearch:(NSNotification*)noti{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:noti.name object:noti.object];
    SCCusSearchModel *searchModel = noti.object;
    [CUSGLOBALVAR.searchCache setValue:searchModel forKey:searchModel.searchKey];
    if (searchModel.searchKey == self.customSearchBar.text) {
        [self initCells];
    }
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    if ([searchText isEqualToString:@""]) {
        [self.cells removeAllObjects];
        [viewAllItemsButton setHidden:YES];
        [secondViewAllButton setHidden:YES];
        [self.contentTableView reloadData];
        return;
    }
    [self searchWithKey:searchText];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [searchBar resignFirstResponder];
}

- (void)hideInputView{
    [self.customSearchBar resignFirstResponder];
}

- (void)createCells{
    SCCusSearchModel *searchModel = [CUSGLOBALVAR.searchCache valueForKey:self.customSearchBar.text];
    if (searchModel.categories.count > 0) {
        SimiSection *categoriesSection = [[SimiSection alloc]initWithIdentifier:Search_Category_Section];
        categoriesSection.header = [[SimiSectionHeader alloc]initWithTitle:SCLocalizedString(@"CATEGORIES") height:44];
        [self.cells addObject:categoriesSection];
        for (int i = 0; i < searchModel.categories.count; i++) {
            SimiRow *categoryRow = [[SimiRow alloc]initWithIdentifier:Search_Category_Row height:50];
            categoryRow.data = [[NSMutableDictionary alloc]initWithDictionary:[searchModel.categories objectAtIndex:i]];
            [categoriesSection addObject:categoryRow];
        }
    }
    if (searchModel.pages.count > 0) {
        SimiSection *pagesSection = [[SimiSection alloc]initWithIdentifier:Search_Page_Section];
        pagesSection.header = [[SimiSectionHeader alloc]initWithTitle:SCLocalizedString(@"PAGES") height:44];
        [self.cells addObject:pagesSection];
        for (int i = 0; i < searchModel.pages.count; i++) {
            SimiRow *pageRow = [[SimiRow alloc]initWithIdentifier:Search_Page_Row height:50];
            pageRow.data = [[NSMutableDictionary alloc]initWithDictionary:searchModel.pages[i]];
            [pagesSection addObject:pageRow];
        }
    }
    if (searchModel.items.count > 0) {
        SimiSection *productsSection = [[SimiSection alloc]initWithIdentifier:Search_Products_Section];
        productsSection.header = [[SimiSectionHeader alloc]initWithTitle:SCLocalizedString(@"PRODUCTS") height:44];
        [self.cells addObject:productsSection];
//        SimiRow *productRow = [[SimiRow alloc]initWithIdentifier:Search_Products_Section height:100];
//        productRow.data = [[NSMutableDictionary alloc]initWithDictionary:@{@"items":searchModel.items}];
//        [productsSection addRow:productRow];
        for (int i = 0; i < searchModel.items.count; i++) {
            SimiRow *productRow = [[SimiRow alloc]initWithIdentifier:Search_Products_Row height:80];
            productRow.data = [[NSMutableDictionary alloc]initWithDictionary:searchModel.items[i]];
            [productsSection addObject:productRow];
        }
        [viewAllItemsButton setTitle:[NSString stringWithFormat:@"View all %d items",searchModel.totalItems] forState:UIControlStateNormal];
        [viewAllItemsButton setHidden:NO];
        [secondViewAllButton setTitle:[NSString stringWithFormat:@"View all %d items",searchModel.totalItems] forState:UIControlStateNormal];
        [secondViewAllButton setHidden:NO];
    }else{
        [viewAllItemsButton setHidden:YES];
        [secondViewAllButton setHidden:YES];
    }
    if (searchModel.items.count == 0 && searchModel.pages.count == 0 && searchModel.categories.count == 0) {
        SimiSection *emptySection = [self.cells addSectionWithIdentifier:Search_Empty_Section];
        [emptySection addRowWithIdentifier:Search_Empty_Section height:60];
    }
}

#pragma mark TableView Delegate&Datasource
- (UIView *)contentTableViewViewForHeaderInSection:(NSInteger)section{
    UITableViewHeaderFooterView *headerView = (UITableViewHeaderFooterView*)[super contentTableViewViewForHeaderInSection:section];
    [headerView.contentView setBackgroundColor:COLOR_WITH_HEX(@"#cacaca")];
    return headerView;
}

- (UITableViewCell *)contentTableViewCellForRowAtIndexPath:(NSIndexPath *)indexPath{
    SimiSection *section = [self.cells objectAtIndex:indexPath.section];
    SimiRow *row = [section objectAtIndex:indexPath.row];
    SimiTableViewCell *cell;
    if ([section.identifier isEqualToString:Search_Category_Section]) {
        cell = [self createCategoryCellWithRow:row];
    }else if([section.identifier isEqualToString:Search_Page_Section]){
        cell = [self createPageCellWithRow:row];
    }else if ([section.identifier isEqualToString:Search_Products_Section]){
        cell = [self createProductsCellWithRow:row];
    }else if ([section.identifier isEqualToString:Search_Empty_Section]){
        cell = [self createEmptyCellWithRow:row];
    }
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    return cell;
}

- (SimiTableViewCell*)createCategoryCellWithRow:(SimiRow*)row{
    NSString *identifier = [NSString stringWithFormat:@"%@%@",Search_Category_Row,[row.data valueForKey:@"category_id"]];
    SimiTableViewCell *cell = [self.contentTableView dequeueReusableCellWithIdentifier:identifier];
    if(cell == nil){
        cell = [[SimiTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        SimiLabel *titleLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(15, 0, tableWidth - 45, row.height) andFont:[UIFont fontWithName:THEME_FONT_NAME size:FONT_SIZE_LARGE]];
        [titleLabel setText:[NSString stringWithFormat:@"%@",[row.data valueForKey:@"title"]]];
        [cell.contentView addSubview:titleLabel];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    return cell;
}

- (SimiTableViewCell*)createPageCellWithRow:(SimiRow*)row{
    NSString *identifier = [NSString stringWithFormat:@"%@%@",Search_Category_Row,[row.data valueForKey:@"page_id"]];
    SimiTableViewCell *cell = [self.contentTableView dequeueReusableCellWithIdentifier:identifier];
    if(cell == nil){
        cell = [[SimiTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        SimiLabel *titleLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(15, 0, tableWidth - 45, row.height) andFont:[UIFont fontWithName:THEME_FONT_NAME size:FONT_SIZE_LARGE]];
        [titleLabel setText:[NSString stringWithFormat:@"%@",[row.data valueForKey:@"title"]]];
        [cell.contentView addSubview:titleLabel];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    return cell;
}


//- (SimiTableViewCell*)createProductsCellWithRow:(SimiRow*)row{
//    SimiTableViewCell *cell = [self.contentTableView dequeueReusableCellWithIdentifier:row.identifier];
//    itemWidth = (SCREEN_WIDTH - 40)/2;
//    itemHeight = itemWidth + 60;
//    if (cell == nil) {
//        cell = [[SimiTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:row.identifier];
//        UICollectionViewFlowLayout *collectionViewFlowLayout = [UICollectionViewFlowLayout new];
//        collectionViewFlowLayout.itemSize = CGSizeMake(itemWidth, itemHeight);
//        collectionViewFlowLayout.minimumLineSpacing = 10;
//        collectionViewFlowLayout.minimumInteritemSpacing = 10;
//        productsCollectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, tableWidth, cell.heightCell) collectionViewLayout:collectionViewFlowLayout];
//        productsCollectionView.delegate = self;
//        productsCollectionView.dataSource = self;
//        productsCollectionView.autoresizingMask = UIViewAutoresizingNone;
//        productsCollectionView.scrollEnabled = NO;
//        [productsCollectionView setContentInset:UIEdgeInsetsMake(10, 15, 10, 15)];
//        [productsCollectionView setBackgroundColor:[UIColor whiteColor]];
//        [cell.contentView addSubview:productsCollectionView];
//        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
//    }
//    currentProducts = [row.data valueForKey:@"items"];
//    cell.heightCell = currentProducts.count/2 *(itemHeight+10) + 54;
//    if (currentProducts.count%2 == 1) {
//        cell.heightCell = (currentProducts.count/2 + 1) *(itemHeight+10)+54;
//    }
//    CGRect frame = productsCollectionView.frame;
//    frame.size.height = cell.heightCell;
//    [productsCollectionView setFrame:frame];
//    [productsCollectionView reloadData];
//    row.height = cell.heightCell;
//    return cell;
//}

- (SimiTableViewCell*)createProductsCellWithRow:(SimiRow*)row{
    NSString *identifier = [NSString stringWithFormat:@"%@%@",Search_Products_Row,[row.data valueForKey:@"product_id"]];
    SimiTableViewCell *cell = [self.contentTableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[SCCustomizeSearchProductTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier productData:row.data];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    return cell;
}

- (SimiTableViewCell*)createEmptyCellWithRow:(SimiRow*)row{
    SimiTableViewCell *cell = [self.contentTableView dequeueReusableCellWithIdentifier:row.identifier];
    if(cell == nil){
        cell = [[SimiTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:row.identifier];
        emptyLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(15, 0, tableWidth - 30, row.height) andFont:[UIFont fontWithName:THEME_FONT_NAME size:FONT_SIZE_LARGE]];
        [emptyLabel setTextAlignment:NSTextAlignmentCenter];
        [cell.contentView addSubview:emptyLabel];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    [emptyLabel setText:[NSString stringWithFormat:@"%@ %@",SCLocalizedString(@"Sorry, nothing found for"),self.customSearchBar.text]];
    return cell;
}

- (void)contentTableViewDidSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.customSearchBar resignFirstResponder];
    SimiSection *section = [self.cells objectAtIndex:indexPath.section];
    SimiRow *row = [section objectAtIndex:indexPath.row];
    if ([row.identifier isEqualToString:Search_Category_Row]) {
        [[SCAppController sharedInstance]openProductListWithNavigationController:self.navigationController productsId:[row.data valueForKey:@"category_id"] productsName:[row.data valueForKey:@"title"] getProductsFrom:ProductListGetProductTypeFromCategory moreParams:nil];
    }else if ([row.identifier isEqualToString:Search_Page_Row]){
        SCWebViewController *pageViewController = [SCWebViewController new];
        pageViewController.urlPath = [NSString stringWithFormat:@"%@",[row.data valueForKey:@"link"]];
        pageViewController.scalesPageToFit = YES;
        pageViewController.webTitle = [NSString stringWithFormat:@"%@",[row.data valueForKey:@"title"]];
        [self.navigationController pushViewController:pageViewController animated:YES];
    }else if ([row.identifier isEqualToString:Search_Products_Row]){
        [[SCAppController sharedInstance]openProductWithNavigationController:self.navigationController productId:[row.data valueForKey:@"product_id"] moreParams:@{}];
    }
    [self.contentTableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)viewAllItems:(UIButton*)sender{
    [self.customSearchBar resignFirstResponder];
    [[SCAppController sharedInstance]openProductListWithNavigationController:self.navigationController productsId:@"" productsName:@"" getProductsFrom:ProductListGetProductTypeFromSearch moreParams:@{KEYEVENT.PRODUCTLISTVIEWCONTROLLER.search_text:self.customSearchBar.text,KEYEVENT.PRODUCTLISTVIEWCONTROLLER.search_option:@1}];
}

#pragma mark Collection Delegate & Datasource;
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [currentProducts count];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(itemWidth, itemHeight);
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *data = [currentProducts objectAtIndex:indexPath.row];
    NSString *identifier = [NSString stringWithFormat:@"%@",[data valueForKey:@"product_id"]];
    [collectionView registerClass:[SCCustomizeSearchProductCollectionViewCell class] forCellWithReuseIdentifier:identifier];
    SCCustomizeSearchProductCollectionViewCell *productCollectionViewCell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    [productCollectionViewCell updateProductDataForCell:data];
    return productCollectionViewCell;
}
@end
