//
//  TimeLoaderViewController.h
//  SimiCartPluginFW
//
//  Created by Gin-Wishky on 10/14/15.
//  Copyright © 2015 Trueplus. All rights reserved.
//

#import <SimiCartBundle/SimiCartBundle.h>
#import "SimiTableView.h"
#import <MessageUI/MessageUI.h>


@interface TimeLoaderViewController : SimiViewController <UITableViewDataSource, UITableViewDelegate,MFMailComposeViewControllerDelegate>
@property(nonatomic, strong)  NSMutableDictionary *dictdata;
@property(nonatomic,strong)   NSMutableArray *cells;
@property(nonatomic,strong)  SimiTableView *timeLoaderTable;
@property(nonatomic,strong)  NSMutableArray *array;
@end
