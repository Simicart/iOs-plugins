//
//  LoyaltyViewController.m
//  SimiCartPluginFW
//
//  Created by Nguyen Dac Doan on 1/15/15.
//  Copyright (c) 2015 Magestore. All rights reserved.
//

#import "LoyaltyViewController.h"
#import "LoyaltyLoginViewController.h"
#import "LoyaltyHistoryViewController.h"
#import "LoyaltySettingViewController.h"

@interface LoyaltyViewController () {
    BOOL _reloadDataFlag;
}
@end

@implementation LoyaltyViewController
@synthesize loyaltyPolicy = _loyaltyPolicy;
@synthesize skipReloadData = _skipReloadData;

- (void)viewDidLoadBefore {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [super viewDidLoadBefore];
    }else{
        [self configureNavigationBarOnViewDidLoad];
    }
    // Init Views
    self.screenTrackingName = @"my_reward";
    self.navigationItem.title = SCLocalizedString(@"My Rewards");
    // Table View
    self.contentTableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStyleGrouped];
    self.contentTableView.delegate = self;
    self.contentTableView.dataSource = self;
    self.contentTableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    if (SIMI_SYSTEM_IOS >= 9) {
        self.contentTableView.cellLayoutMarginsFollowReadableWidth = NO;
    }
    [self.view addSubview:self.contentTableView];
}

- (void)viewWillAppearBefore:(BOOL)animated{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [super viewWillAppearBefore:YES];
    }
}

- (void)viewDidAppearBefore:(BOOL)animated{
    [super viewDidAppearBefore:animated];
    if (_skipReloadData) {
        _skipReloadData = NO;
        return;
    }
    // Start Loading Home Data
    if (_loyaltyPolicy == nil) {
        _loyaltyPolicy = [LoyaltyModel new];
    }
    _reloadDataFlag = YES;
    [self startLoadingData];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:Loyalty_LoadedProgramOverview object:_loyaltyPolicy];
    [_loyaltyPolicy loadProgramOverview];
}

- (void)didReceiveNotification:(NSNotification *)noti{
    [self stopLoadingData];
    [self initCells];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)createCells{
    if ([[SimiGlobalVar sharedInstance] isLogin]) {
        SimiSection *section = [self.cells addSectionWithIdentifier:LOYALTY_BALANCE];
        CGFloat height = 98;
        if (_loyaltyPolicy.invertPoint) {
            height += 88;
        } else if (_loyaltyPolicy.spendingPoint) {
            height += 22;
        }
        if (_loyaltyPolicy.loyaltyHold) {
            height += 24;
        }
        SimiRow *row = [section addRowWithIdentifier:LOYALTY_BALANCE height:height sortOrder:0];
        // More Menu Information
        row = [section addRowWithIdentifier:LOYALTY_HISTORY height:44 sortOrder:0];
        row.title = SCLocalizedString(@"Rewards History");
        row.image = [UIImage imageNamed:@"loyalty_history"];
        row = [section addRowWithIdentifier:LOYALTY_SETTING height:44 sortOrder:0];
        row.title = SCLocalizedString(@"Settings");
        row.image = [UIImage imageNamed:@"loyalty_setting"];
    }
    if (_loyaltyPolicy.earningLabel) {
        SimiSection *section = [self.cells addSectionWithIdentifier:LOYALTY_EARN headerTitle:_loyaltyPolicy.earningLabel];
        SimiRow *row = [section addRowWithIdentifier:LOYALTY_EARN height:44 sortOrder:0];
        row.title = _loyaltyPolicy.earningPolicy;
    }
    if (_loyaltyPolicy.spendingLabel) {
        SimiSection *section = [self.cells addSectionWithIdentifier:LOYALTY_SPEND headerTitle:_loyaltyPolicy.spendingLabel];
        SimiRow *row = [section addRowWithIdentifier:LOYALTY_SPEND height:44 sortOrder:0];
        row.title = _loyaltyPolicy.spendingPolicy;
    }
    NSArray *policies = _loyaltyPolicy.policies;
    if (policies && [policies count]) {
        SimiSection *section = [self.cells addSectionWithIdentifier:LOYALTY_POLICY headerTitle:SCLocalizedString(@"Our policies")];
        SimiRow *row = [section addRowWithIdentifier:LOYALTY_POLICY height:(8 + 36 * policies.count + 18 * (policies.count - 1)) sortOrder:0];
        row.title = [policies componentsJoinedByString:@"\n\n"];
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            row.height = 22 + 22 * policies.count + 18 * (policies.count - 1);
        }
    }
    if (![[SimiGlobalVar sharedInstance] isLogin]) {
        SimiSection *section = [self.cells addSectionWithIdentifier:LOYALTY_LOGIN headerTitle:nil];
        [section addRowWithIdentifier:LOYALTY_LOGIN height:44];
    }
}

