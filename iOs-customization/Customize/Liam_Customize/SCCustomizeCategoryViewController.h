//
//  SCCustomizeCategoryViewController.h
//  SimiCartPluginFW
//
//  Created by Liam on 3/5/18.
//  Copyright © 2018 Trueplus. All rights reserved.
//

#import <SimiCartBundle/SCCategoryViewController.h>

@interface SCCustomizeCategoryViewController : SCCategoryViewController<UISearchBarDelegate>
@property (strong, nonatomic) UISearchBar *searchBarHome;
@property (strong, nonatomic) NSString *keySearch;
@property (strong, nonatomic) UIImageView *imageFog;
@property (strong, nonatomic) UIView *searchBarBackground;
@end
