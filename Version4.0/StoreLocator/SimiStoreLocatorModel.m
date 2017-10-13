//
//  SimiStoreLocatorModel.m
//  SimiCartPluginFW
//
//  Created by Hoang Van Trung on 10/9/17.
//  Copyright © 2017 Trueplus. All rights reserved.
//

#import "SimiStoreLocatorModel.h"
@implementation SimiStoreLocatorModel
- (void)parseData{
    [super parseData];
    self.simistorelocatorId = [NSString stringWithFormat:@"%@",[self.modelData objectForKey:@"simistorelocator_id"]];
    self.websiteId = [NSString stringWithFormat:@"%@",[self.modelData objectForKey:@"website_id"]];
    if([self.modelData objectForKey:@"name"] && ![[self.modelData objectForKey:@"name"] isKindOfClass:[NSNull class]]){
        self.name = [NSString stringWithFormat:@"%@",[self.modelData objectForKey:@"name"]];
    }
    if([self.modelData objectForKey:@"address"] && ![[self.modelData objectForKey:@"address"] isKindOfClass:[NSNull class]]){
        self.address = [NSString stringWithFormat:@"%@",[self.modelData objectForKey:@"address"]];
    }
    if([self.modelData objectForKey:@"city"] && ![[self.modelData objectForKey:@"city"] isKindOfClass:[NSNull class]]){
        self.city = [NSString stringWithFormat:@"%@",[self.modelData objectForKey:@"city"]];
    }
    if([self.modelData objectForKey:@"country"] && ![[self.modelData objectForKey:@"country"] isKindOfClass:[NSNull class]]){
        self.country = [NSString stringWithFormat:@"%@",[self.modelData objectForKey:@"country"]];
    }
    if([self.modelData objectForKey:@"country_name"] && ![[self.modelData objectForKey:@"country_name"] isKindOfClass:[NSNull class]]){
        self.countryName = [NSString stringWithFormat:@"%@",[self.modelData objectForKey:@"country_name"]];
    }
    if([self.modelData objectForKey:@"zipcode"] && ![[self.modelData objectForKey:@"zipcode"] isKindOfClass:[NSNull class]]){
        self.zipcode = [NSString stringWithFormat:@"%@",[self.modelData objectForKey:@"zipcode"]];
    }
    if([self.modelData objectForKey:@"state"] && ![[self.modelData objectForKey:@"state"] isKindOfClass:[NSNull class]]){
        self.state = [NSString stringWithFormat:@"%@",[self.modelData objectForKey:@"state"]];
    }
    if([self.modelData objectForKey:@"email"] && ![[self.modelData objectForKey:@"email"] isKindOfClass:[NSNull class]]){
        self.email = [NSString stringWithFormat:@"%@",[self.modelData objectForKey:@"email"]];
    }
    if([self.modelData objectForKey:@"link"] && ![[self.modelData objectForKey:@"link"] isKindOfClass:[NSNull class]]){
        self.link = [NSString stringWithFormat:@"%@",[self.modelData objectForKey:@"link"]];
    }
    if([self.modelData objectForKey:@"phone"] && ![[self.modelData objectForKey:@"phone"] isKindOfClass:[NSNull class]]){
        self.phone = [NSString stringWithFormat:@"%@",[self.modelData objectForKey:@"phone"]];
    }
    if([self.modelData objectForKey:@"description"] && ![[self.modelData objectForKey:@"description"] isKindOfClass:[NSNull class]]){
        self.storeDescription = [NSString stringWithFormat:@"%@",[self.modelData objectForKey:@"description"]];
    }
    if([self.modelData objectForKey:@"latitude"] && ![[self.modelData objectForKey:@"latitude"] isKindOfClass:[NSNull class]]){
        self.latitude = [NSString stringWithFormat:@"%@",[self.modelData objectForKey:@"latitude"]];
    }
    if([self.modelData objectForKey:@"longtitude"] && ![[self.modelData objectForKey:@"longtitude"] isKindOfClass:[NSNull class]]){
        self.longtitude = [NSString stringWithFormat:@"%@",[self.modelData objectForKey:@"longtitude"]];
    }
    if([[self.modelData objectForKey:@"special_days"] isKindOfClass:[NSArray class]]){
        self.specialDays = [self.modelData objectForKey:@"special_days"];
    }
    if([[self.modelData objectForKey:@"holiday_days"] isKindOfClass:[NSArray class]]){
        self.holidayDays = [self.modelData objectForKey:@"holiday_days"];
    }
    if ([self.modelData objectForKey:@"distance"] && ![[self.modelData objectForKey:@"distance"] isKindOfClass:[NSNull class]]) {
        self.distance = [[self.modelData objectForKey:@"distance"]floatValue];
    }
    self.mondayStatus = [NSString stringWithFormat:@"%@",[self.modelData objectForKey:@"monday_status"]];
    self.mondayOpen = [NSString stringWithFormat:@"%@",[self.modelData objectForKey:@"monday_open"]];
    self.mondayClose = [NSString stringWithFormat:@"%@",[self.modelData objectForKey:@"monday_close"]];
    self.tuesdayStatus = [NSString stringWithFormat:@"%@",[self.modelData objectForKey:@"tuesday_status"]];
    self.tuesdayOpen = [NSString stringWithFormat:@"%@",[self.modelData objectForKey:@"tuesday_open"]];
    self.tuesdayClose = [NSString stringWithFormat:@"%@",[self.modelData objectForKey:@"tuesday_close"]];
    self.wednesdayStatus = [NSString stringWithFormat:@"%@",[self.modelData objectForKey:@"wednesday_status"]];
    self.wednesdayOpen = [NSString stringWithFormat:@"%@",[self.modelData objectForKey:@"wednesday_open"]];
    self.wednesdayClose = [NSString stringWithFormat:@"%@",[self.modelData objectForKey:@"wednesday_close"]];
    self.thursdayStatus = [NSString stringWithFormat:@"%@",[self.modelData objectForKey:@"thursday_status"]];
    self.thursdayOpen = [NSString stringWithFormat:@"%@",[self.modelData objectForKey:@"thursday_open"]];
    self.thursdayClose = [NSString stringWithFormat:@"%@",[self.modelData objectForKey:@"thursday_close"]];
    self.fridayStatus = [NSString stringWithFormat:@"%@",[self.modelData objectForKey:@"friday_status"]];
    self.fridayOpen = [NSString stringWithFormat:@"%@",[self.modelData objectForKey:@"friday_open"]];
    self.fridayClose = [NSString stringWithFormat:@"%@",[self.modelData objectForKey:@"friday_close"]];
    self.saturdayStatus = [NSString stringWithFormat:@"%@",[self.modelData objectForKey:@"saturday_status"]];
    self.saturdayOpen = [NSString stringWithFormat:@"%@",[self.modelData objectForKey:@"saturday_open"]];
    self.saturdayClose = [NSString stringWithFormat:@"%@",[self.modelData objectForKey:@"saturday_close"]];
    self.sundayStatus = [NSString stringWithFormat:@"%@",[self.modelData objectForKey:@"sunday_status"]];
    self.sundayOpen = [NSString stringWithFormat:@"%@",[self.modelData objectForKey:@"sunday_open"]];
    self.sundayClose = [NSString stringWithFormat:@"%@",[self.modelData objectForKey:@"sunday_close"]];
    if([self.modelData objectForKey:@"image"]) {
        self.image = [NSString stringWithFormat:@"%@",[self.modelData objectForKey:@"image"]];
    }
}
@end
