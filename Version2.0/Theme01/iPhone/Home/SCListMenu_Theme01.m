//
//  SCListMenu_Theme01.m
//  SimiCartPluginFW
//
//  Created by Nghieply91 on 8/12/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import <SimiCartBundle/UIImage+SimiCustom.h>
#import <SimiCartBundle/UIImageView+WebCache.h>
#import <SimiCartBundle/SimiTableView.h>
#import <SimiCartBundle/SimiTable.h>

#import "SCListMenu_Theme01.h"
#import "SimiGlobalVar+Theme01.h"
#import "SimiThemeWorker.h"

@interface SCListMenu_Theme01 ()

@end

@implementation SCListMenu_Theme01
{
    CGFloat tableWidth;
    CGFloat sizeIcon;
    UIButton *buttonStore;
    UIButton *buttonHome;
    UIButton *buttonCate;
}

#pragma mark Init List Menu
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        tableWidth = 275;
        sizeIcon = 32;
        _tableViewMenu = [[UITableView alloc]initWithFrame:CGRectMake(0, 20, tableWidth, frame.size.height) style:UITableViewStylePlain];
        _tableViewMenu.contentInset = UIEdgeInsetsMake(0, 0, 20, 0);
        _tableViewMenu.delegate = self;
        _tableViewMenu.dataSource = self;
        _tableViewMenu.scrollEnabled = YES;
        _tableViewMenu.separatorColor = [UIColor colorWithWhite:1.0 alpha:0.1];
        _tableViewMenu.backgroundColor = [UIColor colorWithRed:15.0/255 green:23.0/255 blue:33.0/255 alpha:1.0];
        self.backgroundColor = [UIColor colorWithRed:15.0/255 green:23.0/255 blue:33.0/255 alpha:1.0];
        [_tableViewMenu setShowsVerticalScrollIndicator:NO];
        [self addSubview:_tableViewMenu];
        [self setCells:nil];
        [self getCMSPages];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"ApplicationWillResignActive" object:nil];
        [[SimiGlobalVar sharedInstance] addObserver:self forKeyPath:@"customer" options:NSKeyValueObservingOptionNew context:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"DidGetStoreCollection" object:nil];
    }
    return self;
}

- (void)setSelfController:(UIViewController *)selfController_
{
    _selfController = selfController_;
}

- (void)getCMSPages{
    _cmsPages = [[SimiModelCollection alloc] init];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"DidGetCMSPages" object:_cmsPages];
    [_cmsPages getCMSPagesWithParams:nil];
}

- (UIView*)setOtherCell:(SimiRow *)row
{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, tableWidth, row.height)];
    view.backgroundColor = [UIColor clearColor];
    
    UIImageView *imgView = [[UIImageView alloc]initWithFrame:CGRectMake(215, (row.height - sizeIcon)/2, sizeIcon, sizeIcon)];
    if(row.image)
    {
        imgView.image = row.image;
        if ([row.identifier isEqualToString:@"StoreLocator"]) {
            imgView.image = [imgView.image imageWithColor:[UIColor whiteColor]];
        }
    }else
    {
        if ([row.data valueForKey:@"icon"]){
            NSString *url = [row.data valueForKey:@"icon"];
            [imgView sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"cell_placeholder"] options:SDWebImageRetryFailed];
            imgView.image = [imgView.image imageWithColor:[UIColor whiteColor]];
        }
    }
    imgView.alpha = 0.5;
    UILabel *lblText = [[UILabel alloc]initWithFrame:CGRectMake(15, (row.height - sizeIcon)/2, 190, sizeIcon)];
    [lblText setTextColor:[UIColor whiteColor]];
    [lblText setAlpha:0.5];
    [lblText setFont:[UIFont fontWithName:THEME_FONT_NAME size:THEME_FONT_SIZE - 2]];
    [lblText setText:SCLocalizedString(row.title)];
    [lblText setBackgroundColor:[UIColor clearColor]];
    //  Liam Update RTL
    if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
        [lblText setTextAlignment:NSTextAlignmentRight];
    }
    //  End RTL
    
    [view addSubview:imgView];
    [view addSubview:lblText];
    return view;
}

