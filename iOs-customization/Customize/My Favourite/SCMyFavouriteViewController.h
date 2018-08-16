//
//  SCMyFavouriteViewController.h
//  SimiCartPluginFW
//
//  Created by Hoang Van Trung on 10/26/17.
//  Copyright © 2017 Trueplus. All rights reserved.
//

#import <SimiCartBundle/SimiCartBundle.h>
#import "SCMyFavouriteDetailViewController.h"
#import "SCMyFavouriteHistoryViewController.h"

@protocol SCFavouriteDelegate
- (void)editFavouriteWithId:(NSString *)favouriteId;
- (void)addFolderToCart:(NSString *)listId;
- (void)historyFavouriteWithId:(NSString *)favouriteId;
- (void)removeFavouriteWithId:(NSString *)favouriteId;
@end

@interface SCMyFavouriteViewController : SimiViewController<UITableViewDelegate, UITableViewDataSource, SCFavouriteDelegate,SCFavouriteDetailControllerDelegate, SCFavouriteHistoryDelegate>

@end

@interface SCMyFavouriteCell:UITableViewCell
@property (strong, nonatomic) SimiModel *favouriteModel;
@property (weak, nonatomic) id<SCFavouriteDelegate> delegate;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier cellWidth:(float)cellWidth;
@end

