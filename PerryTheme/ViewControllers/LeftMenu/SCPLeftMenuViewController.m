//
//  SCPLeftMenuViewController.m
//  SimiCartPluginFW
//
//  Created by Hoang Van Trung on 5/14/18.
//  Copyright © 2018 Trueplus. All rights reserved.
//

#import "SCPLeftMenuViewController.h"
#import "SCPGlobalVars.h"
#import "SCPLabel.h"

@interface SCPLeftMenuViewController ()

@end

@implementation SCPLeftMenuViewController
- (void)viewDidLoadBefore{
    tableWidth = (SCREEN_WIDTH*3)/4;
    if(PADDEVICE){
        tableWidth = 328;
    }
    self.contentTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, tableWidth, SCREEN_HEIGHT) style:UITableViewStyleGrouped];
    self.contentTableView.delegate = self;
    self.contentTableView.dataSource = self;
    self.contentTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.contentTableView.backgroundColor = SCP_MENU_BACKGROUND_COLOR;
    if (@available(iOS 11.0, *)) {
        self.contentTableView.estimatedRowHeight = 0;
        self.contentTableView.estimatedSectionHeaderHeight = 0;
        self.contentTableView.estimatedSectionFooterHeight = 0;
    }
    [self.contentTableView setShowsVerticalScrollIndicator:NO];
    [self.view addSubview:self.contentTableView];
    
    self.cmsPages = GLOBALVAR.storeView.cms;
    [self addInitWorkerObservers];
    [self initCells];
}
- (void)createCells{
    SimiSection *section1 = [self.cells addSectionWithIdentifier:LEFTMENU_SECTION_MAIN];
    [section1 addRowWithIdentifier:SCP_LEFTMENU_ROW_ACCOUNT height:64 + tableWidth/3 + 30];
    SimiRow *loginRow = [[SimiRow alloc] initWithIdentifier:LEFTMENU_ROW_LOGIN height:SCP_LEFT_MENU_CELL_HEIGHT];
    loginRow.image = [UIImage imageNamed:@"scp_ic_account"];
    [section1 addRow:loginRow];
    SimiRow *rowNotification = [[SimiRow alloc]initWithIdentifier:LEFTMENU_ROW_NOTIFICATION height:SCP_LEFT_MENU_CELL_HEIGHT];
    rowNotification.image = [UIImage imageNamed:@"scp_ic_noti"];
    rowNotification.title = SCLocalizedString(@"Notifications");
    [section1 addObject:rowNotification];
    
    if (self.cmsPages.collectionData.count > 0) {
        for (int i = 0; i < self.cmsPages.collectionData.count; i++) {
            SimiRow *row20 = [[SimiRow alloc]initWithIdentifier:LEFTMENU_ROW_CMS height:SCP_LEFT_MENU_CELL_HEIGHT];
            SimiModel *cmsPage = [self.cmsPages objectAtIndex:i];
            row20.data = cmsPage.modelData;
            row20.title = [row20.data valueForKey:@"cms_title"];
            [section1 addObject:row20];
        }
    }
    
    SimiRow *settingRow = [[SimiRow alloc]initWithIdentifier:LEFTMENU_ROW_SETTING height:SCP_LEFT_MENU_CELL_HEIGHT sortOrder:10000];
    settingRow.image = [UIImage imageNamed:@"scp_ic_settings"];
    settingRow.title = SCLocalizedString(@"Setting");
    [section1 addRow:settingRow];
}


- (UITableViewCell *)contentTableViewCellForRowAtIndexPath:(NSIndexPath *)indexPath{
    SimiSection *section = [self.cells objectAtIndex:indexPath.section];
    SimiRow *row = [section objectAtIndex:indexPath.row];
    if ([row.identifier isEqualToString:LEFTMENU_ROW_LOGIN]) {
        return [self createLoginCellWithRow:row];
    }else if([row.identifier isEqualToString:SCP_LEFTMENU_ROW_ACCOUNT]){
        return [self createAccountCellForRow:row];
    }else{
        SCPLeftMenuCell *cell = [self createContentCellWithRow:row];
        return cell;
    }
}

- (SCPLeftMenuCell *)createContentCellWithRow:(SimiRow*)row {
    NSString *identifier = row.identifier;
    if ([row.identifier isEqualToString:LEFTMENU_ROW_CMS]) {
        identifier = [NSString stringWithFormat:@"%@_%@",LEFTMENU_ROW_CMS,[row.data valueForKey:@"cms_id"]];
    }
    SCPLeftMenuCell *cell = [self.contentTableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[SCPLeftMenuCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier row:row];
    }
    cell.accessoryType = row.accessoryType;
    return cell;
}

