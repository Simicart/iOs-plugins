//
//  TimeLoaderDetailViewController.h
//  SimiCartPluginFW
//
//  Created by Gin-Wishky on 10/16/15.
//  Copyright © 2015 Trueplus. All rights reserved.
//

#import <SimiCartBundle/SimiCartBundle.h>
#import "SimiTableView.h"
#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <SimiCartBundle/SimiViewController.h>
#import <SimiCartBundle/UIImage+SimiCustom.h>
#import <SimiCartBundle/SimiTable.h>
#import <SimiCartBundle/SimiSection.h>
#import <SimiCartBundle/SimiRow.h>



@interface TimeLoaderDetailViewController : SimiViewController <UITableViewDataSource, UITableViewDelegate,MFMailComposeViewControllerDelegate>
@property(nonatomic,strong)   NSMutableArray *cells;
@property(nonatomic,strong)  SimiTableView *timeLoaderTableDetail;
@property(nonatomic,strong)  NSMutableArray *arrayDetail;
@property(nonatomic,strong)  NSString *stringHeader;

@end
