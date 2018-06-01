//
//  SCPSortViewController.m
//  SimiCartPluginFW
//
//  Created by Liam on 5/15/18.
//  Copyright © 2018 Trueplus. All rights reserved.
//

#import "SCPSortViewController.h"
#import "SCPGlobalVars.h"

@interface SCPSortViewController ()

@end

@implementation SCPSortViewController
- (void)viewDidLoadBefore{
    [[UINavigationBar appearance] setBarTintColor:SCP_BUTTON_BACKGROUND_COLOR];
    self.preferredContentSize = CGSizeMake(SCREEN_WIDTH/3, self.sortArray.count *44 + 60);
    self.navigationItem.title = SCLocalizedString(@"Sort by");
    UIButton *closeButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 44, 44)];
    [closeButton setImage:[[UIImage imageNamed:@"scp_ic_close"]imageWithColor:SCP_TITLE_COLOR] forState:UIControlStateNormal];
    [closeButton setImageEdgeInsets:UIEdgeInsetsMake(10, 0, 10, 20)];
    [closeButton addTarget:self action:@selector(cancelButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *closeButtonItem = [[UIBarButtonItem alloc] initWithCustomView:closeButton];
    self.navigationItem.leftBarButtonItem = closeButtonItem;
    self.contentTableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    self.contentTableView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    if (SIMI_SYSTEM_IOS >= 9) {
        self.contentTableView.cellLayoutMarginsFollowReadableWidth = NO;
    }
    self.contentTableView.separatorStyle = UITableViewCellSelectionStyleNone;
    self.contentTableView.dataSource = self;
    self.contentTableView.delegate = self;
    [self.contentTableView setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:self.contentTableView];
    [self initCells];
}

- (UITableViewCell *)contentTableViewCellForRowAtIndexPath:(NSIndexPath *)indexPath{
    SimiSection *section = [self.cells objectAtIndex:indexPath.section];
    SimiRow *row = [section objectAtIndex:indexPath.row];
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:row.identifier];
    UIImageView *iconImageView = [[UIImageView alloc]initWithFrame:CGRectMake(50, 16, 12, 12)];
    if (self.selectedIndex == indexPath.row) {
        [iconImageView setImage:[[UIImage imageNamed:@"scp_ic_tick"]imageWithColor:SCP_BUTTON_BACKGROUND_COLOR]];
    }else{
        [iconImageView setImage:[UIImage imageNamed:@"scp_ic_untick"]];
    }
    [cell.contentView addSubview:iconImageView];
    
    SimiLabel *titleLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(70, 10, CGRectGetWidth(self.contentTableView.frame) - 100, 22) andFontName:THEME_FONT_NAME_REGULAR andFontSize:FONT_SIZE_LARGE];
    NSString *sortTitle = [NSString stringWithFormat:@"%@",SCLocalizedString([row.data valueForKey:@"value"])];
    titleLabel.text = sortTitle;
    [cell.contentView addSubview:titleLabel];
    
    NSString *stringDirection = @"scp_ic_sort_down";
    if ([[row.data valueForKey:@"direction"] isEqualToString:@"asc"]) {
        stringDirection = @"scp_ic_sort_up";
    }
    float titleWidth = [sortTitle sizeWithAttributes:@{NSFontAttributeName:titleLabel.font}].width + 5;
    UIImageView *sortDirImageView = [[UIImageView alloc]initWithFrame:CGRectMake(70 + titleWidth, 13, 8, 15)];
    [sortDirImageView setImage:[UIImage imageNamed:stringDirection]];
    [cell.contentView addSubview:sortDirImageView];
    [SimiGlobalFunction sortViewForRTL:cell.contentView andWidth:CGRectGetWidth(self.contentTableView.frame)];
    return cell;
}

#pragma mark Table View Delegate
- (void)contentTableViewDidSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.contentTableView deselectRowAtIndexPath:indexPath animated:YES];
    self.selectedIndex = (int)indexPath.row;
    [self dismissViewControllerAnimated:YES completion:^{
        [self.delegate didSortWithIndex:self.selectedIndex];
    }];
}
@end
