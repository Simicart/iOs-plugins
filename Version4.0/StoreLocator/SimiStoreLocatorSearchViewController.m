//
//  SimiStoreLocatorSearchViewController.m
//  SimiCartPluginFW
//
//  Created by NghiepLy on 7/9/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import "SimiStoreLocatorSearchViewController.h"

@interface SimiStoreLocatorSearchViewController ()

@end

@implementation SimiStoreLocatorSearchViewController
{
    BOOL isShowTableCountry;
    float heightContent;
    NSIndexPath* currentPath;
    BOOL isiPhone;
    float widthContent;
    BOOL isFirtsGetTagList;
    
    float labelMainTitleX;
    float labelTitleX;
    float textFieldX;
    
    float widthTitle;
    float widthTextField;
    
    float heightLabel;
    float heightViewControl;
    
    float topDistance;
    float leftDistance;
    
    NSMutableArray *countryNameArray;
    int selectedCountryIndex;
}
@synthesize sLModelCollection, tagModelCollection, stringCitySearch, stringCountrySearchCode,stringCountrySearchName, stringStateSearch, stringZipCodeSearch, delegate, simiAddressStoreLocatorModelCollection, currentLongitube, currentLatitube, stringTagSearch, tagChoise;
@synthesize lblZipcode,lblState,lblCity,lblCountry,lblContentCountry,lblSearchByArea,lblSearchByTag, collectionViewTagContent;
@synthesize txtStateSearch,tblViewCountry,txtCitySearch,txtZipCode;
@synthesize viewSearchByZipcode,viewSearchByState,viewSearchByCity,viewSearchByCountry, viewSearch, viewSearchByTag, scrView;
@synthesize btnSearch, btnClearAll;

- (void)viewDidLoadBefore
{
    self.navigationItem.title = SCLocalizedString(@"Search Store");
    if (PHONEDEVICE) {
        isiPhone = YES;
    }
    scrView = [UIScrollView new];
    if (PHONEDEVICE) {
        [scrView setFrame:self.view.frame];
    }else
    {
        [scrView setFrame:CGRectMake(0, 0, 500, 700)];
    }
    widthContent = CGRectGetWidth(scrView.frame);
    [self.view addSubview:scrView];
    isFirtsGetTagList = YES;
    
    [self setInterfaceSearchByArea];
    
    if (tagModelCollection.count > 0) {
        [self setInterfaceSearchByTag];
    }
    //  Get data for search tag
    __block __weak id weakSelf = self;
    [self.scrView addInfiniteScrollingWithActionHandler:^{
        [weakSelf getTagList];
    }];
    if (tagModelCollection == nil) {
        [self getTagList];
    }
    stringTagSearch = @"";
    
    simiAddressStoreLocatorModelCollection = [SimiGlobalVar sharedInstance].countryColllection;
    countryNameArray = [NSMutableArray new];
    [countryNameArray addObject:@"None"];
    for (int i = 0; i < simiAddressStoreLocatorModelCollection.count; i++) {
        NSDictionary *countryUnit = [simiAddressStoreLocatorModelCollection objectAtIndex:i];
        [countryNameArray addObject:[countryUnit objectForKey:@"country_name"]];
    }
    selectedCountryIndex = 0;
}

- (void)viewWillAppearBefore:(BOOL)animated
{
    if (SIMI_SYSTEM_IOS < 7) {
        self.contentSizeForViewInPopover = CGSizeMake(500, 700);
    }else
    {
        self.preferredContentSize = CGSizeMake(500, 700);
    }
}