- (UIView*)setMainCell:(SimiRow*)row
{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, tableWidth, row.height)];
    view.backgroundColor = [UIColor clearColor];
    
    //    Search
    _searchBar = [[UISearchBar alloc] init];
    _searchBar.frame = CGRectMake(2, 20, tableWidth - 10, 40);
    _searchBar.placeholder = SCLocalizedString(@"Search");
    _searchBar.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _searchBar.delegate = self;
    _searchBar.barTintColor = [UIColor colorWithRed:15.0/255 green:23.0/255 blue:33.0/255 alpha:1.0];
    [view addSubview:_searchBar];
    
    
//    Home
    _imgHome = [[UIImageView alloc]initWithFrame:CGRectMake(20, 90, 45, 45)];
    [_imgHome setImage:[UIImage imageNamed:@"theme1_icon_home"]];
    [_imgHome setAlpha:0.5];
    [view addSubview:_imgHome];
    
    buttonHome = [[UIButton alloc]init];
    buttonHome.frame = _imgHome.frame;
    [buttonHome addTarget:self action:@selector(buttonTouchDown:) forControlEvents:UIControlEventTouchDown];
    [buttonHome addTarget:self action:@selector(buttonTouchUpInSide:) forControlEvents:UIControlEventTouchUpInside];
    buttonHome.tag = 100;
    [view addSubview:buttonHome];
    
    _lblHome = [[UILabel alloc]initWithFrame:CGRectMake(10, 130, 65, 30)];
    [_lblHome setFont:[UIFont fontWithName:THEME_FONT_NAME size:THEME_FONT_SIZE - 2]];
    [_lblHome setAlpha:0.5];
    [_lblHome setTextAlignment:NSTextAlignmentCenter];
    [_lblHome setText:SCLocalizedString(@"Home")];
    [_lblHome setTextColor:[UIColor whiteColor]];
    [view addSubview:_lblHome];
    
//    Category
    _imgCate = [[UIImageView alloc]initWithFrame:CGRectMake(110, 90, 45, 45)];
    [_imgCate setImage:[UIImage imageNamed:@"theme1_icon_cate"]];
    [_imgCate setAlpha:0.5];
    [view addSubview:_imgCate];
    
    buttonCate = [[UIButton alloc]init];
    buttonCate.frame = _imgCate.frame;
    [buttonCate addTarget:self action:@selector(buttonTouchDown:) forControlEvents:UIControlEventTouchDown];
    [buttonCate addTarget:self action:@selector(buttonTouchUpInSide:) forControlEvents:UIControlEventTouchUpInside];
    buttonCate.tag = 101;
    [view addSubview:buttonCate];
    
    _lblCate = [[UILabel alloc]initWithFrame:CGRectMake(100, 130, 65, 30)];
    [_lblCate setFont:[UIFont fontWithName:THEME_FONT_NAME size:THEME_FONT_SIZE - 2]];
    [_lblCate setAlpha:0.5];
    [_lblCate setTextAlignment:NSTextAlignmentCenter];
    [_lblCate setText:SCLocalizedString(@"Category")];
    [_lblCate setTextColor:[UIColor whiteColor]];
    [view addSubview:_lblCate];
    
//    StoreView
    _imgStoreView = [[UIImageView alloc]initWithFrame:CGRectMake(200, 90, 45, 45)];
    [_imgStoreView setImage:[UIImage imageNamed:@"theme1_icon_store"]];
    [_imgStoreView setAlpha:0.5];
    [view addSubview:_imgStoreView];
    
    buttonStore = [[UIButton alloc]init];
    buttonStore.frame = _imgStoreView.frame;
    [buttonStore addTarget:self action:@selector(buttonTouchDown:) forControlEvents:UIControlEventTouchDown];
    [buttonStore addTarget:self action:@selector(buttonTouchUpInSide:) forControlEvents:UIControlEventTouchUpInside];
    buttonStore.tag = 102;
    [view addSubview:buttonStore];
    
    _lblStoreView = [[UILabel alloc]initWithFrame:CGRectMake(180, 130, 85, 30)];
    [_lblStoreView setFont:[UIFont fontWithName:THEME_FONT_NAME size:THEME_FONT_SIZE -2]];
    [_lblStoreView setAlpha:0.5];
    [_lblStoreView setTextAlignment:NSTextAlignmentCenter];
    [_lblStoreView setText:SCLocalizedString(@"Store View")];
    [_lblStoreView setTextColor:[UIColor whiteColor]];
    [view addSubview:_lblStoreView];
    
    [self hiddenStoreViewWhenHasOnlyStore];
    
    return view;
}

