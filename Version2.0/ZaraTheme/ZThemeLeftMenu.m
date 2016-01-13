//
//  ZThemeLeftMenu.m
//  SimiCartPluginFW
//
//  Created by Nghieply91 on 5/12/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import "ZThemeLeftMenu.h"
#import <SimiCartBundle/UIImage+SimiCustom.h>
#import <SimiCartBundle/UIImageView+WebCache.h>
#import <SimiCartBundle/SimiTableView.h>
#import <SimiCartBundle/SimiTable.h>

@implementation ZThemeLeftMenu

#pragma mark Init List Menu
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        tableWidth = 275;
        sizeIcon = 25;
        recentHeight = 80;
        recentTilteHeight = 20;
        loginHeight = 40;
        self.isFirstShow = YES;
        
        self.tableViewMenu = [[UITableView alloc]initWithFrame:CGRectMake(0, 20, tableWidth, frame.size.height) style:UITableViewStylePlain];
        self.tableViewMenu.contentInset = UIEdgeInsetsMake(0, 0, -1, 0);
        self.tableViewMenu.delegate = self;
        self.tableViewMenu.dataSource = self;
        self.tableViewMenu.scrollEnabled = YES;
        self.tableViewMenu.separatorColor = [UIColor grayColor];
        self.tableViewMenu.backgroundColor = [UIColor whiteColor];
        self.backgroundColor = THEME_COLOR;
        [self addSubview:self.tableViewMenu];
        
        if (_btnLogin == nil) {
            _btnLogin = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 0, 0)];
            [_btnLogin.titleLabel setTextAlignment:NSTextAlignmentCenter];
            [_btnLogin setBackgroundColor:[[SimiGlobalVar sharedInstance]colorWithHexString:@"#4d4d4d"]];
            [_btnLogin setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            if ([[SimiGlobalVar sharedInstance]isLogin]) {
                [_btnLogin setTitle:SCLocalizedString(@"Sign out") forState:UIControlStateNormal];
            }else
            {
                [_btnLogin setTitle:SCLocalizedString(@"Sign in") forState:UIControlStateNormal];
            }
            [_btnLogin addTarget:self action:@selector(didTouchSignInButton) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:_btnLogin];
        }
        
        if (_lblRecent == nil) {
            _lblRecent = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 0, 0)];
            [_lblRecent setFont:[UIFont fontWithName:ZTHEME_FONT_NAME_REGULAR size:12]];
            [_lblRecent setText:[SCLocalizedString(@"Recently viewed")uppercaseString]];
            [self addSubview:_lblRecent];
            [_lblRecent setHidden:YES];
        }
        
        if (_collectionRecentView == nil) {
            UICollectionViewLayout *layout = [[UICollectionViewLayout alloc]init];
            _collectionRecentView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, 0, 0) collectionViewLayout:layout];
            _collectionRecentView.dataSource = self;
            _collectionRecentView.delegate = self;
            [self addSubview:_collectionRecentView];
            [_collectionRecentView setHidden:YES];
        }
        
        [self cusSetCells:nil];
        [self getCMSPages];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"ApplicationWillResignActive" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"DidGetStoreCollection" object:nil];
        [[SimiGlobalVar sharedInstance] addObserver:self forKeyPath:@"isLogin" options:NSKeyValueObservingOptionNew context:nil];
    }
    return self;
}

#pragma mark Notification Action

- (void)getCMSPages{
    self.cmsPages = [[SimiModelCollection alloc] init];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"DidGetCMSPages" object:self.cmsPages];
    [self.cmsPages getCMSPagesWithParams:nil];
}

