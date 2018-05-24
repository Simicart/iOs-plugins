//
//  SCPHomeCategoryModel.m
//  SimiCartPluginFW
//
//  Created by Hoang Van Trung on 4/19/18.
//  Copyright © 2018 Trueplus. All rights reserved.
//

#import "SCPHomeCategoryModel.h"

@implementation SCPHomeCategoryModel
- (void)parseData{
    [super parseData];
    self.entityId = [NSString stringWithFormat:@"%@",[self.modelData objectForKey:@"category_id"]?[self.modelData objectForKey:@"category_id"]:[self.modelData objectForKey:@"entity_id"]];
    self.name = [NSString stringWithFormat:@"%@",[self.modelData objectForKey:@"cat_name"]?[self.modelData objectForKey:@"cat_name"]:[self.modelData objectForKey:@"name"]];
    if([self.modelData objectForKey:@"simicategory_filename"]){
        self.imageURL = [NSString stringWithFormat:@"%@",[self.modelData objectForKey:@"simicategory_filename"]];
    }
    if([self.modelData objectForKey:@"simicategory_filename_tablet"]){
        self.imageURLPad = [NSString stringWithFormat:@"%@",[self.modelData objectForKey:@"simicategory_filename_tablet"]];
    }
    self.hasChildren = [[self.modelData objectForKey:@"has_children"] boolValue];
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
        NSArray *children = [self.modelData objectForKey:@"children"];
        if(children.count > 0){
            self.subCategories = [NSMutableArray new];
            for(NSDictionary *category in children){
                [self.subCategories addObject:[[SCPHomeCategoryModel alloc] initWithModelData:category]];
            }
        }
    }
}
@end
