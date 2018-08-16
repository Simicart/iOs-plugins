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
#import <SimiCartBundle/SCNewAddressViewController.h>
#import <SimiCartBundle/SCOrderViewController.h>
#import <SimiCartBundle/SCAddressViewController.h>
#import <SimiCartBundle/SCProductSecondDesignViewController.h>
#import "SCCustomizeSearchViewController.h"
#import "BarCodeWorker.h"

#import "SCCustomChatViewController.h"
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
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(addScanButton:) name:@"SimiViewControllerViewDidAppear" object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(addScanToProductView:) name:SCProductViewControllerInitViewMoreAction object:nil];
    }
    return self;
}

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

- (void)addScanButton:(NSNotification*)noti{
    SimiViewController *viewController = noti.object;
    if ([viewController isKindOfClass:[SCLeftMenuViewController class]] || [viewController isKindOfClass:[SCCartViewController class]]||[viewController isKindOfClass:[SCNewAddressViewController class]] || [viewController isKindOfClass:[SCAddressViewController class]] || [viewController isKindOfClass:[SCCustomizeSearchViewController class]] || [viewController isKindOfClass:[SCOrderViewController class]] || [viewController isKindOfClass:[SCProductSecondDesignViewController class]] || [viewController isKindOfClass:[SCCustomChatViewController class]]) {
        return;
    }
    if (viewController.isPresented || viewController.isInPopover) {
        return;
    }
    if (![viewController.view viewWithTag:3323]) {
        float sizeButton = 60;
        float moreButtonOrgionX = CGRectGetWidth(viewController.view.frame) - sizeButton - 20;
        float moreButtonOrgionY = CGRectGetHeight(viewController.view.frame) - sizeButton - 50;
        UIButton *scanQRButton = [[UIButton alloc]initWithFrame:CGRectMake(moreButtonOrgionX, moreButtonOrgionY, sizeButton, sizeButton)];
        [scanQRButton addTarget:self action:@selector(didTapButtonScan) forControlEvents:UIControlEventTouchUpInside];
        [scanQRButton setBackgroundColor:THEME_BUTTON_BACKGROUND_COLOR];
        [scanQRButton.layer setCornerRadius:sizeButton/2.0f];
        [scanQRButton.layer setShadowOffset:CGSizeMake(1, 1)];
        [scanQRButton.layer setShadowRadius:2];
        scanQRButton.layer.shadowOpacity = 0.5;
        [scanQRButton setImage:[[UIImage imageNamed:@"ic_custom_qrcode"]imageWithColor:THEME_BUTTON_TEXT_COLOR] forState:UIControlStateNormal];
        [scanQRButton setImageEdgeInsets:UIEdgeInsetsMake(15, 15, 15, 15)];
        scanQRButton.tag = 3323;
        [viewController.view addSubview:scanQRButton];
    }
}

- (void)addScanToProductView:(NSNotification*)noti{
    MoreActionView *moreActionView = noti.object;
    float sizeButton = 50;
    UIButton *scanQRButton = [UIButton new];
    [scanQRButton setImage:[[UIImage imageNamed:@"ic_custom_qrcode"] imageWithColor:[UIColor blackColor]] forState:UIControlStateNormal];
    [scanQRButton setImageEdgeInsets:UIEdgeInsetsMake(12, 12, 12, 12)];
    [scanQRButton.layer setCornerRadius:sizeButton/2.0f];
    [scanQRButton.layer setShadowOffset:CGSizeMake(1, 1)];
    [scanQRButton.layer setShadowRadius:2];
    scanQRButton.layer.shadowOpacity = 0.5;
    [scanQRButton setBackgroundColor:[UIColor whiteColor]];
    [scanQRButton addTarget:self action:@selector(didTapButtonScan) forControlEvents:UIControlEventTouchUpInside];
    scanQRButton.tag = 10;
    moreActionView.numberIcon += 1;
    [moreActionView.arrayIcon addObject:scanQRButton];
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
