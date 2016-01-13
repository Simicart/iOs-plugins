//
//  SCMenuSort_Theme01.h
//  SimiCartPluginFW
//
//  Created by SimiCommerce on 4/29/14.
//  Copyright (c) 2014 SimiTeam. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SCMenuSort_Theme01_Delegate <NSObject>
@required
-(void)selectedMenuSort:(ProductCollectionSortType)categoryId rowSelect:(int)rowSelect;
@end

@interface SCMenuSort_Theme01 : UITableViewController

@property (nonatomic, weak) id<SCMenuSort_Theme01_Delegate> delegate;
@property (nonatomic) int rowSelect;

@end
