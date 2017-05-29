//
//  SCBlueberryStoreLocatorViewController.h
//  SimiCartPluginFW
//
//  Created by Hoang Van Trung on 5/26/17.
//  Copyright © 2017 Trueplus. All rights reserved.
//

#import "SCBlueberryViewController.h"
#import <SimiCartBundle/SimiCartBundle.h>
#import <SimiCartBundle/SimiViewController.h>
#import <GoogleMaps/GoogleMaps.h>
#import <SimiCartBundle/SimiModel.h>
#import "SimiStoreLocatorModelCollection.h"
#import "SimiStoreLocatorMaker.h"
#import "SimiStoreLocatorPopup.h"
#import "SimiCLController.h"
#import "SCBlueberryButton.h"
#import "SCBlueberryStoreLocationDetailViewController.h"

@interface SCBlueberryStoreLocatorViewController : SCBlueberryViewController<SimiCLControllerDelegate, UITableViewDelegate, UITableViewDataSource,GMSMapViewDelegate>

@end
@interface SCBlueberryStoreLocationCell : UITableViewCell
@property (nonatomic, strong) SimiModel* storeLocation;
@end
