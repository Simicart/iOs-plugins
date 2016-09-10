//
//  SCEmailContactViewController.h
//  SimiCartPluginFW
//
//  Created by Nghieply91 on 10/15/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <SimiCartBundle/SimiCartBundle.h>
#import <SimiCartBundle/SimiViewController.h>
#import <SimiCartBundle/UIImage+SimiCustom.h>
#import <SimiCartBundle/SimiTable.h>
#import <SimiCartBundle/SimiSection.h>
#import <SimiCartBundle/SimiRow.h>
#import "SCListPhoneViewController.h"

static NSString *EMAILCONTACT_SECTIONMAIN = @"EMAILCONTACT_SECTIONMAIN";
static NSString *EMAILCONTACT_ROWWEBSITE = @"EMAILCONTACT_ROWWEBSITE";
static NSString *EMAILCONTACT_ROWCALL = @"EMAILCONTACT_ROWCALL";
static NSString *EMAILCONTACT_ROWMESSAGE = @"EMAILCONTACT_ROWMESSAGE";
static NSString *EMAILCONTACT_ROWEMAIL = @"EMAILCONTACT_ROWEMAIL";

@interface SCEmailContactViewController : SimiViewController<MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate, UITableViewDataSource, UITableViewDelegate, SCListPhoneViewController_Delegate, UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) UITableView *tblViewContent;
@property (nonatomic, strong) UICollectionView *contactCollectionView;
@property (nonatomic) BOOL isCall;
@property (nonatomic, strong) SimiTable *cells;

@property (nonatomic, strong) SimiModel *contactModel;

@end

@interface ContactCollectionViewCell : UICollectionViewCell
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *titleLabel;
@end
