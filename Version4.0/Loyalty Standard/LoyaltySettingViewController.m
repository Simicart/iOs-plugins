//
//  LoyaltySettingViewController.m
//  SimiCartPluginFW
//
//  Created by Nguyen Dac Doan on 1/21/15.
//  Copyright (c) 2015 Magestore. All rights reserved.
//

#import <SimiCartBundle/SimiTable.h>
#import <SimiCartBundle/SimiRow.h>
#import "LoyaltySettingViewController.h"
#import "LoyaltyViewController.h"

@interface LoyaltySettingViewController ()
@property (strong, nonatomic) LoyaltyModel *settings;
@end

@implementation LoyaltySettingViewController
@synthesize model = _model;
@synthesize settings = _settings;

- (void)viewDidLoadBefore{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [super viewDidLoadBefore];
    }else
        [self configureNavigationBarOnViewDidLoad];
    self.title = SCLocalizedString(@"Settings");
    self.screenTrackingName = @"reward_setting";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(saveSettings)];
    
    // Init Table View Data
    self.contentTableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    self.contentTableView.backgroundColor = [UIColor clearColor];
    self.contentTableView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    if (SIMI_SYSTEM_IOS >= 9) {
        self.contentTableView.cellLayoutMarginsFollowReadableWidth = NO;
    }
    self.contentTableView.dataSource = self;
    self.contentTableView.delegate = self;
    [self.view addSubview:self.contentTableView];
    
    // Init Settings Data
    _settings = [LoyaltyModel new];
    [_settings setObject:_model.isNotification?@"1":@"0" forKey:@"is_notification"];
    [_settings setValue:_model.expireNotification?@"1":@"0" forKey:@"expire_notification"];
    [self initCells];
}

- (void)viewWillAppearBefore:(BOOL)animated{
    
}

- (void)saveSettings
{
    [self startLoadingData];
    [self.navigationItem.rightBarButtonItem setEnabled:NO];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSaveSettings:) name:Loyalty_SavedLoyaltySettings object:nil];
    [_settings saveSettings];
}

- (void)didSaveSettings:(NSNotification *)noti
{
    [self stopLoadingData];
    [self.navigationItem.rightBarButtonItem setEnabled:YES];
    SimiResponder *responder = [noti.userInfo valueForKey:responderKey];
    if (responder.status == SUCCESS) {
        LoyaltyViewController *back = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count - 2];
        back.skipReloadData = NO;
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self showAlertWithTitle:@"" message:responder.message];
    }
    [self removeObserverForNotification:noti];
}

- (void)createCells{
    [self.cells addSectionWithIdentifier:LOYALTY_EMAIL_SETTING headerTitle:SCLocalizedString(@"Email Subscriptions")];
    SimiSection *balanceUpdate = [self.cells addSectionWithIdentifier:LOYALTY_EMAIL_NOTI headerTitle:nil footerTitle:@"Subscribe to receive updates on your point balance"];
    [[balanceUpdate addRowWithIdentifier:LOYALTY_EMAIL_NOTI height:44 sortOrder:0] setTitle:SCLocalizedString(@"Point Balance Update")];
    
    SimiSection *expiringPoints = [self.cells addSectionWithIdentifier:LOYALTY_EMAIL_EXP headerTitle:nil footerTitle:SCLocalizedString(@"Subscribe to receive notifications of expiring points in advance")];
    [[expiringPoints addRowWithIdentifier:LOYALTY_EMAIL_EXP height:44 sortOrder:0] setTitle:SCLocalizedString(@"Expired Point Transaction")];
}

#pragma mark - Table view datasource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SimiSection *section = [self.cells objectAtIndex:indexPath.section];
    SimiRow *row = [section objectAtIndex:indexPath.row];
    UITableViewCell *cell = [self.contentTableView dequeueReusableCellWithIdentifier:row.identifier];
    if(!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:row.identifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor clearColor];
        cell.textLabel.text = row.title;
        cell.textLabel.font = [UIFont fontWithName:THEME_FONT_NAME size:FONT_SIZE_LARGE];
        cell.textLabel.textColor = THEME_CONTENT_COLOR;
        if (GLOBALVAR.isReverseLanguage) {
            [cell.textLabel setTextAlignment:NSTextAlignmentRight];
        }
        if ([section.identifier isEqualToString:LOYALTY_EMAIL_NOTI]) {
            UISwitch *switcher = [UISwitch new];
            switcher.tag = (NSInteger)LOYALTY_EMAIL_NOTI;
            switcher.on = _settings.isNotification;
            [switcher addTarget:self action:@selector(toggleSwitcher:) forControlEvents:UIControlEventValueChanged];
            cell.accessoryView = switcher;
        } else if ([section.identifier isEqualToString:LOYALTY_EMAIL_EXP]) {
            UISwitch *switcher = [UISwitch new];
            switcher.tag = (NSInteger)LOYALTY_EMAIL_EXP;
            switcher.on = _settings.expireNotification;
            [switcher addTarget:self action:@selector(toggleSwitcher:) forControlEvents:UIControlEventValueChanged];
            cell.accessoryView = switcher;
        }
    }
    return cell;
}
#pragma mark - Update settings
- (void)toggleSwitcher:(UISwitch *)sender
{
    if (sender.tag == (NSInteger)LOYALTY_EMAIL_NOTI) {
        [_settings setValue:sender.on?@1:@0 forKey:@"is_notification"];
    } else if (sender.tag == (NSInteger)LOYALTY_EMAIL_EXP) {
        [_settings setValue:sender.on?@1:@0 forKey:@"expire_notification"];
    }
}

@end
