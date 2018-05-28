//
//  SCPCategoryModelCollection.h
//  SimiCartPluginFW
//
//  Created by Hoang Van Trung on 4/24/18.
//  Copyright © 2018 Trueplus. All rights reserved.
//

#import <SimiCartBundle/SimiCartBundle.h>
#import <SimiCartBundle/SimiCategoryModelCollection.h>

@interface SCPCategoryModelCollection : SimiCategoryModelCollection
- (void)getRootCategories;
- (void)getSubCategoriesWithId:(NSString *)categoryID level:(NSString *)level;
@end