#pragma mark
#pragma mark Set Interface Search View Controller
- (void)setInterfaceSearchByArea
{
    heightContent = 15;
    labelMainTitleX = 10;
    labelTitleX = 30;
    textFieldX = 110;
    
    widthTitle = 80;
    widthTextField = 180;
    
    heightLabel = 30;
    heightViewControl = 45;
    
    topDistance = 7.5;
    leftDistance = 15;
    if (PADDEVICE) {
        labelMainTitleX = 20;
        labelTitleX = 50;
        textFieldX = 150;
        
        widthTitle = 90;
        widthTextField = 271;
        
        heightLabel = 42;
        heightViewControl = 68;
        topDistance = 13;
    }
    
    lblSearchByArea = [[UILabel alloc]initWithFrame:CGRectMake(labelMainTitleX, heightContent, widthContent - 100, heightLabel)];
    [lblSearchByArea setTextColor:[[SimiGlobalVar sharedInstance] colorWithHexString:@"#393939"]];
    [lblSearchByArea setFont:[UIFont fontWithName:[NSString stringWithFormat:@"%@-%@",THEME_FONT_NAME,@"Bold"] size:THEME_FONT_SIZE + 3]];
    [lblSearchByArea setText: SCLocalizedString(@"Search By Area")];
    [scrView addSubview:lblSearchByArea];
    
    btnClearAll = [[UIButton alloc]initWithFrame:CGRectMake(widthContent - 100, heightContent, 80, heightLabel)];
    [btnClearAll addTarget:self action:@selector(btnClear:) forControlEvents:UIControlEventTouchUpInside];
    [btnClearAll setTitle:SCLocalizedString(@"Clear") forState:UIControlStateNormal];
    [btnClearAll setTitleColor:[[SimiGlobalVar sharedInstance] colorWithHexString:@"#ff9900"] forState:UIControlStateNormal];
    [btnClearAll.titleLabel setFont:[UIFont fontWithName:THEME_FONT_NAME size:THEME_FONT_SIZE - 2]];
    
    [btnClearAll setImage:[UIImage imageNamed:@"storelocator__search_iphone"] forState:UIControlStateNormal];
    [btnClearAll setTitleEdgeInsets:UIEdgeInsetsMake(0, 5, 0, 0)];
    [scrView addSubview:btnClearAll];
    heightContent += heightLabel;
    
#pragma mark Search by Country
    viewSearchByCountry = [[UIControl alloc]initWithFrame:CGRectMake(0, heightContent, widthContent, heightViewControl)];
    [viewSearchByCountry addTarget:self action:@selector(btnTouchOutLayer_Click:) forControlEvents:UIControlEventTouchUpInside];
    [scrView addSubview:viewSearchByCountry];
    
    lblCountry = [[UILabel  alloc]initWithFrame:CGRectMake(labelTitleX, topDistance, widthTitle, heightLabel)];
    [lblCountry setTextColor:[[SimiGlobalVar sharedInstance] colorWithHexString:@"#393939"]];
    [lblCountry setFont:[UIFont fontWithName:THEME_FONT_NAME size:THEME_FONT_SIZE - 2]];
    [lblCountry setText:[NSString stringWithFormat:@"%@:", SCLocalizedString(@"Country")]];
    [viewSearchByCountry addSubview:lblCountry];
    
    _imgCountry = [[UIImageView alloc]initWithFrame:CGRectMake(textFieldX, topDistance, widthTextField, heightLabel)];
    [_imgCountry setImage:[UIImage imageNamed:@"storelocator_searchdropbox"]];
    [viewSearchByCountry addSubview:_imgCountry];
    
    lblContentCountry = [[UILabel alloc]initWithFrame:CGRectMake(textFieldX + leftDistance, 8.5, widthTextField - leftDistance, heightLabel)];
    [lblContentCountry setTextColor:[[SimiGlobalVar sharedInstance] colorWithHexString:@"#393939"]];
    [lblContentCountry setFont:[UIFont fontWithName:THEME_FONT_NAME size:THEME_FONT_SIZE - 2]];
    if (stringCountrySearchName == nil|| [stringCountrySearchName isEqualToString:@""]) {
        stringCountrySearchName = @"None";
    }
    lblContentCountry.text = SCLocalizedString(stringCountrySearchName);
    [viewSearchByCountry addSubview:lblContentCountry];
    
    _btnCountry = [[UIButton alloc]initWithFrame:CGRectMake(textFieldX, topDistance, widthTextField, heightLabel)];
    [_btnCountry addTarget:self action:@selector(btnDropDownList_Click:) forControlEvents:UIControlEventTouchUpInside];
    [_btnCountry setBackgroundColor:[UIColor clearColor]];
    [viewSearchByCountry addSubview:_btnCountry];
    heightContent +=  CGRectGetHeight(viewSearchByCountry.frame);
    
#pragma mark Search by City
    viewSearchByCity = [[UIControl alloc]initWithFrame:CGRectMake(0, heightContent, widthContent, heightViewControl)];
    [viewSearchByCity addTarget:self action:@selector(btnTouchOutLayer_Click:) forControlEvents:UIControlEventTouchUpInside];
    [scrView addSubview:viewSearchByCity];
    
    lblCity = [[UILabel alloc]initWithFrame:CGRectMake(labelTitleX, topDistance, widthTitle, heightLabel)];
    [lblCity setTextColor:[[SimiGlobalVar sharedInstance] colorWithHexString:@"#393939"]];
    [lblCity setFont:[UIFont fontWithName:THEME_FONT_NAME size:THEME_FONT_SIZE - 2]];
    [lblCity setText:[NSString stringWithFormat:@"%@:", SCLocalizedString(@"City")]];
    [viewSearchByCity addSubview:lblCity];
    
    _imgCity = [[UIImageView alloc]initWithFrame:CGRectMake(textFieldX, topDistance, widthTextField, heightLabel)];
    [_imgCity setImage:[UIImage imageNamed:@"storelocator_search_text_field"]];
    [viewSearchByCity addSubview:_imgCity];
    
    txtCitySearch = [[UITextField alloc]initWithFrame:CGRectMake(textFieldX + leftDistance, topDistance, widthTextField - leftDistance, heightLabel)];
    txtCitySearch.textColor = [[SimiGlobalVar sharedInstance] colorWithHexString:@"#393939"];
    [txtCitySearch setFont: [UIFont fontWithName:THEME_FONT_NAME size:THEME_FONT_SIZE]];
    txtCitySearch.text = stringCitySearch;
    [viewSearchByCity addSubview:txtCitySearch];
    
    heightContent += CGRectGetHeight(viewSearchByCity.frame);
    
#pragma mark Search By State
    viewSearchByState = [[UIControl alloc]initWithFrame:CGRectMake(0, heightContent, widthContent, heightViewControl)];
    [viewSearchByState addTarget:self action:@selector(btnTouchOutLayer_Click:) forControlEvents:UIControlEventTouchUpInside];
    [scrView addSubview:viewSearchByState];
    
    lblState = [[UILabel alloc]initWithFrame:CGRectMake(labelTitleX, topDistance, widthTitle, heightLabel)];
    [lblState setTextColor:[[SimiGlobalVar sharedInstance] colorWithHexString:@"#393939"]];
    [lblState setFont:[UIFont fontWithName:THEME_FONT_NAME size:THEME_FONT_SIZE - 2]];
    [lblState setText:[NSString stringWithFormat:@"%@:", SCLocalizedString(@"State")]];
    [viewSearchByState addSubview:lblState];
    
    _imgState = [[UIImageView alloc]initWithFrame:CGRectMake(textFieldX, topDistance, widthTextField, heightLabel)];
    [_imgState setImage:[UIImage imageNamed:@"storelocator_search_text_field"]];
    [viewSearchByState addSubview:_imgState];
    
    txtStateSearch = [[UITextField alloc]initWithFrame:CGRectMake(textFieldX + leftDistance, topDistance, widthTextField - leftDistance, heightLabel)];
    txtStateSearch.textColor = [[SimiGlobalVar sharedInstance] colorWithHexString:@"#393939"];
    [txtStateSearch setFont: [UIFont fontWithName:THEME_FONT_NAME size:THEME_FONT_SIZE]];
    txtStateSearch.text = stringStateSearch;
    [viewSearchByState addSubview:txtStateSearch];
    
    heightContent += CGRectGetHeight(viewSearchByState.frame);
    
#pragma mark Search By Zipcode
    viewSearchByZipcode = [[UIControl alloc]initWithFrame:CGRectMake(0, heightContent, widthContent, heightViewControl)];
    [viewSearchByZipcode addTarget:self action:@selector(btnTouchOutLayer_Click:) forControlEvents:UIControlEventTouchUpInside];
    [scrView addSubview:viewSearchByZipcode];
    
    lblZipcode = [[UILabel alloc]initWithFrame:CGRectMake(labelTitleX, topDistance, widthTitle, heightLabel)];
    [lblZipcode setTextColor:[[SimiGlobalVar sharedInstance] colorWithHexString:@"#393939"]];
    [lblZipcode setFont:[UIFont fontWithName:THEME_FONT_NAME size:THEME_FONT_SIZE - 2]];
    [lblZipcode setText:[NSString stringWithFormat:@"%@:", SCLocalizedString(@"Zip Code")]];
    [viewSearchByZipcode addSubview:lblZipcode];
    
    _imgZipCode = [[UIImageView alloc]initWithFrame:CGRectMake(textFieldX, topDistance, widthTextField, heightLabel)];
    [_imgZipCode setImage:[UIImage imageNamed:@"storelocator_search_text_field"]];
    [viewSearchByZipcode addSubview:_imgZipCode];
    
    txtZipCode = [[UITextField alloc]initWithFrame:CGRectMake(textFieldX + leftDistance, topDistance, widthTextField - leftDistance, heightLabel)];
    txtZipCode.textColor = [[SimiGlobalVar sharedInstance] colorWithHexString:@"#393939"];
    [txtZipCode setFont: [UIFont fontWithName:THEME_FONT_NAME size:THEME_FONT_SIZE]];
    txtZipCode.text = stringZipCodeSearch;
    [viewSearchByZipcode addSubview:txtZipCode];
    
    heightContent += CGRectGetHeight(viewSearchByZipcode.frame);
    
#pragma mark Button Search
    viewSearch = [[UIView alloc]initWithFrame:CGRectMake(0, heightContent, widthContent, heightViewControl)];
    [viewSearch setBackgroundColor:[UIColor clearColor]];
    [scrView addSubview:viewSearch];
    
    btnSearch = [[UIButton alloc]initWithFrame:CGRectMake(textFieldX, topDistance, widthTextField, heightLabel)];
    [btnSearch addTarget:self action:@selector(btnSearch_Click:) forControlEvents:UIControlEventTouchUpInside];
    [btnSearch setBackgroundImage:[UIImage imageNamed:@"storelocator_bt_search"] forState:UIControlStateNormal];
    [btnSearch setTitle:SCLocalizedString(@"Search") forState:UIControlStateNormal];
    [viewSearch addSubview:btnSearch];
    heightContent += heightViewControl;
    
    [SimiGlobalVar sortViewForRTL:scrView andWidth:CGRectGetWidth(scrView.frame)];
    [SimiGlobalVar sortViewForRTL:viewSearchByCountry andWidth:widthContent];
    [SimiGlobalVar sortViewForRTL:viewSearchByState andWidth:widthContent];
    [SimiGlobalVar sortViewForRTL:viewSearchByCity andWidth:widthContent];
    [SimiGlobalVar sortViewForRTL:viewSearchByZipcode andWidth:widthContent];
}

