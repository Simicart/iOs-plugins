//
//  LoyaltyPluginInitial.m
//  SimiCartPluginFW
//
//  Created by Nguyen Dac Doan on 12/31/14.
//  Copyright (c) 2014 Magestore. All rights reserved.
//

#import "LoyaltyPluginInitial.h"

#import <SimiCartBundle/SCProductViewController.h>
#import <SimiCartBundle/SCCartViewController.h>
#import <SimiCartBundle/SCAccountViewController.h>
#import <SimiCartBundle/SimiSection.h>
#import <SimiCartBundle/SimiGlobalVar.h>
#import <SimiCartBundle/SimiTable.h>
#import <SimiCartBundle/SCOrderFeeCell.h>
#import <SimiCartBundle/SimiFormatter.h>

#import <SimiCartBundle/SCProductViewControllerPad.h>
#import "LoyaltyViewController.h"
#import "SimiOrderModel+Loyalty.h"

#import <SimiCartBundle/SCOrderViewControllerPad.h>
#import <SimiCartBundle/SCLeftMenuViewController.h>
#import <SimiCartBundle/SCProductInfoView.h>


static NSString *ACCOUNT_REWARDS_ROW     = @"account_rewards";
static NSString *LEFTMENU_REWARDS_ROW     = @"leftmenu_rewards";


@implementation LoyaltyPluginInitial{
    NSDictionary *loyaltyData;
    SimiGlobalVar *globalVar;
}

- (instancetype)init
{
    if (self = [super init]) {
        globalVar = [SimiGlobalVar sharedInstance];
        // Show Label on Shopping Cart
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(initCartCells:) name:[NSString stringWithFormat:@"%@%@",SCCartViewController_RootEventName, SimiTableViewController_SubKey_InitCells_Begin] object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(initializedCartCell:) name:[NSString stringWithFormat:@"%@%@",SCCartViewController_RootEventName, SimiTableViewController_SubKey_InitializedCell_End] object:nil];
        
        //My Account Screen
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(initializedAccountCellAfter:) name:[NSString stringWithFormat:@"%@%@",SCAccountViewController_RootEventName,SimiTableViewController_SubKey_InitCells_End] object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSelectAccountCellAtIndexPath:) name:[NSString stringWithFormat:@"%@%@",SCAccountViewController_RootEventName,SimiTableViewController_SubKey_DidSelectCell] object:nil];
        
        //Left Menu
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(listMenuInitCellsAfter:) name:[NSString stringWithFormat:@"%@%@",SCLeftMenuViewController_RootEventName,SimiTableViewController_SubKey_InitCells_End] object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(listMenuDidSelectRow:) name:[NSString stringWithFormat:@"%@%@",SCLeftMenuViewController_RootEventName,SimiTableViewController_SubKey_DidSelectCell] object:nil];
        
        //Product Info View
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productInforViewSetInterfacecellAfter:) name:@"SCProductInforViewSetInterfacecell_After" object:nil];
        
        // Order Review
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orderViewControllerViewDidLoad:) name:@"SCOrderViewControllerViewDidLoad" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(initLoyaltyCell:) name:[NSString stringWithFormat:@"%@%@",SCOrderViewController_RootEventName,SimiTableViewController_SubKey_InitCells_End] object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(initializeOrderCellAfter:) name:[NSString stringWithFormat:@"%@%@",SCOrderViewController_RootEventName,SimiTableViewController_SubKey_InitializedCell_End] object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSpendPointsOrder:) name:Loyalty_DidSpendPointsOrder object:nil];
    }
    return self;
}

#pragma mark Loyalty on Cart
- (void)initCartCells:(NSNotification *)noti{
    SimiQuoteItemModelCollection *cart = [globalVar cart];
    loyaltyData = [cart.data valueForKey:@"loyalty"];
    if (cart.count && loyaltyData.count > 0) {
        // Add Row to show Loyalty Labels
        SimiTable *cartCells = noti.object;
        SimiSection *loyaltySection = [cartCells addSectionWithIdentifier:LOYALTY_CART];
        [loyaltySection addRowWithIdentifier:LOYALTY_CART height:44];
    }
}