- (void)setCells:(SimiTable *)cells
{
    if (cells) {
        _cells = cells;
    }else
    {
        _cells = [SimiTable new];
        SimiSection *sectionMain = [[SimiSection alloc]initWithHeaderTitle:nil footerTitle:nil];
        sectionMain.identifier = THEME01_LISTMENU_SECTION_MAIN;
        
        SimiRow *row01 = [[SimiRow alloc]initWithIdentifier:THEME01_LISTMENU_ROW_MAIN height:190];
        [sectionMain addRow:row01];
        [_cells addObject:sectionMain];
        
        SimiSection *sectionMyAccount = [[SimiSection alloc]initWithHeaderTitle:SCLocalizedString(@"My Account")  footerTitle:nil];
        sectionMyAccount.identifier = THEME01_LISTMENU_SECTION_MYACCOUNT;
        SimiRow *row11 = [[SimiRow alloc]initWithIdentifier:THEME01_LISTMENU_ROW_PROFILE height:45];
        row11.title = @"Profile";
        row11.image = [UIImage imageNamed:@"theme1_icon_profile"];
        row11.accessoryType = UITableViewCellAccessoryNone;
        [sectionMyAccount addRow:row11];
        
        SimiRow *row12 = [[SimiRow alloc]initWithIdentifier:THEME01_LISTMENU_ROW_ADDRESS height:45];
        row12.title = @"Address Book";
        row12.image = [UIImage imageNamed:@"theme1_icon_address"];
        row12.accessoryType = UITableViewCellAccessoryNone;
        [sectionMyAccount addRow:row12];
        
        SimiRow *row13 = [[SimiRow alloc]initWithIdentifier:THEME01_LISTMENU_ROW_ORDERHISTORY height:45];
        row13.title = SCLocalizedString(@"Order History");
        row13.image = [UIImage imageNamed:@"theme1_icon_history"];
        row13.accessoryType = UITableViewCellAccessoryNone;
        [sectionMyAccount addRow:row13];
        
        [_cells addObject:sectionMyAccount];
        
        SimiSection *section1 = [[SimiSection alloc] initWithHeaderTitle:SCLocalizedString(@"More") footerTitle:nil];
        section1.identifier = THEME01_LISTMENU_SECTION_MORE;
        if (_cmsPages.count > 0) {
            for (int i = 0; i < _cmsPages.count; i++) {
                SimiRow *row = [[SimiRow alloc] init];
                row.identifier = THEME01_LISTMENU_ROW_CMS;
                row.height = 45;
                row.title = [[_cmsPages objectAtIndex:i] valueForKey:@"title"];
                [row setData:[_cmsPages objectAtIndex:i]];
                row.accessoryType = UITableViewCellAccessoryNone;
                [section1 addRow:row];
            }
        }
        SimiRow *row21 = [[SimiRow alloc]init];
        row21.identifier = THEME01_LISTMENU_ROW_SIGNIN;
        row21.height = 45;
        if (![[SimiGlobalVar sharedInstance]isLogin]) {
            
            row21.title = SCLocalizedString(@"Sign In");
            row21.image = [UIImage imageNamed:@"theme1_icon_signin"];
        }else
        {
            row21.title = SCLocalizedString(@"Sign Out");
            row21.image = [UIImage imageNamed:@"theme1_log_out"];
        }
        [section1 addObject:row21];
        [_cells addObject:section1];
        
        SimiSection *section3 = [[SimiSection alloc]initWithHeaderTitle:SCLocalizedString(@"Setting") footerTitle:nil];
        section3.identifier = THEME01_LISTMENU_SECTION_SETTING;
        SimiRow *row30 = [[SimiRow alloc]initWithIdentifier:THEME01_LISTMENU_ROW_SETTING height:40];
        row30.title = SCLocalizedString(@"App setting");
        row30.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        [section3 addRow:row30];
        [_cells addObject:section3];
    }
    [[NSNotificationCenter defaultCenter]postNotificationName:@"SCListMenu_Theme01-InitCellsAfter" object:_cells];
}