- (void)setInterfaceSearchByTag
{
    int numberRowCollection = (int)(tagModelCollection.count+1)/3 + 1;
    if (isFirtsGetTagList) {
        isFirtsGetTagList =  NO;
        lblSearchByTag = [[UILabel alloc]initWithFrame:CGRectMake(labelMainTitleX, heightContent, widthContent - labelMainTitleX *2, heightLabel)];
        [lblSearchByTag setText:SCLocalizedString(@"Search By Tag")];
        [lblSearchByTag setTextColor:[[SimiGlobalVar sharedInstance] colorWithHexString:@"#393939"]];
        [lblSearchByTag setFont:[UIFont fontWithName:[NSString stringWithFormat:@"%@-%@",THEME_FONT_NAME,@"Bold"] size:THEME_FONT_SIZE + 3]];
        if ([SimiGlobalVar sharedInstance].isReverseLanguage) {
            [lblSearchByTag setTextAlignment:NSTextAlignmentRight];
        }
        [scrView addSubview:lblSearchByTag];
        heightContent += heightLabel;
        
        UICollectionViewLayout *layout = [UICollectionViewLayout new];
        UICollectionViewFlowLayout* grid = [[UICollectionViewFlowLayout alloc] init];
        if (isiPhone) {
            collectionViewTagContent = [[UICollectionView alloc]initWithFrame:CGRectMake(labelMainTitleX, heightContent, widthContent - 2*labelMainTitleX, numberRowCollection*39) collectionViewLayout:layout];
            grid.itemSize = CGSizeMake(85, 29);
        }else
        {
            collectionViewTagContent = [[UICollectionView alloc]initWithFrame:CGRectMake(labelMainTitleX, heightContent, widthContent - 2*labelMainTitleX, numberRowCollection*56) collectionViewLayout:layout];
            grid.itemSize = CGSizeMake(122, 41);
        }
        [self.collectionViewTagContent setCollectionViewLayout:grid];
        [self.collectionViewTagContent setBackgroundColor:[UIColor whiteColor]];
        collectionViewTagContent.delegate = self;
        collectionViewTagContent.dataSource = self;
        [scrView addSubview:self.collectionViewTagContent];
    }
    if (isiPhone) {
        [collectionViewTagContent setContentSize:CGSizeMake(widthContent - labelMainTitleX*2, numberRowCollection*39)];
    }else
    {
        [collectionViewTagContent setContentSize:CGSizeMake(widthContent - labelMainTitleX*2, numberRowCollection*56)];
    }
    
    CGRect frame = collectionViewTagContent.frame;
    frame.size.height = collectionViewTagContent.contentSize.height;
    frame.origin.y = heightContent;
    [collectionViewTagContent setFrame:frame];
    [collectionViewTagContent reloadData];
    
    CGSize scrollSize = scrView.contentSize;
    scrollSize.height = heightContent + CGRectGetHeight(collectionViewTagContent.frame);
    [scrView setContentSize:scrollSize];
}

