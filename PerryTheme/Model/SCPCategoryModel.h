//
//  SCPCategoryModel.h
//  SimiCartPluginFW
//
//  Created by Hoang Van Trung on 4/24/18.
//  Copyright © 2018 Trueplus. All rights reserved.
//

#import <SimiCartBundle/SimiCartBundle.h>
#import <SimiCartBundle/SimiCategoryModel.h>

typedef enum : NSUInteger {
    CategoryLevelOne,
    CategoryLevelTwo,
    CategoryLevelThree,
} SCPCategoryLevel;

@interface SCPCategoryModel : SimiCategoryModel
@property (nonatomic) float width, height, widthTablet, heightTablet;
@property (nonatomic) SCPCategoryLevel level;
@property (strong, nonatomic) NSString *imageURL,*imageURLPad;
@property (nonatomic) BOOL isSelected;
@property (nonatomic) NSMutableArray<SCPCategoryModel *> *subCategories;
@property (nonatomic, strong) SCPCategoryModel *parentCategory;
@end
