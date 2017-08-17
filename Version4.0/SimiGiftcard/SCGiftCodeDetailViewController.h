//
//  SCGiftCodeDetailViewController.h
//  SimiCartPluginFW
//
//  Created by Liam on 8/13/17.
//  Copyright © 2017 Trueplus. All rights reserved.
//

#import "SimiGiftCodeModel.h"

static NSString *giftcode_info_row = @"giftcode_info_row";
static NSString *giftcode_history_row = @"giftcode_history_row";

@interface SCGiftCodeDetailViewController : SimiViewController<UITableViewDelegate, UITableViewDataSource>{
    SimiGiftCodeModel* giftCodeModel;
    UITableView *giftCodeDetailTableView;
    NSArray *giftCodeHistories;
    SimiButton *redeemButton;
    SimiButton *emailToFriendButton;
}
@property (strong, nonatomic) NSString *giftCodeId;
@end

@interface GiftCodeHistoryTableViewCell: UITableViewCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier info:(NSDictionary*)info;
@end