#pragma mark
#pragma mark Collection DataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return tagModelCollection.count + 1;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView registerClass:[SimiTagCollectionCell class] forCellWithReuseIdentifier:@"SimiTagCollectionCell"];
    SimiTagCollectionCell *cell= [collectionView dequeueReusableCellWithReuseIdentifier:@"SimiTagCollectionCell" forIndexPath:indexPath];
    [cell setData];
    cell.imgTag.image = [UIImage imageNamed:@"storelocator_search_iphone_dai_05"];
    cell.lblTagName.textColor = [self colorWithStringHex:@"393939"];
    [cell.lblTagName setFont:[UIFont fontWithName:THEME_FONT_NAME size:THEME_FONT_SIZE - 4]];
    if (indexPath.row == 0) {
        cell.lblTagName.text = SCLocalizedString(@"All");
    }else
    {
        cell.simiTagModel = [tagModelCollection objectAtIndex:indexPath.row - 1];
        cell.lblTagName.text = [cell.simiTagModel valueForKey:@"value"];
    }
    
    if (tagChoise == nil) {
        tagChoise = SCLocalizedString(@"All");
        stringTagSearch = @"";
    }
    if ([cell.lblTagName.text isEqualToString:tagChoise]) {
        cell.imgTag.image = [UIImage imageNamed:@"storelocator_search_iphone_dai_10"];
        currentPath = indexPath;
    }
    return cell;
}

