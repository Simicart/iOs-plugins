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
@implementation SimiStoreLocatorSearchViewController{
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
    
    NSArray *searchConfig;
}
@synthesize currentCity, currentState, currentCountry, storeName, tag;
@synthesize sLModelCollection, tagModelCollection, delegate, currentLongitube, currentLatitube, stringTagSearch, tagChoise;
@synthesize lblStoreName,lblState,lblCity,lblCountry,lblSearchByArea,lblSearchByTag, collectionViewTagContent;
@synthesize btnState,tblViewCountry,btnCity,txtStoreName;
@synthesize viewSearchByStoreName,viewSearchByState,viewSearchByCity,viewSearchByCountry, viewSearch, viewSearchByTag, scrView;
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
    
    searchConfig = [SimiGlobalVar sharedInstance].searchConfigs;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:SCLocalizedString(@"Clear") style:UIBarButtonItemStylePlain target:self action:@selector(btnClear:)];
}

- (void)viewWillAppearBefore:(BOOL)animated{
    if (SIMI_SYSTEM_IOS < 7) {
        self.contentSizeForViewInPopover = CGSizeMake(500, 700);
    }else{
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
    
    _btnCountry = [[UIButton alloc]initWithFrame:CGRectMake(textFieldX, topDistance, widthTextField, heightLabel)];
    [_btnCountry addTarget:self action:@selector(btnDropDownList_Click:) forControlEvents:UIControlEventTouchUpInside];
    [_btnCountry setBackgroundColor:[UIColor clearColor]];
    [viewSearchByCountry addSubview:_btnCountry];
    [_btnCountry setTitleColor:[[SimiGlobalVar sharedInstance] colorWithHexString:@"#393939"] forState:UIControlStateNormal];
    _btnCountry.titleLabel.font = [UIFont fontWithName:THEME_FONT_NAME size:THEME_FONT_SIZE - 2];
    [_btnCountry setTitle:SCLocalizedString(@"Select country") forState:UIControlStateNormal];
    if(currentCountry){
        [_btnCountry setTitle:SCLocalizedString([currentCountry objectForKey:@"country_name"]) forState:UIControlStateNormal];
    }
    
    heightContent +=  CGRectGetHeight(viewSearchByCountry.frame);
    
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
    [_imgState setImage:[UIImage imageNamed:@"storelocator_searchdropbox"]];
    [viewSearchByState addSubview:_imgState];
    
    btnState = [[UIButton alloc]initWithFrame:CGRectMake(textFieldX, topDistance, widthTextField, heightLabel)];
    [btnState addTarget:self action:@selector(btnDropDownList_Click:) forControlEvents:UIControlEventTouchUpInside];
    [btnState setBackgroundColor:[UIColor clearColor]];
    [viewSearchByState addSubview:btnState];
    [btnState setTitleColor:[[SimiGlobalVar sharedInstance] colorWithHexString:@"#393939"] forState:UIControlStateNormal];
    btnState.titleLabel.font = [UIFont fontWithName:THEME_FONT_NAME size:THEME_FONT_SIZE - 2];
    [btnState setTitle:SCLocalizedString(@"Select state") forState:UIControlStateNormal];
    if(currentState){
        [btnState setTitle:SCLocalizedString([currentState objectForKey:@"state_name"]) forState:UIControlStateNormal];
    }
    heightContent += CGRectGetHeight(viewSearchByState.frame);
    
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
    [_imgCity setImage:[UIImage imageNamed:@"storelocator_searchdropbox"]];
    [viewSearchByCity addSubview:_imgCity];
    
    btnCity = [[UIButton alloc]initWithFrame:CGRectMake(textFieldX, topDistance, widthTextField, heightLabel)];
    [btnCity addTarget:self action:@selector(btnDropDownList_Click:) forControlEvents:UIControlEventTouchUpInside];
    [btnCity setBackgroundColor:[UIColor clearColor]];
    [viewSearchByCity addSubview:btnCity];
    [btnCity setTitleColor:[[SimiGlobalVar sharedInstance] colorWithHexString:@"#393939"] forState:UIControlStateNormal];
    btnCity.titleLabel.font = [UIFont fontWithName:THEME_FONT_NAME size:THEME_FONT_SIZE - 2];
    [btnCity setTitle:SCLocalizedString(@"Select city") forState:UIControlStateNormal];
    if(currentCity){
        [btnCity setTitle:SCLocalizedString([currentCity objectForKey:@"city_name"]) forState:UIControlStateNormal];
    }
    heightContent += CGRectGetHeight(viewSearchByCity.frame);
    
#pragma mark Search By Zipcode
    viewSearchByStoreName = [[UIControl alloc]initWithFrame:CGRectMake(0, heightContent, widthContent, heightViewControl)];
    [viewSearchByStoreName addTarget:self action:@selector(btnTouchOutLayer_Click:) forControlEvents:UIControlEventTouchUpInside];
    [scrView addSubview:viewSearchByStoreName];
    
    lblStoreName = [[UILabel alloc]initWithFrame:CGRectMake(labelTitleX, topDistance, widthTitle, heightLabel)];
    [lblStoreName setTextColor:[[SimiGlobalVar sharedInstance] colorWithHexString:@"#393939"]];
    [lblStoreName setFont:[UIFont fontWithName:THEME_FONT_NAME size:THEME_FONT_SIZE - 2]];
    [lblStoreName setText:[NSString stringWithFormat:@"%@:", SCLocalizedString(@"Store Name")]];
    [viewSearchByStoreName addSubview:lblStoreName];
    
    _imgStoreName = [[UIImageView alloc]initWithFrame:CGRectMake(textFieldX, topDistance, widthTextField, heightLabel)];
    [_imgStoreName setImage:[UIImage imageNamed:@"storelocator_search_text_field"]];
    [viewSearchByStoreName addSubview:_imgStoreName];
    
    txtStoreName = [[UITextField alloc]initWithFrame:CGRectMake(textFieldX + leftDistance, topDistance, widthTextField - leftDistance, heightLabel)];
    txtStoreName.textColor = [[SimiGlobalVar sharedInstance] colorWithHexString:@"#393939"];
    [txtStoreName setFont: [UIFont fontWithName:THEME_FONT_NAME size:THEME_FONT_SIZE]];
    txtStoreName.text = @"";
    if(self.storeName){
        txtStoreName.text = self.storeName;
    }
    [viewSearchByStoreName addSubview:txtStoreName];
    
    heightContent += CGRectGetHeight(viewSearchByStoreName.frame);
    
#pragma mark Button Search
    viewSearch = [[UIView alloc]initWithFrame:CGRectMake(0, heightContent, widthContent, heightViewControl)];
    [viewSearch setBackgroundColor:[UIColor clearColor]];
    [scrView addSubview:viewSearch];
    btnSearch = [[UIButton alloc]initWithFrame:CGRectMake(textFieldX, topDistance, widthTextField, heightLabel)];
    [btnSearch addTarget:self action:@selector(btnSearch_Click:) forControlEvents:UIControlEventTouchUpInside];
    [btnSearch setBackgroundImage:[UIImage imageNamed:@"storelocator_bt_search"] forState:UIControlStateNormal];
    [btnSearch setTitle:SCLocalizedString(@"Search") forState:UIControlStateNormal];
    btnSearch.titleLabel.font = [UIFont fontWithName:THEME_FONT_NAME size:THEME_FONT_SIZE - 2];
    [viewSearch addSubview:btnSearch];
    heightContent += heightViewControl;
    
    [SimiGlobalVar sortViewForRTL:scrView andWidth:CGRectGetWidth(scrView.frame)];
    [SimiGlobalVar sortViewForRTL:viewSearchByCountry andWidth:widthContent];
    [SimiGlobalVar sortViewForRTL:viewSearchByState andWidth:widthContent];
    [SimiGlobalVar sortViewForRTL:viewSearchByCity andWidth:widthContent];
    [SimiGlobalVar sortViewForRTL:viewSearchByStoreName andWidth:widthContent];
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
    [self getStoreLocator];
    [self startLoadingData];
//    for (UIView *subView in scrView.subviews) {
//        subView.userInteractionEnabled = NO;
//        subView.alpha = 0.5;
//    }
}

- (void)btnDropDownList_Click:(id)sender
{
    NSInteger initialSelection = 0;
    if(sender == _btnCountry){
        NSMutableArray *countryList = [[NSMutableArray alloc] initWithObjects:@"Select country", nil];
        [countryList addObjectsFromArray:[searchConfig valueForKey:@"country_name"]];
        if(self.currentCountry){
            initialSelection = [searchConfig indexOfObject:self.currentCountry] + 1;
        }
        ActionSheetStringPicker *picker = [[ActionSheetStringPicker alloc]initWithTitle:@"Select Country" rows:countryList initialSelection:initialSelection target:self successAction:@selector(didSelectCountryAtIndex:) cancelAction:@selector(cancelActionSheet:) origin:self.view];
        if (PADDEVICE) {
            picker = [[ActionSheetStringPicker alloc]initWithTitle:@"Select Country" rows:countryList initialSelection:initialSelection target:self successAction:@selector(didSelectCountryAtIndex:) cancelAction:@selector(cancelActionSheet:) origin:_btnCountry];
        }
        [picker showActionSheetPicker];
    }else if(sender == btnCity){
        NSMutableArray *cityList = [[NSMutableArray alloc] initWithObjects:@"Select city", nil];
        NSArray *cities = [self.currentState objectForKey:@"cities"];
        [cityList addObjectsFromArray:[cities valueForKey:@"city_name"]];
        if(self.currentCity){
            initialSelection = [cities indexOfObject:self.currentCity] + 1;
        }
        ActionSheetStringPicker *picker = [[ActionSheetStringPicker alloc]initWithTitle:@"Select City" rows:cityList initialSelection:initialSelection target:self successAction:@selector(didSelectCityAtIndex:) cancelAction:@selector(cancelActionSheet:) origin:self.view];
        if (PADDEVICE) {
            picker = [[ActionSheetStringPicker alloc]initWithTitle:@"Select City" rows:cityList initialSelection:initialSelection target:self successAction:@selector(didSelectCityAtIndex:) cancelAction:@selector(cancelActionSheet:) origin:btnCity];
        }
        [picker showActionSheetPicker];
    }else if(sender == btnState){
        NSMutableArray *stateList = [[NSMutableArray alloc] initWithObjects:@"Select state", nil];
        NSArray *states = [self.currentCountry objectForKey:@"states"];
        [stateList addObjectsFromArray:[states valueForKey:@"state_name"]];
        if(self.currentState){
            initialSelection = [states indexOfObject:self.currentState] + 1;
        }
        ActionSheetStringPicker *picker = [[ActionSheetStringPicker alloc]initWithTitle:@"Select State" rows:stateList initialSelection:initialSelection target:self successAction:@selector(didSelectStateAtIndex:) cancelAction:@selector(cancelActionSheet:) origin:self.view];
        if (PADDEVICE) {
            picker = [[ActionSheetStringPicker alloc]initWithTitle:@"Select State" rows:stateList initialSelection:initialSelection target:self successAction:@selector(didSelectStateAtIndex:) cancelAction:@selector(cancelActionSheet:) origin:btnState];
        }
        [picker showActionSheetPicker];
    }
}

- (void)didSelectCountryAtIndex:(NSNumber*)selectedIndex{
    if([selectedIndex intValue] == 0){
        self.currentCountry = nil;
        self.currentState = nil;
        self.currentCity = nil;
        [_btnCountry setTitle:SCLocalizedString(@"Select country") forState:UIControlStateNormal];
        [btnCity setTitle:SCLocalizedString(@"Select city") forState:UIControlStateNormal];
        [btnState setTitle:SCLocalizedString(@"Select state") forState:UIControlStateNormal];
    }else{
        NSDictionary *selectedCountry = [searchConfig objectAtIndex:[selectedIndex intValue]-1];
        if(self.currentCountry != selectedCountry){
            self.currentCountry = selectedCountry;
            [_btnCountry setTitle:[self.currentCountry objectForKey:@"country_name"] forState:UIControlStateNormal];
            [btnCity setTitle:SCLocalizedString(@"Select city") forState:UIControlStateNormal];
            [btnState setTitle:SCLocalizedString(@"Select state") forState:UIControlStateNormal];
        }
    }
}

- (void)didSelectStateAtIndex:(NSNumber*)selectedIndex{
    if([selectedIndex intValue] == 0){
        self.currentState = nil;
        self.currentCity = nil;
        [btnCity setTitle:SCLocalizedString(@"Select city") forState:UIControlStateNormal];
        [btnState setTitle:SCLocalizedString(@"Select state") forState:UIControlStateNormal];
    }else{
        NSArray *states = [self.currentCountry objectForKey:@"states"];
        NSDictionary *selectedState = [states objectAtIndex:[selectedIndex intValue] - 1];
        if(self.currentState != selectedState){
            self.currentState = selectedState;
            [btnState setTitle:[self.currentState objectForKey:@"state_name"] forState:UIControlStateNormal];
            [btnCity setTitle:SCLocalizedString(@"Select city") forState:UIControlStateNormal];
        }
    }
}

- (void)didSelectCityAtIndex:(NSNumber*)selectedIndex{
    if([selectedIndex intValue] == 0){
        currentCity = nil;
        [btnCity setTitle:SCLocalizedString(@"Select city") forState:UIControlStateNormal];
    }else{
        NSArray* cities = [currentState objectForKey:@"cities"];
        NSDictionary *selectedCity = [cities objectAtIndex:[selectedIndex intValue] - 1];
        if(currentCity != selectedCity){
            currentCity = selectedCity;
            [btnCity setTitle:[currentCity objectForKey:@"city_name"] forState:UIControlStateNormal];
        }
    }
}

- (void)cancelActionSheet:(id)sender
{
    
}

- (void)btnSearch_Click:(id)sender
{
    [self getStoreLocator];
}

- (void)btnTouchOutLayer_Click:(id)sender
{
    CGRect frame = tblViewCountry.frame;
    frame.size.height = 0;
    [UIView animateWithDuration:0.3 animations:^{
        [tblViewCountry setFrame:frame];
    }];
    isShowTableCountry = NO;
    
    [txtStoreName resignFirstResponder];
}

- (void)btnClear:(id)sender
{
    currentCountry = nil;
    currentState = nil;
    currentCity = nil;
    txtStoreName.text = @"";
    [_btnCountry setTitle:SCLocalizedString(@"Select country") forState:UIControlStateNormal];
    [btnState setTitle:SCLocalizedString(@"Select state") forState:UIControlStateNormal];
    [btnCity setTitle:SCLocalizedString(@"Select city") forState:UIControlStateNormal];
    [self getStoreLocator];
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
    NSString *countryCode = @"";
    NSString *cityName = @"";
    NSString *stateName = @"";
    if(currentCountry){
        countryCode = [currentCountry objectForKey:@"country_code"];
    }
    if(currentCity){
        cityName = [currentCity objectForKey:@"city_name"];
    }
    if(currentState){
        stateName = [currentState objectForKey:@"state_name"];
    }
     [sLModelCollection getStoreListWithLatitude:[NSString stringWithFormat:@"%f",currentLatitube] longitude:[NSString stringWithFormat:@"%f",currentLongitube] offset:@"0" limit:@"20" country:countryCode city:cityName state:stateName storeName:txtStoreName.text tag:stringTagSearch];
    [self startLoadingData];
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
        NSString *countryCode = @"";
        NSString *countryName = @"";
        NSString *cityName = @"";
        NSString *stateName = @"";
        if(currentCountry){
            countryCode = [currentCountry objectForKey:@"country_code"];
            countryName = [currentCountry objectForKey:@"country_name"];
        }
        if(currentCity){
            cityName = [currentCity objectForKey:@"city_name"];
        }
        if(currentState){
            stateName = [currentState objectForKey:@"state_name"];
        }
        
        if (sLModelCollection.count > 0) {
            [self.delegate searchStoreLocatorWithCountry:currentCountry state:currentState city:currentCity storeName:txtStoreName.text tag:stringTagSearch];
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