- (SCPLeftMenuCell *)createLoginCellWithRow:(SimiRow*)row {
    SCPLeftMenuCell *cell = [self.contentTableView dequeueReusableCellWithIdentifier:LEFTMENU_ROW_LOGIN];
    if (cell == nil) {
        cell = [[SCPLeftMenuCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:LEFTMENU_ROW_LOGIN row:row];
    }
    if (GLOBALVAR.isLogin) {
        [cell.rowName setText:SCLocalizedString(@"My Account")];
        cell.rowName.textColor = [UIColor blackColor];
        cell.rowIcon.image = [cell.rowIcon.image imageWithColor:SCP_ICON_COLOR];
        cell.contentView.backgroundColor = [UIColor clearColor];
    }else{
        [cell.rowName setText:SCLocalizedString(@"Sign In")];
        cell.rowName.textColor = SCP_BUTTON_TEXT_COLOR;
        cell.rowIcon.image = [cell.rowIcon.image imageWithColor:SCP_BUTTON_TEXT_COLOR];
        cell.contentView.backgroundColor = SCP_BUTTON_BACKGROUND_COLOR;
    }
    return cell;
}

- (SCPLeftMenuAccountCell *)createAccountCellForRow:(SimiRow *)row{
    SCPLeftMenuAccountCell *cell = [self.contentTableView dequeueReusableCellWithIdentifier:row.identifier];
    if(!cell){
        cell = [[SCPLeftMenuAccountCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:row.identifier width:tableWidth];
    }
    if(GLOBALVAR.isLogin){
        cell.customer = GLOBALVAR.customer;
    }else{
        cell.customer = nil;
    }
    return cell;
}
- (void)contentTableViewDidSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    SimiSection *section = [self.cells objectAtIndex:indexPath.section];
    SimiRow *row = [section objectAtIndex:indexPath.row];
    if(![row.identifier isEqualToString:SCP_LEFTMENU_ROW_ACCOUNT]){
        [kMainViewController hideLeftViewAnimated:YES completionHandler:^{
        }];
        
        if ([section.identifier isEqualToString:LEFTMENU_SECTION_MAIN]) {
            if([row.identifier isEqualToString:LEFTMENU_ROW_NOTIFICATION])
            {
                [[SCAppController sharedInstance]openNotificationHistoryScreenWithNavigationController:GLOBALVAR.currentlyNavigationController moreParams:@{}];
            }else if ([row.identifier isEqualToString:LEFTMENU_ROW_LOGIN]){
                if (!GLOBALVAR.isLogin) {
                    [[SCAppController sharedInstance]openLoginScreenWithNavigationController:GLOBALVAR.currentlyNavigationController moreParams:@{}];
                }else{
                    [[SCAppController sharedInstance]openMyAccountScreenWithNavigationController:GLOBALVAR.currentlyNavigationController moreParams:@{}];
                }
            }
        }
    }
}
@end
@implementation SCPLeftMenuAccountCell
{
    UIView *topView;
    UIView *accountView;
    UIImageView *avatarView;
    UIView *signInView;
    SCPLabel *nameLabel;
    UIButton *backButton;
}
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier width:(CGFloat)width{
    if(self == [super initWithStyle:style reuseIdentifier:reuseIdentifier]){
        float padding = 15;
        float contentWidth = width - 2*padding;
        topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, 64)];
        backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 64, 64)];
        [backButton setImage:[[UIImage imageNamed:@"scp_ic_back"] imageWithColor:SCP_ICON_COLOR] forState:UIControlStateNormal];
        backButton.imageEdgeInsets = UIEdgeInsetsMake(20, 20, 20, 20);
        [backButton addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
        [topView addSubview:backButton];
        [self.contentView addSubview:topView];
        accountView = [[UIView alloc] initWithFrame:CGRectMake(0, 64, width, contentWidth/3 + 2*padding)];
        avatarView = [[UIImageView alloc] initWithFrame:CGRectMake(padding + 10, padding + 10, contentWidth/3 - 20, contentWidth/3 - 20)];
        [avatarView setImage:[[UIImage imageNamed:@"scp_ic_user"] imageWithColor:[UIColor whiteColor]]];
        [accountView addSubview:avatarView];
        signInView = [[UIView alloc] initWithFrame:CGRectMake(padding + contentWidth/3, padding, 2*contentWidth/3, contentWidth/3)];
        [accountView addSubview:signInView];
        SCPLabel *signInLabel = [[SCPLabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(signInView.frame), CGRectGetHeight(signInView.frame)/2) andFontName:THEME_FONT_NAME_REGULAR andFontSize:FONT_SIZE_HEADER andTextColor:[UIColor blackColor] text:@"Not signed in"];
        [signInView addSubview:signInLabel];
        SCPLabel *infoLabel = [[SCPLabel alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(signInView.frame)/2, CGRectGetWidth(signInView.frame), CGRectGetHeight(signInView.frame)/2) andFontName:THEME_FONT_NAME andFontSize:FONT_SIZE_SMALL andTextColor:[UIColor blackColor] text:@"Use your account to track orders and more"];
        infoLabel.numberOfLines = 2;
        [signInView addSubview:infoLabel];
        nameLabel = [[SCPLabel alloc] initWithFrame:signInView.frame andFontName:THEME_FONT_NAME_REGULAR andFontSize:FONT_SIZE_HEADER andTextColor:[UIColor whiteColor]];
        [accountView addSubview:nameLabel];
        [self.contentView addSubview:accountView];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}