- (void)initializedCartCell:(NSNotification *)noti{
    NSIndexPath *indexPath = [noti.userInfo valueForKey:KEYEVENT.SIMITABLEVIEWCONTROLLER.indexpath];
    SimiTable *cells = noti.object;
    SimiSection *section = [cells objectAtIndex:indexPath.section];
    SimiRow *row = [section objectAtIndex:indexPath.row];
    if ([row.identifier isEqualToString:LOYALTY_CART]) {
        SCCartViewController *cartViewController = [noti.userInfo valueForKey:KEYEVENT.SIMITABLEVIEWCONTROLLER.viewcontroller];
        UITableView *tableView = cartViewController.contentTableView;
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:LOYALTY_CART];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:LOYALTY_CART];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            UIView *loyalty = [UIView new];
            loyalty.tag = LOYALTY_TAG;
            [cell addSubview:loyalty];
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
                loyalty.frame = CGRectMake(10, 2, SCREEN_WIDTH - 20, 40);
            } else {
                loyalty.frame = CGRectMake(10, 2, 380, 40);
            }
            
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 11, 18, 18)];
            imageView.tag = 3821;
            [loyalty addSubview:imageView];
            
            UILabel *label = [UILabel new];
            label.font = [UIFont fontWithName:THEME_FONT_NAME size:THEME_FONT_SIZE];
            label.numberOfLines = 2;
            label.adjustsFontSizeToFitWidth = YES;
            label.minimumScaleFactor = 0.7f;
            label.tag = 3822;
            [loyalty addSubview:label];
        }
        SimiQuoteItemModelCollection *cart = [globalVar cart];
        
        UIView *loyalty = [cell viewWithTag:LOYALTY_TAG];
        UIImageView *imageView = (UIImageView *)[loyalty viewWithTag:3821];
        UILabel *label = (UILabel *)[loyalty viewWithTag:3822];
        
        loyaltyData = [cart.data valueForKey:@"loyalty"];
        [imageView sd_setImageWithURL:[NSURL URLWithString:[loyaltyData objectForKey:@"loyalty_image"]] placeholderImage:nil options:SDWebImageRetryFailed];
        label.text = [loyaltyData objectForKey:@"loyalty_label"];
        
        // Center label and image
        CGFloat textWidth = [label textRectForBounds:CGRectMake(24, 0, loyalty.frame.size.width - 24, 40) limitedToNumberOfLines:2].size.width;
        imageView.frame = CGRectMake((loyalty.frame.size.width - textWidth - 24) / 2, 11, 18, 18);
        label.frame = CGRectMake(imageView.frame.origin.x + 24, 0, textWidth, 40);
        
        cartViewController.isDiscontinue = YES;
        row.tableCell = cell;
    }
}

#pragma mark Loyalty on Order
- (void)orderViewControllerViewDidLoad:(NSNotification *)noti{
    self.orderViewController = noti.object;
}

- (void)didSpendPointsOrder:(NSNotification*)noti{
    [self.orderViewController didGetOrderConfig:noti];
}

- (void)initLoyaltyCell:(NSNotification *)noti{
    if (self.orderViewController) {
        SimiOrderModel *order = [self.orderViewController order];
        SimiTable *orderTable = self.orderViewController.cells;
        if (PADDEVICE) {
            orderTable = self.orderViewController.cells;
        }
        NSArray *rules = [[order.modelData valueForKey:@"loyalty"] objectForKey:@"loyalty_rules"];
        if ([rules count]) {
            NSDictionary *rule = [rules objectAtIndex:0];
            if ([orderTable getSectionIndexByIdentifier:LOYALTY_CHECKOUT] == NSNotFound) {
                NSUInteger index = [orderTable getSectionIndexByIdentifier:ORDER_TOTALS_SECTION];
                if (index != NSNotFound) {
                    SimiSection *section = [orderTable addSectionWithIdentifier:LOYALTY_CHECKOUT atIndex:index];
                    section.headerTitle = SCLocalizedString(@"Spend my Points");
                    CGFloat height = [[rule objectForKey:@"optionType"] isEqualToString:@"slider"] ? 105 : 40;
                    if (![globalVar isLogin]) height = 40;
                    [section addRowWithIdentifier:LOYALTY_CHECKOUT height:height];
                }
            }
        }
        SimiRow *totalRow;
        for (SimiRow * row in [orderTable getSectionByIdentifier:ORDER_TOTALS_SECTION].rows) {
            if (row.identifier == ORDER_VIEW_TOTAL) {
                totalRow = row;
                break;
            }
        }
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            [self.orderViewController.contentTableView reloadData];
        }
    }
}

