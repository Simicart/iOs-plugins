//
//  SCPCategoryModel.m
//  SimiCartPluginFW
//
//  Created by Hoang Van Trung on 4/24/18.
//  Copyright © 2018 Trueplus. All rights reserved.
//

#import "SCPCategoryModel.h"

@implementation SCPCategoryModel
- (void)parseData{
    if([self.modelData objectForKey:@"width"]){
        self.width = [[self.modelData objectForKey:@"width"] floatValue];
    }
    if([self.modelData objectForKey:@"height"]){
        self.height = [[self.modelData objectForKey:@"height"] floatValue];
    }
    if([self.modelData objectForKey:@"width_tablet"]){
        self.widthTablet = [[self.modelData objectForKey:@"width_tablet"] floatValue];
    }
    if([self.modelData objectForKey:@"height_tablet"]){
        self.heightTablet = [[self.modelData objectForKey:@"height_tablet"] floatValue];
    }
    if([[self.modelData objectForKey:@"children"] isKindOfClass:[NSArray class]]){
        self.subCategories = [self.modelData objectForKey:@"children"];
    }
    if([self.modelData objectForKey:@"image_url"]){
        self.imageURL = [self.modelData objectForKey:@"image_url"];
    }
    if([self.modelData objectForKey:@"image_url_tablet"]){
        self.imageURLPad = [self.modelData objectForKey:@"image_url_pad"];
    }
}
@end