#pragma mark
#pragma mark Collection Delegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    SimiTagCollectionCell *cellBefore = (SimiTagCollectionCell*)[collectionView cellForItemAtIndexPath:currentPath];
    cellBefore.imgTag.image = [UIImage imageNamed:@"storelocator_search_iphone_dai_05"];
    
    SimiTagCollectionCell *cell = (SimiTagCollectionCell*)[collectionView cellForItemAtIndexPath:indexPath];
    cell.imgTag.image = [UIImage imageNamed:@"storelocator_search_iphone_dai_10"];
    if ([cell.lblTagName.text isEqualToString:SCLocalizedString(@"All")]) {
        stringTagSearch = @"";
    }else
    {
        stringTagSearch = cell.lblTagName.text;
    }
    currentPath = indexPath;
    self.tagChoise = cell.lblTagName.text;
    [self searchStoreLocator];

}

- (void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    /*
    SimiTagCollectionCell *cell = (SimiTagCollectionCell*)[collectionView cellForItemAtIndexPath:indexPath];
    cell.imgTag.image = [UIImage imageNamed:@"storelocator_search_iphone_dai_03"];
    */
}
#pragma mark
#pragma mark Action
- (void)searchStoreLocator
{
    if (txtCitySearch.text == nil) {
        stringCitySearch = @"";
    }else
    {
        stringCitySearch = txtCitySearch.text;
    }
    
    if (txtStateSearch.text == nil) {
        stringStateSearch = @"";
    }else
    {
        stringStateSearch = txtStateSearch.text;
    }
    
    if (txtZipCode.text == nil) {
        stringZipCodeSearch = @"";
    }else
    {
        stringZipCodeSearch = txtZipCode.text;
    }
    if (lblContentCountry.text == nil ||[lblContentCountry.text isEqualToString:@"None"] || [lblContentCountry.text isEqualToString:@""]) {
        stringCountrySearchCode = @"";
        stringCountrySearchName = @"";
    }
    
    [self getStoreLocator];
    [self startLoadingData];
    for (UIView *subView in scrView.subviews) {
        subView.userInteractionEnabled = NO;
        subView.alpha = 0.5;
    }
}

