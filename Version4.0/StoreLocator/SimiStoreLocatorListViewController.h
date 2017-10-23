//
//  SimiStoreLocatorListViewController.h
//  SimiCartPluginFW
//
//  Created by NghiepLy on 7/1/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <SimiCartBundle/UIScrollView+SVInfiniteScrolling.h>
#import <SimiCartBundle/UILabelDynamicSize.h>
#import <SimiCartBundle/SimiModel.h>

#import "SimiCLController.h"
#import "SimiStoreLocatorModelCollection.h"
#import "SCStoreListTableViewCell.h"

typedef NS_ENUM(NSInteger, ListViewOption){
    ListViewOptionNoneSearch,
    ListViewOptionSearched
};

@protocol SimiStoreLocatorListViewControllerDelegate<NSObject>
@optional
- (void)didChoiseStoreFromListToMap;
- (void)showViewDetailControllerFromList:(SimiModel*) sLModel_;
@end


@interface SimiStoreLocatorListViewController : UITableViewController<UITableViewDataSource, UITableViewDelegate, SCStoreListTableViewCellDelegate,MFMailComposeViewControllerDelegate>
{
    SimiCLController *cLController;
}
@property (nonatomic, weak) id<SimiStoreLocatorListViewControllerDelegate> delegate;
@property (nonatomic, strong) SimiStoreLocatorModelCollection *sLModelCollection;
@property (nonatomic, strong) SimiModel *sLModel;
@property (nonatomic) ListViewOption listViewOption;
@property (nonatomic) float currentLatitube;
@property (nonatomic) float currentLongitube;
@property (nonatomic, strong) NSDictionary *currentCountry;
@property (nonatomic, strong) NSDictionary *currentCity;
@property (nonatomic, strong) NSDictionary *currentState;
@property (nonatomic, strong) NSString *tag;
@property (nonatomic, strong) NSString *storeName;

- (void)getStoreLocatorList;
- (void)didGetStoreLocatorList;

@end
