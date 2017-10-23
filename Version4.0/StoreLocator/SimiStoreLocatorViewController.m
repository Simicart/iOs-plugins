//
//  SimiStoreLocatorViewController.m
//  SimiCartPluginFW
//
//  Created by NghiepLy on 6/30/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import "SimiStoreLocatorViewController.h"
@interface SimiStoreLocatorViewController ()

@end

@implementation SimiStoreLocatorViewController
@synthesize storeLocatorModelCollection, searchButton,tagChoise, simiTagModelCollection;

#pragma mark View Controller Cycle

- (void)viewDidLoadBefore
{
    [super viewDidLoadBefore];
    self.screenTrackingName = @"store_locator";
    self.dataSource = self;
    self.delegate = self;
}

- (void)viewWillAppearBefore:(BOOL)animated{
    
}

- (void)viewWillAppearAfter:(BOOL)animated
{
    [super viewWillAppearAfter:YES];
    searchButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"storelocator_search.png"] style:UIBarButtonItemStylePlain target:self action:@selector(btnSearch_Click)];
    searchButton.width = 44;
    self.navigationItem.rightBarButtonItem = searchButton;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Simi TabViewController Data Source
- (NSUInteger)numberOfTabsForSimiTabView:(SimiTabViewController *)simiTabView
{
    return 2;
}

- (UIView *)simiTabView:(SimiTabViewController *)simiTabView viewForTabAtIndex:(NSUInteger)index;
{
    UILabel *lblStoreList = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH/2, 30)];
    lblStoreList.textAlignment = NSTextAlignmentCenter;
    lblStoreList.text = SCLocalizedString(@"Store List");
    lblStoreList.textColor = [UIColor orangeColor];
    [lblStoreList setFont:[UIFont fontWithName:[NSString stringWithFormat:@"%@-%@",THEME_FONT_NAME,@"Bold"] size:16]];
    
    UILabel *lblMapView = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH/2, 30)];
    lblMapView.textAlignment = NSTextAlignmentCenter;
    lblMapView.text = SCLocalizedString(@"Map View");
    lblMapView.textColor = [UIColor orangeColor];
    [lblMapView setFont:[UIFont fontWithName:[NSString stringWithFormat:@"%@-%@",THEME_FONT_NAME,@"Bold"] size:16]];
    switch (index) {
        case 0:
            return lblStoreList;
            break;
        case 1:
            return lblMapView;
            break;
        default:
            return lblStoreList;
            break;
    }
    
}

- (UIViewController *)simiTabView:(SimiTabViewController *)simiTabView contentViewControllerForTabAtIndex:(NSUInteger)index
{
    switch (index) {
        case 0:
            sLListViewController = [[SimiStoreLocatorListViewController alloc]init];
            sLListViewController.delegate = self;
            return sLListViewController;
            break;
            
        default:
            if (sLMapViewController == nil) {
                sLMapViewController = [[SimiStoreLocatorMapViewController alloc]init];
            }
            sLMapViewController.delegate = self;
            sLMapViewController.currentLatitube = sLListViewController.currentLatitube;
            sLMapViewController.currentLongitube = sLListViewController.currentLongitube;
            sLMapViewController.sLModelCollectionSyncList = sLListViewController.sLModelCollection;
            
            if (sLMapViewController.mapViewOption != MapViewSelectedMarker) {
                sLMapViewController.mapViewOption = MapViewNoneSelectedMarker;
            }
            return sLMapViewController;
            break;
    }
}


#pragma mark Simi Tab View Delegate
- (CGFloat)simiTabView:(SimiTabViewController *)simiTabView valueForOption:(SimiTabViewOption)option withDefault:(CGFloat)value{
    switch (option) {
        case SimiTabViewOptionTabWidth:
            return self.view.frame.size.width/2;
            break;
        case SimiTabViewOptionTabHeight:
            return 50;
        default:
            return value;
            break;
    }
}

- (void)simiTabView:(SimiTabViewController *)simiTabView didChangeTabToIndex:(NSUInteger)index
{
    switch (index) {
        case 0:
            if (sLMapViewController != nil) {
                sLMapViewController.mapViewOption = MapViewNoneSelectedMarker;
            }
            break;
        case 1:
            break;
        default:
            break;
    }
}

#pragma mark Simi StoreLocatorMapViewController Delegate
-(void)showViewDetailControllerFromMap:(SimiModel *)sLModel_
{
    SimiStoreLocatorDetailViewController *sLDetailViewController = [SimiStoreLocatorDetailViewController new];
    sLDetailViewController.sLModel = sLModel_;
    sLDetailViewController.title = @"Store List Detail";
    sLDetailViewController.currentLatitude = sLMapViewController.currentLatitube;
    sLDetailViewController.currentLongitude = sLMapViewController.currentLongitube;
    sLDetailViewController.delegate = self;
    [self.navigationController pushViewController:sLDetailViewController animated:YES];
}

