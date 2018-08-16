//
//  SCMyFavouriteHistoryViewController.h
//  SimiCartPluginFW
//
//  Created by Hoang Van Trung on 10/27/17.
//  Copyright © 2017 Trueplus. All rights reserved.
//

#import <SimiCartBundle/SimiCartBundle.h>
#import "SCMyFavouriteModel.h"
@protocol SCFavouriteHistoryDelegate
- (void)updateItem;
@end

@interface SCMyFavouriteHistoryViewController : SimiViewController<UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) NSString *listId;
@property (weak, nonatomic) id<SCFavouriteHistoryDelegate> delegate;
@end