- (void)initializeOrderCellAfter:(NSNotification *)noti
{
    NSIndexPath *indexPath = [noti.userInfo valueForKey:KEYEVENT.SIMITABLEVIEWCONTROLLER.indexpath];
    SimiTable *cells = noti.object;
    SimiSection *section = [cells objectAtIndex:indexPath.section];
    SimiRow *row = [section objectAtIndex:indexPath.row];
    SCOrderViewController *orderViewController = [noti.userInfo valueForKey:KEYEVENT.SIMITABLEVIEWCONTROLLER.viewcontroller];
    if ([row.identifier isEqualToString:LOYALTY_CHECKOUT]) {
        UITableViewCell *cell = [noti.userInfo objectForKey:KEYEVENT.SIMITABLEVIEWCONTROLLER.cell];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        if (![globalVar isLogin]) {
            cell.textLabel.font = [UIFont fontWithName:THEME_FONT_NAME size:THEME_FONT_SIZE];
            cell.textLabel.numberOfLines = 2;
            cell.textLabel.text = SCLocalizedString(@"Please login before using points to spend");
            return;
        }
        SimiOrderModel *order = [self.orderViewController order];
        NSArray *rules = [[order.modelData valueForKey:@"loyalty"] objectForKey:@"loyalty_rules"];
        if ([rules count]) {
            NSDictionary *rule = [rules objectAtIndex:0];
            if ([[rule objectForKey:@"optionType"] isEqualToString:@"slider"]) {
                // Slider
                UITableView *tableView = orderViewController.contentTableView;
                CGFloat width = tableView.frame.size.width - 30;
                UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 11, width, 22)];
                label.font = [UIFont fontWithName:THEME_FONT_NAME size:THEME_FONT_SIZE];
                label.adjustsFontSizeToFitWidth = YES;
                label.minimumScaleFactor = 0.7;
                label.text = [NSString stringWithFormat:SCLocalizedString(@"Each of %@ gets %@ discount"), [rule objectForKey:@"pointStepLabel"], [rule objectForKey:@"pointStepDiscount"]];
                [cell addSubview:label];
                
                UISlider *slider = [[UISlider alloc] initWithFrame:CGRectMake(15, 44, width, 28)];
                slider.minimumValue = [[rule objectForKey:@"minPoints"] floatValue];
                slider.maximumValue = [[rule objectForKey:@"maxPoints"] floatValue];
                if ([[order.modelData valueForKey:@"loyalty"] objectForKey:@"loyalty_spend"]) {
                    slider.value = [[[order.modelData valueForKey:@"loyalty"] objectForKey:@"loyalty_spend"] floatValue];
                }else
                    slider.value = 0;
                [slider addTarget:self action:@selector(changeSpendingPoints:) forControlEvents:UIControlEventValueChanged];
                [slider addTarget:self action:@selector(stopSpendingPointsSlide:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside];
                [cell addSubview:slider];
                
                UILabel *points = [label clone];
                points.font = [UIFont fontWithName:THEME_FONT_NAME size:THEME_FONT_SIZE];
                points.textAlignment = NSTextAlignmentCenter;
                points.frame = CGRectMake(15, 72, width, 22);
                if ([[order.modelData valueForKey:@"loyalty"] objectForKey:@"loyalty_spend"]) {
                    points.text = [[SCLocalizedString(@"Spending") stringByAppendingString:@": "] stringByAppendingString:[[[order.modelData valueForKey:@"loyalty"] objectForKey:@"loyalty_spend"] stringValue]];
                }
                [cell addSubview:points];
                slider.simiObjectIdentifier = points;
                points.simiObjectIdentifier = [rule objectForKey:@"pointStep"];
                
                UILabel *minLabel = [label clone];
                minLabel.frame = CGRectMake(20, 72, 70, 22);
                minLabel.text = [[rule objectForKey:@"minPoints"] stringValue];
                minLabel.textColor = [UIColor grayColor];
                [cell addSubview:minLabel];
                
                UILabel *maxLabel = [label clone];
                maxLabel.frame = CGRectMake(width - 60, 72, 70, 22);
                maxLabel.textAlignment = NSTextAlignmentRight;
                maxLabel.text = [[rule objectForKey:@"maxPoints"] stringValue];
                maxLabel.textColor = [UIColor grayColor];
                [cell addSubview:maxLabel];
            } else {
                // Need Points
                cell.textLabel.font = [UIFont fontWithName:THEME_FONT_NAME size:THEME_FONT_SIZE];
                cell.textLabel.numberOfLines = 2;
                cell.textLabel.text = [NSString stringWithFormat:SCLocalizedString(@"You need to earn more %@ to use this rule"), [rule objectForKey:@"needPointLabel"]];
            }
        }
        self.orderViewController.isDiscontinue = YES;
        row.tableCell = cell;
    }
}

