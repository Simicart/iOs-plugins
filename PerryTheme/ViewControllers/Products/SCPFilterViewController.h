//
//  SCPFilterViewController.h
//  SimiCartPluginFW
//
//  Created by Liam on 5/16/18.
//  Copyright © 2018 Trueplus. All rights reserved.
//

#import <SimiCartBundle/SCFilterViewController.h>

@protocol ActiveFilterCollectionViewCellDelegate<NSObject>
- (void)removeActivedFilterValue:(NSDictionary*)selectedFilter;
@end

@interface SCPFilterViewController : SCFilterViewController<ActiveFilterCollectionViewCellDelegate>

@end

@interface ActiveFilterCollectionViewCell:UICollectionViewCell{
    SimiLabel *selectedValueLabel;
    UIButton *deleteButton;
    NSDictionary *filterAttribute;
}
@property (strong,nonatomic) id<ActiveFilterCollectionViewCellDelegate> delegate;
- (void)updateCellData:(NSDictionary*)data;
@end

@interface SelectFilterTableViewCell:SimiTableViewCell{
    UIImageView *iconImageView;
    SimiLabel *titleLabel;
}
@property (strong, nonatomic) NSDictionary *filterValueData;
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier row:(SimiRow*)row;
- (void)updateCellStateWithRow:(SimiRow*)row;
@end