-(void)didReceiveNotification:(NSNotification *)noti
{
    if ([noti.name isEqualToString:@"ApplicationWillResignActive"]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"ApplicationDidBecomeActive" object:nil];
        [self removeObserverForNotification:noti];
    }else if ([noti.name isEqualToString:@"ApplicationDidBecomeActive"]){
        [self setCells:nil];
        [_tableViewMenu reloadData];
        [self getCMSPages];
        [self removeObserverForNotification:noti];
    }else if ([noti.name isEqualToString:@"DidGetCMSPages"]) {
        [self removeObserverForNotification:noti];
        [self setCells:nil];
        [_tableViewMenu reloadData];
    }else if ([noti.name isEqualToString:@"DidGetStoreCollection"])
    {
        SimiResponder *responder = (SimiResponder *)[noti.userInfo valueForKey:@"responder"];
        if ([responder.status isEqualToString:@"SUCCESS"]) {
            _stores = noti.object;
            [self hiddenStoreViewWhenHasOnlyStore];
        }
    }
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
    cell.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryType = row.accessoryType;
    if ([row.identifier isEqualToString: THEME01_LISTMENU_ROW_MAIN]) {
        [cell addSubview:[self setMainCell:row]];
        UITapGestureRecognizer *hiddenKeyBoardRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hiddenKeyBoard:)];
        [cell addGestureRecognizer:hiddenKeyBoardRecognizer];
    }else
    {
        [cell addSubview:[self setOtherCell:row]];
    }
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
    return 30;
}


- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, tableWidth, 40)];
    //view.backgroundColor = [UIColor clearColor];
    view.backgroundColor = [UIColor colorWithRed:15.0/255 green:23.0/255 blue:33.0/255 alpha:1.0];
    SimiSection *simiSection = [_cells objectAtIndex:section];
    if(section == 0){
        //    Logo
        UIImageView *imgLogo = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 220, 40)];
        imgLogo.contentMode = UIViewContentModeScaleAspectFit;
        imgLogo.image = [UIImage imageNamed:@"logo"];
        [view addSubview:imgLogo];
        
        //    List menu
        _imgListMenu = [[UIImageView alloc]initWithFrame:CGRectMake(230, 8, 32, 32)];
        [_imgListMenu setImage:[UIImage imageNamed:@"theme1_icon_menu"]];
        [view addSubview:_imgListMenu];
        UIButton *buttonListMenu = [[UIButton alloc]init];
        buttonListMenu.frame = _imgListMenu.frame;
        [buttonListMenu addTarget:self action:@selector(buttonTouchDown:) forControlEvents:UIControlEventTouchDown];
        [buttonListMenu addTarget:self action:@selector(buttonTouchUpInSide:) forControlEvents:UIControlEventTouchUpInside];
        buttonListMenu.tag = 103;
        [view addSubview:buttonListMenu];
        UITapGestureRecognizer *hiddenKeyBoardRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hiddenKeyBoard:)];
        [view addGestureRecognizer:hiddenKeyBoardRecognizer];
        return view;
    }else{
        UILabel *headerTitleSection = [[UILabel alloc]initWithFrame:CGRectMake(5, 0, tableView.bounds.size.width - 10, 30)];
        headerTitleSection.text = simiSection.headerTitle;
        [headerTitleSection setFont:[UIFont fontWithName:THEME01_FONT_NAME_REGULAR size:15]];
        [headerTitleSection setTextColor:[UIColor whiteColor]];
        //  Liam Update RTL
        if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
            [headerTitleSection setTextAlignment:NSTextAlignmentRight];
        }
        //  End RTL
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 45)];
        [headerView setBackgroundColor:[[SimiGlobalVar sharedInstance] colorWithHexString:@"#273039"]];
        [headerView addSubview:headerTitleSection];
        UITapGestureRecognizer *hiddenKeyBoardRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hiddenKeyBoard:)];
        [headerView addGestureRecognizer:hiddenKeyBoardRecognizer];
        return headerView;
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if ([keyPath isEqualToString:@"customer"]) {
        for (int i = 0; i< _cells.count; i++) {
            SimiSection *section = [_cells objectAtIndex:i];
            if ([section.identifier isEqualToString:THEME01_LISTMENU_SECTION_MORE]) {
                for (int j = 0; j < section.count; j++) {
                    SimiRow *row = [section objectAtIndex:j];
                    if ([row.identifier isEqualToString:THEME01_LISTMENU_ROW_SIGNIN]) {
                        if ([[SimiGlobalVar sharedInstance] isLogin] && _cells != nil) {
                            row.title = SCLocalizedString(@"Sign Out");
                            row.image = [UIImage imageNamed:@"theme1_log_out"];
                        }else if (![[SimiGlobalVar sharedInstance] isLogin]){
                            row.title = SCLocalizedString(@"Sign In");
                            row.image = [UIImage imageNamed:@"theme1_icon_signin"];
                            [self.delegate getOutToCartWhenDidLogout];
                            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:@"You have logged out" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                            [alert show];
                        }
                    }
                }
            }
        }
        [_tableViewMenu reloadData];
    }
}