-(void)didReceiveNotification:(NSNotification *)noti
{
    if ([noti.name isEqualToString:@"ApplicationWillResignActive"]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"ApplicationDidBecomeActive" object:nil];
        [self removeObserverForNotification:noti];
    }else if ([noti.name isEqualToString:@"ApplicationDidBecomeActive"]){
        [self cusSetCells:nil];
        [self getCMSPages];
        [self removeObserverForNotification:noti];
    }else if ([noti.name isEqualToString:@"DidGetCMSPages"]) {
        [self removeObserverForNotification:noti];
        [self cusSetCells:nil];
    }else if ([noti.name isEqualToString:@"DidGetStoreCollection"])
    {
        SimiResponder *responder = (SimiResponder *)[noti.userInfo valueForKey:@"responder"];
        if ([responder.status isEqualToString:@"SUCCESS"]) {
            _stores = noti.object;
            [self cusSetCells:nil];
        }
    }
}

#pragma mark Configure Data Table View

- (UIView*)setTableCell:(SimiRow *)row
{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, tableWidth, row.height)];
    view.backgroundColor = [UIColor clearColor];
    
    UIImageView *imgView = [[UIImageView alloc]initWithFrame:CGRectMake(15, (row.height - sizeIcon)/2, sizeIcon, sizeIcon)];
    if(row.image)
    {
        imgView.image = [row.image imageWithColor:[[SimiGlobalVar sharedInstance] colorWithHexString:@"#474545"]];
    }else
    {
        if ([row.data valueForKey:@"icon"]){
            NSString *url = [row.data valueForKey:@"icon"];
            [imgView sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"cell_placeholder"] options:SDWebImageRetryFailed];
        }
    }
    UILabel *lblText = [[UILabel alloc]initWithFrame:CGRectMake(20 + sizeIcon, (row.height - sizeIcon)/2, 200, sizeIcon)];
    [lblText setTextColor:[[SimiGlobalVar sharedInstance] colorWithHexString:@"#474545"]];
    [lblText setFont:[UIFont fontWithName:ZTHEME_FONT_NAME_LIGHT size:THEME_FONT_SIZE - 2]];
    [lblText setText:SCLocalizedString(row.title)];
    [lblText setBackgroundColor:[UIColor clearColor]];
    //  Liam Update RTL
    if ([SimiGlobalVar sharedInstance].isReverseLanguage) {
        [lblText setTextAlignment:NSTextAlignmentRight];
    }
    //  End RTL
    
    [view addSubview:imgView];
    [view addSubview:lblText];
    return view;
}


