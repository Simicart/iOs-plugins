//
//  ProductWorker.m
//  SimiCartPluginFW
//
//  Created by Hoang Van Trung on 2/4/18.
//  Copyright © 2018 Trueplus. All rights reserved.
//

#import <SimiCartBundle/SCProductSecondDesignViewController.h>
#import "ProductWorker.h"
#import "SCMyFavouriteModelCollection.h"
#import "SCCustomizeProductSecondDesignViewController.h"
#import "SCCustomizeProductSecondDesignViewControllerPad.h"
#import "SCCustomizeWebViewController.h"

#define PRODUCT_BRAND @"PRODUCT_BRAND"
#define PRODUCT_VIDEO @"PRODUCT_VIDEO"

@implementation ProductWorker{
    UIButton *favouriteButton;
    SCProductSecondDesignViewController *cherryVC;
}
- (id)init{
    if(self == [super init]){
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cherryInitCellsEnd:) name:[NSString stringWithFormat:@"%@%@",SCProductSecondDesignViewController_RootEventName,SimiTableViewController_SubKey_InitCells_End] object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cherryInitializeCellBegin:) name:[NSString stringWithFormat:@"%@%@",SCProductSecondDesignViewController_RootEventName,SimiTableViewController_SubKey_InitializedCell_Begin] object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(cherryViewDidLoad:) name:@"SCProductSecondDesignViewControllerViewDidLoad" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showCherryView:) name:SIMI_SHOWPRODUCTDETAIL object:nil];
    }
    return self;
}
- (void)showCherryView:(NSNotification *)noti{
    SCAppController *appController = noti.object;
    appController.isDiscontinue = YES;
    if(PHONEDEVICE){
        SCCustomizeProductSecondDesignViewController *cherryVC = [SCCustomizeProductSecondDesignViewController new];
        cherryVC.productId = [noti.userInfo objectForKey:KEYEVENT.PRODUCTVIEWCONTROLLER.product_id];
        [GLOBALVAR.currentlyNavigationController pushViewController:cherryVC animated:YES];
    }else{
        SCCustomizeProductSecondDesignViewControllerPad *cherryVC = [SCCustomizeProductSecondDesignViewControllerPad new];
        cherryVC.productId = [noti.userInfo objectForKey:KEYEVENT.PRODUCTVIEWCONTROLLER.product_id];
        [GLOBALVAR.currentlyNavigationController pushViewController:cherryVC animated:YES];
    }
}
- (void)cherryViewDidLoad:(NSNotification *)noti{
    cherryVC = noti.object;
}
- (void)cherryInitCellsEnd:(NSNotification *)noti{
    SimiTable *cells = noti.object;
    SCProductSecondDesignViewController *productViewController = [noti.userInfo objectForKey:KEYEVENT.SIMITABLEVIEWCONTROLLER.viewcontroller];
    SimiSection *section = [cells getSectionByIdentifier:product_main_section];
    SimiRow *row = [section getRowByIdentifier:product_nameandprice_row];
    if ([productViewController.product valueForKey:@"brand_images"]) {
        [section addRowWithIdentifier:PRODUCT_BRAND height:44 sortOrder:row.sortOrder + 1];
    }
    if([productViewController.product objectForKey:@"wistia_video"]){
        SimiRow *videoRow = [section addRowWithIdentifier:PRODUCT_VIDEO height:44 sortOrder:row.sortOrder + 2];
        videoRow.simiObjectName = [NSString stringWithFormat:@"%@",[productViewController.product objectForKey:@"wistia_video"]];
    }
}
- (void)cherryInitializeCellBegin:(NSNotification *)noti{
    SimiTable *cells = noti.object;
    NSIndexPath *indexPath = [noti.userInfo objectForKey:KEYEVENT.SIMITABLEVIEWCONTROLLER.indexpath];
    SimiSection *section = [cells objectAtIndex:indexPath.section];
    SimiRow *row = [section objectAtIndex:indexPath.row];
    if([row.identifier isEqualToString:PRODUCT_BRAND]){
        SCProductSecondDesignViewController *vc = [noti.userInfo objectForKey:KEYEVENT.SIMITABLEVIEWCONTROLLER.viewcontroller];
        vc.isDiscontinue = YES;
        UITableViewCell *cell = [vc.contentTableView dequeueReusableCellWithIdentifier:PRODUCT_BRAND];
        if(!cell){
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:row.identifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, vc.contentTableView.frame.size.width, 44)];
            [cell addSubview:imageView];
            [imageView sd_setImageWithURL:[NSURL URLWithString:[vc.product objectForKey:@"brand_images"]]];
            [imageView setContentMode:UIViewContentModeScaleAspectFit];
        }
        row.tableCell = cell;
    }else if([row.identifier isEqualToString:PRODUCT_VIDEO]){
        SCProductSecondDesignViewController *vc = [noti.userInfo objectForKey:KEYEVENT.SIMITABLEVIEWCONTROLLER.viewcontroller];
        vc.isDiscontinue = YES;
        UITableViewCell *cell = [vc.contentTableView dequeueReusableCellWithIdentifier:PRODUCT_VIDEO];
        if(!cell){
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:row.identifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            float paddingX = 15;
            float contentWidth = CGRectGetWidth(vc.contentTableView.frame) - 2* paddingX;
            UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(paddingX, 0, contentWidth, 44)];
            [button addTarget:self action:@selector(showVideo:) forControlEvents:UIControlEventTouchUpInside];
            button.simiObjectName = row.simiObjectName;
            [button setImage:[UIImage imageNamed:@"ic_play_video"] forState:UIControlStateNormal];
            [button setTitle:SCLocalizedString(@"WATCH VIDEO") forState:UIControlStateNormal];
            [button setImageEdgeInsets:UIEdgeInsetsMake(5, 0, 5, contentWidth - 34)];
            [button setTitleEdgeInsets:UIEdgeInsetsMake(0, 5, 0, 0)];
            [button setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
            [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [cell.contentView addSubview:button];
        }
        row.tableCell = cell;
    }
}
- (void)showVideo:(UIButton *)sender{
    NSString *urlString = sender.simiObjectName;
    SCCustomizeWebViewController *webVC = [SCCustomizeWebViewController new];
    webVC.urlPath = urlString;
    if(PHONEDEVICE){
        webVC.modalPresentationStyle = UIModalPresentationCustom;
        webVC.transitioningDelegate = self;
        [GLOBALVAR.currentViewController presentViewController:webVC animated:YES completion:nil];
    }else{
        [GLOBALVAR.currentlyNavigationController pushViewController:webVC animated:YES];
    }
}

- (UIPresentationController *)presentationControllerForPresentedViewController:(UIViewController *)presented presentingViewController:(UIViewController *)presenting sourceViewController:(UIViewController *)source{
    return [[CustomizePresentationController alloc] initWithPresentedViewController:presented presentingViewController:presenting];
}

@end

@implementation CustomizePresentationController
- (CGRect)frameOfPresentedViewInContainerView{
    self.containerView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.2];
    float width = SCREEN_WIDTH - 40;
    float height = width * 720/1280;
    return CGRectMake(20, SCREEN_HEIGHT/2 - height/2 , width, height);
}
@end
