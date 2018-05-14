//
//  SCPHomeCategoryModel.h
//  SimiCartPluginFW
//
//  Created by Hoang Van Trung on 4/19/18.
//  Copyright © 2018 Trueplus. All rights reserved.
//

#import <SimiCartBundle/SimiCartBundle.h>

typedef enum : NSUInteger {
    HomeCategoryLevelOne,
    HomeCategoryLevelTwo,
    HomeCategoryLevelThree,
} SCPHomeCategoryLevel;

@interface SCPHomeCategoryModel : SimiModel
@property (strong,nonatomic) NSString *categoryId;
@property (strong, nonatomic) NSString *imageURL,*imageURLPad;
@property (nonatomic) BOOL hasChildren;
@property (strong, nonatomic) NSString *name;
@property (nonatomic) float width, height, widthTablet, heightTablet;
@property (nonatomic) BOOL isSelected;
@property (nonatomic) SCPHomeCategoryLevel level;
@property (nonatomic) NSMutableArray<SCPHomeCategoryModel *> *subCategories;
@property (nonatomic, strong) SCPHomeCategoryModel *parentCategory;
@end
