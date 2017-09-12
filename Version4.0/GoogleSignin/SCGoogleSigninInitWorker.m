//
//  SCGoogleSigninInitWorker.m
//  SimiCartPluginFW
//
//  Created by Hoang Van Trung on 9/12/16.
//  Copyright © 2016 Trueplus. All rights reserved.
//

#import "SCGoogleSigninInitWorker.h"
#import <SimiCartBundle/SimiSection.h>
#import <SimiCartBundle/SimiTable.h>

#define ApplicationOpenURL @"ApplicationOpenURL"
#define SCLoginViewController_InitCellAfter @"SCLoginViewController_InitCellAfter"
#define SCLoginViewController_InitCellsAfter @"SCLoginViewController_InitCellsAfter"
#define GoogleLoginCell @"GoogleLoginCell"

@implementation SCGoogleSigninInitWorker{
    SimiCustomerModel* customerModel;
    SimiTable* cells;
    SimiViewController* loginViewController;
}

-(id) init{
    if(self == [super init]){
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationOpenURL:) name:ApplicationOpenURL object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:SCLoginViewController_InitCellAfter object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:SCLoginViewController_InitCellsAfter object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didLogout:) name:Simi_DidLogin object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didLogin:) name:Simi_DidLogout object:nil];
        
        //Init GIDSignin attributes
        [GIDSignIn sharedInstance].delegate = self;
        [GIDSignIn sharedInstance].uiDelegate = self;
        [GIDSignIn sharedInstance].clientID = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"GoogleClientID"];
    }
    return self;
}

-(void) applicationOpenURL: (NSNotification*) noti{
    BOOL numberBool = [[noti object] boolValue];
    numberBool  = [[GIDSignIn sharedInstance] handleURL:[[noti userInfo] valueForKey:@"url"]
                        sourceApplication:[[noti userInfo] valueForKey:@"source_application"]
                               annotation:[[noti userInfo] valueForKey:@"annotation"]];
}

-(void) didReceiveNotification:(NSNotification *)noti{
    if([noti.name isEqualToString:SCLoginViewController_InitCellsAfter]){
        cells = noti.object;
        loginViewController = (SimiViewController*)[noti.userInfo valueForKey:@"controller"];
        SimiSection *section = [cells objectAtIndex:0];
        SimiRow *row = [[SimiRow alloc] initWithIdentifier:GoogleLoginCell height:[SimiGlobalVar scaleValue:50]];
        [section addRow:row];
    }else if([noti.name isEqualToString:SCLoginViewController_InitCellAfter]){
        NSIndexPath *indexPath = [noti.userInfo valueForKey:@"indexPath"];
        SimiSection *section = [cells objectAtIndex:indexPath.section];
        SimiRow *row = [section objectAtIndex:indexPath.row];
        
        if ([row.identifier isEqualToString:GoogleLoginCell]) {
            
            UITableViewCell *cell = noti.object;
            float loginViewWidth = CGRectGetWidth(loginViewController.view.frame);
            float heightCell = [SimiGlobalVar scaleValue:35];
            float paddingY = [SimiGlobalVar scaleValue:7.5];
            float paddingX = [SimiGlobalVar scaleValue:20];
            
            float widthCell = loginViewWidth - 2* paddingX;
            GIDSignInButton* ggSignInButton = [GIDSignInButton new];
            ggSignInButton.frame = CGRectMake(paddingX, paddingY , widthCell, heightCell);
            cell.backgroundColor = [UIColor clearColor];
            [cell addSubview:ggSignInButton];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        }
    }
}

-(void) didLogout: (NSNotification*) noti{
    if([[GIDSignIn sharedInstance] currentUser])
        [[GIDSignIn sharedInstance] signOut];
}

-(void) didLogin: (NSNotification*) noti{
    if([[GIDSignIn sharedInstance] currentUser])
       [loginViewController stopLoadingData];
}

//GIDSigninDelegate
-(void) signIn:(GIDSignIn *)signIn didSignInForUser:(GIDGoogleUser *)user withError:(NSError *)error{
    if(!error){
        NSString *firstName = user.profile.givenName;
        NSString *lastName = user.profile.familyName;
        NSString *email = user.profile.email;
        if(!customerModel){
            customerModel = [SimiCustomerModel new];
        }
        [customerModel loginWithSocialEmail:email password:[[SimiGlobalVar sharedInstance] md5PassWordWithEmail:email]  firstName:firstName lastName:lastName];
        [loginViewController startLoadingData];
    }
}

-(void) signIn:(GIDSignIn *)signIn didDisconnectWithUser:(GIDGoogleUser *)user withError:(NSError *)error{
    if(!error){
        
    }
}


//GIDSignInUIDelegate
-(void) signInWillDispatch:(GIDSignIn *)signIn error:(NSError *)error{
    [loginViewController stopLoadingData];
}

-(void) signIn:(GIDSignIn *)signIn presentViewController:(UIViewController *)viewController{
    [loginViewController presentViewController:viewController animated:YES completion:nil];
}

- (void)signIn:(GIDSignIn *)signIn
dismissViewController:(UIViewController *)viewController {
    [loginViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
