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
#import <SimiCartBundle/SCThemeWorker.h>
#import <SimiCartBundle/SCProductInfoView.h>


static NSString *ACCOUNT_REWARDS_ROW     = @"account_rewards";
static NSString *LEFTMENU_REWARDS_ROW     = @"leftmenu_rewards";


@implementation LoyaltyPluginInitial{
    UITextField* rewardPointTextField;
    SimiOrderModel* order;
    NSDictionary* loyaltyData;
}

- (instancetype)init
{
    if (self = [super init]) {
        
        // Show Label on Shopping Cart
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"InitCartCell-Before" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"InitializedCartCell-Before" object:nil];
        
        //My Account Screen
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(initializedAccountCellAfter:) name:@"SCAccountViewController-InitCellsAfter" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSelectAccountCellAtIndexPath:) name:@"DidSelectAccountCellAtIndexPath" object:nil];
        
        //Left Menu
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(listMenuInitCellsAfter:) name:@"SCLeftMenu_InitCellsAfter" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(listMenuDidSelectRow:) name:@"SCLeftMenu_DidSelectRow" object:nil];
        
        //Product Info View
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productInforViewSetInterfacecellAfter:) name:@"SCProductInforViewSetInterfacecell_After" object:nil];
        
        // Spend Point when Checkout
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orderViewControllerViewDidLoad:) name:@"SCOrderViewControllerViewDidLoad" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"DidGetOrderConfig" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"DidSetCouponCode" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"DidSaveShippingMethod" object:nil];
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"DidSpendPointsOrder" object:nil];
        
        //Order screen init order table on iphone
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"SCOrderViewController-InitTableBefore" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"SCOrderViewController-InitTableAfter" object:nil];
        
        //Order screen init order table on ipad
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"SCOrderViewController-InitRightTableAfter" object:nil];
        
        //Order screen init cell
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(initializeOrderCellAfter:) name:@"InitializedOrderCell-After" object:nil];
        
        //Update Point balance after checkout
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"DidPlaceOrder" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"LoadedProgramOverview" object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveNotification:(NSNotification *)noti{
#pragma mark set Order Table
    if (([noti.name isEqualToString:@"DidGetOrderConfig"] || [noti.name isEqualToString:@"DidSetCouponCode"] || [noti.name isEqualToString:@"DidSaveShippingMethod"] || [noti.name isEqualToString:@"SCOrderViewController-InitTableBefore"] || [noti.name isEqualToString:@"SCOrderViewController-InitTableAfter"]||[noti.name isEqualToString:@"SCOrderViewController-InitRightTableAfter"]) && self.orderViewController) {
        order = [self.orderViewController order];
        SimiTable *orderTable = [self.orderViewController orderTable];
        if (PADDEVICE) {
            orderTable = [(SCOrderViewControllerPad *)self.orderViewController orderTableRight];
        }
        loyaltyData = [order objectForKey:@"loyalty"];
//        NSArray *rules = [[order valueForKey:@"loyalty"] objectForKey:@"loyalty_rules"];
        if ([[loyaltyData objectForKey:@"loyalty_max"] floatValue] > 0) {
//            NSDictionary *rule = [rules objectAtIndex:0];
            if ([orderTable getSectionIndexByIdentifier:LOYALTY_CHECKOUT] == NSNotFound) {
                NSUInteger index = [orderTable getSectionIndexByIdentifier:ORDER_TOTALS_SECTION];
                if (index != NSNotFound) {
                    SimiSection *section = [orderTable addSectionWithIdentifier:LOYALTY_CHECKOUT atIndex:index];
                    section.headerTitle = SCLocalizedString(@"Use Reward Points");
//                    CGFloat height = [[rule objectForKey:@"optionType"] isEqualToString:@"slider"] ? 105 : 40;
//                    if (![[SimiGlobalVar sharedInstance] isLogin]) height = 40;
                    [section addRowWithIdentifier:LOYALTY_CHECKOUT height:145];
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
            [[(SCOrderViewControllerPad *)self.orderViewController tableRight] reloadData];
        }
#pragma mark init Cart Cell
    }else if([noti.name isEqualToString:@"DidSpendPointsOrder"] ){
        [[NSNotificationCenter defaultCenter] removeObserver:self name:noti.name object:nil];
        SimiViewController *currentVC = [SimiGlobalVar sharedInstance].currentlyNavigationController.viewControllers.lastObject;
        [currentVC stopLoadingData];
        if([currentVC isKindOfClass:[SCCartViewController class]]){
            [((SCCartViewController*) currentVC) getCart];
        }else if([currentVC isKindOfClass:[SCOrderViewController class]]){
            [self.orderViewController didGetOrderConfig:noti];
        }
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            [[(SCOrderViewControllerPad *)self.orderViewController tableRight] reloadData];
        }
    }else if ([noti.name isEqualToString:@"InitCartCell-Before"]) {
        SimiCartModelCollection *cart = [[SimiGlobalVar sharedInstance] cart];
        loyaltyData = cart.loyaltyData;
        if (cart.count && [[loyaltyData objectForKey:@"loyalty_max"] floatValue] > 0) {
            // Add Row to show Loyalty Labels
            SimiTable *cartCells = (SimiTable *)noti.object;
            SimiSection *loyaltySection = [cartCells addSectionWithIdentifier:LOYALTY_CART];
            loyaltySection.sortOrder = 150;
            SimiRow* loyaltyRow = [loyaltySection getRowByIdentifier:LOYALTY_CART];
            if(!loyaltyRow){
                loyaltyRow = [[SimiRow alloc] initWithIdentifier:LOYALTY_CART height:150];
                [loyaltySection addRow:loyaltyRow];
            }
        }
    } else if ([noti.name isEqualToString:@"InitializedCartCell-Before"]) {
        SimiRow *row = [noti.userInfo objectForKey:@"row"];
        if ([row.identifier isEqualToString:LOYALTY_CART]) {
            SCCartViewController *controller = noti.object;
            controller.isDiscontinue = YES;
            
            UITableView *tableView = (UITableView *)[noti.userInfo objectForKey:@"tableView"];
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:LOYALTY_CART];
            if (cell == nil) {
                SimiCartModelCollection *cart = [[SimiGlobalVar sharedInstance] cart];
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:LOYALTY_CART];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                //        if (![[SimiGlobalVar sharedInstance] isLogin]) {
                //            cell.textLabel.font = [UIFont fontWithName:THEME_FONT_NAME size:THEME_FONT_SIZE];
                //            cell.textLabel.numberOfLines = 2;
                //            cell.textLabel.text = SCLocalizedString(@"Please login before using points to spend");
                //            return;
                //        }
                UITableView *tableView = (UITableView *)[noti.userInfo objectForKey:@"tableView"];
//                SimiOrderModel *order = [self.orderViewController order];
                loyaltyData = cart.loyaltyData;
                SimiLabel* titleLabel = [[SimiLabel alloc] initWithFrame:CGRectMake(15, 5,tableView.frame.size.width - 30 , 25)];
                titleLabel.text = [NSString stringWithFormat:@"You have %@ Reward Points available.", [loyaltyData objectForKey:@"loyalty_max"]];
                [cell addSubview:titleLabel];
                rewardPointTextField = [[UITextField alloc] initWithFrame:CGRectMake(15, 30, tableView.frame.size.width - 30, 40)];
                if([[loyaltyData objectForKey:@"loyalty_spend"] floatValue] > 0){
                    rewardPointTextField.text = [NSString stringWithFormat:@"%@",[loyaltyData objectForKey:@"loyalty_spend"]];
                }
                rewardPointTextField.placeholder = SCLocalizedString(@"Enter amount of points to spend");
                rewardPointTextField.font = [UIFont fontWithName:THEME_FONT_NAME size:THEME_FONT_SIZE];
                rewardPointTextField.keyboardType = UIKeyboardTypeNumberPad;
                [cell addSubview:rewardPointTextField];
                SimiButton* applyButton = [[SimiButton alloc] initWithFrame:CGRectMake(15, 75, (tableView.frame.size.width - 30)/2 - 5, 35)];
                [applyButton setTitle:SCLocalizedString(@"Apply Points") forState:UIControlStateNormal];
                SimiButton* cancelButton = [[SimiButton alloc] initWithFrame:CGRectMake(tableView.frame.size.width / 2 + 5, 75, (tableView.frame.size.width - 30)/2 - 5, 35)];
                [cancelButton setTitle:SCLocalizedString(@"Cancel Points") forState:UIControlStateNormal];
                [applyButton addTarget:self action:@selector(applyPoints:) forControlEvents:UIControlEventTouchUpInside];
                [cancelButton addTarget:self action:@selector(cancelPoints:) forControlEvents:UIControlEventTouchUpInside];
                [cell addSubview:cancelButton];
                [cell addSubview:applyButton];
                M13Checkbox* useMaxCheckbox = [[M13Checkbox alloc] initWithFrame:CGRectMake(15, 115, tableView.frame.size.width - 30, 25)];
                useMaxCheckbox.checkAlignment = M13CheckboxAlignmentLeft;
                useMaxCheckbox.strokeColor = THEME_BUTTON_BACKGROUND_COLOR;
                useMaxCheckbox.checkColor = THEME_BUTTON_BACKGROUND_COLOR;
                useMaxCheckbox.titleLabel.text = [NSString stringWithFormat:@"%@ %@",SCLocalizedString(@"Use maximum"),[loyaltyData objectForKey:@"loyalty_max"]];
                useMaxCheckbox.titleLabel.font = [UIFont fontWithName:THEME_FONT_NAME size:THEME_FONT_SIZE];
                [useMaxCheckbox addTarget:self action:@selector(useMaxCheckbox:) forControlEvents:UIControlEventValueChanged];
                [cell addSubview:useMaxCheckbox];
            }
            SimiCartModelCollection *cart = [[SimiGlobalVar sharedInstance] cart];
            
            UIView *loyalty = [cell viewWithTag:LOYALTY_TAG];
            UIImageView *imageView = (UIImageView *)[loyalty viewWithTag:3821];
            UILabel *label = (UILabel *)[loyalty viewWithTag:3822];
            
            [imageView sd_setImageWithURL:[NSURL URLWithString:[cart.loyaltyData objectForKey:@"loyalty_image"]] placeholderImage:nil options:SDWebImageRetryFailed];
            label.text = [cart.loyaltyData objectForKey:@"loyalty_label"];
            
            // Center label and image
            CGFloat textWidth = [label textRectForBounds:CGRectMake(24, 0, loyalty.frame.size.width - 24, 40) limitedToNumberOfLines:2].size.width;
            imageView.frame = CGRectMake((loyalty.frame.size.width - textWidth - 24) / 2, 11, 18, 18);
            label.frame = CGRectMake(imageView.frame.origin.x + 24, 0, textWidth, 40);
            
            controller.simiObjectIdentifier = cell;
        }
#pragma mark Did Place Order
    } else if ([noti.name isEqualToString:@"DidPlaceOrder"]) {
        if ([noti.object objectForKey:@"loyalty_balance"]) {
            SimiCustomerModel *customer = [[SimiGlobalVar sharedInstance] customer];
            if ([[SimiGlobalVar sharedInstance] isLogin] && customer) {
                [customer setValue:[noti.object objectForKey:@"loyalty_balance"] forKey:@"loyalty_balance"];
                [self.loyaltyMenuRow setTitle:[self rewardMenuLabel]];
            }
        }
#pragma mark Loaded Program OverView
    } else if ([noti.name isEqualToString:@"LoadedProgramOverview"]) {
        if ([noti.object objectForKey:@"loyalty_redeem"]) {
            SimiCustomerModel *customer = [[SimiGlobalVar sharedInstance] customer];
            if ([[SimiGlobalVar sharedInstance] isLogin] && customer) {
                [customer setValue:[noti.object objectForKey:@"loyalty_redeem"] forKey:@"loyalty_balance"];
                [self.loyaltyMenuRow setTitle:[self rewardMenuLabel]];
            }
        }
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
    
    order = [self.orderViewController order];
    if ([[[order valueForKey:@"loyalty"] objectForKey:@"loyalty_spend"] integerValue] == pointValue) {
        return;
    }
    NSDictionary *rule = [[[order valueForKey:@"loyalty"] objectForKey:@"loyalty_rules"] objectAtIndex:0];
    
    [[NSNotificationCenter defaultCenter] addObserver:self.orderViewController selector:@selector(didReceiveNotification:) name:@"DidSpendPointsOrder" object:order];
    [order spendPoints:pointValue ruleId:[rule objectForKey:@"id"]];
    [self.orderViewController startLoadingData];
}

