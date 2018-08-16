//
//  SCMyFavouriteDetailViewController.h
//  SimiCartPluginFW
//
//  Created by Hoang Van Trung on 10/26/17.
//  Copyright © 2017 Trueplus. All rights reserved.
//

#import <SimiCartBundle/SimiCartBundle.h>

@protocol SCFavouriteDetailControllerDelegate
- (void)updateItem;
@end

@protocol SCFavouriteDetailDelegate
- (void)updateSuggestedQty:(NSString *)qty forItem:(NSDictionary *)item;
- (void)updateQty:(NSString *)qty forItem:(NSDictionary *)item;
@end
@interface SCMyFavouriteDetailViewController : SimiViewController<UITableViewDelegate, UITableViewDataSource, SCFavouriteDetailDelegate>
@property (strong, nonatomic) NSString *favouriteId;
@property (weak, nonatomic) id<SCFavouriteDetailControllerDelegate> delegate;
@end

@interface SCFavouriteDetailCell:UITableViewCell
@property (strong, nonatomic) NSDictionary* item;
@property (nonatomic) float cellWidth;
@property (weak, nonatomic) id<SCFavouriteDetailDelegate> delegate;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier cellWidth:(float)cellWidth;
@end

