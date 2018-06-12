//
//  SimiStoreLocatorMapViewController.m
//  SimiCartPluginFW
//
//  Created by NghiepLy on 7/1/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import "SimiStoreLocatorMapViewController.h"

@interface SimiStoreLocatorMapViewController ()

@end

@implementation SimiStoreLocatorMapViewController
{
    SimiStoreLocatorPopup *storeLocatorPopup;
}
@synthesize sLModelCollectionSyncList, currentLongitube, currentLatitube, mapViewOption;
@synthesize sLModel, sLModelCollectionAll, sLModelCollectionUpdate, delegate, searchOption;
@synthesize dictSearch;
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    sLModelCollectionAll = [[SimiStoreLocatorModelCollection alloc]init];
    sLModelCollectionUpdate = [[SimiStoreLocatorModelCollection alloc]init];
    
    GMSCameraPosition *camera;
    float latitude = [sLModel.latitude floatValue];
    float longitude = [sLModel.longtitude floatValue];
    switch (mapViewOption) {
        case MapViewNoneSelectedMarker:
            camera = [GMSCameraPosition cameraWithLatitude:currentLatitube
                                                                    longitude:currentLongitube
                                                                    zoom:0];
            break;
        case MapViewSelectedMarker:
            camera = [GMSCameraPosition cameraWithLatitude:latitude
                                                 longitude:longitude
                                                      zoom:[sLModel.zoomLevel floatValue]];
            break;
        default:
            return;
            break;
    }
    
    mapView_ = [GMSMapView mapWithFrame:CGRectZero camera:camera];
    
    mapView_.myLocationEnabled = YES;
    mapView_.delegate = self;
    [self.view addSubview:mapView_];
    if (PHONEDEVICE) {
        storeLocatorPopup = [[SimiStoreLocatorPopup alloc]initWithFrame:CGRectMake(0, 0, 265, 76)];
    }else
        storeLocatorPopup = [[SimiStoreLocatorPopup alloc]initWithFrame:CGRectMake(0, 0, 300, 90)];
}

- (void)viewDidAppear:(BOOL)animated
{
    //Load lai du lieu vao collection all
    [mapView_ setFrame:self.view.bounds];
    [self syncDataFromList];
    [self showMaker];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark GMS MapView Delegate

- (UIView*)mapView:(GMSMapView *)mapView markerInfoWindow:(SimiStoreLocatorMaker *)marker
{
    if (marker.storeLocatorModel != nil) {
        storeLocatorPopup.storeLocatorModel = marker.storeLocatorModel;
        if (marker.storeLocatorModel.name != nil) {
            [[NSNotificationCenter defaultCenter]postNotificationName:TRACKINGEVENT object:@"store_locator_action" userInfo:@{@"action":@"clicked_store_maker",@"store_name":marker.storeLocatorModel.name}];
        }
        [storeLocatorPopup setContentForPopup];
        return storeLocatorPopup;
    }else
    {
        return nil;
    }
    
}

- (void)mapView:(GMSMapView *)mapView didTapInfoWindowOfMarker:( SimiStoreLocatorMaker*)marker
{
    if (marker.storeLocatorModel != nil) {
        [self.delegate showViewDetailControllerFromMap:marker.storeLocatorModel];
    }
}

- (void)mapView:(GMSMapView *)mapView idleAtCameraPosition:(GMSCameraPosition *)position
{
    [self getStoreLocatorList:position];
}

- (void)getStoreLocatorList:(GMSCameraPosition *)position
{
    if (sLModelCollectionUpdate == nil) {
        sLModelCollectionUpdate = [[SimiStoreLocatorModelCollection alloc]init];
    }
    [sLModelCollectionUpdate removeAllObjects];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetStoreLocatorList:) name:StoreLocator_DidGetStoreList object:sLModelCollectionUpdate];
    switch (searchOption) {
        case SearchOptionNoneSearch:
            [sLModelCollectionUpdate getStoreListWithLatitude:[NSString stringWithFormat:@"%f",position.target.latitude] longitude:[NSString stringWithFormat:@"%f",position.target.longitude] offset:@"0" limit:@"20"];
            break;
        case SearchOptionSearched:
            [sLModelCollectionUpdate getStoreListWithLatitude:[NSString stringWithFormat:@"%f",position.target.latitude] longitude:[NSString stringWithFormat:@"%f",position.target.longitude] offset:@"0" limit:@"20" country:[dictSearch valueForKey:@"countryCode"] city:[dictSearch valueForKey:@"city"] state:[dictSearch valueForKey:@"state"] zipcode:[dictSearch valueForKey:@"zipcode"] tag:[dictSearch valueForKey:@"tag"]];
            break;
        default:
            break;
    }
}

