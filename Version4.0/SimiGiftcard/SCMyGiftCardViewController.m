//
//  SCMyGiftCardViewController.m
//  SimiCartPluginFW
//
//  Created by Liam on 8/11/17.
//  Copyright © 2017 Trueplus. All rights reserved.
//

#import "SCMyGiftCardViewController.h"
#import "SCMyCreditDetailViewController.h"
#import "SCAddRedeemViewController.h"
#import "SCGiftCodeDetailViewController.h"

@interface SCMyGiftCardViewController ()

@end

@implementation SCMyGiftCardViewController
- (void)viewDidLoadBefore{
    self.navigationItem.title = SCLocalizedString(@"GIFT CARD");
}

- (void)viewDidAppearBefore:(BOOL)animated{
    if (myGiftCardTableView == nil) {
        myGiftCardTableView = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStylePlain];
        myGiftCardTableView.delegate = self;
        myGiftCardTableView.dataSource = self;
        myGiftCardTableView.tableFooterView = [UIView new];
        [self.view addSubview:myGiftCardTableView];
    }
    [self getCustomerCreditInfo];
}

- (void)getCustomerCreditInfo{
    giftCardCreditModel = [SimiGiftCardCreditModel new];
    [giftCardCreditModel getCustomerCreditWithParams:@{}];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetCustomerCreditInfo:) name:DidGetCustomerCredit object:giftCardCreditModel];
    [self startLoadingData];
}

- (void)didGetCustomerCreditInfo:(NSNotification*)noti{
    [self removeObserverForNotification:noti];
    [self stopLoadingData];
    SimiResponder *responder = [noti.userInfo valueForKey:@"responder"];
    if ([responder.status isEqualToString:@"SUCCESS"]) {
        if ([[giftCardCreditModel valueForKey:@"listcode"] isKindOfClass:[NSArray class]]) {
            giftCodes = [giftCardCreditModel valueForKey:@"listcode"];
        }
        [self setCells:nil];
    }else
        [self showAlertWithTitle:responder.status message:responder.responseMessage];

}

- (void)setCells:(SimiTable *)cells{
    if (cells) {
        _cells = cells;
    }else{
        _cells = [SimiTable new];
        SimiSection *mainSection = [_cells addSectionWithIdentifier:@"main_section"];
        [mainSection addRowWithIdentifier:mygiftcard_creditinfo_row height:110];
        if (giftCodes.count > 0) {
            for (int i = 0; i < giftCodes.count; i++) {
                SimiRow *row = [mainSection addRowWithIdentifier:mygiftcard_giftcode_row height:150 sortOrder:0];
                row.data = [[NSMutableDictionary alloc]initWithDictionary:[giftCodes objectAtIndex:i]];
            }
        }
    }
    [myGiftCardTableView reloadData];
}

#pragma mark TableView Delegate&DataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    SimiSection *simiSection = [self.cells objectAtIndex:indexPath.section];
    SimiRow *row = [simiSection objectAtIndex:indexPath.row];
    UITableViewCell *cell = nil;
    if ([row.identifier isEqualToString:mygiftcard_creditinfo_row]) {
        cell = [tableView dequeueReusableCellWithIdentifier:mygiftcard_creditinfo_row];
        if (cell == nil) {
            float padding = 10;
            float cellWidth = SCREEN_WIDTH;
            float detailWidth = 100;
            float redeemWidth = SCREEN_WIDTH - padding *3 - detailWidth;
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:mygiftcard_creditinfo_row];
            myCreditLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(padding, padding, cellWidth - padding*2, 30) andFontName:THEME_FONT_NAME_REGULAR andFontSize:20 andTextColor:THEME_CONTENT_COLOR];
            [cell.contentView addSubview:myCreditLabel];
            
            SimiButton *viewDetailButton = [[SimiButton alloc]initWithFrame:CGRectMake(padding, padding*2+30, detailWidth, 40) title:@"View Detail" titleFont:[UIFont fontWithName:THEME_FONT_NAME_REGULAR size:14] cornerRadius:4 borderWidth:0 borderColor:0];
            [viewDetailButton addTarget:self action:@selector(viewCustomerCreditDetail:) forControlEvents:UIControlEventTouchUpInside];
            [cell.contentView addSubview:viewDetailButton];
            
            SimiButton *addorRedeemaGiftCard = [[SimiButton alloc]initWithFrame:CGRectMake(padding*2 + detailWidth, padding*2+30, redeemWidth, 40) title:@"Add/Redeem A Gift Card" titleFont:[UIFont fontWithName:THEME_FONT_NAME_REGULAR size:14] cornerRadius:4 borderWidth:0 borderColor:0];
            [addorRedeemaGiftCard addTarget:self action:@selector(openAddOrRedeemScreen:) forControlEvents:UIControlEventTouchUpInside];
            [cell.contentView addSubview:addorRedeemaGiftCard];
        }
        NSString *currencySymbol = @"";
        if ([giftCardCreditModel valueForKey:@"currency_symbol"] && ![[giftCardCreditModel valueForKey:@"currency_symbol"] isKindOfClass:[NSNull class]]) {
            currencySymbol = [giftCardCreditModel valueForKey:@"currency_symbol"];
        }
        NSString *balance = [NSString stringWithFormat:@"%@",[giftCardCreditModel valueForKey:@"balance"]];
        balance = [[SimiFormatter sharedInstance] priceWithPrice:balance andCurrency:currencySymbol];
        [myCreditLabel setText:[NSString stringWithFormat:@"%@: %@", SCLocalizedString(@"My credit balance"), balance]];
    }else if ([row.identifier isEqualToString:mygiftcard_giftcode_row]){
        NSString *identifer = [NSString stringWithFormat:@"%@_%@",mygiftcard_giftcode_row,[row.data valueForKey:@"giftvoucher_id"]];
        GiftCodeDetailTableViewCell *aCell = [tableView dequeueReusableCellWithIdentifier:identifer];
        if (aCell == nil) {
            aCell = [[GiftCodeDetailTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifer giftCodeInfo:row.data];
            aCell.delegate = self;
        }
        [aCell setGiftCodeInfo:row.data];
        cell = aCell;
    }
    [cell setSeparatorInset:UIEdgeInsetsZero];
    [cell setPreservesSuperviewLayoutMargins:NO];
    [cell setLayoutMargins:UIEdgeInsetsZero];
    if (cell == nil) {
        cell = [UITableViewCell new];
    }
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    SimiSection *simiSection = [self.cells objectAtIndex:section];
    return simiSection.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    SimiSection *simiSection = [self.cells objectAtIndex:indexPath.section];
    SimiRow *row = [simiSection objectAtIndex:indexPath.row];
    return row.height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    SimiSection *simiSection = [self.cells objectAtIndex:indexPath.section];
    SimiRow *row = [simiSection objectAtIndex:indexPath.row];
    if ([row.identifier isEqualToString:mygiftcard_giftcode_row]) {
        SCGiftCodeDetailViewController *giftCodeDetailViewController = [SCGiftCodeDetailViewController new];
        giftCodeDetailViewController.giftCodeId = [row.data valueForKey:@"giftvoucher_id"];
        [self.navigationController pushViewController:giftCodeDetailViewController animated:YES];
    }
}

