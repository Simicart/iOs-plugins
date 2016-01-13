//
//  SCMenuTableView.h
//  SimiCartPluginFW
//
//  Created by SimiCommerce on 4/24/14.
//  Copyright (c) 2014 SimiTeam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SimiCartBundle/SimiCategoryModelCollection.h>
#import <SimiCartBundle/SimiCategoryModel.h>
#import <SimiCartBundle/SimiMutableArray.h>
#import <SimiCartBundle/NSObject+SimiObject.h>
#import "SCDefineSimiCart_Pad.h"
#import <SimiCartBundle/UIScrollView+SVInfiniteScrolling.h>

#import "SimiGlobalVar+Theme01.h"

@protocol SCMenuCategory_Theme01Delegate <NSObject>
@required
-(void)selectedIDMenu:(NSString*)categoryId;
@end


@interface SCMenuCategory_Theme01 : UITableViewController{
    BOOL isHasChild;
    NSIndexPath *indexSelect;
    UIActivityIndicatorView *activity;
}

@property (strong, nonatomic) NSString *categoryId;
@property (nonatomic) NSInteger indexPathRow;
@property (nonatomic, weak) id<SCMenuCategory_Theme01Delegate> delegate;
@property (strong, nonatomic) SimiCategoryModelCollection *categoryCollection;
@property (strong, nonatomic) SimiCategoryModelCollection *categoryCollection1;
@property (nonatomic) BOOL isFinishLoad;

- (void)getCategories;
- (void)didGetCategories:(NSNotification *)noti;

@end
