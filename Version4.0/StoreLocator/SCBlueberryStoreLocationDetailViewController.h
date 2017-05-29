//
//  SCBlueberryStoreLocationDetailViewController.h
//  SimiCartPluginFW
//
//  Created by Hoang Van Trung on 5/26/17.
//  Copyright © 2017 Trueplus. All rights reserved.
//

#import "SCBlueberryViewController.h"

@interface SCBlueberryStoreLocationDetailViewController : SCBlueberryViewController<UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) SimiModel* storeLocation;
@property float currentLatitude,currentLongitude;
@end
