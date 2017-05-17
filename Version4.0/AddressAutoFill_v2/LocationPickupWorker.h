//
//  LocationPickupWorker.h
//  SimiCartPluginFW
//
//  Created by NghiepLy on 7/17/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SimiAddressAutofillModel.h"
#import <GoogleMaps/GoogleMaps.h>
#import <GooglePlaces/GooglePlaces.h>

@interface LocationPickupWorker : NSObject<GMSAutocompleteTableDataSourceDelegate,UITextFieldDelegate>

@end