- (NSString *)rewardMenuLabel
{
    SimiCustomerModel *customer = [[SimiGlobalVar sharedInstance] customer];
    if ([[SimiGlobalVar sharedInstance] isLogin] && customer && [customer objectForKey:@"loyalty_balance"]) {
        return [[SCLocalizedString(@"My Rewards") stringByAppendingString:@" "] stringByAppendingString:[customer objectForKey:@"loyalty_balance"]];
    }
    return SCLocalizedString(@"My Rewards");
}

#pragma mark Add to My Account Screen
-(void)initializedAccountCellAfter:(NSNotification *)noti
{
    NSArray * cells = noti.object;
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
            SimiRow *wishlistRow = [[SimiRow alloc]initWithIdentifier:ACCOUNT_REWARDS_ROW height:rowHeight sortOrder:310];
            wishlistRow.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            wishlistRow.title = SCLocalizedString(@"My Rewards");
            wishlistRow.image = [UIImage imageNamed:@"loyalty_reward"];
            [section addRow:wishlistRow];
            [section sortItems];
        }
    }
}

-(void)didSelectAccountCellAtIndexPath:(NSNotification *)noti
{
    if ([(SimiRow *)noti.object identifier] == ACCOUNT_REWARDS_ROW) {
        SCAccountViewController *accountVC = [noti.userInfo objectForKey:@"self"];
        LoyaltyViewController *loyalty = [LoyaltyViewController new];
        [accountVC.navigationController pushViewController:loyalty animated:YES];
        accountVC.isDiscontinue = YES;
    }
}