- (void)viewCustomerCreditDetail:(UIButton*)sender{
    SCMyCreditDetailViewController *creditDetailViewController = [SCMyCreditDetailViewController new];
    creditDetailViewController.giftCardCreditModel = giftCardCreditModel;
    [self.navigationController pushViewController:creditDetailViewController animated:YES];
}

- (void)openAddOrRedeemScreen:(UIButton*)sender{
    SCAddRedeemViewController *redeemViewController = [SCAddRedeemViewController new];
    [self.navigationController pushViewController:redeemViewController animated:YES];
}
- (void)removeGiftCodeWithId:(NSString *)customerVoucherId{
    [giftCardCreditModel removeGiftCodeFromCustomerWithParams:@{@"id":customerVoucherId}];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didRemoveGiftCode:) name:DidRemoveGiftCode object:giftCardCreditModel];
    [self startLoadingData];
}

- (void)didRemoveGiftCode:(NSNotification*)noti{
    [self removeObserverForNotification:noti];
    [self stopLoadingData];
    SimiResponder *responder = [noti.userInfo valueForKey:@"responder"];
    if ([responder.status isEqualToString:@"SUCCESS"]) {
        giftCodes = @[];
        if ([[giftCardCreditModel valueForKey:@"listcode"] isKindOfClass:[NSArray class]]) {
            giftCodes = [giftCardCreditModel valueForKey:@"listcode"];
        }
        [self setCells:nil];
        NSString *message = [giftCardCreditModel valueForKey:@"message"];
        [self showToastMessage:message duration:1.5];
    }else
        [self showToastMessage:responder.responseMessage duration:1.5];
}
@end

@implementation GiftCodeDetailTableViewCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier giftCodeInfo:(NSDictionary*)info{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    self.giftCodeInfo = info;
    float labelHeight = 25;
    float height = 5;
    float padding = 10;
    float titleWidth = 120;
    float cellWidth = SCREEN_WIDTH;
    float valueWidth = cellWidth - titleWidth - padding*3 - 40;
    if(self){
        NSArray *actions = [info valueForKey:@"action"];
        if ([actions containsObject:@"Remove"]) {
            UIButton *removeButton = [[UIButton alloc]initWithFrame:CGRectMake(cellWidth - 40, 0, 40, 40)];
            [removeButton setImageEdgeInsets:UIEdgeInsetsMake(8, 16, 16, 8)];
            [removeButton setImage:[UIImage imageNamed:@"ic_delete"] forState:UIControlStateNormal];
            [removeButton addTarget:self action:@selector(removeGiftCode:) forControlEvents:UIControlEventTouchUpInside];
            [self.contentView addSubview:removeButton];
        }
        
        SimiLabel *giftCardCodeLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(padding, height, titleWidth, labelHeight) andFontName:THEME_FONT_NAME_REGULAR andFontSize:14 andTextColor:THEME_CONTENT_COLOR text:@"Gift Card Code"];
        [self.contentView addSubview:giftCardCodeLabel];
        
        SimiTextView *giftCardCodeTextView = [[SimiTextView alloc]initWithFrame:CGRectMake(titleWidth+padding*2, height, valueWidth, 40) font:[UIFont systemFontOfSize:14 weight:UIFontWeightSemibold] borderWidth:1 borderColor:[UIColor lightGrayColor] paddingLeft:10];
        giftCardCodeTextView.layer.cornerRadius = 6;
        giftCardCodeTextView.editable = NO;
        giftCardCodeTextView.text = [info valueForKey:@"gift_code"];
        [self.contentView addSubview:giftCardCodeTextView];
        height += 40;
        
        SimiLabel *balanceLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(padding, height, titleWidth, labelHeight) andFontName:THEME_FONT_NAME_REGULAR andFontSize:14 andTextColor:THEME_CONTENT_COLOR text:@"Balance"];
        [self.contentView addSubview:balanceLabel];
        
        balanceValueLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(titleWidth+padding*2, height, valueWidth, labelHeight) andFontName:THEME_FONT_NAME andFontSize:14 andTextColor:THEME_CONTENT_COLOR text:@""];
        [self.contentView addSubview:balanceValueLabel];
        height += labelHeight;
        
        SimiLabel *statusLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(padding, height, titleWidth, labelHeight) andFontName:THEME_FONT_NAME_REGULAR andFontSize:14 andTextColor:THEME_CONTENT_COLOR text:@"Status"];
        [self.contentView addSubview:statusLabel];
        
        statusValueLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(titleWidth+padding*2, height, valueWidth, labelHeight) andFontName:THEME_FONT_NAME andFontSize:14 andTextColor:THEME_CONTENT_COLOR text:@""];
        [self.contentView addSubview:statusValueLabel];
        height += labelHeight;
        
        SimiLabel *addedLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(padding, height, titleWidth, labelHeight) andFontName:THEME_FONT_NAME_REGULAR andFontSize:14 andTextColor:THEME_CONTENT_COLOR text:@"Added Date"];
        [self.contentView addSubview:addedLabel];
        
        NSString *addedValue = [info valueForKey:@"added_date"];
        SimiLabel *addedValueLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(titleWidth+padding*2, height, valueWidth, labelHeight) andFontName:THEME_FONT_NAME andFontSize:14 andTextColor:THEME_CONTENT_COLOR text:addedValue];
        [self.contentView addSubview:addedValueLabel];
        height += labelHeight;
        
        SimiLabel *expiredLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(padding, height, titleWidth, labelHeight) andFontName:THEME_FONT_NAME_REGULAR andFontSize:14 andTextColor:THEME_CONTENT_COLOR text:@"Expired Date"];
        [self.contentView addSubview:expiredLabel];
        
        NSString *expiredValue = [info valueForKey:@"expired_at"];
        SimiLabel *expiredValueLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(titleWidth+padding*2, height, valueWidth, labelHeight) andFontName:THEME_FONT_NAME andFontSize:14 andTextColor:THEME_CONTENT_COLOR text:expiredValue];
        [self.contentView addSubview:expiredValueLabel];
        height += labelHeight;
        [SimiGlobalVar sortViewForRTL:self.contentView andWidth:cellWidth];
    }
    return self;
}

- (void)removeGiftCode:(UIButton*)sender{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:[NSString stringWithFormat:@"%@?",SCLocalizedString(@"Are you sure you want to delete this gift card")] preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:SCLocalizedString(@"Cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:SCLocalizedString(@"Ok") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.delegate removeGiftCodeWithId:[self.giftCodeInfo valueForKey:@"customer_voucher_id"]];
    }]];
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertController animated:YES completion:nil];
}

- (void)setGiftCodeInfo:(NSDictionary *)giftCodeInfo{
    _giftCodeInfo = giftCodeInfo;
    NSString *statusValue = [giftCodeInfo valueForKey:@"status"];
    switch ([statusValue integerValue]) {
        case 1:
            statusValue = @"Pending";
            break;
        case 2:
            statusValue = @"Active";
            break;
        case 3:
            statusValue = @"Disabled";
            break;
        case 4:
            statusValue = @"Used";
            break;
        case 5:
            statusValue = @"Expried";
            break;
        case 6:
            statusValue = @"Deleted";
            break;
        default:
            break;
    }
    [statusValueLabel setText:statusValue];
    
    NSString *currencySymbol = @"";
    if ([giftCodeInfo valueForKey:@"currency_symbol"] && ![[giftCodeInfo valueForKey:@"currency_symbol"] isKindOfClass:[NSNull class]]) {
        currencySymbol = [giftCodeInfo valueForKey:@"currency_symbol"];
    }

    NSString *balanceValue = [[SimiFormatter sharedInstance]priceWithPrice:[giftCodeInfo valueForKey:@"balance"] andCurrency:currencySymbol];
    [balanceValueLabel setText:balanceValue];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    return NO;
}
@end