- (void)cusSetCells:(SimiTable *)cells
{
    if (cells) {
        self.cells = cells;
    }else
    {
        self.cells = [SimiTable new];
        SimiSection *sectionMain = [[SimiSection alloc]initWithHeaderTitle:nil footerTitle:nil];
        sectionMain.identifier = ZTHEME_SECTION_MAIN;
        
        SimiRow *row01 = [[SimiRow alloc]initWithIdentifier:ZTHEME_ROW_HOME height:ZTHEME_LEFTMENU_ROWHEIGT];
        row01.title = @"Home";
        row01.image = [UIImage imageNamed:@"ztheme_ic_home"];
        [sectionMain addRow:row01];
        
        SimiRow *row02 = [[SimiRow alloc]initWithIdentifier:ZTHEME_ROW_CATEGORY height:ZTHEME_LEFTMENU_ROWHEIGT];
        row02.title = @"Category";
        row02.image = [UIImage imageNamed:@"ztheme_ic_category"];
        [sectionMain addRow:row02];
        
        if (_stores.count > 1) {
            SimiRow *row03 = [[SimiRow alloc]initWithIdentifier:ZTHEME_ROW_STOREVIEW height:ZTHEME_LEFTMENU_ROWHEIGT];
            row03.title = @"Store View";
            row03.image = [UIImage imageNamed:@"ztheme_ic_storeview"];
            [sectionMain addRow:row03];
        }
        
        [self.cells addObject:sectionMain];
        
        
        if ([[SimiGlobalVar sharedInstance] isLogin]) {
            SimiSection *sectionMyAccount = [[SimiSection alloc]initWithHeaderTitle:SCLocalizedString(@"My Account")  footerTitle:nil];
            sectionMyAccount.identifier = ZTHEME_SECTION_MYACCOUNT;
            SimiRow *row11 = [[SimiRow alloc]initWithIdentifier:ZTHEME_ROW_PROFILE height:ZTHEME_LEFTMENU_ROWHEIGT];
            row11.title = @"Profile";
            row11.image = [UIImage imageNamed:@"ztheme_ic_profile"];
            row11.accessoryType = UITableViewCellAccessoryNone;
            [sectionMyAccount addRow:row11];
            
            SimiRow *row12 = [[SimiRow alloc]initWithIdentifier:ZTHEME_ROW_ADDRESSBOOK height:ZTHEME_LEFTMENU_ROWHEIGT];
            row12.title = @"Address Book";
            row12.image = [UIImage imageNamed:@"ztheme_ic_address"];
            row12.accessoryType = UITableViewCellAccessoryNone;
            [sectionMyAccount addRow:row12];
            
            SimiRow *row13 = [[SimiRow alloc]initWithIdentifier:ZTHEME_ROW_ORDERHISTORY height:ZTHEME_LEFTMENU_ROWHEIGT];
            row13.title = SCLocalizedString(@"Order History");
            row13.image = [UIImage imageNamed:@"ztheme_ic_orderhistory"];
            row13.accessoryType = UITableViewCellAccessoryNone;
            [sectionMyAccount addRow:row13];
            
            [self.cells addObject:sectionMyAccount];
        }
        
        
        SimiSection *section1 = [[SimiSection alloc] initWithHeaderTitle:SCLocalizedString(@"More") footerTitle:nil];
        section1.identifier = ZTHEME_SECTION_MORE;
        if (_cmsPages.count > 0) {
            for (int i = 0; i < _cmsPages.count; i++) {
                SimiRow *row = [[SimiRow alloc] init];
                row.identifier = ZTHEME_ROW_CMS;
                row.height = 45;
                row.title = [[_cmsPages objectAtIndex:i] valueForKey:@"title"];
                [row setData:[_cmsPages objectAtIndex:i]];
                row.accessoryType = UITableViewCellAccessoryNone;
                [section1 addRow:row];
            }
        }
        [self.cells addObject:section1];
        
        SimiSection *section3 = [[SimiSection alloc]initWithHeaderTitle:SCLocalizedString(@"Setting") footerTitle:nil];
        section3.identifier = ZTHEME_SECTION_SETTING;
        SimiRow *row30 = [[SimiRow alloc]initWithIdentifier:ZTHEME_ROW_SETTINGAPP height:ZTHEME_LEFTMENU_ROWHEIGT];
        row30.image = [UIImage imageNamed:@"ztheme_ic_setting"];
        row30.title = SCLocalizedString(@"App Setting");
        row30.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        [section3 addRow:row30];
        [self.cells addObject:section3];
    }
    [[NSNotificationCenter defaultCenter]postNotificationName:@"SCListMenu_Theme01-InitCellsAfter" object:self.cells];
    [self.tableViewMenu reloadData];
}

#pragma mark TableView DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return _cells.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SimiSection *section = [_cells objectAtIndex:indexPath.section];
    SimiRow *row = [section objectAtIndex:indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:row.identifier];
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:row.identifier];
    cell.backgroundColor = [UIColor whiteColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryType = row.accessoryType;
    [cell addSubview:[self setTableCell:row]];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    SimiSection *simiSection = [_cells objectAtIndex:section];
    return simiSection.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SimiSection *section = [_cells objectAtIndex:indexPath.section];
    SimiRow *row = [section objectAtIndex:indexPath.row];
    return row.height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(section == 0){
        return 45;
    }
    return 20;
}


- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, tableWidth, 30)];
    SimiSection *simiSection = [_cells objectAtIndex:section];
    if(section == 0){
        view.backgroundColor = THEME_COLOR;
        //    Logo
        UIImageView *imgLogo = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 220, 40)];
        imgLogo.contentMode = UIViewContentModeScaleAspectFit;
        imgLogo.image = [UIImage imageNamed:@"logo"];
        [view addSubview:imgLogo];
        
        //    List menu
        _imgListMenu = [[UIImageView alloc]initWithFrame:CGRectMake(230, 8, 32, 32)];
        [_imgListMenu setImage:[UIImage imageNamed:@"Ztheme_icon_menu"]];
        [view addSubview:_imgListMenu];
        UIButton *buttonListMenu = [[UIButton alloc]init];
        buttonListMenu.frame = _imgListMenu.frame;
        [buttonListMenu addTarget:self action:@selector(didClickHide) forControlEvents:UIControlEventTouchUpInside];
        buttonListMenu.tag = 103;
        [view addSubview:buttonListMenu];
        return view;
    }else{
        
        UILabel *headerTitleSection = [[UILabel alloc]initWithFrame:CGRectMake(5, 0, tableView.bounds.size.width - 10, 20)];
        headerTitleSection.text = simiSection.headerTitle;
        //  Liam Update RTL
        if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
            [headerTitleSection setTextAlignment:NSTextAlignmentRight];
        }
        //  End RTL
        [headerTitleSection setFont:[UIFont fontWithName:ZTHEME_FONT_NAME_REGULAR size:12]];
        [headerTitleSection setTextColor:[UIColor blackColor]];
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 20)];
        [headerView setBackgroundColor:[[SimiGlobalVar sharedInstance]colorWithHexString:@"#dbdbdb"]];
        [headerView addSubview:headerTitleSection];
        
        return headerView;
    }
}

#pragma mark Table Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SimiSection *section = [_cells objectAtIndex:indexPath.section];
    SimiRow *row = [section objectAtIndex:indexPath.row];
    if ([section.identifier isEqualToString:ZTHEME_SECTION_SETTING]) {
        if ([row.identifier isEqualToString:ZTHEME_ROW_SETTINGAPP]) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        }
    }
    [self.delegate menu:self didSelectRow:row withIndexPath:indexPath];
    [self didClickHide];
}

#pragma mark Action Touch
- (void)didClickShow
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    _arrayRecentProducts = (NSMutableArray*)[defaults objectForKey:@"Recent Products"];
    if (_arrayRecentProducts.count > 0) {
        self.haveRecentProducts = YES;
    }
    
    CGRect frame = self.frame;
    frame.size.height = [[UIScreen mainScreen] bounds].size.height;
    self.frame = frame;
    frame = self.tableViewMenu.frame;
    if (self.haveRecentProducts) {
        frame.size.height = self.frame.size.height - loginHeight -recentHeight - recentTilteHeight - 20;
    }else
    {
        frame.size.height = self.frame.size.height - loginHeight - 20;
    }
    self.tableViewMenu.frame = frame;
    if (self.isFirstShow) {
        [_btnLogin setFrame:CGRectMake(0, self.frame.size.height - loginHeight, CGRectGetWidth(frame), loginHeight)];
        [_lblRecent setFrame:CGRectMake(5, CGRectGetHeight(self.frame) - loginHeight - recentHeight - recentTilteHeight, CGRectGetWidth(self.frame) - 5, recentTilteHeight)];
        [_collectionRecentView setFrame:CGRectMake(0, CGRectGetHeight(self.frame) - loginHeight - recentHeight, CGRectGetWidth(self.frame), recentHeight)];
        UICollectionViewFlowLayout *grid = [[UICollectionViewFlowLayout alloc]init];
        [grid setScrollDirection:UICollectionViewScrollDirectionHorizontal];
        grid.itemSize = CGSizeMake(52.25, 70);
        grid.minimumInteritemSpacing = 10;
        grid.minimumLineSpacing = 7;
        [self.collectionRecentView setCollectionViewLayout:grid animated:YES];
        [self.collectionRecentView setContentInset:UIEdgeInsetsMake(5, 0, 5, 7)];
        self.collectionRecentView.showsVerticalScrollIndicator = NO;
        [self.collectionRecentView setBackgroundColor:[UIColor whiteColor]];
    }
    
    if (self.haveRecentProducts) {
        [self.lblRecent setHidden:NO];
        [self.collectionRecentView setHidden:NO];
        [_collectionRecentView reloadSections:[[NSIndexSet alloc]initWithIndex:0]];
        [self.collectionRecentView setContentSize:CGSizeMake(_arrayRecentProducts.count * 62.25, 70)];
    }else
    {
        [self.lblRecent setHidden:YES];
        [self.collectionRecentView setHidden:YES];
    }
    
    [UIView animateWithDuration:0.2
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         CGRect frame = self.frame;
                         frame.origin.x += self.tableViewMenu.frame.size.width;
                         self.frame = frame;
                     }
                     completion:^(BOOL finished) {
                         [self.delegate menu:self didClickShowButonWithShow:YES];
                     }];
}

