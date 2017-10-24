//
//  SCMyGiftCardViewController.h
//  SimiCartPluginFW
//
//  Created by Liam on 8/11/17.
//  Copyright © 2017 Trueplus. All rights reserved.
//

#import <SimiCartBundle/SimiCartBundle.h>
#import <SimiCartBundle/SimiTable.h>
#import <SimiCartBundle/SimiTextView.h>
#import "SimiGiftCardCreditModel.h"
static NSString *mygiftcard_creditinfo_row = @"mygiftcard_creditinfo_row";
static NSString *mygiftcard_giftcode_row = @"mygiftcard_giftcode_row";

@protocol GiftCodeDetailCellDelegate <NSObject>
- (void)removeGiftCodeWithId:(NSString*)customerVoucherId;
@end

@interface SCMyGiftCardViewController : SimiViewController<UITableViewDelegate, UITableViewDataSource,GiftCodeDetailCellDelegate>{
    UITableView *myGiftCardTableView;
    SimiGiftCardCreditModel *giftCardCreditModel;
    NSArray *giftCodes;
    SimiLabel *myCreditLabel;
}
@property (strong, nonatomic) SimiTable *cells;
@end

@interface GiftCodeDetailTableViewCell: UITableViewCell{
    SimiLabel *balanceValueLabel;
    SimiLabel *statusValueLabel;
}
@property (nonatomic, weak) id<GiftCodeDetailCellDelegate> delegate;
@property (strong, nonatomic) NSDictionary *giftCodeInfo;
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier giftCodeInfo:(NSDictionary*)info;
@end
