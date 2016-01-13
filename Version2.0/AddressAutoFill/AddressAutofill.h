//
//  AddressAutofill.h
//  SimiCartPluginFW
//
//  Created by biga on 10/29/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@protocol AddressAutofillDelegate <NSObject>
@optional
-(void)autofillUpdateAddressTable:(CLPlacemark*)place;
@end

@interface AddressAutofill : NSObject <CLLocationManagerDelegate,UIAlertViewDelegate>
{
    CLGeocoder *geocoder;
    CLLocationManager* locationManager;
}

@property (weak, nonatomic) id<AddressAutofillDelegate> delegate;
-(void)start;
-(void)locationPermision;

@end