#pragma mark Add to Left Menu
-(void)listMenuInitCellsAfter:(NSNotification *)noti
{
    NSArray * cells = noti.object;
    if ([[SimiGlobalVar sharedInstance] isLogin]) {
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
                
                SimiRow *wishlistRow = [[SimiRow alloc]initWithIdentifier:LEFTMENU_REWARDS_ROW height:rowHeight sortOrder:310];
                wishlistRow.title = SCLocalizedString(@"My Rewards");
                wishlistRow.image = [UIImage imageNamed:@"loyalty_reward_invert"];
                [section addRow:wishlistRow];
                [section sortItems];
            }
        }
    }
}

-(void)listMenuDidSelectRow:(NSNotification *)noti
{
    
    if ([(SimiRow *)[noti.userInfo objectForKey:@"simirow"] identifier] == LEFTMENU_REWARDS_ROW) {
        UIViewController *currentVC = [(UITabBarController *)[[(SCAppDelegate *)[[UIApplication sharedApplication]delegate] window] rootViewController] selectedViewController];
        LoyaltyViewController *loyalty = [LoyaltyViewController new];
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
            [(UINavigationController *)currentVC pushViewController:loyalty animated:YES];
        [(SCNavigationBarPhone*)noti.object setIsDiscontinue:YES];
    }
}