- (void)back:(id)sender{
    [kMainViewController hideLeftViewAnimated:YES completionHandler:^{
    }];
}
- (void)setCustomer:(SimiCustomerModel *)customer{
    _customer = customer;
    if(customer){
        [avatarView sd_setImageWithURL:[NSURL URLWithString:customer.url] placeholderImage:[UIImage imageNamed:@"scp_ic_user"]];
        nameLabel.text = [NSString stringWithFormat:@"%@ %@",customer.firstName, customer.lastName];
        nameLabel.textColor = SCP_BUTTON_TEXT_COLOR;
        nameLabel.hidden = NO;
        signInView.hidden = YES;
        [backButton setImage:[backButton.imageView.image imageWithColor:SCP_BUTTON_TEXT_COLOR] forState:UIControlStateNormal];
        self.contentView.backgroundColor = SCP_BUTTON_BACKGROUND_COLOR;
    }else{
        nameLabel.hidden = YES;
        signInView.hidden = NO;
        self.contentView.backgroundColor = COLOR_WITH_HEX(@"#F2F2F2");
        [backButton setImage:[backButton.imageView.image imageWithColor:[UIColor blackColor]] forState:UIControlStateNormal];
        [avatarView setImage:[[UIImage imageNamed:@"scp_ic_user"] imageWithColor:[UIColor whiteColor]]];
    }
}

@end
@implementation SCPLeftMenuCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier row:(SimiRow *)row{
    float cellWidth = 3*SCREEN_WIDTH/4;
    if(PADDEVICE){
        cellWidth = 328;
    }
    float iconSize = 20;
    float iconOrigionX = cellWidth/4;
    float distanceIconandName = 25;
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    self.rowIcon = [[UIImageView alloc]initWithFrame:CGRectMake(iconOrigionX, (row.height - iconSize)/2, iconSize, iconSize)];
    if (row.image) {
        self.rowIcon.image = [row.image imageWithColor:SCP_ICON_COLOR];
    }else if(row.data){
        if ([[row.data valueForKey:@"icon"] isKindOfClass:[NSString class]]) {
            [self.rowIcon sd_setImageWithURL:[NSURL URLWithString:[row.data valueForKey:@"icon"]]];
        }
        if ([[row.data valueForKey:@"cms_image"] isKindOfClass:[NSString class]]) {
            [self.rowIcon sd_setImageWithURL:[NSURL URLWithString:[row.data valueForKey:@"cms_image"]]];
        }
    }
    [self.contentView addSubview:self.rowIcon];
    CGRect rowNameFrame = CGRectZero;
    rowNameFrame.origin.x = iconOrigionX + iconSize + distanceIconandName;
    rowNameFrame.origin.y = (row.height - iconSize)/2;
    rowNameFrame.size.width = cellWidth - rowNameFrame.origin.x - 30;
    rowNameFrame.size.height = iconSize;
    
    self.rowName = [[SimiLabel alloc]initWithFrame:rowNameFrame andFontName:THEME_FONT_NAME_REGULAR andFontSize:FONT_SIZE_LARGE andTextColor:SCP_ICON_COLOR];
    [self.rowName setText:row.title];
    [self.contentView addSubview:self.rowName];
    [SimiGlobalFunction sortViewForRTL:self.contentView andWidth:cellWidth];
    self.contentView.backgroundColor = [UIColor clearColor];
    self.backgroundColor = [UIColor clearColor];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    return self;
}
@end