#pragma mark - table view datasource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell;
    SimiSection *section = [self.cells objectAtIndex:indexPath.section];
    SimiRow *row = [section objectAtIndex:indexPath.row];
    
    if ([row.identifier isEqualToString:LOYALTY_BALANCE]) {
        // Balance & ID Cell
        cell = [tableView dequeueReusableCellWithIdentifier:LOYALTY_BALANCE];
        if (cell == nil || _reloadDataFlag) {
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:LOYALTY_BALANCE];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            } else if (_reloadDataFlag) {
                [[cell viewWithTag:100] removeFromSuperview];
            }
            CGFloat width = MIN(CGRectGetWidth(tableView.frame), 360);
            UIView *view = [[UIView alloc] initWithFrame:CGRectMake((CGRectGetWidth(tableView.frame) - width) / 2, 0, width, row.height)];
            view.tag = 100;
            [cell addSubview:view];
            // Draw Reward Points Information
            CGFloat y = 20;
            CGFloat height;
            if (_loyaltyPolicy.invertPoint || _loyaltyPolicy.spendingLabel) {
                height = 90;
            } else {
                height = 68;
            }
            UIView *left = [[UIView alloc] initWithFrame:CGRectMake(20, y, width - 144, height)];
            UIView *right = [[UIView alloc] initWithFrame:CGRectMake(width - 113, y, 113, height)];
            UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(width - 114, y, 1, height)];
            separator.backgroundColor = [UIColor lightGrayColor];
            [view addSubview:left];
            [view addSubview:right];
            [view addSubview:separator];
            // Left Info: Balance
            UILabel *balance = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, left.frame.size.width, 40)];
            balance.font = [UIFont fontWithName:THEME_FONT_NAME size:40];
            balance.textColor = THEME_PRICE_COLOR;
            balance.textAlignment = NSTextAlignmentCenter;
            if(_loyaltyPolicy.loyaltyPoint)
                balance.text = [NSString stringWithFormat:@"%.f",_loyaltyPolicy.loyaltyPoint];
            else
                balance.text = @"0";
            [left addSubview:balance];
            UILabel *available = [[UILabel alloc] initWithFrame:CGRectMake(0, 40, left.frame.size.width, 24)];
            available.font = [UIFont fontWithName:THEME_FONT_NAME size:20];
            available.textAlignment = NSTextAlignmentCenter;
            available.text = SCLocalizedString(@"AVAILABLE POINTS");
            available.adjustsFontSizeToFitWidth = YES;
            available.minimumScaleFactor = 0.5;
            [left addSubview:available];
            if (_loyaltyPolicy.invertPoint || _loyaltyPolicy.spendingLabel) {
                UILabel *invert = [[UILabel alloc] initWithFrame:CGRectMake(0, 66, left.frame.size.width, 24)];
                invert.font = [UIFont fontWithName:THEME_FONT_NAME size:14];
                invert.textAlignment = NSTextAlignmentCenter;
                invert.adjustsFontSizeToFitWidth = YES;
                invert.minimumScaleFactor = 0.5;
                invert.textColor = [UIColor grayColor];
                if (_loyaltyPolicy.invertPoint) {
                    if (_loyaltyPolicy.startDiscount) {
                        invert.text = [NSString stringWithFormat:SCLocalizedString(@"Only %@ until %@"), _loyaltyPolicy.invertPoint, _loyaltyPolicy.startDiscount];
                    } else {
                        invert.text = [NSString stringWithFormat:SCLocalizedString(@"Only %@ until redeemable"), _loyaltyPolicy.invertPoint];
                    }
                } else {
                    invert.text = [NSString stringWithFormat:SCLocalizedString(@"Equal %@ to redeem"), _loyaltyPolicy.loyaltyRedeem];
                }
                [left addSubview:invert];
            }
            // Right Info: Rate
            UIImageView *coinBg = [[UIImageView alloc] initWithFrame:CGRectMake(20, 0, 68, 68)];
            coinBg.image = [UIImage imageNamed:@"loyalty_coin"];
            [right addSubview:coinBg];
            UILabel *coin = [[UILabel alloc] initWithFrame:CGRectMake(24, 0, 60, 68)];
            coin.shadowColor = [UIColor colorWithWhite:0.8f alpha:1.0f];
            coin.shadowOffset = CGSizeMake(1.0f, 1.0f);
            coin.backgroundColor = [UIColor clearColor];
            coin.font = [UIFont fontWithName:THEME_FONT_NAME size:24];
            coin.textColor = [UIColor colorWithWhite:0.4f alpha:1.0f];
            coin.textAlignment = NSTextAlignmentCenter;
            coin.adjustsFontSizeToFitWidth = YES;
            coin.adjustsLetterSpacingToFitWidth = YES;
            coin.minimumScaleFactor = 0.5;
            coin.text = _loyaltyPolicy.spendingDiscount ? _loyaltyPolicy.spendingDiscount : @"1";
            [right addSubview:coin];
            if (_loyaltyPolicy.spendingPoint) {
                UILabel *rate = [[UILabel alloc] initWithFrame:CGRectMake(0, 66, right.frame.size.width, 24)];
                rate.font = [UIFont fontWithName:THEME_FONT_NAME size:14];
                rate.textAlignment = NSTextAlignmentCenter;
                rate.adjustsFontSizeToFitWidth = YES;
                rate.minimumScaleFactor = 0.5;
                rate.textColor = [UIColor grayColor];
                rate.backgroundColor = [UIColor clearColor];
                rate.text = [NSString stringWithFormat:@"%@ = %@", _loyaltyPolicy.spendingPoint, _loyaltyPolicy.spendingDiscount];
                [right addSubview:rate];
            }
            y += height;
            // Draw Holding Balance
            if (_loyaltyPolicy.loyaltyHold) {
                UILabel *holding = [[UILabel alloc] initWithFrame:CGRectMake(20, y, width - 40, 24)];
                holding.font = [UIFont fontWithName:THEME_FONT_NAME size:16];
                holding.textAlignment = NSTextAlignmentCenter;
                holding.adjustsFontSizeToFitWidth = YES;
                holding.minimumScaleFactor = 0.5;
                holding.textColor = [UIColor grayColor];
                holding.text = [NSString stringWithFormat:SCLocalizedString(@"You have %@ that are pending for approval"), _loyaltyPolicy.loyaltyHold];
                [view addSubview:holding];
                y += 24;
            }
            // Draw Status Bar
            if (_loyaltyPolicy.invertPoint) {
                width -= 20;
                UIView *status = [[UIView alloc] initWithFrame:CGRectMake(10, y, width, 66)];
                [view addSubview:status];
                
                UIView *rulerMark = [[UIView alloc] initWithFrame:CGRectMake(10, 20, 1, 24)];
                rulerMark.backgroundColor = [UIColor lightGrayColor];
                [status addSubview:rulerMark];
                rulerMark = [[UIView alloc] initWithFrame:CGRectMake(width - 11, 20, 1, 24)];
                rulerMark.backgroundColor = [UIColor lightGrayColor];
                [status addSubview:rulerMark];
                
                UIView *ruler = [[UIView alloc] initWithFrame:CGRectMake(10, 20, width - 20, 20)];
                [ruler.layer setBorderWidth:1.0f];
                [ruler.layer setBorderColor:[UIColor lightGrayColor].CGColor];
                ruler.backgroundColor = [UIColor colorWithWhite:0.8f alpha:1];
                [status addSubview:ruler];
                
                NSInteger point = [_loyaltyPolicy.loyaltyBalance integerValue];
                NSInteger max = _loyaltyPolicy.spendingMin;
                if (point > 0 && max > 0) {
                    // Draw current balance on ruler
                    CGFloat pointWidth = (width - 22) * point / max;
                    UIView *process = [[UIView alloc] initWithFrame:CGRectMake(1, 1, pointWidth, 18)];
                    process.backgroundColor = [UIColor greenColor];
                    [ruler addSubview:process];
                }
                UILabel *zeroLabel = [[UILabel alloc] initWithFrame:CGRectMake(1, 44, 18, 22)];
                zeroLabel.text = @"0";
                zeroLabel.font = [UIFont fontWithName:THEME_FONT_NAME size:14];
                zeroLabel.textAlignment = NSTextAlignmentCenter;
                zeroLabel.textColor = [UIColor grayColor];
                zeroLabel.adjustsFontSizeToFitWidth = YES;
                zeroLabel.minimumScaleFactor = 0.5;
                [status addSubview:zeroLabel];
                UILabel *maxLabel = [[UILabel alloc] initWithFrame:CGRectMake(width - 101, 44, 100, 22)];
                maxLabel.text = [NSString stringWithFormat:@"%d",_loyaltyPolicy.spendingMin];
                maxLabel.font = [UIFont fontWithName:THEME_FONT_NAME size:14];
                maxLabel.textAlignment = NSTextAlignmentRight;
                maxLabel.textColor = [UIColor grayColor];
                maxLabel.adjustsFontSizeToFitWidth = YES;
                maxLabel.minimumScaleFactor = 0.5;
                [status addSubview:maxLabel];
            }
        }
    } else if ([section.identifier isEqualToString:LOYALTY_LOGIN]) {
        // Login Cell
        cell = [tableView dequeueReusableCellWithIdentifier:LOYALTY_LOGIN];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:LOYALTY_LOGIN];
            UILabel *loginLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 2, tableView.frame.size.width - 20, 40)];
            loginLabel.font = [UIFont fontWithName:THEME_FONT_NAME size:THEME_FONT_SIZE];
            [cell addSubview:loginLabel];
            loginLabel.backgroundColor = [UIColor clearColor];
            loginLabel.text = SCLocalizedString(@"Login or Signup");
            loginLabel.textColor = [UIColor whiteColor];
            loginLabel.textAlignment = NSTextAlignmentCenter;
            cell.backgroundColor = THEME_COLOR;
        }
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:LOYALTY_EARN];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:LOYALTY_EARN];
            cell.textLabel.numberOfLines = 0;
            cell.textLabel.font = [UIFont fontWithName:THEME_FONT_NAME size:THEME_FONT_SIZE];
            cell.textLabel.adjustsFontSizeToFitWidth = YES;
            cell.textLabel.minimumScaleFactor = 0.5f;
        }
        if ([row.identifier isEqualToString:LOYALTY_HISTORY] || [row.identifier isEqualToString:LOYALTY_SETTING]) {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        cell.imageView.image = row.image;
        cell.textLabel.text = row.title;
    }
    return cell;
}

#pragma mark - table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SimiSection *section = [self.cells objectAtIndex:indexPath.section];
    SimiRow *row = [section objectAtIndex:indexPath.row];
    _skipReloadData = YES;
    if ([section.identifier isEqualToString:LOYALTY_LOGIN]) {
        [self.navigationController pushViewController:[LoyaltyLoginViewController new] animated:YES];
    } else if ([row.identifier isEqualToString:LOYALTY_HISTORY]) {
        [self.navigationController pushViewController:[LoyaltyHistoryViewController new] animated:YES];
    } else if ([row.identifier isEqualToString:LOYALTY_SETTING]) {
        LoyaltySettingViewController *settings = [LoyaltySettingViewController new];
        settings.model = _loyaltyPolicy;
        [self.navigationController pushViewController:settings animated:YES];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