- (void)btnDropDownList_Click:(id)sender
{
    ActionSheetStringPicker *picker = [[ActionSheetStringPicker alloc]initWithTitle:@"Select Country" rows:countryNameArray initialSelection:selectedCountryIndex target:self successAction:@selector(didSelectValue:element:) cancelAction:@selector(cancelActionSheet:) origin:self.view];
    if (PADDEVICE) {
        picker = [[ActionSheetStringPicker alloc]initWithTitle:@"Select Country" rows:countryNameArray initialSelection:selectedCountryIndex target:self successAction:@selector(didSelectValue:element:) cancelAction:@selector(cancelActionSheet:) origin:lblContentCountry];
    }
    [picker showActionSheetPicker];
}

- (void)didSelectValue:(NSNumber *)selectedIndex element:(id)element
{
    selectedCountryIndex = [selectedIndex intValue];
    if (selectedCountryIndex == 0) {
        stringCountrySearchCode = @"";
        stringCountrySearchName = SCLocalizedString(@"None");
    }else
    {
        NSDictionary *countryUnit = [simiAddressStoreLocatorModelCollection objectAtIndex:(selectedCountryIndex - 1)];
        stringCountrySearchName = [countryUnit valueForKey:@"country_name"];
        stringCountrySearchCode = [countryUnit valueForKey:@"country_code"];
    }
    lblContentCountry.text = stringCountrySearchName;
}

- (void)cancelActionSheet:(id)sender
{
    
}

- (void)btnSearch_Click:(id)sender
{
    [self searchStoreLocator];
}

- (void)btnTouchOutLayer_Click:(id)sender
{
    CGRect frame = tblViewCountry.frame;
    frame.size.height = 0;
    [UIView animateWithDuration:0.3 animations:^{
        [tblViewCountry setFrame:frame];
    }];
    isShowTableCountry = NO;
    
    [txtCitySearch resignFirstResponder];
    [txtStateSearch resignFirstResponder];
    [txtZipCode resignFirstResponder];
}

- (void)btnClear:(id)sender
{
    stringCountrySearchCode = @"";
    stringCountrySearchName = @"";
    stringCitySearch = @"";
    stringStateSearch = @"";
    stringZipCodeSearch = @"";
    
    lblContentCountry.text = SCLocalizedString(@"None");
    txtCitySearch.text = @"";
    txtStateSearch.text = @"";
    txtZipCode.text = @"";
}

#pragma mark
#pragma mark Modify UIColor

- (UIColor*) colorWithStringHex:(NSString*)stringHex
{
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:stringHex];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

#pragma mark
#pragma mark TextField Delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark
#pragma mark Notification StoreLocatorModel
- (void)getStoreLocator
{
    sLModelCollection = [[SimiStoreLocatorModelCollection alloc]init];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetStoreLocator:) name:@"StoreLocator_DidGetStoreList" object:sLModelCollection];
    
     [sLModelCollection getStoreListWithLatitude:[NSString stringWithFormat:@"%f",currentLatitube] longitude:[NSString stringWithFormat:@"%f",currentLongitube] offset:@"0" limit:@"20" country:stringCountrySearchCode city:stringCitySearch state:stringStateSearch zipcode:stringZipCodeSearch tag:stringTagSearch];
}

