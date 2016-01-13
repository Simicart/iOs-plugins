//
//  SCLoginViewController_Theme01.h
//  SimiCartPluginFW
//
//  Created by Tan Hoang on 3/2/14.
//  Copyright (c) 2014 SimiTeam. All rights reserved.
//

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
@protocol  SCLoginViewController_Theme01_Delegate<NSObject>
@optional
- (void) didFinishLoginSuccess;
@end

@interface SCLoginViewController_Theme01 : SCLoginViewController

/*
 The function tableView cellForRowAtIndexPath raise notification name: "InitializedLoginCell-After" after created a cell.
 The function tableView didSelectRowAtIndexPath raise notification name: "DidSelectLoginCellAtIndexPath" before TO-DO list in the function.
 */

@property (nonatomic, weak) id<SCLoginViewController_Theme01_Delegate> delegate;
@property (nonatomic) SCLoginWhenClick scLoginWhenClick;

@end
