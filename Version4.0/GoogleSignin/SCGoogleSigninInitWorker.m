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
      
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didLogout:) name:Simi_DidLogin object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didLogin:) name:Simi_DidLogout object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(initCellsOnLoginViewController:) name:[NSString stringWithFormat:@"%@%@",SCLoginViewController_RootEventName,SimiTableViewController_SubKey_InitCells_End] object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(initializedCellsOnLoginViewController:) name:[NSString stringWithFormat:@"%@%@",SCLoginViewController_RootEventName,SimiTableViewController_SubKey_InitializedCell_End] object:nil];
        
        //Init GIDSignin attributes
        [GIDSignIn sharedInstance].delegate = self;
        [GIDSignIn sharedInstance].uiDelegate = self;
        [GIDSignIn sharedInstance].clientID = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"GoogleClientID"];
    }
    return self;
}

- (void)initCellsOnLoginViewController:(NSNotification *)noti{
    cells = noti.object;
    loginViewController = [noti.userInfo objectForKey:KEYEVENT.SIMITABLEVIEWCONTROLLER.viewcontroller];
    SimiSection *section = [cells getSectionByIdentifier:LOGIN_SECTION];
    SimiRow *signInRow = [section getRowByIdentifier:LOGIN_SIGNIN_BUTTON];
    SimiRow *row = [[SimiRow alloc] initWithIdentifier:GoogleLoginCell height:SCALEVALUE(50) sortOrder:signInRow.sortOrder + 1];
    [section addRow:row];
}

- (void)initializedCellsOnLoginViewController:(NSNotification *)noti{
    NSIndexPath *indexPath = [noti.userInfo valueForKey:KEYEVENT.SIMITABLEVIEWCONTROLLER.indexpath];
    SimiSection *section = [cells objectAtIndex:indexPath.section];
    SimiRow *row = [section objectAtIndex:indexPath.row];
    
    if ([row.identifier isEqualToString:GoogleLoginCell]) {
        UITableViewCell *cell = [noti.userInfo objectForKey:KEYEVENT.SIMITABLEVIEWCONTROLLER.cell];
        float loginViewWidth = CGRectGetWidth(loginViewController.view.frame);
        float heightCell = SCALEVALUE(32);
        float paddingY = SCALEVALUE(6);
        float paddingX = SCALEVALUE(16);
        float widthCell = loginViewWidth - 2* paddingX;
        GIDSignInButton* ggSignInButton = [GIDSignInButton new];
        ggSignInButton.frame = CGRectMake(paddingX, paddingY , widthCell, heightCell);
        cell.backgroundColor = [UIColor clearColor];
        [cell addSubview:ggSignInButton];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
}

-(void) applicationOpenURL: (NSNotification*) noti{
    BOOL numberBool = [[noti object] boolValue];
    numberBool  = [[GIDSignIn sharedInstance] handleURL:[[noti userInfo] valueForKey:@"url"]
                        sourceApplication:[[noti userInfo] valueForKey:@"source_application"]
                               annotation:[[noti userInfo] valueForKey:@"annotation"]];
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
        [customerModel loginWithSocialEmail:email password:[SimiGlobalFunction md5PassWordWithEmail:email]  firstName:firstName lastName:lastName];
        [SimiCustomerModel saveEmailPasswordForAutoLoginToLocal:email password:[SimiGlobalFunction md5PassWordWithEmail:email]];
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
