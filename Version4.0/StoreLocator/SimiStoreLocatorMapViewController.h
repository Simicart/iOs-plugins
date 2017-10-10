//
//  SimiStoreLocatorMapViewController.h
//  SimiCartPluginFW
//
//  Created by NghiepLy on 7/1/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import <SimiCartBundle/SimiCartBundle.h>
#import <SimiCartBundle/SimiViewController.h>
#import <GoogleMaps/GoogleMaps.h>
#import <SimiCartBundle/SimiModel.h>
#import "SimiStoreLocatorModelCollection.h"
#import "SimiStoreLocatorMaker.h"
#import "SimiStoreLocatorPopup.h"
#import "SimiStoreLocatorModel.h"

typedef NS_ENUM(NSInteger, MapViewOption){
        MapViewNoneSelectedMarker,
        MapViewSelectedMarker
};

typedef NS_ENUM(NSInteger, SearchOption){
        SearchOptionNoneSearch,
        SearchOptionSearched,
};

@protocol SimiStoreLocatorMapViewControllerDelegate <NSObject>
@optional
- (void)showViewDetailControllerFromMap:(SimiStoreLocatorModel*) sLModel_;

@end
@interface SimiStoreLocatorMapViewController : SimiViewController<GMSMapViewDelegate, SimiStoreLocatorPopupDelegate >
{
    GMSMapView *mapView_;
}

@property (nonatomic, strong) SimiStoreLocatorModelCollection *sLModelCollectionSyncList;
@property (nonatomic, strong) SimiStoreLocatorModelCollection *sLModelCollectionUpdate;
@property (nonatomic, strong) SimiStoreLocatorModelCollection *sLModelCollectionAll;
@property (nonatomic, strong) SimiStoreLocatorModel *sLModel;
@property (nonatomic, strong) NSDictionary *dictSearch;
@property (nonatomic) float currentLatitube;
@property (nonatomic) float currentLongitube;
@property (nonatomic)   MapViewOption mapViewOption;
@property (nonatomic)   SearchOption    searchOption;
@property (nonatomic, weak) id<SimiStoreLocatorMapViewControllerDelegate> delegate;

- (void)showMaker;
- (void)syncDataFromList;
@end
