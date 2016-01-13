//
//  ZThemeRightMenuPad.h
//  SimiCartPluginFW
//
//  Created by Cody Nguyen on 5/21/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import <SimiCartBundle/SimiCartBundle.h>
#import <SimiCartBundle/SimiView.h>
#import <SimiCartBundle/SimiCategoryModelCollection.h>

@interface ZThemeRightMenuPad : SimiView

@property (nonatomic) BOOL isShowing;
-(void)updateCategory:(SimiCategoryModelCollection *) categoryModelCollection :(NSString *)categoryId :(NSString *) categoryName;
-(void) updateCategory: (NSString *)categoryId :(NSString *)categoryName;
-(void) dismissView;

@end
