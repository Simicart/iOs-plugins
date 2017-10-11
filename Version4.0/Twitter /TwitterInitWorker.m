//
//  TwitterInitWorker.m
//  SimiCartPluginFW
//
//  Created by Hoang Van Trung on 9/13/16.
//  Copyright © 2016 Trueplus. All rights reserved.
//

#import "TwitterInitWorker.h"
#import <SimiCartBundle/SimiTable.h>
#import <SimiCartBundle/SimiSection.h>
#import <TwitterKit/TwitterKit.h>
//#import <Fabric/Fabric.h>
#import <SimiCartBundle/SimiCustomerModel.h>


#define ApplicationOpenURL @"ApplicationOpenURL"
#define SCLoginViewController_InitCellAfter @"SCLoginViewController_InitCellAfter"
#define SCLoginViewController_InitCellsAfter @"SCLoginViewController_InitCellsAfter"
#define TwitterLoginCell @"TwitterLoginCell"

@implementation TwitterInitWorker{
    SimiCustomerModel* customerModel;
    SimiTable* cells;
    SimiViewController* loginViewController;
}

-(id) init{
    if(self == [super init]){
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidFinishLaunching:) name:@"ApplicationDidFinishLaunching" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationOpenURL:) name:ApplicationOpenURL object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:SCLoginViewController_InitCellAfter object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:SCLoginViewController_InitCellsAfter object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didLogout:) name:Simi_DidLogout object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didLogin:) name:Simi_DidLogout object:nil];
        [[TwitterKit sharedInstance] startWithConsumerKey:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"TwitterConsumerKey"] consumerSecret:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"TwitterConsumerSecret"]];
        
//        [Fabric with:@[[Twitter class]]];
    }
    return self;
}

-(void) applicationDidFinishLaunching: (NSNotification* ) noti{
}

-(void) applicationOpenURL: (NSNotification*) noti{
    BOOL numberBool = [[noti object] boolValue];
    numberBool = [[Twitter sharedInstance] application:[[noti userInfo] valueForKey:@"app"] openURL:[[noti userInfo] valueForKey:@"url"] options:[[noti userInfo] valueForKey:@"options"]];
}

-(void) didReceiveNotification:(NSNotification *)noti{
    if([noti.name isEqualToString:SCLoginViewController_InitCellsAfter]){
        cells = noti.object;
        loginViewController = (SimiViewController*)[noti.userInfo valueForKey:@"controller"];
        SimiSection *section = [cells objectAtIndex:0];
        SimiRow *row = [[SimiRow alloc] initWithIdentifier:TwitterLoginCell height:[SimiGlobalVar scaleValue:50]];
        [section addRow:row];
    }else if([noti.name isEqualToString:SCLoginViewController_InitCellAfter]){
        NSIndexPath *indexPath = [noti.userInfo valueForKey:@"indexPath"];
        SimiSection *section = [cells objectAtIndex:indexPath.section];
        SimiRow *row = [section objectAtIndex:indexPath.row];
        
        if ([row.identifier isEqualToString:TwitterLoginCell]) {
            
            UITableViewCell *cell = noti.object;
            float loginViewWidth = CGRectGetWidth(loginViewController.view.frame);
            float heightCell = [SimiGlobalVar scaleValue:35];
            float paddingY = [SimiGlobalVar scaleValue:7.5];
            float paddingX = [SimiGlobalVar scaleValue:20];
            float widthCell = loginViewWidth - 2* paddingX;
            TWTRLogInButton *logInButton = [TWTRLogInButton buttonWithLogInCompletion:^(TWTRSession *session, NSError *error) {
                if (session) {
                    // Objective-C
                    TWTRAPIClient *client = [TWTRAPIClient clientWithCurrentUser];
                    NSURLRequest *request = [client URLRequestWithMethod:@"GET"
                                                                     URL:@"https://api.twitter.com/1.1/account/verify_credentials.json"
                                                              parameters:@{@"include_email": @"true", @"skip_status": @"true"}
                                                                   error:nil];
                    
                    [client sendTwitterRequest:request completion:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                        if(!connectionError){
                            if(!customerModel){
                                customerModel = [SimiCustomerModel new];
                            }
                            NSError *responseError;
                            NSMutableDictionary * responseData = [NSJSONSerialization
                                                               JSONObjectWithData:data options:kNilOptions error:&responseError
                                                               ];
                            NSLog(@"%@", responseData);
                            NSString* email = [responseData objectForKey:@"id"];
                            NSString* firstName = [responseData objectForKey:@"name"];
                            NSString* lastName = [responseData objectForKey:@"screen_name"];
                            [customerModel loginWithSocialEmail:email password:[[SimiGlobalVar sharedInstance] md5PassWordWithEmail:email] firstName:firstName lastName:lastName];
                            [loginViewController startLoadingData];
                        }else{
                            
                        }
                    }];
                } else {
                    [loginViewController showAlertWithTitle:@"" message:[NSString stringWithFormat:@"%@",error]];
                }
            }];
            
            // TODO: Change where the log in button is positioned in your view
            logInButton.frame = CGRectMake(paddingX, paddingY, widthCell, heightCell);
            cell.backgroundColor = [UIColor clearColor];
            [cell addSubview:logInButton];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];

        }
    }
}

-(void) didLogout: (NSNotification*) noti{
    TWTRSessionStore *store = [[Twitter sharedInstance] sessionStore];
    if(store){
        [store logOutUserID:store.session.userID];
    }
}

-(void) didLogin: (NSNotification*) noti{
    [loginViewController stopLoadingData];
}

@end