- (void)didGetStoreLocator:(NSNotification*)noti
{
    SimiResponder* responder = [noti.userInfo valueForKey:@"responder"];
    if ([[responder.status uppercaseString] isEqualToString:@"SUCCESS"]) {
        [self stopLoadingData];
        for (UIView* subView in scrView.subviews) {
            subView.userInteractionEnabled = YES;
            subView.alpha = 1.0;
        }
        
        if (sLModelCollection.count > 0) {
            [self.delegate searchStoreLocatorWithCountryName:stringCountrySearchName countryCode:stringCountrySearchCode city:stringCitySearch state:stringStateSearch zipcode:stringZipCodeSearch tag:stringTagSearch];
            [self.delegate cacheDataWithstoreLocatorModelCollection:sLModelCollection simiTagModelCollection:tagModelCollection tagChoise:tagChoise];
            [self.navigationController popViewControllerAnimated:YES];
        }else
        {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Result" message:SCLocalizedString(@"No store match with your searching") delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [self.view addSubview:alert];
            [alert show];
        }
    }
}

#pragma mark
#pragma mark Notification Tag
- (void)getTagList
{
    if (tagModelCollection == nil) {
        tagModelCollection = [[SimiTagModelCollection alloc]init];
    }
    NSInteger offset = tagModelCollection.count;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetTagList:) name:@"DidFinishGetTagList" object:tagModelCollection];
    [tagModelCollection getTagWithOffset:[NSString stringWithFormat:@"%d",(int)offset] limit:@"20"];
    [self.scrView.infiniteScrollingView startAnimating];
}

- (void)didGetTagList:(NSNotification*)noti
{
    SimiResponder* responder = [noti.userInfo valueForKey:@"responder"];
    if ([[responder.status uppercaseString] isEqualToString:@"SUCCESS"]) {
        if (tagModelCollection.count >  0) {
            [self setInterfaceSearchByTag];
        }
    }
    [self.scrView.infiniteScrollingView stopAnimating];
}

@end

@implementation SimiStoreLocatorSearchViewControllerCustomize
{
    UISearchBar *searchBar;
    UITableView *searchTableView;
    SimiStoreLocatorModelCollection *storeCollection;
}

- (void)viewDidLoad {
    searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 44)];
    searchBar.delegate = self;
    [self.view addSubview:searchBar];
    searchBar.placeholder = SCLocalizedString(@"Tim kiem");
    searchTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 44, SCREEN_WIDTH, SCREEN_HEIGHT - 44 - 64) style:UITableViewStylePlain];
    searchTableView.delegate = self;
    searchTableView.dataSource = self;
    searchTableView.tableFooterView = [UIView new];
    [self.view addSubview:searchTableView];
    storeCollection = [SimiStoreLocatorModelCollection new];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetSearchAutoCompleteStores:) name:DidGetSearchAutoCompleteStores object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    self.navigationItem.title = SCLocalizedString(@"Tim kiem cua hang");
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *store = [storeCollection objectAtIndex:indexPath.row];
    if([store objectForKey:@"value"]) {
        [self.navigationController popViewControllerAnimated:YES];
        [self.delegate getStoreListWithValue:[store objectForKey:@"value"]];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return storeCollection.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"storelocator_cell"];
    NSDictionary *store = [storeCollection objectAtIndex:indexPath.row];
    if([store isKindOfClass:[NSDictionary class]] && [store objectForKey:@"value"]) {
        cell.textLabel.text = [NSString stringWithFormat:@"%@",[store objectForKey:@"value"]];
        cell.textLabel.font = [UIFont fontWithName:THEME_FONT_NAME size:THEME_FONT_SIZE];
    }
    return cell;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [storeCollection getSearchAutoCompleteStoreWithKey:searchText];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (void)didGetSearchAutoCompleteStores: (NSNotification *)noti {
    SimiResponder *responder = [noti.userInfo objectForKey:@"responder"];
    if([responder.status isEqualToString:@"SUCCESS"]) {
        [searchTableView reloadData];
    }
}
- (void)viewWillDisappearBefore:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [searchTableView endEditing:YES];
}

#pragma mark - keyboard movements
- (void)keyboardWillShow:(NSNotification *)notification
{
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    searchTableView.contentInset = UIEdgeInsetsMake(0, 0, keyboardSize.height, 0);
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    searchTableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
}

@end
