//
//  SCPPadProductViewController.m
//  SimiCartPluginFW
//
//  Created by Liam on 6/17/18.
//  Copyright © 2018 Trueplus. All rights reserved.
//

#import "SCPPadProductViewController.h"

@interface SCPPadProductViewController ()

@end

@implementation SCPPadProductViewController
- (void)viewDidAppearBefore:(BOOL)animated{
    tableWidth = SCALEVALUE(510);
    if (self.contentTableView == nil) {
        CGRect frame = self.view.bounds;
        frame.origin.x = SCALEVALUE(514);
        frame.size.width -= SCALEVALUE(514);
        self.contentTableView = [[UITableView alloc]initWithFrame:frame style:UITableViewStyleGrouped];
        if (@available(iOS 11.0, *)) {
            self.contentTableView.estimatedRowHeight = 0;
            self.contentTableView.estimatedSectionHeaderHeight = 0;
            self.contentTableView.estimatedSectionFooterHeight = 0;
        }
        self.contentTableView.delegate = self;
        self.contentTableView.dataSource = self;
        [self.view addSubview:self.contentTableView];
        [self.contentTableView setContentInset:UIEdgeInsetsMake(0, 0, CGRectGetHeight(self.tabBarController.tabBar.frame), 0)];
        self.contentTableView.backgroundColor = COLOR_WITH_HEX(@"#ededed");
        self.contentTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self.contentTableView setHidden:YES];
        [self getProductDetail];
        [self startLoadingData];
    }
}
@end