- (void)didGetStoreLocatorList:(NSNotification*)noti
{
    SimiResponder* responder = [noti.userInfo valueForKey:responderKey];
    if (responder.status == SUCCESS) {
        
        NSUInteger sLModelCollectionUpdateCount = [sLModelCollectionUpdate count];
        NSUInteger sLModelCollectionAllCount = sLModelCollectionAll.count;
        SimiStoreLocatorModelCollection* newSLModelCollection = [[SimiStoreLocatorModelCollection alloc]init];
        for (int i = 0; i < sLModelCollectionUpdateCount; i++) {
            BOOL isNewStoreLocatorModel = YES;
            for (int j = 0; j < sLModelCollectionAllCount; j++) {
                if ([((SimiStoreLocatorModel *)[sLModelCollectionAll objectAtIndex:j]).simistorelocatorId intValue] == [((SimiStoreLocatorModel *)[sLModelCollectionUpdate objectAtIndex:i]).simistorelocatorId intValue])
                {
                    isNewStoreLocatorModel = NO;
                    break;
                }
            }
            if (isNewStoreLocatorModel) {
                [sLModelCollectionAll addObject:[sLModelCollectionUpdate objectAtIndex:i]];
                [newSLModelCollection addObject:[sLModelCollectionUpdate objectAtIndex:i]];
            }
        }
        if (newSLModelCollection.count > 0) {
            for (int i = 0; i < newSLModelCollection.count; i++) {
                SimiStoreLocatorMaker * storeLocatorMaker_ = [[SimiStoreLocatorMaker alloc]init];
                storeLocatorMaker_.storeLocatorModel = [newSLModelCollection objectAtIndex:i];
                float lat = (float)[[NSString stringWithFormat:@"%@",storeLocatorMaker_.storeLocatorModel.latitude] floatValue];
                float lng = (float)[[NSString stringWithFormat:@"%@",storeLocatorMaker_.storeLocatorModel.longtitude] floatValue];
                storeLocatorMaker_.position = CLLocationCoordinate2DMake(lat,lng);
                storeLocatorMaker_.icon = [UIImage imageNamed:@"storelocator_point"];
                storeLocatorMaker_.map = mapView_;
            }
        }
        
        NSLog(@" So luong all store:%d",(int)sLModelCollectionAll.count);
        [self removeObserverForNotification:noti];
    }
}