#pragma mark Set Product Info View
-(void)productInforViewSetInterfacecellAfter:(NSNotification *)noti
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

#pragma mark Add to Order Screen

-(void)orderViewControllerViewDidLoad:(NSNotification *)noti
{
    self.orderViewController = noti.object;
}

- (void)initOrderRightTableAfter:(NSNotification *)noti
{
    order = [self.orderViewController order];
    NSArray *rules = [[order objectForKey:@"fee"] objectForKey:@"loyalty_rules"];
    if ([rules count]) {
        NSDictionary *rule = [rules objectAtIndex:0];
        SimiTable *orderTable = [self.orderViewController orderTable];
        SimiSection *shipment = [orderTable getSectionByIdentifier:ORDER_TOTALS_SECTION];
        shipment.headerTitle = SCLocalizedString(@"Shipment Details");
        shipment = [orderTable getSectionByIdentifier:ORDER_SHIPMENT_SECTION];
        shipment.headerTitle = SCLocalizedString(@"Shipping Method");
        if ([orderTable getSectionIndexByIdentifier:LOYALTY_CHECKOUT] == NSNotFound) {
            SimiSection *section = [orderTable addSectionWithIdentifier:LOYALTY_CHECKOUT atIndex:0];
            section.headerTitle = SCLocalizedString(@"Spend my Points");
            CGFloat height = [[rule objectForKey:@"optionType"] isEqualToString:@"slider"] ? 105 : 40;
            if (![[SimiGlobalVar sharedInstance] isLogin]) height = 40;
            [section addRowWithIdentifier:LOYALTY_CHECKOUT height:height];
        }
    }
}

