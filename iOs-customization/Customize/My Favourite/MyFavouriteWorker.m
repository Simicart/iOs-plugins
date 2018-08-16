//
//  MyFavouriteWorker.m
//  SimiCartPluginFW
//
//  Created by Hoang Van Trung on 2/3/18.
//  Copyright © 2018 Trueplus. All rights reserved.
//

#import "MyFavouriteWorker.h"
#define MYFAVOURITE @"MYFAVOURITE"

@implementation MyFavouriteWorker
- (id)init{
    if(self == [super init]){
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(leftMenuInitCellsEnd:) name:[NSString stringWithFormat:@"%@%@",SCLeftMenuViewController_RootEventName,SimiTableViewController_SubKey_InitCells_End] object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(leftMenuDidSelectCell:) name:[NSString stringWithFormat:@"%@%@",SCLeftMenuViewController_RootEventName,SimiTableViewController_SubKey_DidSelectCell] object:nil];
    }
    return self;
}
- (void)leftMenuInitCellsEnd:(NSNotification *)noti{
    SimiTable *cells = noti.object;
    SimiSection *section = [cells getSectionByIdentifier:LEFTMENU_SECTION_MAIN];
    if(GLOBALVAR.isLogin){
        SimiRow *row = [section getRowByIdentifier:LEFTMENU_ROW_ORDERHISTORY];
        SimiRow *favourite = [section addRowWithIdentifier:MYFAVOURITE height:row.height sortOrder:row.sortOrder + 1];
        favourite.image = [UIImage imageNamed:@"favourite_leftmenu_icon"];
        favourite.title = SCLocalizedString(@"My Favourites");
    }
}
- (void)leftMenuDidSelectCell:(NSNotification *)noti{
    SimiTable *cells = noti.object;
    NSIndexPath *indexPath = [noti.userInfo objectForKey:KEYEVENT.SIMITABLEVIEWCONTROLLER.indexpath];
    SimiSection *section = [cells objectAtIndex:indexPath.section];
    SimiRow *row = [section objectAtIndex:indexPath.row];
    SCLeftMenuViewController *leftMenuVC;
    if([row.identifier isEqualToString:MYFAVOURITE]){
        leftMenuVC.isDiscontinue = YES;
        [kMainViewController hideLeftViewAnimated:YES completionHandler:^{
        }];
        SCMyFavouriteViewController *myFavouriteVC = [SCMyFavouriteViewController new];
        if(PHONEDEVICE){
            [GLOBALVAR.currentlyNavigationController pushViewController:myFavouriteVC animated:YES];
        }else{
            UINavigationController *favouriteNavi = [[UINavigationController alloc]initWithRootViewController:myFavouriteVC];
            favouriteNavi.navigationBar.tintColor = THEME_NAVIGATION_ICON_COLOR;
            favouriteNavi.navigationBar.barTintColor = THEME_COLOR;
            favouriteNavi.modalPresentationStyle = UIModalPresentationPopover;
            UIPopoverPresentationController *popover = favouriteNavi.popoverPresentationController;
            popover.sourceRect = CGRectMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2, 1, 1);
            popover.sourceView = [UIApplication sharedApplication].delegate.window.rootViewController.view;
            popover.permittedArrowDirections = 0;
            [[UIApplication sharedApplication].delegate.window.rootViewController presentViewController:favouriteNavi animated:YES completion:nil];
        }
    }
}
@end
