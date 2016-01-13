//
//  ZThemeLeftMenuPad.m
//  SimiCartPluginFW
//
//  Created by Cody Nguyen on 5/20/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import "ZThemeLeftMenuPad.h"
#import <SimiCartBundle/UIImageView+WebCache.h>
#import <SimiCartBundle/UIImage+SimiCustom.h>

@implementation ZThemeLeftMenuPad


#pragma mark Init List Menu
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        tableWidth = frame.size.width;
        sizeIcon = 35;
        recentHeight = frame.size.height;
        recentTilteHeight = 30;
        loginHeight = 40;
        self.isFirstShow = YES;
        
        [self.tableViewMenu setFrame:CGRectMake(0, 20, tableWidth, frame.size.height)];
        self.tableViewMenu.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
        self.tableViewMenu.separatorColor = [[SimiGlobalVar sharedInstance]colorWithHexString:@"#dbdbdb"];
        
        [self.lblRecent setFrame:CGRectMake(10, 0, 0, 30)];
        [self.lblRecent setFont:[UIFont fontWithName:ZTHEME_FONT_NAME_REGULAR size:THEME_FONT_SIZE]];
    }
    return self;
}

#pragma mark Action Touch
- (void)didClickShow
{
    [super didClickShow];
    if (self.isFirstShow) {
        [self.lblRecent setFrame:CGRectMake(10, CGRectGetHeight(self.frame) - loginHeight - recentHeight - recentTilteHeight, CGRectGetWidth(self.frame), recentTilteHeight)];
        UICollectionViewFlowLayout *gridPad = [[UICollectionViewFlowLayout alloc]init];
        [gridPad setScrollDirection:UICollectionViewScrollDirectionHorizontal];
        gridPad.itemSize = CGSizeMake(100, 100);
        gridPad.minimumInteritemSpacing = 10;
        gridPad.minimumLineSpacing = 7;
        [self.collectionRecentView setCollectionViewLayout:gridPad animated:YES];
    }
    [self.collectionRecentView reloadSections:[[NSIndexSet alloc]initWithIndex:0]];
    [self.collectionRecentView setContentSize:CGSizeMake(self.arrayRecentProducts.count * 62.25, 70)];
}

#pragma mark -
#pragma mark TableView Functions

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(section == 0){
        return 45;
    }
    return 30;
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, tableWidth, 30)];
    SimiSection *simiSection = [self.cells objectAtIndex:section];
    if(section == 0){
        view.backgroundColor = THEME_COLOR;
        //    Logo
        UIImageView *imgLogo = [[UIImageView alloc]initWithFrame:CGRectMake(10, -5, 400, 50)];
        //imgLogo.contentMode = UIViewContentModeScaleAspectFit;
        imgLogo.image = [UIImage imageNamed:@"logo~ipad"];
        [view addSubview:imgLogo];
        
        //    List menu
        self.imgListMenu = [[UIImageView alloc]initWithFrame:CGRectMake(410, 8, 32, 32)];
        [self.imgListMenu setImage:[UIImage imageNamed:@"Ztheme_icon_menu"]];
        [view addSubview:self.imgListMenu];
        UIButton *buttonListMenu = [[UIButton alloc]init];
        buttonListMenu.frame = self.imgListMenu.frame;
        [buttonListMenu addTarget:self action:@selector(didClickHide) forControlEvents:UIControlEventTouchUpInside];
        buttonListMenu.tag = 103;
        [view addSubview:buttonListMenu];
        return view;
    }else{
        
        UILabel *headerTitleSection = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, tableView.bounds.size.width - 30, 30)];
        headerTitleSection.text = simiSection.headerTitle;
        //  Liam Update RTL
        if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
            [headerTitleSection setTextAlignment:NSTextAlignmentRight];
        }
        //  End RTL
        [headerTitleSection setFont:[UIFont fontWithName:ZTHEME_FONT_NAME_REGULAR size:THEME_FONT_SIZE]];
        [headerTitleSection setTextColor:[UIColor blackColor]];
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 40)];
        [headerView setBackgroundColor:[[SimiGlobalVar sharedInstance]colorWithHexString:@"#dbdbdb"]];
        [headerView addSubview:headerTitleSection];
        
        return headerView;
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
    UILabel *lblText = [[UILabel alloc]initWithFrame:CGRectMake(30 + sizeIcon, (row.height - sizeIcon)/2, 355, sizeIcon)];
    [lblText setTextColor:[[SimiGlobalVar sharedInstance] colorWithHexString:@"#474545"]];
    [lblText setFont:[UIFont fontWithName:ZTHEME_FONT_NAME_REGULAR size:THEME_FONT_SIZE]];
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

@end