- (void)changeSpendingPoints:(UISlider *)slider
{
    UILabel *points = (UILabel *)slider.simiObjectIdentifier;
    NSInteger pointStep = [(NSNumber *)points.simiObjectIdentifier integerValue];
    NSInteger pointValue = (NSInteger)roundf(slider.value / pointStep);
    pointValue *= pointStep;
    points.text = [[SCLocalizedString(@"Spending") stringByAppendingString:@": "] stringByAppendingString:[NSString stringWithFormat:@"%ld", (long)pointValue]];
}

- (void)stopSpendingPointsSlide:(UISlider *)slider
{
    UILabel *points = (UILabel *)slider.simiObjectIdentifier;
    NSInteger pointStep = [(NSNumber *)points.simiObjectIdentifier integerValue];
    NSInteger pointValue = (NSInteger)roundf(slider.value / pointStep);
    pointValue *= pointStep;
    slider.value = (float)pointValue;
    
    SimiOrderModel *order = [self.orderViewController order];
    if ([[[order.modelData valueForKey:@"loyalty"] objectForKey:@"loyalty_spend"] integerValue] == pointValue) {
        return;
    }
    NSDictionary *rule = [[[order.modelData valueForKey:@"loyalty"] objectForKey:@"loyalty_rules"] objectAtIndex:0];
    
    [[NSNotificationCenter defaultCenter] addObserver:self.orderViewController selector:@selector(didReceiveNotification:) name:Loyalty_DidSpendPointsOrder object:order];
    [order spendPoints:pointValue ruleId:[rule objectForKey:@"id"]];
    [self.orderViewController startLoadingData];
}

- (NSString *)rewardMenuLabel
{
    SimiCustomerModel *customer = [globalVar customer];
    if ([globalVar isLogin] && customer && [customer.modelData objectForKey:@"loyalty_balance"]) {
        return [[SCLocalizedString(@"My Rewards") stringByAppendingString:@" "] stringByAppendingString:[customer objectForKey:@"loyalty_balance"]];
    }
    return SCLocalizedString(@"My Rewards");
}

#pragma mark Add to My Account Screen
- (void)initializedAccountCellAfter:(NSNotification *)noti{
    SimiTable *cells = noti.object;
    for (SimiSection *section in cells) {
        if (section.identifier != ACCOUNT_MAIN_SECTION)
            return;
        if ([section isKindOfClass:[SimiSection class]]) {
            float rowHeight;
            for (SimiRow *row in section.rows) {
                rowHeight = row.height;
                if (row.identifier == ACCOUNT_REWARDS_ROW)
                    return;
            }
            SimiRow *loyaltyRow = [[SimiRow alloc]initWithIdentifier:ACCOUNT_REWARDS_ROW height:rowHeight sortOrder:310];
            loyaltyRow.title = SCLocalizedString(@"My Rewards");
            loyaltyRow.image = [UIImage imageNamed:@"loyalty_reward"];
            loyaltyRow.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            [section addRow:loyaltyRow];
            [section sortItems];
        }
    }
}

