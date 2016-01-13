//
//  ZThemeLoginViewController.h
//  SimiCartPluginFW
//
//  Created by Cody Nguyen on 6/1/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import <SimiCartBundle/SimiCartBundle.h>
#import <SimiCartBundle/SCLoginViewController.h>


#import <SimiCartBundle/SCLoginViewController.h>
#import <SimiCartBundle/SimiTableView.h>
#import <SimiCartBundle/SCOrderViewController.h>
#import <SimiCartBundle/SCAddressViewController.h>
#import <SimiCartBundle/SCProfileViewController.h>
#import <SimiCartBundle/SCRegisterViewController.h>

typedef NS_ENUM(NSInteger, SCLoginWhenClick) {
    SCLoginWhenClickSignIn,
    SCLoginWhenClickAddressBook,
    SCLoginWhenClickProfile,
    SCLoginWhenClickOrderHistory
};
@protocol  ZThemeLoginViewController_Delegate<NSObject>
@optional
- (void) didFinishLoginSuccess;
@end


@interface ZThemeLoginViewController : SCLoginViewController

@property (nonatomic, weak) id<ZThemeLoginViewController_Delegate> delegate;
@property (nonatomic) SCLoginWhenClick scLoginWhenClick;

@end