#pragma mark Simi StoreLocatorListViewController Delegate
- (void)didChoiseStoreFromListToMap
{
    if (sLMapViewController == nil) {
        sLMapViewController = [[SimiStoreLocatorMapViewController alloc]init];
    }
    sLMapViewController.sLModel = sLListViewController.sLModel;
    sLMapViewController.mapViewOption = MapViewSelectedMarker;
    [self selectTabAtIndex:1];
}

- (void)showViewDetailControllerFromList:(SimiModel *)sLModel_
{
    SimiStoreLocatorDetailViewController *sLDetailViewController = [[SimiStoreLocatorDetailViewController alloc]init];
    sLDetailViewController.sLModel = sLModel_;
    sLDetailViewController.title = SCLocalizedString(@"Store List Detail");
    sLDetailViewController.currentLatitude = sLListViewController.currentLatitube;
    sLDetailViewController.currentLongitude = sLListViewController.currentLongitube;
    sLDetailViewController.delegate = self;
    [self.navigationController pushViewController:sLDetailViewController animated:YES];
}

#pragma mark Simi StoreLocatorDetailView Controller Delegate
-(void)returnMapViewController:(SimiModel*) sLModelParam
{
    if (sLMapViewController == nil) {
        sLMapViewController = [[SimiStoreLocatorMapViewController alloc]init];
    }
    sLMapViewController.sLModel = sLModelParam;
    sLMapViewController.mapViewOption = MapViewSelectedMarker;
    [self selectTabAtIndex:1];
}

#pragma mark Search
- (void)btnSearch_Click
{
    SimiStoreLocatorSearchViewController * sLSearchViewController = [SimiStoreLocatorSearchViewController new];
    sLSearchViewController.delegate = self;
    sLSearchViewController.currentLatitube = sLListViewController.currentLatitube;
    sLSearchViewController.currentLongitube = sLListViewController.currentLongitube;
    sLSearchViewController.currentCountry = sLListViewController.currentCountry;
    sLSearchViewController.currentState = sLListViewController.currentState;
    sLSearchViewController.currentCity = sLListViewController.currentCity;
    sLSearchViewController.storeName = sLListViewController.storeName;
    sLSearchViewController.tag = sLListViewController.tag;
    
    if (tagChoise != nil) {
        sLSearchViewController.tagChoise = tagChoise;
    }
    
    if (simiTagModelCollection != nil) {
        sLSearchViewController.tagModelCollection = simiTagModelCollection;
    }
    [self.navigationController pushViewController:sLSearchViewController animated:YES];
}

#pragma  mark Search ViewController Delegate

- (void)searchStoreLocatorWithCountry:(NSDictionary *)country state:(NSDictionary *)state city:(NSDictionary *)city storeName:(NSString *)storeName tag:(NSString *)tag
{
    sLListViewController.currentCountry = country;
    sLListViewController.currentState = state;
    sLListViewController.currentCity = city;
    sLListViewController.tag = tag;
    sLListViewController.storeName = storeName;
    
    
    if (sLMapViewController == nil) {
        sLMapViewController = [[SimiStoreLocatorMapViewController alloc]init];
    }
    sLMapViewController.currentCountry = country;
    sLMapViewController.currentState = state;
    sLMapViewController.currentCity = city;
    sLMapViewController.tag = tag;
    sLMapViewController.storeName = storeName;
    
    sLListViewController.listViewOption = ListViewOptionSearched;
    sLMapViewController.searchOption = SearchOptionSearched;
}

- (void)cacheDataWithstoreLocatorModelCollection:(SimiStoreLocatorModelCollection *)collection simiTagModelCollection:(SimiTagModelCollection *)tagModelCollection tagChoise:(NSString *)tagString
{
    [sLListViewController.sLModelCollection removeAllObjects];
    for (int i = 0; i < collection.count; i++) {
        [sLListViewController.sLModelCollection addObject:[collection objectAtIndex:i]];
    }
    
    if (sLMapViewController == nil) {
        sLMapViewController = [[SimiStoreLocatorMapViewController alloc]init];
    }
    [sLMapViewController.sLModelCollectionAll removeAllObjects];
    for (int i = 0; i < collection.count; i++) {
        [sLMapViewController.sLModelCollectionAll addObject:[collection objectAtIndex:i]];
    }
    
    simiTagModelCollection = tagModelCollection;
    tagChoise = tagString;
}
@end