#pragma mark Action
- (void)buttonTouchDown:(id)sender
{
    UIButton *button = (UIButton*)sender;
    switch (button.tag) {
        case 100:
            _imgHome.alpha = 1;
            _lblHome.alpha = 1;
            break;
        case 101:
            _imgCate.alpha = 1;
            _lblCate.alpha = 1;
            break;
        case 102:
            _imgStoreView.alpha = 1;
            _lblStoreView.alpha = 1;
            break;
        default:
            break;
    }
}

- (void)buttonTouchUpInSide:(id)sender
{
    UIButton *button = (UIButton*)sender;
    switch (button.tag) {
        case 100:
            [self.delegate didClickHomeButton];
            break;
        case 101:
            [self.delegate didClickCategoryButton];
            break;
        case 102:
            [self.delegate didClickStoreButton];
            break;
        default:
            break;
    }
    [self didClickHide];
    [self.searchBar resignFirstResponder];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SimiSection *section = [_cells objectAtIndex:indexPath.section];
    SimiRow *row = [section objectAtIndex:indexPath.row];
    if ([section.identifier isEqualToString:THEME01_LISTMENU_SECTION_SETTING]) {
        if ([row.identifier isEqualToString:THEME01_LISTMENU_ROW_SETTING]) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        }
    }
    if(![row.identifier isEqualToString:THEME01_LISTMENU_ROW_MAIN]){
        [self.delegate menu:self didSelectRow:row withIndexPath:indexPath];
        [self didClickHide];
        [self.searchBar resignFirstResponder];
    }
}

#pragma mark Action
- (void)didClickShow
{
    CGRect frame = self.frame;
    frame.size.height = [[UIScreen mainScreen] bounds].size.height;
    self.frame = frame;
    
    frame = self.tableViewMenu.frame;
    frame.size.height = self.frame.size.height;
    self.tableViewMenu.frame = frame;
    
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
    [self.searchBar resignFirstResponder];
}

#pragma mark - Search Bar Delegate
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar_{
   //tableViewSearch.hidden = YES;
}
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    if ([searchText isEqualToString:@" "]) {
        self.searchBar.text = @"";
    }
}
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar_{
    if (![self.searchBar.text isEqualToString:@""]) {
        [self.delegate didSearchButtonClicked:self.searchBar.text];
        [self.searchBar resignFirstResponder];
        [self didClickHide];
    }
}

- (void)hiddenKeyBoard:(UIGestureRecognizer *)sender
{
    [self.searchBar resignFirstResponder];
}

#pragma mark Hidden Store View
- (void)hiddenStoreViewWhenHasOnlyStore
{
    if (_stores == nil) {
        return;
    }
    if (_stores.count < 2) {
        [_lblStoreView setHidden:YES];
        [_imgStoreView setHidden:YES];
        [buttonStore setHidden:YES];
        
        int deltaX = 45;
        CGRect frame = _imgHome.frame;
        frame.origin.x += deltaX;
        [_imgHome setFrame:frame];
        
        frame = _lblHome.frame;
        frame.origin.x += deltaX;
        [_lblHome setFrame:frame];
        
        frame = buttonHome.frame;
        frame.origin.x += deltaX;
        [buttonHome setFrame:frame];
        
        deltaX += 15;
        frame = _imgCate.frame;
        frame.origin.x += deltaX;
        [_imgCate setFrame:frame];
        
        frame = _lblCate.frame;
        frame.origin.x += deltaX;
        [_lblCate setFrame:frame];
        
        frame = buttonCate.frame;
        frame.origin.x += deltaX;
        [buttonCate setFrame:frame];
    }
}

@end
