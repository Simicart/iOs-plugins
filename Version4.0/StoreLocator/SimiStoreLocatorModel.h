//
//  SimiStoreLocatorModel.h
//  SimiCartPluginFW
//
//  Created by Hoang Van Trung on 10/9/17.
//  Copyright © 2017 Trueplus. All rights reserved.
//

#import <SimiCartBundle/SimiCartBundle.h>

@interface SimiStoreLocatorModel : SimiModel

@property (strong, nonatomic) NSString *simistorelocatorId;
@property (strong, nonatomic) NSString *websiteId;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *address;
@property (strong, nonatomic) NSString *city;
@property (strong, nonatomic) NSString *country;
@property (strong, nonatomic) NSString *countryName;
@property (strong, nonatomic) NSString *zipcode;
@property (strong, nonatomic) NSString *state;
@property (strong, nonatomic) NSString *link;
@property (strong, nonatomic) NSString *email;
@property (strong, nonatomic) NSString *phone;
@property (strong, nonatomic) NSString *storeDescription;
@property (strong, nonatomic) NSString *latitude;
@property (strong, nonatomic) NSString *longtitude;
@property (strong, nonatomic) NSArray *specialDays;
@property (strong, nonatomic) NSArray *holidayDays;
@property (strong, nonatomic) NSString *mondayStatus;
@property (strong, nonatomic) NSString *mondayOpen;
@property (strong, nonatomic) NSString *mondayClose;
@property (nonatomic) float distance;
@property (strong, nonatomic) NSString *tuesdayStatus;
@property (strong, nonatomic) NSString *tuesdayOpen;
@property (strong, nonatomic) NSString *tuesdayClose;
@property (strong, nonatomic) NSString *wednesdayStatus;
@property (strong, nonatomic) NSString *wednesdayOpen;
@property (strong, nonatomic) NSString *wednesdayClose;
@property (strong, nonatomic) NSString *thursdayStatus;
@property (strong, nonatomic) NSString *thursdayOpen;
@property (strong, nonatomic) NSString *thursdayClose;
@property (strong, nonatomic) NSString *fridayStatus;
@property (strong, nonatomic) NSString *fridayOpen;
@property (strong, nonatomic) NSString *fridayClose;
@property (strong, nonatomic) NSString *saturdayStatus;
@property (strong, nonatomic) NSString *saturdayOpen;
@property (strong, nonatomic) NSString *saturdayClose;
@property (strong, nonatomic) NSString *sundayStatus;
@property (strong, nonatomic) NSString *sundayOpen;
@property (strong, nonatomic) NSString *sundayClose;
@property (strong, nonatomic) NSString *image;
@property (strong, nonatomic) NSString *zoomLevel;
@end
