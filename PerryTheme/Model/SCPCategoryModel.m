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
    [super parseData];
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
        NSArray *subCates = [self.modelData objectForKey:@"children"];
        self.subCategories = [NSMutableArray new];
        for(NSDictionary *subCate in subCates){
            SCPCategoryModel *cate = [[SCPCategoryModel alloc] initWithModelData:subCate];
            [self.subCategories addObject:cate];
        }
    }
    if([self.modelData objectForKey:@"thumbnail"]){
        self.imageURL = [self.modelData objectForKey:@"thumbnail"];
    }
    if([self.modelData objectForKey:@"thumbnail"]){
        self.imageURLPad = [self.modelData objectForKey:@"thumbnail"];
    }
}
@end
