//
//  SCMyCreditDetailViewController.h
//  SimiCartPluginFW
//
//  Created by Liam on 8/11/17.
//  Copyright © 2017 Trueplus. All rights reserved.
//

#import "SimiGiftCardCreditModel.h"
#import "SimiTable.h"
#import "SimiTextField.h"

static NSString *mycredit_creditinfo_row = @"mycredit_creditinfo_row";
static NSString *mycredit_credithistory_row = @"mycredit_credithistory_row";

@interface SCMyCreditDetailViewController : SimiViewController<UITableViewDelegate, UITableViewDataSource>{
    UITableView *myCreditTableView;
    NSArray *myCreditHistories;
}
@property (strong, nonatomic) SimiGiftCardCreditModel *giftCardCreditModel;
@property (strong, nonatomic) SimiTable *cells;
@end


@interface MyCreditHistoryTableViewCell: UITableViewCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier info:(NSDictionary*)info;
@end