- (void)initializeOrderCellAfter:(NSNotification *)noti
{
    SimiRow *row = noti.object;
    if ([row.identifier isEqualToString:LOYALTY_CHECKOUT]) {
        UITableViewCell *cell = (UITableViewCell *)[noti.userInfo objectForKey:@"cell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
//        if (![[SimiGlobalVar sharedInstance] isLogin]) {
//            cell.textLabel.font = [UIFont fontWithName:THEME_FONT_NAME size:THEME_FONT_SIZE];
//            cell.textLabel.numberOfLines = 2;
//            cell.textLabel.text = SCLocalizedString(@"Please login before using points to spend");
//            return;
//        }
        UITableView *tableView = (UITableView *)[noti.userInfo objectForKey:@"tableView"];
        order = [self.orderViewController order];
        loyaltyData = [order objectForKey:@"loyalty"];
        SimiLabel* titleLabel = [[SimiLabel alloc] initWithFrame:CGRectMake(15, 5,tableView.frame.size.width - 30 , 25)];
        titleLabel.text = [NSString stringWithFormat:@"You have %@ Reward Points available.", [loyaltyData objectForKey:@"loyalty_max"]];
        [cell addSubview:titleLabel];
        rewardPointTextField = [[UITextField alloc] initWithFrame:CGRectMake(15, 30, tableView.frame.size.width - 30, 40)];
        if([[loyaltyData objectForKey:@"loyalty_spend"] floatValue] > 0){
            rewardPointTextField.text = [NSString stringWithFormat:@"%@",[loyaltyData objectForKey:@"loyalty_spend"]];
        }
        rewardPointTextField.placeholder = SCLocalizedString(@"Enter amount of points to spend");
        rewardPointTextField.font = [UIFont fontWithName:THEME_FONT_NAME size:THEME_FONT_SIZE];
        rewardPointTextField.keyboardType = UIKeyboardTypeNumberPad;
        [cell addSubview:rewardPointTextField];
        SimiButton* applyButton = [[SimiButton alloc] initWithFrame:CGRectMake(15, 75, (tableView.frame.size.width - 30)/2 - 5, 35)];
        [applyButton setTitle:SCLocalizedString(@"Apply Points") forState:UIControlStateNormal];
        SimiButton* cancelButton = [[SimiButton alloc] initWithFrame:CGRectMake(tableView.frame.size.width / 2 + 5, 75, (tableView.frame.size.width - 30)/2 - 5, 35)];
        [cancelButton setTitle:SCLocalizedString(@"Cancel Points") forState:UIControlStateNormal];
        [applyButton addTarget:self action:@selector(applyPoints:) forControlEvents:UIControlEventTouchUpInside];
        [cancelButton addTarget:self action:@selector(cancelPoints:) forControlEvents:UIControlEventTouchUpInside];
        [cell addSubview:cancelButton];
        [cell addSubview:applyButton];
        M13Checkbox* useMaxCheckbox = [[M13Checkbox alloc] initWithFrame:CGRectMake(15, 115, tableView.frame.size.width - 30, 25)];
        useMaxCheckbox.checkAlignment = M13CheckboxAlignmentLeft;
        useMaxCheckbox.strokeColor = THEME_BUTTON_BACKGROUND_COLOR;
        useMaxCheckbox.checkColor = THEME_BUTTON_BACKGROUND_COLOR;
        useMaxCheckbox.titleLabel.text = [NSString stringWithFormat:@"%@ %@",SCLocalizedString(@"Use maximum"),[loyaltyData objectForKey:@"loyalty_max"]];
        useMaxCheckbox.titleLabel.font = [UIFont fontWithName:THEME_FONT_NAME size:THEME_FONT_SIZE];
        [useMaxCheckbox addTarget:self action:@selector(useMaxCheckbox:) forControlEvents:UIControlEventValueChanged];
        [cell addSubview:useMaxCheckbox];
//        NSArray *rules = [[order valueForKey:@"loyalty"] objectForKey:@"loyalty_rules"];
//        if ([rules count]) {
//            NSDictionary *rule = [rules objectAtIndex:0];
//            if ([[rule objectForKey:@"optionType"] isEqualToString:@"slider"]) {
//                // Slider
//                CGFloat width = tableView.frame.size.width - 30;
//                UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 11, width, 22)];
//                label.font = [UIFont fontWithName:THEME_FONT_NAME size:THEME_FONT_SIZE];
//                label.adjustsFontSizeToFitWidth = YES;
//                label.minimumScaleFactor = 0.7;
//                label.text = [NSString stringWithFormat:SCLocalizedString(@"Each of %@ gets %@ discount"), [rule objectForKey:@"pointStepLabel"], [rule objectForKey:@"pointStepDiscount"]];
//                [cell addSubview:label];
//                
//                UISlider *slider = [[UISlider alloc] initWithFrame:CGRectMake(15, 44, width, 28)];
//                slider.minimumValue = [[rule objectForKey:@"minPoints"] floatValue];
//                slider.maximumValue = [[rule objectForKey:@"maxPoints"] floatValue];
//                if ([[order valueForKey:@"loyalty"] objectForKey:@"loyalty_spend"]) {
//                    slider.value = [[[order valueForKey:@"loyalty"] objectForKey:@"loyalty_spend"] floatValue];
//                }else
//                    slider.value = 0;
//                [slider addTarget:self action:@selector(changeSpendingPoints:) forControlEvents:UIControlEventValueChanged];
//                [slider addTarget:self action:@selector(stopSpendingPointsSlide:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside];
//                [cell addSubview:slider];
//                
//                UILabel *points = [label clone];
//                points.font = [UIFont fontWithName:THEME_FONT_NAME size:THEME_FONT_SIZE];
//                points.textAlignment = NSTextAlignmentCenter;
//                points.frame = CGRectMake(15, 72, width, 22);
//                if ([[order valueForKey:@"loyalty"] objectForKey:@"loyalty_spend"]) {
//                    points.text = [[SCLocalizedString(@"Spending") stringByAppendingString:@": "] stringByAppendingString:[[[order valueForKey:@"loyalty"] objectForKey:@"loyalty_spend"] stringValue]];
//                }
//                [cell addSubview:points];
//                slider.simiObjectIdentifier = points;
//                points.simiObjectIdentifier = [rule objectForKey:@"pointStep"];
//                
//                UILabel *minLabel = [label clone];
//                minLabel.frame = CGRectMake(20, 72, 70, 22);
//                minLabel.text = [[rule objectForKey:@"minPoints"] stringValue];
//                minLabel.textColor = [UIColor grayColor];
//                [cell addSubview:minLabel];
//                
//                UILabel *maxLabel = [label clone];
//                maxLabel.frame = CGRectMake(width - 60, 72, 70, 22);
//                maxLabel.textAlignment = NSTextAlignmentRight;
//                maxLabel.text = [[rule objectForKey:@"maxPoints"] stringValue];
//                maxLabel.textColor = [UIColor grayColor];
//                [cell addSubview:maxLabel];
//            } else {
//                // Need Points
//                cell.textLabel.font = [UIFont fontWithName:THEME_FONT_NAME size:THEME_FONT_SIZE];
//                cell.textLabel.numberOfLines = 2;
//                cell.textLabel.text = [NSString stringWithFormat:SCLocalizedString(@"You need to earn more %@ to use this rule"), [rule objectForKey:@"needPointLabel"]];
//            }
//        }
    }
}

-(void) applyPoints: (id) sender{
    SimiViewController *currentVC = [SimiGlobalVar sharedInstance].currentlyNavigationController.viewControllers.lastObject;
    [currentVC startLoadingData];
    if(!order){
        order = [SimiOrderModel new];
    }
    float maxPoint = [[loyaltyData objectForKey:@"loyalty_max"] floatValue];
    float minPoint = [[loyaltyData objectForKey:@"loyalty_min"] floatValue];
    float currentPoint = [rewardPointTextField.text floatValue];
    if(currentPoint > maxPoint){
        [self.orderViewController showToastMessage:[NSString stringWithFormat:@"%@ %@",SCLocalizedString(@"Maximum point is"),[loyaltyData objectForKey:@"loyalty_max"]]];
        rewardPointTextField.text = [NSString stringWithFormat:@"%@",[loyaltyData objectForKey:@"loyalty_max"]];
        return;
    }
    if(currentPoint < minPoint){
        [self.orderViewController showToastMessage:[NSString stringWithFormat:@"%@ %@",SCLocalizedString(@"Minimum point is"),[loyaltyData objectForKey:@"loyalty_min"]]];
        rewardPointTextField.text = [NSString stringWithFormat:@"%@",[loyaltyData objectForKey:@"loyalty_min"]];
        return;
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"DidSpendPointsOrder" object:nil];
    [order spendPoints:rewardPointTextField.text];
}

-(void) cancelPoints:(id) sender{
    SimiViewController *currentVC = [SimiGlobalVar sharedInstance].currentlyNavigationController.viewControllers.lastObject;
    [currentVC startLoadingData];
    if(!order){
        order = [SimiOrderModel new];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"DidSpendPointsOrder" object:nil];
    [order spendPoints:@"0"];
}

-(void) useMaxCheckbox:(id) sender{
    M13Checkbox* checkbox = (M13Checkbox*) sender;
    if(checkbox.checkState == M13CheckboxStateChecked){
        rewardPointTextField.text = [NSString stringWithFormat:@"%@",[loyaltyData objectForKey:@"loyalty_max"]];
    }else{
        rewardPointTextField.text = @"0";
    }
}

@end