- (void)didClickHide
{
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    [UIView animateWithDuration:0.2
                          delay:0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         CGRect frame = self.frame;
                         frame.origin.x -= self.tableViewMenu.frame.size.width;
                         self.frame = frame;
                     }
                     completion:^(BOOL finished) {
                         CGRect frame = self.frame;
                         frame.size.height = 1;
                         self.frame = frame;
                         
                         frame = self.tableViewMenu.frame;
                         frame.size.height = self.frame.size.height;
                         self.tableViewMenu.frame = frame;
                         [self.delegate menu:self didClickShowButonWithShow:NO];
                         [[UIApplication sharedApplication] endIgnoringInteractionEvents];
                     }];
}

- (void)didTouchSignInButton
{
    [self didClickHide];
    [self.delegate didTouchSignInButton];
}

#pragma mark UICollection Delegate, Datasource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _arrayRecentProducts.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    SimiProductModel *productModel = [self.arrayRecentProducts objectAtIndex:indexPath.row];
    NSString *stringCell = [NSString stringWithFormat:@"CELL_ID%@",[productModel valueForKey:@"product_id"]];
    [collectionView registerClass:[ZThemeLeftMenuCollectionViewCell class] forCellWithReuseIdentifier:stringCell];
    ZThemeLeftMenuCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:stringCell forIndexPath:indexPath];
    [cell cusSetProductModel:productModel];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self didClickHide];
    NSMutableDictionary *productModel = [self.arrayRecentProducts objectAtIndex:indexPath.row];
    [self.delegate didSelectRecentProductWithProductModel:productModel];
}

#pragma mark Observer Action

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if ([keyPath isEqualToString:@"isLogin"]) {
        if([[SimiGlobalVar sharedInstance]isLogin])
        {
            [_btnLogin setTitle:SCLocalizedString(@"Sign Out") forState:UIControlStateNormal];
        }else
        {
            [_btnLogin setTitle:SCLocalizedString(@"Sign In") forState:UIControlStateNormal];
        }
        [self cusSetCells:nil];
    }
}
@end


#pragma mark Create New Collection Cell
@implementation ZThemeLeftMenuCollectionViewCell

- (void)cusSetProductModel:(SimiProductModel *)productModel_
{
    if (![_productModel isEqual:productModel_]) {
        _productModel = productModel_;
        _productImage = [[UIImageView alloc]initWithFrame:self.bounds];
        NSString *firstImage = [(NSMutableArray*)[productModel_ valueForKey:@"product_images"] objectAtIndex:0];
        [_productImage sd_setImageWithURL:[NSURL URLWithString:firstImage ] placeholderImage:[UIImage imageNamed:@"logo"]];
        [_productImage setContentMode:UIViewContentModeScaleAspectFit];
        [self addSubview:_productImage];
    }
}
@end

