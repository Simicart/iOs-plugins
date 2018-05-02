//
//  BarCodeWorker.m
//  SimiCartPluginFW
//
//  Created by Nghieply91 on 1/16/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//
#import <SimiCartBundle/SCHomeViewController.h>
#import <SimiCartBundle/SimiRow.h>
#import <SimiCartBundle/SimiGlobalVar.h>
#import <SimiCartBundle/SCAppDelegate.h>
#import <SimiCartBundle/SimiSection.h>
#import <SimiCartBundle/UIImage+SimiCustom.h>
#import <SimiCartBundle/SimiTable.h>

#import <SimiCartBundle/SCLeftMenuViewController.h>
#import <SimiCartBundle/SCLeftMenuViewControllerPad.h>
#import <SimiCartBundle/SCNavigationBarPhone.h>
#import <SimiCartBundle/SCNavigationBarPad.h>
#import "BarCodeWorker.h"
#if __has_include("SCPSearchViewController.h")
#import "SCPSearchViewController.h"
#endif
@implementation BarCodeWorker{
    UISearchBar *searchBar;
    UITableViewCell *cell;
    UIButton *btnScanBarCode;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didInitCellsAfter:) name:[NSString stringWithFormat:@"%@%@",SCLeftMenuViewController_RootEventName,SimiTableViewController_SubKey_InitCells_End] object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didSelectRow:) name:[NSString stringWithFormat:@"%@%@",SCLeftMenuViewController_RootEventName,SimiTableViewController_SubKey_DidSelectCell] object:nil];
        #if __has_include("SCPSearchViewController.h")
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(perrySearchViewDidLoad:) name:@"SCPSearchViewControllerViewDidLoad" object:nil];
        #endif
    }
    return self;
}

#if __has_include("SCPSearchViewController.h")
- (void)perrySearchViewDidLoad:(NSNotification *)noti{
    SCPSearchViewController *searchVC = noti.object;
    UIScrollView *mainScrollView = searchVC.mainScrollView;
    float paddingX = 15;
    float contentWidth = CGRectGetWidth(searchVC.mainScrollView.frame) - 2*paddingX;
    UIView *scanView = [[UIView alloc] initWithFrame:CGRectMake(paddingX + contentWidth - 100, 15, 100, 30)];
    UITextField *scanTextField = [[UITextField alloc] initWithFrame:scanView.bounds];
    [scanView addSubview:scanTextField];
    UIButton *scanButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 35, 30)];
    [scanButton setImage:[UIImage imageNamed:@"scp_ic_scan"] forState:UIControlStateNormal];
    [scanButton setImageEdgeInsets:UIEdgeInsetsMake(5, 5, 5, 10)];
    scanTextField.leftView = scanButton;
    scanTextField.leftViewMode = UITextFieldViewModeAlways;
    scanTextField.text = SCLocalizedString(@"Scan");
    scanTextField.userInteractionEnabled = NO;
    [mainScrollView addSubview:scanView];
    [scanView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapButtonScan)]];
}
#endif

- (void)didInitCellsAfter:(NSNotification*)noti{
    SimiTable *cells = noti.object;
    for (int i = 0; i < cells.count; i++) {
        SimiSection *section = [cells objectAtIndex:i];
        if ([section.identifier isEqualToString:LEFTMENU_SECTION_MORE]) {
            SimiRow *row = [[SimiRow alloc]initWithIdentifier:LEFTMENU_ROW_BARCODE height:50 sortOrder:50];
            row.image = [UIImage imageNamed:@"barcode_icon"];
            row.title = SCLocalizedString(@"Scan Now");
            [section addObject:row];
            [section sortItems];
        }
    }
}

- (void)didSelectRow:(NSNotification*)noti{
    NSIndexPath *indexPath = [noti.userInfo valueForKey:KEYEVENT.SIMITABLEVIEWCONTROLLER.indexpath];
    SimiTable *cells = noti.object;
    SimiSection *section = [cells objectAtIndex:indexPath.section];
    SimiRow *row = [section objectAtIndex:indexPath.row];
    if ([row.identifier isEqualToString:LEFTMENU_ROW_BARCODE]) {
        [self didTapButtonScan];
    }
}

- (void)didTapButtonScan
{
    SimiNavigationController *navi = kNavigationController;
    if (_barCodeViewController == nil) {
        _barCodeViewController = [BarCodeViewController new];
    }
    if ([navi.viewControllers containsObject:_barCodeViewController]    ) {
        [navi popToViewController:_barCodeViewController animated:NO];
    }else
    {
        [navi pushViewController:_barCodeViewController animated:NO];
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}
@end