#pragma mark Show Choice Maker on iPad
- (void)syncDataFromList
{
    NSUInteger sLModelCollectionAllCount;
    NSUInteger storeLocatorModelCollectionSyncListCount;
    sLModelCollectionAllCount = sLModelCollectionAll.count;
    storeLocatorModelCollectionSyncListCount = sLModelCollectionSyncList.count;
    if (storeLocatorModelCollectionSyncListCount != 0) {
        if (sLModelCollectionAllCount == 0 ) {
            for (int i = 0; i < storeLocatorModelCollectionSyncListCount; i++)
            {
                [sLModelCollectionAll addObject:[sLModelCollectionSyncList objectAtIndex:i]];
                SimiStoreLocatorMaker * storeLocatorMaker_ = [[SimiStoreLocatorMaker alloc]init];
                storeLocatorMaker_.storeLocatorModel = [sLModelCollectionSyncList objectAtIndex:i];
                float lat = (float)[[NSString stringWithFormat:@"%@",storeLocatorMaker_.storeLocatorModel.latitude] floatValue];
                float lng = (float)[[NSString stringWithFormat:@"%@",storeLocatorMaker_.storeLocatorModel.longtitude] floatValue];
                storeLocatorMaker_.position = CLLocationCoordinate2DMake(lat,lng);
                storeLocatorMaker_.icon = [UIImage imageNamed:@"storelocator_point"];
                storeLocatorMaker_.map = mapView_;
            }
        }else
        {
            for (int i = 0; i < storeLocatorModelCollectionSyncListCount; i++) {
                BOOL isNewStoreLocatorModel = YES;
                for (int j = 0; j < sLModelCollectionAllCount; j++) {
                    if ([((SimiStoreLocatorModel *)[sLModelCollectionSyncList objectAtIndex:i]).simistorelocatorId isEqualToString:((SimiStoreLocatorModel *)[sLModelCollectionAll objectAtIndex:j]).simistorelocatorId]) {
                        isNewStoreLocatorModel = NO;
                    }
                }
                if (isNewStoreLocatorModel) {
                    [sLModelCollectionAll addObject:[sLModelCollectionSyncList objectAtIndex:i]];
                    SimiStoreLocatorMaker * storeLocatorMaker_ = [[SimiStoreLocatorMaker alloc]init];
                    storeLocatorMaker_.storeLocatorModel = [sLModelCollectionSyncList objectAtIndex:i];
                    float lat = (float)[[NSString stringWithFormat:@"%@",storeLocatorMaker_.storeLocatorModel.latitude] floatValue];
                    float lng = (float)[[NSString stringWithFormat:@"%@",storeLocatorMaker_.storeLocatorModel.longtitude] floatValue];
                    storeLocatorMaker_.position = CLLocationCoordinate2DMake(lat,lng);
                    storeLocatorMaker_.icon = [UIImage imageNamed:@"storelocator_point"];
                    storeLocatorMaker_.map = mapView_;
                }
            }
        }
    }
}
- (void)showMaker
{
    [mapView_ clear];
    SimiStoreLocatorMaker *currentLocations = [[SimiStoreLocatorMaker alloc]init];
    currentLocations.position = CLLocationCoordinate2DMake(currentLatitube, currentLongitube);
    currentLocations.title = SCLocalizedString(@"You are here");
    currentLocations.icon = [UIImage imageNamed:@"sl_icon__09.png"];
    currentLocations.map = mapView_;
    currentLocations.tappable = YES;
    
    for (int i = 0; i < [sLModelCollectionAll count]; i++) {
        SimiStoreLocatorModel *storeLocatorModel_ = [sLModelCollectionAll objectAtIndex:i];
        SimiStoreLocatorMaker * storeLocatorMaker_ = [[SimiStoreLocatorMaker alloc]init];
        float lat = (float)[[NSString stringWithFormat:@"%@",storeLocatorModel_.latitude] floatValue];
        float lng = (float)[[NSString stringWithFormat:@"%@",storeLocatorModel_.longtitude] floatValue];
        storeLocatorMaker_.position = CLLocationCoordinate2DMake(lat,lng);
        storeLocatorMaker_.storeLocatorModel = [sLModelCollectionAll objectAtIndex:i];
        
        if (mapViewOption == MapViewSelectedMarker) {
            if ([storeLocatorMaker_.storeLocatorModel.simistorelocatorId isEqualToString:sLModel.simistorelocatorId])
            {
                [mapView_ setSelectedMarker:storeLocatorMaker_];
            }
        }
        storeLocatorMaker_.icon = [UIImage imageNamed:@"storelocator_point"];
        storeLocatorMaker_.map = mapView_;
    }
    
    if (mapViewOption == MapViewSelectedMarker) {
        float latitude = [sLModel.latitude floatValue];
        float longitude = [sLModel.longtitude floatValue];
        
        GMSCameraPosition *cameraPosition = [GMSCameraPosition cameraWithLatitude:latitude longitude:longitude zoom:[sLModel.zoomLevel floatValue]];
        [mapView_ setCamera:cameraPosition];
    }
}
@end
