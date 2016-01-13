//
//  SimiFacebookWorker.m
//  SimiCartPluginFW
//
//  Created by Tan Hoang on 3/19/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import "SimiFacebookWorker.h"
#import <SimiCartBundle/SimiTableView.h>
#import <SimiCartBundle/SCAppDelegate.h>
#import <SimiCartBundle/SimiSection.h>
#import <SimiCartBundle/SimiViewController.h>
#import <SimiCartBundle/KeychainItemWrapper.h>
#import "SimiCustomerModel+Facebook.h"

@implementation SimiFacebookWorker{
    NSMutableArray *cells;
    SimiCustomerModel *customer;
    SimiViewController *viewController;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"SCLoginViewController_LocationLoginWithFaceBook" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"ApplicationOpenURL" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"DidLogout" object:customer];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"InitializedLoginCell-After" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"ApplicationWillTerminate" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"AutoLoginWithFacebook" object:nil];
    }
    return self;
}

- (void)didReceiveNotification:(NSNotification *)noti{
    if ([noti.name isEqualToString:@"SCLoginViewController_LocationLoginWithFaceBook"]) {
        cells = noti.object;
        viewController = (SimiViewController*)[noti.userInfo valueForKey:@"controller"];
        SimiSection *section = [[SimiSection alloc] init];
        SimiRow *row = [[SimiRow alloc] initWithIdentifier:@"FacebookLoginCell" height:60];
        [section.rows addObject:row];
        [cells addObject:section];
    }else if ([noti.name isEqualToString:@"InitializedLoginCell-After"]){
        NSIndexPath *indexPath = [noti.userInfo valueForKey:@"indexPath"];
        SimiSection *section = [cells objectAtIndex:indexPath.section];
        SimiRow *row = [section.rows objectAtIndex:indexPath.row];
        if ([row.identifier isEqualToString:@"FacebookLoginCell"]) {
            UITableViewCell *cell = noti.object;
            @try {
                FBLoginView *loginView = [[FBLoginView alloc] initWithReadPermissions:@[@"email"]];
                if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
                    loginView.frame = CGRectMake(10, 10, SCREEN_WIDTH - 20, 40);
                }else
                {
                    loginView.frame = CGRectMake(10, 10, 2*SCREEN_WIDTH/3 - 20, 40);
                }
                loginView.delegate = self;
                cell.backgroundColor = [UIColor clearColor];
                [cell addSubview:loginView];
            }
            @catch (NSException *exception) {
                NSLog(@"%@", exception.description);
            }
            @finally {
                
            }
        }
    }else if ([noti.name isEqualToString:@"ApplicationOpenURL"]){
        NSNumber *number = noti.object;
        NSURL *url = [noti.userInfo valueForKey:@"url"];
        NSString *source = [noti.userInfo valueForKey:@"source_application"];
        BOOL wasHandled = [FBAppCall handleOpenURL:url sourceApplication:source];
        number = [NSNumber numberWithBool:wasHandled];
    }else if ([noti.name isEqualToString:@"DidLogout"] || [noti.name isEqualToString:@"ApplicationWillTerminate"]){
        [[FBSession activeSession] closeAndClearTokenInformation];
    }else if([noti.name isEqualToString:@"DidLogin"])
    {
        [viewController stopLoadingData];
        [self removeObserverForNotification:noti];
    }else if([noti.name isEqualToString:@"AutoLoginWithFacebook"])
    {
        NSString *stringEmail = noti.object;
        NSString *stringName = [noti.userInfo valueForKey:@"name"];
        if (customer == nil) {
            customer = [[SimiCustomerModel alloc]init];
            [customer loginWithFacebookEmail:stringEmail name:stringName];
        }
    }
}

#pragma mark FB Login View Delegates
- (void)loginView:(FBLoginView *)loginView handleError:(NSError *)error{
    NSString *alertMessage, *alertTitle;
    // If the user should perform an action outside of you app to recover,
    // the SDK will provide a message for the user, you just need to surface it.
    // This conveniently handles cases like Facebook password change or unverified Facebook accounts.
    if ([FBErrorUtility shouldNotifyUserForError:error]) {
        alertTitle = @"Facebook error";
        alertMessage = [FBErrorUtility userMessageForError:error];
        
        // This code will handle session closures that happen outside of the app
        // You can take a look at our error handling guide to know more about it
        // https://developers.facebook.com/docs/ios/errors
    } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryAuthenticationReopenSession) {
        alertTitle = @"Session Error";
        alertMessage = @"Your current session is no longer valid. Please log in again.";
        
        // If the user has cancelled a login, we will do nothing.
        // You can also choose to show the user a message if cancelling login will result in
        // the user not being able to complete a task they had initiated in your app
        // (like accessing FB-stored information or posting to Facebook)
    } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryUserCancelled) {
        NSLog(@"user cancelled login");
        
        // For simplicity, this sample handles other errors with a generic message
        // You can checkout our error handling guide for more detailed information
        // https://developers.facebook.com/docs/ios/errors
    } else {
        alertTitle  = @"Something went wrong";
        alertMessage = @"Please try again later.";
        NSLog(@"Unexpected error:%@", error);
    }
    
    if (alertMessage) {
        [[[UIAlertView alloc] initWithTitle:SCLocalizedString(alertTitle)
                                    message:SCLocalizedString(alertMessage)
                                   delegate:nil
                          cancelButtonTitle:SCLocalizedString(@"OK")
                          otherButtonTitles:nil] show];
    }
}
- (void)loginViewFetchedUserInfo:(FBLoginView *)loginView user:(id<FBGraphUser>)user{
    NSString *email = @"";
    NSString *name = user.name;
    NSString *string = user.objectID;
    //Sent email & name to server
    if (customer == nil) {
        customer = [[SimiCustomerModel alloc] init];
    }
    if ([user objectForKey:@"email"] == nil || [[user objectForKey:@"email"] isKindOfClass:[NSNull class]]) {
        email = [NSString stringWithFormat:@"%@@facebook.com",string];
    }else
    {
        email = [user objectForKey:@"email"];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"DidLogin" object:customer];
    NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
    NSString *bundleIdentifier = [NSString stringWithFormat:@"%@", [info objectForKey:@"CFBundleIdentifier"]];
    KeychainItemWrapper *wrapper = [[KeychainItemWrapper alloc] initWithIdentifier:bundleIdentifier accessGroup:nil];
    [wrapper setObject:name forKey:(__bridge id)(kSecAttrComment)];
    [wrapper setObject:@"loginwithfacebook" forKey:(__bridge id)(kSecAttrLabel)];
    [customer loginWithFacebookEmail:email name:name];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SimiFaceBookWorker_StartLoginWithFaceBook" object:nil];
    [viewController startLoadingData];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}
@end