- (void)didSelectAccountCellAtIndexPath:(NSNotification *)noti{
    NSIndexPath *indexPath = [noti.userInfo valueForKey:KEYEVENT.SIMITABLEVIEWCONTROLLER.indexpath];
    SimiTable *cells = noti.object;
    SimiSection *section = [cells objectAtIndex:indexPath.section];
    SimiRow *row = [section objectAtIndex:indexPath.row];
    if ([row.identifier isEqualToString:ACCOUNT_REWARDS_ROW]) {
        SCAccountViewController *accountVC = [noti.userInfo objectForKey:KEYEVENT.SIMITABLEVIEWCONTROLLER.viewcontroller];
        LoyaltyViewController *loyalty = [LoyaltyViewController new];
        [accountVC.navigationController pushViewController:loyalty animated:YES];
        accountVC.isDiscontinue = YES;
    }
}

#pragma mark Add to Left Menu
- (void)listMenuInitCellsAfter:(NSNotification *)noti
{
    SimiTable *cells = noti.object;
    if ([globalVar isLogin]) {
        for (SimiSection *section in cells) {
            if ([section isKindOfClass:[SimiSection class]]) {
                if (section.identifier != LEFTMENU_SECTION_MAIN)
                    return;
                float rowHeight = 50;
                for (SimiRow *row in section.rows) {
                    rowHeight = row.height;
                    if (row.identifier == LEFTMENU_REWARDS_ROW)
                        return;
                }
                
                SimiRow *rewardsRow = [[SimiRow alloc]initWithIdentifier:LEFTMENU_REWARDS_ROW height:rowHeight sortOrder:310];
                rewardsRow.title = SCLocalizedString(@"My Rewards");
                rewardsRow.image = [UIImage imageNamed:@"loyalty_reward_invert"];
                [section addRow:rewardsRow];
                
                [section sortItems];
            }
        }
    }
}

- (void)listMenuDidSelectRow:(NSNotification *)noti{
    SimiTable *cells = noti.object;
    NSIndexPath *indexPath = [noti.userInfo valueForKey:KEYEVENT.SIMITABLEVIEWCONTROLLER.indexpath];
    SimiSection *section = [cells objectAtIndex:indexPath.section];
    SimiRow *row = [section objectAtIndex:indexPath.row];
    if ([row.identifier isEqualToString:LEFTMENU_REWARDS_ROW]) {
        LoyaltyViewController *loyalty = [LoyaltyViewController new];
        UINavigationController *currentVC = kNavigationController;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            UINavigationController *navi = [[UINavigationController alloc]initWithRootViewController:loyalty];
            navi.modalPresentationStyle = UIModalPresentationPopover;
            UIPopoverPresentationController *popover = navi.popoverPresentationController;
            popover.sourceRect = CGRectMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2, 1, 1);
            popover.sourceView = currentVC.view;
            popover.permittedArrowDirections = 0;
            [currentVC presentViewController:navi animated:YES completion:nil];
        }
        else
            [currentVC pushViewController:loyalty animated:YES];
    }
}

#pragma mark Loytalty on Product
- (void)productInforViewSetInterfacecellAfter:(NSNotification *)noti
{
    SCProductInfoView *productInfoView = noti.object;
    UIView *loyalty = [productInfoView viewWithTag:LOYALTY_TAG];
    if (loyalty == nil) {
        loyalty = [[UIView alloc] initWithFrame:CGRectMake(productInfoView.productNameLabel.frame.origin.x , productInfoView.heightCell+10, productInfoView.productNameLabel.frame.size.width, 44)];
        loyalty.tag = LOYALTY_TAG;
        [productInfoView addSubview:loyalty];
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 13, 18, 18)];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        [imageView sd_setImageWithURL:[NSURL URLWithString:[productInfoView.product objectForKey:@"loyalty_image"]] placeholderImage:nil options:SDWebImageRetryFailed];
        [loyalty addSubview:imageView];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(24, 0, loyalty.frame.size.width - 24, 44)];
        label.font = [UIFont fontWithName:THEME_FONT_NAME size:THEME_FONT_SIZE_REGULAR];
        label.text = [productInfoView.product objectForKey:@"loyalty_label"];
        label.numberOfLines = 2;
        [loyalty addSubview:label];
    }
}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
