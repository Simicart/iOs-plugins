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
#import <SimiCartBundle/SCMoreViewController.h>
#import <SimiCartBundle/SCAccountViewController.h>
#import <SimiCartBundle/SCOrderViewController.h>
#import <SimiCartBundle/SimiSection.h>
#import <SimiCartBundle/SimiGlobalVar.h>
#import <SimiCartBundle/SimiTable.h>
#import <SimiCartBundle/SCOrderFeeCell.h>
#import <SimiCartBundle/SimiFormatter.h>

#import "SCProductViewController_Pad.h"
#import "SimiNavigationBarWorker.h"

#import "LoyaltyViewController.h"
#import "SimiOrderModel+Loyalty.h"

@implementation LoyaltyPluginInitial

- (instancetype)init
{
    if (self = [super init]) {
        // Show Label on Product iPad
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"SCProductViewControllerPad-AfterConfigAddToCartButton" object:nil];
        // Show Label on Product iPhone
        if (SIMI_SYSTEM_IOS >= 8) {            
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"SCProductViewController-InitCellsAfter" object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"InitializedProductCell-After" object:nil];
        }
        // Show Label on Shopping Cart
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"InitCartCell-Before" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"InitializedCartCell-Before" object:nil];
        
        // Reward Menu
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"SCMoreViewController_SetCellsForTableView" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"SCMoreViewController_UpdateCellsForTableView" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"SCAccountViewController-ViewDidLoad" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"InitializedAccountCell-After" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"SCLeftMenu_InitCellsAfter" object:nil];
        // Reward Menu Action
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"SCMoreViewController-ViewDidLoad" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"SCMoreViewController_DidSelectCellAtIndexPath" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"DidSelectAccountCellAtIndexPath" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"SCLeftMenu_DidSelectRow" object:nil];
        
        // Spend Point when Checkout
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"SCOrderViewController-ViewDidLoad" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"DidGetOrderConfig" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"DidSetCouponCode" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"DidSaveShippingMethod" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"DidSpendPointsOrder" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"InitializedOrderCell-After" object:nil];
        
        // Update Point balance after checkout
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"DidPlaceOrder" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"LoadedProgramOverview" object:nil];
        
        // Fix bugs for Matrix theme
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"SCListMenu_Theme01-InitCellsAfter" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"SCListMenu_DidSelectRow" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"SCOrderViewController-InitTableBefore" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"SCOrderViewController-InitTableAfter" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"SCOrderViewController-InitRightTableAfter" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"InitializedOrderCellTheme01-After" object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveNotification:(NSNotification *)noti
{
    if ([noti.name isEqualToString:@"SCProductViewControllerPad-AfterConfigAddToCartButton"]) {
        // Add Label for Product Detail Page - iPad version
        SCProductViewController_Pad *controller = (SCProductViewController_Pad *)noti.object;
        // Remove Label & Image if they were showed
        UIView *loyalty = [controller.view viewWithTag:LOYALTY_TAG];
        if (loyalty) {
            [loyalty removeFromSuperview];
            loyalty = nil;
        }
        if ([controller.product objectForKey:@"loyalty_label"]) {
            CGRect frame = controller.btaddToCart.frame;
            
            // Show Label & Image
            loyalty = [[UIView alloc] initWithFrame:CGRectMake(frame.origin.x, frame.origin.y - 10, 500, 24)];
            loyalty.tag = LOYALTY_TAG;
            [controller.scrollView addSubview:loyalty];
            
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 3, 18, 18)];
            imageView.contentMode = UIViewContentModeScaleAspectFit;
            [imageView sd_setImageWithURL:[NSURL URLWithString:[controller.product objectForKey:@"loyalty_image"]] placeholderImage:nil options:SDWebImageRetryFailed];
            [loyalty addSubview:imageView];
            
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(24, 0, 476, 24)];
            label.font = [UIFont fontWithName:THEME_FONT_NAME size:THEME_FONT_SIZE_REGULAR];
            label.text = [controller.product objectForKey:@"loyalty_label"];
            [loyalty addSubview:label];
            
            // Update BTN Add Cart
            frame.origin.y += 24;
            controller.btaddToCart.frame = frame;
            
            float newHeight = frame.origin.y + 70;
            controller.scrollHeightContent = MAX(controller.scrollHeightContent, newHeight);
        }
    } else if ([noti.name isEqualToString:@"SCProductViewController-InitCellsAfter"]) {
        SCProductViewController *controller = (SCProductViewController *)[noti.userInfo objectForKey:@"controller"];
        if ([controller.product objectForKey:@"loyalty_label"]) {
            SimiSection *section = [noti.object objectAtIndex:0];
            SimiRow *row = [section getRowByIdentifier:PRODUCT_ACTION_CELL_ID];
            row.height += 44;
        }
    } else if ([noti.name isEqualToString:@"InitializedProductCell-After"]) {
        SCProductViewController *controller = (SCProductViewController *)[noti.userInfo objectForKey:@"controller"];
        NSIndexPath *indexPath = (NSIndexPath *)[noti.userInfo objectForKey:@"indexPath"];
        SimiSection *section = [controller.cells objectAtIndex:indexPath.section];
        SimiRow *row = [section.rows objectAtIndex:indexPath.row];
        if ([row.identifier isEqualToString:PRODUCT_ACTION_CELL_ID] && [controller.product objectForKey:@"loyalty_label"]) {
            UITableViewCell *cell = (UITableViewCell *)noti.object;
            UIView *loyalty = [cell viewWithTag:LOYALTY_TAG];
            if (loyalty == nil) {
                // Move all view to get space
                for (UIView *subView in cell.subviews) {
                    CGRect frame = subView.frame;
                    frame.origin.y += 18;
                    subView.frame = frame;
                }
                // Show Label & Image
                loyalty = [[UIView alloc] initWithFrame:CGRectMake(15, 5, cell.frame.size.width - 20, 44)];
                loyalty.tag = LOYALTY_TAG;
                [cell addSubview:loyalty];
                
                UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 13, 18, 18)];
                imageView.contentMode = UIViewContentModeScaleAspectFit;
                [imageView sd_setImageWithURL:[NSURL URLWithString:[controller.product objectForKey:@"loyalty_image"]] placeholderImage:nil options:SDWebImageRetryFailed];
                [loyalty addSubview:imageView];
                
                UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(24, 0, loyalty.frame.size.width - 24, 44)];
                label.font = [UIFont fontWithName:THEME_FONT_NAME size:THEME_FONT_SIZE_REGULAR];
                label.text = [controller.product objectForKey:@"loyalty_label"];
                label.numberOfLines = 2;
                [loyalty addSubview:label];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"LoyaltyPlugin-Enable" object:nil];
            }
        }
    } else if ([noti.name isEqualToString:@"InitCartCell-Before"]) {
        SimiCartModelCollection *cart = [[SimiGlobalVar sharedInstance] cart];
        if (cart.count && [[cart objectAtIndex:0] objectForKey:@"loyalty_label"]) {
            // Add Row to show Loyalty Labels
            SimiTable *cartCells = (SimiTable *)noti.object;
            SimiSection *loyaltySection = [cartCells addSectionWithIdentifier:LOYALTY_CART];
            [loyaltySection addRowWithIdentifier:LOYALTY_CART height:44];
        }
    } else if ([noti.name isEqualToString:@"InitializedCartCell-Before"]) {
        SimiRow *row = [noti.userInfo objectForKey:@"row"];
        if ([row.identifier isEqualToString:LOYALTY_CART]) {
            SCCartViewController *controller = noti.object;
            controller.isDiscontinue = YES;
            
            UITableView *tableView = (UITableView *)[noti.userInfo objectForKey:@"tableView"];
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
                    loyalty.frame = CGRectMake(10, 2, 660, 40);
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
            SimiCartModelCollection *cart = [[SimiGlobalVar sharedInstance] cart];
            
            UIView *loyalty = [cell viewWithTag:LOYALTY_TAG];
            UIImageView *imageView = (UIImageView *)[loyalty viewWithTag:3821];
            UILabel *label = (UILabel *)[loyalty viewWithTag:3822];
            
            [imageView sd_setImageWithURL:[NSURL URLWithString:[[cart objectAtIndex:0] objectForKey:@"loyalty_image"]] placeholderImage:nil options:SDWebImageRetryFailed];
            label.text = [[cart objectAtIndex:0] objectForKey:@"loyalty_label"];
            
            // Center label and image
            CGFloat textWidth = [label textRectForBounds:CGRectMake(24, 0, loyalty.frame.size.width - 24, 40) limitedToNumberOfLines:2].size.width;
            imageView.frame = CGRectMake((loyalty.frame.size.width - textWidth - 24) / 2, 11, 18, 18);
            label.frame = CGRectMake(imageView.frame.origin.x + 24, 0, textWidth, 40);
            
            controller.simiObjectIdentifier = cell;
        }
    } else if ([noti.name isEqualToString:@"SCMoreViewController_SetCellsForTableView"]) {
        SCMoreViewController *controller = (SCMoreViewController *)noti.object;
        NSMutableArray *cells = controller.cells;
        
        SimiSection *section = [[SimiSection alloc] initWithIdentifier:LOYALTY_CART];
        section.headerTitle = SCLocalizedString(@"Reward Points");
        // [cells addObject:section];
        [cells insertObject:section atIndex:1];
        
        SimiRow *row = [section addRowWithIdentifier:LOYALTY_CART height:40 sortOrder:0];
        row.image = [UIImage imageNamed:@"loyalty_reward.png"];
        row.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        row.title = [self rewardMenuLabel];
        self.loyaltyMenuRow = row;
    } else if ([noti.name isEqualToString:@"SCMoreViewController_UpdateCellsForTableView"]) {
        SCMoreViewController *controller = (SCMoreViewController *)noti.object;
        for (SimiSection *section in controller.cells) {
            if ([section.identifier isEqualToString:LOYALTY_CART]) {
                SimiRow *row = [section getRowByIdentifier:LOYALTY_CART];
                row.title = [self rewardMenuLabel];
                self.loyaltyMenuRow = row;
            }
        }
    } else if ([noti.name isEqualToString:@"SCAccountViewController-ViewDidLoad"]) {
        SimiSection *section = [[SimiSection alloc] initWithIdentifier:LOYALTY_CART];
        section.headerTitle = SCLocalizedString(@"Reward Points");
        [((SCAccountViewController *)noti.object).accountCells addObject:section];
        [section addRowWithIdentifier:LOYALTY_CART height:40];
    } else if ([noti.name isEqualToString:@"InitializedAccountCell-After"]) {
        SCAccountViewController *controller = (SCAccountViewController *)[noti.userInfo objectForKey:@"self"];
        NSIndexPath *indexPath = (NSIndexPath *)[noti.userInfo objectForKey:@"indexPath"];
        
        SimiRow *row = [[controller.accountCells objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
        UITableViewCell *cell = (UITableViewCell *)noti.object;
        if ([row.identifier isEqualToString:LOYALTY_CART]) {
            cell.imageView.image = [UIImage imageNamed:@"loyalty_reward.png"];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.textLabel.text = [self rewardMenuLabel];
        } else {
            cell.imageView.image = nil;
        }
    } else if ([noti.name isEqualToString:@"SCLeftMenu_InitCellsAfter"]) {
        SimiTable *cells = noti.object;
        
        SimiSection *section = [cells addSectionWithIdentifier:LOYALTY_CART atIndex:1];
        section.headerTitle = SCLocalizedString(@"Reward Points");
        
        SimiRow *row = [section addRowWithIdentifier:LOYALTY_CART height:40 sortOrder:0];
        row.image = [UIImage imageNamed:@"loyalty_reward.png"];
        row.title = [self rewardMenuLabel];
        self.loyaltyMenuRow = row;
    } else if ([noti.name isEqualToString:@"SCMoreViewController-ViewDidLoad"]) {
        self.moreViewController = noti.object;
    } else if ([noti.name isEqualToString:@"SCMoreViewController_DidSelectCellAtIndexPath"]) {
        SCMoreViewController *controller = self.moreViewController;
        NSIndexPath *indexPath = [noti.userInfo objectForKey:@"indexPath"];
        SimiRow *row = [[controller.cells objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
        if ([row.identifier isEqualToString:LOYALTY_CART]) {
            [controller.navigationController pushViewController:[LoyaltyViewController new] animated:YES];
            controller.isDiscontinue = YES;
        }
    } else if ([noti.name isEqualToString:@"DidSelectAccountCellAtIndexPath"]) {
        SimiRow *row = noti.object;
        if ([row.identifier isEqualToString:LOYALTY_CART]) {
            UITableView *tableView = (UITableView *)[noti.userInfo objectForKey:@"tableView"];
            SCAccountViewController *controller = (SCAccountViewController *)tableView.delegate;
            [controller.navigationController pushViewController:[LoyaltyViewController new] animated:YES];
            controller.isDiscontinue = YES;
        }
    } else if ([noti.name isEqualToString:@"SCLeftMenu_DidSelectRow"]) {
        // iPad show My Rewards
        SimiRow *row = (SimiRow *)[noti.userInfo objectForKey:@"simirow"];
        if ([row.identifier isEqualToString:LOYALTY_CART]) {
            SimiNavigationBarWorker *worker = noti.object;
            LoyaltyViewController *loyalty = [LoyaltyViewController new];
            worker.popController = nil;
            worker.popController = [[UIPopoverController alloc] initWithContentViewController:[[UINavigationController alloc] initWithRootViewController:loyalty]];
            loyalty.isInPopover = YES;
            
            UIViewController *currentVC = [(UITabBarController *)[[(SCAppDelegate *)[[UIApplication sharedApplication] delegate] window] rootViewController] selectedViewController];
            [worker.popController presentPopoverFromRect:CGRectMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2, 1, 1) inView:currentVC.view permittedArrowDirections:0 animated:YES];
            
            [(NSObject *)noti.object setIsDiscontinue:YES];
        }
    } else if ([noti.name isEqualToString:@"SCOrderViewController-ViewDidLoad"]) {
        self.orderViewController = noti.object;
    } else if (([noti.name isEqualToString:@"DidGetOrderConfig"] || [noti.name isEqualToString:@"DidSpendPointsOrder"] || [noti.name isEqualToString:@"DidSetCouponCode"] || [noti.name isEqualToString:@"DidSaveShippingMethod"] || [noti.name isEqualToString:@"SCOrderViewController-InitTableBefore"] || [noti.name isEqualToString:@"SCOrderViewController-InitTableAfter"]) && self.orderViewController) {
        SimiOrderModel *order = [self.orderViewController order];
        NSArray *rules = [[order objectForKey:@"fee"] objectForKey:@"loyalty_rules"];
        if ([rules count]) {
            NSDictionary *rule = [rules objectAtIndex:0];
            SimiTable *orderTable = [self.orderViewController orderTable];
            if ([orderTable getSectionIndexByIdentifier:LOYALTY_CHECKOUT] == NSNotFound) {
                NSUInteger index = [orderTable getSectionIndexByIdentifier:ORDER_PAYMENT_SECTION];
                if (index != NSNotFound) {
                    index++;
                    SimiSection *section = [orderTable addSectionWithIdentifier:LOYALTY_CHECKOUT atIndex:index];
                    section.headerTitle = SCLocalizedString(@"Spend my Points");
                    CGFloat height = [[rule objectForKey:@"optionType"] isEqualToString:@"slider"] ? 105 : 40;
                    if (![[SimiGlobalVar sharedInstance] isLogin]) height = 40;
                    [section addRowWithIdentifier:LOYALTY_CHECKOUT height:height];
                }
            }
        }
        NSDictionary *fee = [order objectForKey:@"fee"];
        NSMutableDictionary *v2 = [fee valueForKey:@"v2"];
        if (![v2 isKindOfClass:[NSMutableDictionary class]]) {
            v2 = [[NSMutableDictionary alloc] initWithDictionary:v2];
            [fee setValue:v2 forKey:@"v2"];
        }
        if ([[fee objectForKey:@"loyalty_spend"] integerValue]) {
            [v2 setValue:[fee objectForKey:@"loyalty_spending"] forKey:@"loyalty_spend"];
            [v2 setValue:[fee objectForKey:@"loyalty_discount"] forKey:@"loyalty_discount"];
        } else {
            [v2 removeObjectForKey:@"loyalty_spend"];
            [v2 removeObjectForKey:@"loyalty_discount"];
        }
        if ([[fee objectForKey:@"loyalty_earn"] integerValue]) {
            [v2 setValue:[fee objectForKey:@"loyalty_earning"] forKey:@"loyalty_earn"];
        } else {
            [v2 removeObjectForKey:@"loyalty_earn"];
        }
    } else if ([noti.name isEqualToString:@"InitializedOrderCell-After"] || [noti.name isEqualToString:@"InitializedOrderCellTheme01-After"]) {
        SimiRow *row = noti.object;
        if ([row.identifier isEqualToString:LOYALTY_CHECKOUT]) {
            UITableViewCell *cell = (UITableViewCell *)[noti.userInfo objectForKey:@"cell"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            if (![[SimiGlobalVar sharedInstance] isLogin]) {
                cell.textLabel.font = [UIFont fontWithName:THEME_FONT_NAME size:THEME_FONT_SIZE];
                cell.textLabel.numberOfLines = 2;
                cell.textLabel.text = SCLocalizedString(@"Please login before using points to spend");
                return;
            }
            SimiOrderModel *order = [self.orderViewController order];
            NSArray *rules = [[order objectForKey:@"fee"] objectForKey:@"loyalty_rules"];
            if ([rules count]) {
                NSDictionary *rule = [rules objectAtIndex:0];
                if ([[rule objectForKey:@"optionType"] isEqualToString:@"slider"]) {
                    // Slider
                    UITableView *tableView = (UITableView *)[noti.userInfo objectForKey:@"tableView"];
                    CGFloat width = tableView.frame.size.width - 30;
                    if ([noti.name isEqualToString:@"InitializedOrderCellTheme01-After"]) {
                        width = 470;
                    }
                    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 11, width, 22)];
                    label.font = [UIFont fontWithName:THEME_FONT_NAME size:THEME_FONT_SIZE];
                    label.adjustsFontSizeToFitWidth = YES;
                    label.minimumScaleFactor = 0.7;
                    label.text = [NSString stringWithFormat:SCLocalizedString(@"Each of %@ gets %@ discount"), [rule objectForKey:@"pointStepLabel"], [rule objectForKey:@"pointStepDiscount"]];
                    [cell addSubview:label];
                    
                    UISlider *slider = [[UISlider alloc] initWithFrame:CGRectMake(15, 44, width, 28)];
                    slider.minimumValue = [[rule objectForKey:@"minPoints"] floatValue];
                    slider.maximumValue = [[rule objectForKey:@"maxPoints"] floatValue];
                    slider.value = [[[order objectForKey:@"fee"] objectForKey:@"loyalty_spend"] floatValue];
                    [slider addTarget:self action:@selector(changeSpendingPoints:) forControlEvents:UIControlEventValueChanged];
                    [slider addTarget:self action:@selector(stopSpendingPointsSlide:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside];
                    [cell addSubview:slider];
                    
                    UILabel *points = [label clone];
                    points.font = [UIFont fontWithName:THEME_FONT_NAME size:THEME_FONT_SIZE];
                    points.textAlignment = NSTextAlignmentCenter;
                    points.frame = CGRectMake(15, 72, width, 22);
                    points.text = [[SCLocalizedString(@"Spending") stringByAppendingString:@": "] stringByAppendingString:[[[order objectForKey:@"fee"] objectForKey:@"loyalty_spend"] stringValue]];
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
                    cell.textLabel.text = [NSString stringWithFormat:SCLocalizedString(@"You need to earn more %@ to use this rule."), [rule objectForKey:@"needPointLabel"]];
                }
            }
        }
        SCOrderFeeCell *cell = [noti.userInfo objectForKey:@"cell"];
        NSDictionary *fee    = [[[self.orderViewController order] objectForKey:@"fee"] objectForKey:@"v2"];
        if ([cell isKindOfClass:[SCOrderFeeCell class]] && fee) {
            // Label 22 + 3
            CGFloat origionTitleX = cell.frame.size.width - 310;
            CGFloat widthTitle    = 190;
            CGFloat origionValueX = cell.frame.size.width - 170;
            CGFloat widthValue    = 160;
            UILabel *earn, *earnValue, *spend, *spendValue, *discount, *discountValue;
            CGFloat marginTop     = 0;
            if ([fee objectForKey:@"loyalty_earn"]) {
                earn = [[UILabel alloc] initWithFrame:CGRectMake(origionTitleX, 5, widthTitle, 22)];
                earn.text = [SCLocalizedString(@"You will earn") stringByAppendingString:@":"];
                earn.font = [UIFont fontWithName:THEME_FONT_NAME size:THEME_FONT_SIZE];
                earnValue = [[UILabel alloc] initWithFrame:CGRectMake(origionValueX, 5, widthValue, 22)];
                earnValue.text = [fee objectForKey:@"loyalty_earn"];
                earnValue.font = earn.font;
                earnValue.textColor = THEME_PRICE_COLOR;
                earnValue.textAlignment = NSTextAlignmentRight;
                marginTop += 25;
            }
            CGFloat subThreshold   = 0;
            CGFloat subTotalMargin = marginTop;
            if ([fee objectForKey:@"loyalty_spend"]) {
                for (UIView *view in cell.subviews) {
                    if ([view isEqual:cell.subTotalExclLabel] || [view isEqual:cell.subTotalLabel] || [view isEqual:cell.subTotalInclLabel]) {
                        subThreshold = MAX(subThreshold, view.frame.origin.y);
                    }
                }
                spend = [[UILabel alloc] initWithFrame:CGRectMake(origionTitleX, marginTop + 5, widthTitle, 22)];
                spend.text = [SCLocalizedString(@"You will spend") stringByAppendingString:@":"];
                spend.font = [UIFont fontWithName:THEME_FONT_NAME size:THEME_FONT_SIZE];
                spendValue = [[UILabel alloc] initWithFrame:CGRectMake(origionValueX, marginTop + 5, widthValue, 22)];
                spendValue.text = [fee objectForKey:@"loyalty_spend"];
                spendValue.font = spend.font;
                spendValue.textColor = THEME_PRICE_COLOR;
                spendValue.textAlignment = NSTextAlignmentRight;
                marginTop += 25;
                subTotalMargin = marginTop + 25;
                discount = [spend clone];
                discountValue = [spendValue clone];
                discount.frame = CGRectMake(origionTitleX, subThreshold + subTotalMargin, widthTitle, 22);
                discount.text = [[[[fee objectForKey:@"loyalty_spend"] stringByAppendingString:@" "] stringByAppendingString:SCLocalizedString(@"Discount")] stringByAppendingString:@":"];
                discountValue.frame = CGRectMake(origionValueX, subThreshold + subTotalMargin, widthValue, 22);
                discountValue.text = [[SimiFormatter sharedInstance] priceByLocalizeNumber:[fee objectForKey:@"loyalty_discount"]];
            }
            if (marginTop > 1) {
                for (UIView *view in cell.subviews) {
                    CGRect frame = view.frame;
                    if (frame.origin.y > subThreshold) {
                        frame.origin.y += subTotalMargin;
                    } else {
                        frame.origin.y += marginTop;
                    }
                    view.frame = frame;
                }
            }
            if (earnValue) {
                [cell addSubview:earn];
                [cell addSubview:earnValue];
            }
            if (spendValue) {
                [cell addSubview:spend];
                [cell addSubview:spendValue];
                [cell addSubview:discount];
                [cell addSubview:discountValue];
            }
        }
    } else if ([noti.name isEqualToString:@"DidPlaceOrder"]) {
        if ([noti.object objectForKey:@"loyalty_balance"]) {
            SimiCustomerModel *customer = [[SimiGlobalVar sharedInstance] customer];
            if ([[SimiGlobalVar sharedInstance] isLogin] && customer) {
                [customer setValue:[noti.object objectForKey:@"loyalty_balance"] forKey:@"loyalty_balance"];
                [self.loyaltyMenuRow setTitle:[self rewardMenuLabel]];
            }
        }
    } else if ([noti.name isEqualToString:@"LoadedProgramOverview"]) {
        if ([noti.object objectForKey:@"loyalty_redeem"]) {
            SimiCustomerModel *customer = [[SimiGlobalVar sharedInstance] customer];
            if ([[SimiGlobalVar sharedInstance] isLogin] && customer) {
                [customer setValue:[noti.object objectForKey:@"loyalty_redeem"] forKey:@"loyalty_balance"];
                [self.loyaltyMenuRow setTitle:[self rewardMenuLabel]];
            }
        }
    } else if ([noti.name isEqualToString:@"SCListMenu_Theme01-InitCellsAfter"]) {
        SimiTable *cells = noti.object;
        
        SimiSection *section = [cells addSectionWithIdentifier:LOYALTY_CART atIndex:2];
        section.headerTitle = SCLocalizedString(@"Reward Points");
        
        CGFloat height = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 60 : 45;
        SimiRow *row = [section addRowWithIdentifier:LOYALTY_CART height:height sortOrder:0];
        row.image = [UIImage imageNamed:@"loyalty_reward_invert.png"];
        row.title = [self rewardMenuLabel];
        self.loyaltyMenuRow = row;
    } else if ([noti.name isEqualToString:@"SCListMenu_DidSelectRow"]) {
        SimiRow *row = (SimiRow *)[noti.userInfo objectForKey:@"simirow"];;
        if ([row.identifier isEqualToString:LOYALTY_CART]) {
            UINavigationController *currentVC = (UINavigationController*)[(UITabBarController *)[[(SCAppDelegate *)[[UIApplication sharedApplication]delegate] window] rootViewController] selectedViewController];
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                LoyaltyViewController *loyalty = [LoyaltyViewController new];
                [noti.object setPopController:[[UIPopoverController alloc] initWithContentViewController:[[UINavigationController alloc] initWithRootViewController:loyalty]]];
                loyalty.isInPopover = YES;
                [[noti.object popController] presentPopoverFromRect:CGRectMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2, 1, 1) inView:currentVC.view permittedArrowDirections:0 animated:YES];
            } else {
                [currentVC pushViewController:[LoyaltyViewController new] animated:YES];
            }
            [noti.object setIsDiscontinue:YES];
        }
    } else if ([noti.name isEqualToString:@"SCOrderViewController-InitRightTableAfter"]) {
        SimiOrderModel *order = [self.orderViewController order];
        NSArray *rules = [[order objectForKey:@"fee"] objectForKey:@"loyalty_rules"];
        if ([rules count]) {
            NSDictionary *rule = [rules objectAtIndex:0];
            SimiTable *orderTable = [self.orderViewController orderTableRight];
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
}

- (SimiTable *)orderTableRight
{
    return nil;
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
    if ([[[order objectForKey:@"fee"] objectForKey:@"loyalty_spend"] integerValue] == pointValue) {
        return;
    }
    NSDictionary *rule = [[[order objectForKey:@"fee"] objectForKey:@"loyalty_rules"] objectAtIndex:0];
    
    [[NSNotificationCenter defaultCenter] addObserver:self.orderViewController selector:@selector(didGetOrderConfig:) name:@"DidSpendPointsOrder" object:order];
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

@end
