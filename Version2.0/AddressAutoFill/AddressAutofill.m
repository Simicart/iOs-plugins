//
//  AddressAutofill.m
//  SimiCartPluginFW
//
//  Created by biga on 10/29/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import "AddressAutofill.h"
#import <AddressBook/AddressBook.h>

@implementation AddressAutofill

- (void)locationPermision
{
    if(locationManager == nil)
    {
        locationManager = [[CLLocationManager alloc]init];
        locationManager.delegate = self;
        [locationManager requestAlwaysAuthorization];
    }
}

- (void)start
{
    geocoder = [[CLGeocoder alloc] init];
    if (locationManager == nil){
        locationManager = [[CLLocationManager alloc]init];
        locationManager.delegate = self;
        [locationManager requestAlwaysAuthorization];
    }
    [locationManager startUpdatingLocation];
    
    //Block address
    [geocoder reverseGeocodeLocation: locationManager.location completionHandler:
     ^(NSArray *placemarks, NSError *error) {
         if (error==nil) {
             //Get address
             CLPlacemark *placemark = [placemarks objectAtIndex:0];
             if (SIMI_DEBUG_ENABLE) {
                 NSLog(@"Placemark array: %@",placemark.addressDictionary );
                 NSLog(@"zip key test %@",[placemark.addressDictionary objectForKey:(NSString*) kABPersonAddressCityKey]);
                 NSLog(@"zip key test %@",[placemark.addressDictionary objectForKey:(NSString *)kABPersonAddressZIPKey]);
                 //String to address
                 NSString *locatedaddress = [[placemark.addressDictionary valueForKey:@"FormattedAddressLines"] componentsJoinedByString:@", "];
             
                 //Print the location in the console
                 NSLog(@"Currently address is: %@",locatedaddress);
             }
             [self.delegate autofillUpdateAddressTable:placemark];
         } else {
             CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
             
             // If the status is denied or only granted for when in use, display an alert
             if (status == kCLAuthorizationStatusAuthorizedWhenInUse || status == kCLAuthorizationStatusDenied) {
                 NSString *title;
                 title = (status == kCLAuthorizationStatusDenied) ? @"Location services are off" : @"Background location is not enabled";
                 NSString *message = @"To use your current location, you must turn to \"Always\" in Location settings";
                 
                 UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                                     message:message
                                                                    delegate:self
                                                           cancelButtonTitle:@"Cancel"
                                                           otherButtonTitles:@"Settings", nil];
                 [alertView show];
             }
             // The user has not enabled any location services. Request background authorization.
             else if (status == kCLAuthorizationStatusNotDetermined) {
                 [locationManager requestAlwaysAuthorization];
             }
             [self.delegate autofillUpdateAddressTable:nil];
             /*{
             if(error.code == 8)
             {
                 UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:SCLocalizedString(@"Notify") message:SCLocalizedString(@"Let's allow this application to use your location data in device setting.") delegate:nil cancelButtonTitle:SCLocalizedString(@"OK") otherButtonTitles:nil];
                 [alertView show];
             }
             [self.delegate autofillUpdateAddressTable:nil];
             }*/
         }
     }];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        // Send the user to the Settings for this app
        NSURL *settingsURL = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        [[UIApplication sharedApplication] openURL:settingsURL];
    }
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    NSLog(@"updated location");
    if(locationManager!=nil &&  [locations count] > 0 && ![locationManager.location isEqual:[locations objectAtIndex:0]])
    {
        NSLog(@"updated address");
        //Block address
        [geocoder reverseGeocodeLocation: locationManager.location completionHandler:
         ^(NSArray *placemarks, NSError *error) {
             
             //Get address
             CLPlacemark *placemark = [placemarks objectAtIndex:0];
             
             NSLog(@"Placemark array: %@",placemark.addressDictionary );
             
             //String to address
             NSString *locatedaddress = [[placemark.addressDictionary valueForKey:@"FormattedAddressLines"] componentsJoinedByString:@", "];
             
             //Print the location in the console
             NSLog(@"Currently address is: %@",locatedaddress);
             [locationManager stopUpdatingLocation];
             [self.delegate autofillUpdateAddressTable:placemark];
         }];
    }
}

@end
