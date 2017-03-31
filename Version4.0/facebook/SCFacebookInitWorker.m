//
//  SCFacebookInitWorker.m
//  SimiCartPluginFW
//
//  Created by Hoang Van Trung on 8/24/16.
//  Copyright © 2016 Trueplus. All rights reserved.
//

#import "SCFacebookInitWorker.h"
#import <SimiCartBundle/SCAppDelegate.h>
#import <SimiCartBundle/SimiTable.h>
#import <SimiCartBundle/SCLeftMenuViewController.h>
#import <SimiCartBundle/SCCategoryViewController.h>
#import <SimiCartBundle/SCProductListViewControllerPad.h>

//Product More View notifications
#define SCProductMoreViewController_ViewDidLoadBefore @"SCProductViewMoreController-ViewDidLoadBefore"
#define SCProductMoreViewController_InitViewMoreAction @"SCProductMoreViewController_InitViewMoreAction"
#define SCProductMoreViewController_BeforeTouchMoreAction @"SCProductMoreViewController-BeforeTouchMoreAction"
//Login view controller notifications
#define SCLoginViewController_InitCellsAfter @"SCLoginViewController_InitCellsAfter"
#define ApplicationOpenURL @"ApplicationOpenURL"
#define ApplicationDidBecomeActive @"ApplicationDidBecomeActive"
#define SCLoginViewController_InitCellAfter @"SCLoginViewController_InitCellAfter"
#define FacebookLoginCell @"FacebookLoginCell"
#define SimiFaceBookWorker_StartLoginWithFaceBook @"SimiFaceBookWorker_StartLoginWithFaceBook"
#define SCLeftMenu_InitCellsAfter @"SCLeftMenu_InitCellsAfter"
#define SCLeftMenu_DidSelectRow @"SCLeftMenu_DidSelectRow"

#define LEFTMENU_ROW_FACEBOOK_INVITE @"LEFTMENU_ROW_FACEBOOK_INVITE"

#define COMMENT_VIEW_TAG 1111
#define FB_BUTTON_SIZE 50

@implementation SCFacebookInitWorker
{
    SimiViewController* loginViewController, *currentlyViewController;
    NSDictionary* product;
    NSArray* cells;
    SimiCustomerModel* customerModel;
    NSString* facebookAppID;
    MoreActionView* moreActionView;
    float widthFacebookView,facebookViewInitX;
    UIView* fbView;
    UIButton* fbButton;
    BOOL isShowFacebookView;
//    UIActivityIndicatorView* activityView;
    UIWebView* commentWebView;
    NSString* commentHTMLString;
    UIButton* btnClearAllFacebookCookies;
    NSString* productURL;
}
-(id) init{
    if(self == [super init]){
        //add notifications
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(initViewMoreAction:) name:SCProductMoreViewController_InitViewMoreAction object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(beforeTouchMoreAction:) name:SCProductMoreViewController_BeforeTouchMoreAction object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(initViewMoreAction:) name:@"SCProductViewController_InitViewMoreAction" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(beforeTouchMoreAction:) name:@"SCProductViewController_BeforeTouchMoreAction" object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetFacebookViewPosition:) name:@"SCProductSecondDesignViewControllerViewDidAppear" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetFacebookViewPosition:) name:@"SCProductMoreViewControllerViewDidAppear" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetFacebookViewPosition:) name:@"SCProductSecondDesignViewControllerPadViewDidAppear" object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:SCLoginViewController_InitCellsAfter object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:ApplicationOpenURL object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:SCLoginViewController_InitCellAfter object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didLogin:) name:DidLogin object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didLogout:) name:DidLogout object:nil];
        
        //App Invite
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didInitLeftMenuRows:) name:SCLeftMenu_InitCellsAfter object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSelectInviteFriends:) name:SCLeftMenu_DidSelectRow object:nil];
        //Catch when done init the app
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didInitApp:) name:@"DidInit" object:nil];
        //ApplicationDidBecomeActive
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:ApplicationDidBecomeActive object:nil];
        //Facebook Analytics
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(trackingEvent:) name:TRACKINGEVENT object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(trackingViewedScreen:) name:@"SimiViewControllerViewDidAppear" object:nil];
        
        facebookAppID = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"FacebookAppID"];
        commentHTMLString = @"\
                             <!DOCTYPE html>\
                             <html xmlns:fb='http://ogp.me/ns/fb#'>\
                             <head>\
                             <meta name='viewport' content='width=%f, initial-scale=1.0'>\
                             </head>\
                             <body high=100%>\
                             <div id='fb-root'></div>\
                             <script>\
                             window.fbAsyncInit = function() {\
                             FB.init({\
                             appId      : '%@',\
                             cookie     : true,\
                             status     : true,\
                             xfbml      : true\
                             });\
                             FB.Event.subscribe('xfbml.render', function(response) {\
                             FB.Canvas.setSize();\
                             });\
                             };\
                             (function(d, s, id){\
                             var js, fjs = d.getElementsByTagName(s)[0];\
                             if (d.getElementById(id)) {return;}\
                             js = d.createElement(s); js.id = id;\
                             js.src = 'http://connect.facebook.net/en_US/all.js';\
                             fjs.parentNode.insertBefore(js, fjs);\
                             }(document, 'script', 'facebook-jssdk'));\
                             </script>\
                             <div class='fb-comments' data-href='%@' data-numposts='5' data-colorscheme='light'></div>\
                             </body>\
                             </html>\
                             <style type=\"text/css\">\
                             .fb_hide_iframes iframe {\
                             left: 0;\
                             top:0;\
                             right:0;\
                             bottom:0;\
                             }\
                             </style>\
                             ";
    }
    return self;
}

-(void) didReceiveNotification:(NSNotification *)noti{
    if([noti.name isEqualToString:SCLoginViewController_InitCellsAfter]){
        cells = noti.object;
        loginViewController = (SimiViewController*)[noti.userInfo valueForKey:@"controller"];
        SimiSection *section = [cells objectAtIndex:0];
        SimiRow *row = [[SimiRow alloc] initWithIdentifier:FacebookLoginCell height:[SimiGlobalVar scaleValue:50]];
        [section addRow:row];
    }else if([noti.name isEqualToString:ApplicationOpenURL]){
        BOOL numberBool = [[noti object] boolValue];
        numberBool  = [[FBSDKApplicationDelegate sharedInstance] application:[[noti userInfo] valueForKey:@"application"] openURL:[[noti userInfo] valueForKey:@"url"] sourceApplication:[[noti userInfo] valueForKey:@"source_application"] annotation:[[noti userInfo] valueForKey:@"annotation"]];
        if([noti.userInfo objectForKey:@"url"]){
            NSURL* url = [noti.userInfo objectForKey:@"url"];
            [self handleOpeningURL:url.absoluteString];
        }
    }else if([noti.name isEqualToString:ApplicationDidBecomeActive]){
        //Active Facebook App
        [FBSDKAppEvents activateApp];
    }
    else if([noti.name isEqualToString:SCLoginViewController_InitCellAfter]){
        NSIndexPath *indexPath = [noti.userInfo valueForKey:@"indexPath"];
        SimiSection *section = [cells objectAtIndex:indexPath.section];
        SimiRow *row = [section objectAtIndex:indexPath.row];
        
        if ([row.identifier isEqualToString:FacebookLoginCell]) {
            UITableViewCell *cell = noti.object;
            float loginViewWidth = CGRectGetWidth(loginViewController.view.frame);
            float heightCell = [SimiGlobalVar scaleValue:35];
            float paddingY = [SimiGlobalVar scaleValue:7.5];
            float paddingX = [SimiGlobalVar scaleValue:20];
            
            float widthCell = loginViewWidth - 2* paddingX;
            
            FBSDKLoginButton *loginButton = [[FBSDKLoginButton alloc] initWithFrame:CGRectMake(paddingX, paddingY, widthCell, heightCell)];
            loginButton.readPermissions = @[@"email"];
            loginButton.publishPermissions = @[@"publish_actions"];
            loginButton.delegate = self;
            cell.backgroundColor = [UIColor clearColor];
            [cell addSubview:loginButton];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        }
    }else if ([noti.name isEqualToString:@"ApplicationWillTerminate"])
    {
        NSHTTPCookieStorage* cookies = [NSHTTPCookieStorage sharedHTTPCookieStorage];
        NSArray* facebookCookies = [cookies cookiesForURL:
                                    [NSURL URLWithString:@"https://facebook.com"]];
        for (NSHTTPCookie* cookie in facebookCookies) {
            [cookies deleteCookie:cookie];
        }
    }
}

-(void) didInitApp:(NSNotification*) noti{
    if([SimiGlobalVar sharedInstance].deepLinkURL != nil){
        [self handleOpeningURL:[SimiGlobalVar sharedInstance].deepLinkURL.absoluteString];
        [SimiGlobalVar sharedInstance].deepLinkURL = nil;
    }
    //Active Facebook App
    [FBSDKAppEvents activateApp];
}

#pragma mark Logging events and setting user properties
- (void)trackingEvent:(NSNotification*) noti{
    if([noti.object isKindOfClass:[NSString class]])
    {
        NSString *trackingName = noti.object;
        NSDictionary *params = noti.userInfo;
        if (params == nil) {
            params = @{};
        }
        NSMutableDictionary *trackingProperties = [[NSMutableDictionary alloc]initWithDictionary:params];
        if ([SimiGlobalVar sharedInstance].isLogin) {
            [trackingProperties setValue:[[SimiGlobalVar sharedInstance].customer valueForKey:@"email"]  forKey:@"customer_identity"];
        }else
        {
            if ([[SimiGlobalVar sharedInstance].baseConfig valueForKey:@"customer_identity"]) {
                NSString *customerIdentity = [NSString stringWithFormat:@"%@",[[SimiGlobalVar sharedInstance].baseConfig valueForKey:@"customer_identity"]];
                if (![customerIdentity isEqualToString:@""] && ![[[SimiGlobalVar sharedInstance].baseConfig valueForKey:@"customer_identity"] isKindOfClass:[NSNull class]]) {
                    [trackingProperties setValue:customerIdentity  forKey:@"customer_identity"];
                }
            }
        }
        [FBSDKAppEvents logEvent:trackingName parameters:trackingProperties];
    }
}

- (void)trackingViewedScreen:(NSNotification*)noti
{
    SimiViewController *viewController = noti.object;
    if (viewController.screenTrackingName != nil && ![viewController.screenTrackingName isEqualToString:@""]) {
        NSString *actionValue = [NSString stringWithFormat:@"viewed_%@_screen",viewController.screenTrackingName];
        NSMutableDictionary *trackingProperties = [[NSMutableDictionary alloc]initWithDictionary:@{@"action":actionValue}];
        if ([SimiGlobalVar sharedInstance].isLogin) {
            [trackingProperties setValue:[[SimiGlobalVar sharedInstance].customer valueForKey:@"email"]  forKey:@"customer_identity"];
        }else
        {
            if ([[SimiGlobalVar sharedInstance].baseConfig valueForKey:@"customer_identity"]) {
                NSString *customerIdentity = [NSString stringWithFormat:@"%@",[[SimiGlobalVar sharedInstance].baseConfig valueForKey:@"customer_identity"]];
                if (![customerIdentity isEqualToString:@""] && ![[[SimiGlobalVar sharedInstance].baseConfig valueForKey:@"customer_identity"] isKindOfClass:[NSNull class]]) {
                    [trackingProperties setValue:customerIdentity  forKey:@"customer_identity"];
                }
            }
        }
        [FBSDKAppEvents logEvent:@"page_view_action" parameters:trackingProperties];
    }
}

// Handle url 
-(void) handleOpeningURL:(NSString*) url{
    if(![url isEqualToString:@""]){
        NSMutableDictionary *urlParamsDictionary = [[NSMutableDictionary alloc] init];
        NSArray *urlComponents = [url componentsSeparatedByString:@"?"];
        if(urlComponents.count > 0){
            NSString* firstURLParam = [NSString stringWithFormat:@"%@",[urlComponents objectAtIndex:0]];
            NSArray* firstURLParamComponents = [firstURLParam componentsSeparatedByString:@"://"];
            if(firstURLParamComponents.count > 1){
                NSString* paramsPath = [NSString stringWithFormat:@"%@",[firstURLParamComponents objectAtIndex:1]];
                NSArray* paramsPathComponents = [paramsPath componentsSeparatedByString:@"&"];
                if(paramsPathComponents.count > 0){
                    for(NSString* paramsPathComponent in paramsPathComponents){
                        NSArray* paramComponents = [paramsPathComponent componentsSeparatedByString:@"="];
                        if(paramComponents.count == 2){
                            [urlParamsDictionary setValue:[NSString stringWithFormat:@"%@",[paramComponents objectAtIndex:1]] forKey:[NSString stringWithFormat:@"%@",[paramComponents objectAtIndex:0]]];
                        }
                    }
                }
            }
        }
        if([urlParamsDictionary objectForKey:@"product_id"] && ![[NSString stringWithFormat:@"%@",[urlParamsDictionary objectForKey:@"product_id"]] isEqualToString:@""]){
            [SimiGlobalVar pushProductDetailWithNavigationController:[SimiGlobalVar sharedInstance].currentlyNavigationController andProductID:[NSString stringWithFormat:@"%@",[urlParamsDictionary objectForKey:@"product_id"]] andProductIDs:[[NSMutableArray alloc] initWithArray:@[[NSString stringWithFormat:@"%@",[urlParamsDictionary objectForKey:@"product_id"]]]]];
        }else if([urlParamsDictionary objectForKey:@"category_id"] && ![[NSString stringWithFormat:@"%@",[urlParamsDictionary objectForKey:@"category_id"]] isEqualToString:@""]){
            NSString* categoryId = [NSString stringWithFormat:@"%@",[urlParamsDictionary objectForKey:@"category_id"]];
            BOOL hasChild = [[urlParamsDictionary objectForKey:@"has_child"] boolValue];
            if(PHONEDEVICE){
                if (hasChild){
                    SCCategoryViewController *nextController = [[SCCategoryViewController alloc]init];
                    nextController.openFrom = CategoryOpenFromParentCategory;
                    [nextController setCategoryId:categoryId];
                    [[SimiGlobalVar sharedInstance].currentlyNavigationController pushViewController:nextController animated:YES];
                }else{
                    SCProductListViewController *nextController = [[SCProductListViewController alloc]init];;
                    [nextController setCategoryID: categoryId];
                    [[SimiGlobalVar sharedInstance].currentlyNavigationController pushViewController:nextController animated:YES];
                }
            }else if(PADDEVICE){
                SCProductListViewControllerPad * nextViewController = [SCProductListViewControllerPad new];
                [nextViewController setCategoryID:categoryId];
                [[SimiGlobalVar sharedInstance].currentlyNavigationController pushViewController:nextViewController animated:YES];
            }
        }
    }
}

- (void)initViewMoreAction:(NSNotification*)noti
{
    moreActionView = noti.object;
    fbButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, FB_BUTTON_SIZE, FB_BUTTON_SIZE)];
    [fbButton setImage:[UIImage imageNamed:@"facebookconnect_ic_detail"] forState:UIControlStateNormal];
    [fbButton setImageEdgeInsets:UIEdgeInsetsMake(9, 9, 9, 9)];
    [fbButton.layer setCornerRadius:FB_BUTTON_SIZE/2.0f];
    [fbButton.layer setShadowOffset:CGSizeMake(1, 1)];
    [fbButton.layer setShadowRadius:2];
    fbButton.layer.shadowOpacity = 0.5;
    [fbButton setBackgroundColor:[UIColor whiteColor]];
    [fbButton addTarget:self action:@selector(fbButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    moreActionView.numberIcon += 1;
    [moreActionView.arrayIcon addObject:fbButton];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(afterInitViewMore:) name:@"SCProductMoreViewController-AfterInitViewMore" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(afterInitViewMore:) name:@"SCProductViewController-AfterInitViewMore" object:nil];
}

- (void)afterInitViewMore:(NSNotification*)noti
{
    [self removeObserverForNotification:noti];
    product = [noti.userInfo valueForKey:@"productModel"];
    if([product objectForKey:@"url_path"]){
        productURL = [NSString stringWithFormat:@"%@%@",kBaseURL, [product objectForKey:@"url_path"]];
    }else{
        productURL = nil;
    }
    currentlyViewController = [noti.userInfo valueForKey:@"controller"];
    
    float likeViewSize = 68;
    UIView *facebookLikeView = [[UIView alloc] initWithFrame:CGRectMake([SimiGlobalVar scaleValue:5], -5, likeViewSize, likeViewSize)];
    
    UIImageView* fbLikeBackgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_bg_more"]];
    fbLikeBackgroundImageView.frame = CGRectMake(0, 0, likeViewSize, likeViewSize);
    fbLikeBackgroundImageView.contentMode = UIViewContentModeScaleAspectFit;
    
//    if (fbLikeControl == nil) {
    FBSDKLikeControl* fbLikeControl = [[FBSDKLikeControl alloc]initWithFrame:CGRectMake(0,likeViewSize/5,likeViewSize, likeViewSize)];
    fbLikeControl.transform = CGAffineTransformMakeScale(0.7, 0.7);
    fbLikeControl.likeControlStyle = FBSDKLikeControlStyleBoxCount;
//    }
    fbLikeControl.objectID = productURL;
    
    [facebookLikeView addSubview:fbLikeBackgroundImageView];
    [facebookLikeView addSubview:fbLikeControl];
    [facebookLikeView setBackgroundColor:[UIColor clearColor]];
    
    //fbComment button
    UIButton* fbCommentButton = [[UIButton alloc]initWithFrame:CGRectMake([SimiGlobalVar scaleValue:92], 5, FB_BUTTON_SIZE, FB_BUTTON_SIZE)];
    [fbCommentButton setImage:[UIImage imageNamed:@"facebookconnect_comment"] forState:UIControlStateNormal];
    [fbCommentButton setImageEdgeInsets:UIEdgeInsetsMake(9, 9, 9, 9)];
    [fbCommentButton.layer setCornerRadius:FB_BUTTON_SIZE/2.0f];
    [fbCommentButton.layer setShadowOffset:CGSizeMake(1, 1)];
    [fbCommentButton.layer setShadowRadius:2];
    fbCommentButton.layer.shadowOpacity = 0.5;
    [fbCommentButton setBackgroundColor:[UIColor whiteColor]];
    [fbCommentButton addTarget:self action:@selector(fbCommentButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton* fbShareButton = [[UIButton alloc]initWithFrame:CGRectMake([SimiGlobalVar scaleValue:170], 5, FB_BUTTON_SIZE, FB_BUTTON_SIZE)];
    [fbShareButton setImage:[UIImage imageNamed:@"facebookconnect_share"] forState:UIControlStateNormal];
    [fbShareButton setImageEdgeInsets:UIEdgeInsetsMake(9, 9, 9, 9)];
    [fbShareButton.layer setCornerRadius:FB_BUTTON_SIZE/2.0f];
    [fbShareButton.layer setShadowOffset:CGSizeMake(1, 1)];
    [fbShareButton.layer setShadowRadius:2];
    fbShareButton.layer.shadowOpacity = 0.5;
    [fbShareButton setBackgroundColor:[UIColor whiteColor]];
    [fbShareButton addTarget:self action:@selector(fbShareButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
        widthFacebookView = SCREEN_WIDTH - fbButton.frame.size.width - 30;
    }
    else{
        widthFacebookView = 250;
    }
    
    fbView = [UIView new];
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        fbView.frame =  CGRectMake(SCREEN_WIDTH - fbButton.frame.size.width - 15, moreActionView.frame.origin.y - moreActionView.heightMoreView + fbButton.frame.origin.y - 5, 0, fbButton.frame.size.height+10);
    else if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        fbView.frame =  CGRectMake(CGRectGetWidth(currentlyViewController.view.frame) - fbButton.frame.size.width - 15, moreActionView.frame.origin.y - moreActionView.heightMoreView + fbButton.frame.origin.y -5, 0, fbButton.frame.size.height+10);
    [fbView addSubview:facebookLikeView];
    [fbView addSubview:fbCommentButton];
    [fbView addSubview:fbShareButton];
    
    [currentlyViewController.view addSubview:fbView];
    fbView.clipsToBounds = YES;
}

-(void) didInitLeftMenuRows:(NSNotification*) noti{
    SimiTable* leftMenuCells = noti.object;
    SimiSection* moreSection = [leftMenuCells getSectionByIdentifier:LEFTMENU_SECTION_MORE];
    SimiRow *inviteRow = [[SimiRow alloc]initWithIdentifier:LEFTMENU_ROW_FACEBOOK_INVITE height:50 sortOrder:9999];
    inviteRow.image = [UIImage imageNamed:@"facebook_invite"];
    inviteRow.title = SCLocalizedString(@"Invite Friends");
    inviteRow.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    [moreSection addObject:inviteRow];
}

-(void) didSelectInviteFriends:(NSNotification*) noti{
    SimiRow* inviteRow = (SimiRow*)[noti.userInfo objectForKey:@"simirow"];
    if([inviteRow.identifier isEqualToString:LEFTMENU_ROW_FACEBOOK_INVITE]){
        if([[SimiGlobalVar sharedInstance].allConfig objectForKey:@"facebook_connect"]){
            NSDictionary* fbConnect = [[SimiGlobalVar sharedInstance].allConfig objectForKey:@"facebook_connect"];
            FBSDKAppInviteContent *content =[[FBSDKAppInviteContent alloc] init];
            NSString* inviteLink = [NSString stringWithFormat:@"%@",[fbConnect objectForKey:@"invite_link"]];
            NSString* inviteImageURL = [NSString stringWithFormat:@"%@",[fbConnect objectForKey:@"image_description_link"]];
            content.appLinkURL = [NSURL URLWithString:inviteLink];
            content.appInvitePreviewImageURL = [NSURL URLWithString:inviteImageURL];
            [FBSDKAppInviteDialog showFromViewController:[SimiGlobalVar sharedInstance].currentlyNavigationController.viewControllers.lastObject withContent:content delegate:self];
        }
    }
}

#pragma mark FBSDKAppInviteDelegate
- (void)appInviteDialog:(FBSDKAppInviteDialog *)appInviteDialog didCompleteWithResults:(NSDictionary *)results{
//    [((SimiViewController*)[SimiGlobalVar sharedInstance].currentlyNavigationController.viewControllers.lastObject) showToastMessage:SCLocalizedString(@"Invite successfully")];
}
- (void)appInviteDialog:(FBSDKAppInviteDialog *)appInviteDialog didFailWithError:(NSError *)error{
//    [((SimiViewController*)[SimiGlobalVar sharedInstance].currentlyNavigationController.viewControllers.lastObject) showToastMessage:SCLocalizedString(@"Invite unsuccessfully")];
}
- (void)beforeTouchMoreAction:(NSNotification*)noti
{
    if(isShowFacebookView){
        CGRect frame = fbView.frame;
        frame.origin.x += widthFacebookView;
        frame.size.width = 0;
        [UIView animateWithDuration:0.15f animations:^{
            [fbView setFrame:frame];
            [fbButton setTransform:CGAffineTransformMakeRotation(0)];
        } completion:^(BOOL finished) {
            
        }];
        isShowFacebookView = NO;
    }
}

//Handling button clicking
-(void) fbButtonClicked: (id) sender{
    [[NSNotificationCenter defaultCenter]postNotificationName:TRACKINGEVENT object:@"facebook_connect_action" userInfo:@{@"action":@"clicked_facebook_connect_button",@"product_name":[product valueForKey:@"name"],@"product_id":[product valueForKey:@"entity_id"],@"sku":[product valueForKey:@"sku"]}];
    if (!isShowFacebookView) {
        CGRect frame = fbView.frame;
        frame.origin.x -= widthFacebookView;
        frame.size.width = widthFacebookView;
        [UIView animateWithDuration:0.15f animations:^{
            [fbView setFrame:frame];
            [fbButton setTransform:CGAffineTransformMakeRotation(M_PI_4)];
        } completion:^(BOOL finished) {
            
        }];
    }else{
        CGRect frame = fbView.frame;
        frame.origin.x += widthFacebookView;
        frame.size.width = 0;
        [UIView animateWithDuration:0.15f animations:^{
            [fbView setFrame:frame];
            [fbButton setTransform:CGAffineTransformMakeRotation(0)];
        } completion:^(BOOL finished) {
            
        }];
    }
    
    isShowFacebookView = !isShowFacebookView;
}

-(void) fbCommentButtonClicked: (id) sender{
    if(productURL){
        UIView* commentView = [[UIView alloc]init];
        commentView.tag = COMMENT_VIEW_TAG;
        UIViewController *currentVC = [(UITabBarController *)[[(SCAppDelegate *)[[UIApplication sharedApplication] delegate] window] rootViewController] selectedViewController];
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            commentView.frame = [UIScreen mainScreen].bounds;
        }else
        {
            commentView.frame = currentVC.view.bounds;
        }
        [commentView setBackgroundColor:[UIColor clearColor]];
        UIImageView *imgBackground = [[UIImageView alloc]initWithFrame:commentView.bounds];
        [imgBackground setBackgroundColor:[UIColor blackColor]];
        [imgBackground setAlpha:0.5];
        imgBackground.userInteractionEnabled = YES;
        [commentView addSubview:imgBackground];
        
        CGRect frame = commentView.bounds;
        frame.origin.x += 10;
        frame.origin.y += 20;
        frame.size.width -= 20;
        frame.size.height -= 30;
        UIView *viewContent = [[UIView alloc]initWithFrame:frame];
        [viewContent setBackgroundColor:[UIColor whiteColor]];
        [viewContent.layer setCornerRadius:10.0f];
        [viewContent.layer setMasksToBounds:YES];
        [commentView addSubview:viewContent];
        
        btnClearAllFacebookCookies = [[UIButton alloc]initWithFrame:CGRectMake(20, 25, frame.size.width - 60, 35)];
        [btnClearAllFacebookCookies setTitle:SCLocalizedString(@"Logout your facebook account") forState:UIControlStateNormal];
        [btnClearAllFacebookCookies setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btnClearAllFacebookCookies setBackgroundColor:[UIColor colorWithRed:70.0/255 green:98.0/255 blue:158.0/255 alpha:1.0]];
        [btnClearAllFacebookCookies.layer setCornerRadius:5.0f];
        [btnClearAllFacebookCookies.layer setMasksToBounds:YES];
        [btnClearAllFacebookCookies addTarget:self action:@selector(btnClearAllFacebookCookiesClicked:) forControlEvents:UIControlEventTouchUpInside];
        [btnClearAllFacebookCookies.titleLabel setFont:[UIFont fontWithName:THEME_FONT_NAME size:THEME_FONT_SIZE]];
        [commentView addSubview:btnClearAllFacebookCookies];
        btnClearAllFacebookCookies.hidden = YES;
        
        UIButton *btnClose = [[UIButton alloc]initWithFrame:CGRectMake(frame.size.width - 40, 20, 50, 50)];
        [btnClose setImage:[UIImage imageNamed:@"facebookconnect_close"] forState:UIControlStateNormal];
        [btnClose setImageEdgeInsets:UIEdgeInsetsMake(10, 26, 26, 10)];
        [btnClose setBackgroundColor:[UIColor clearColor]];
        [btnClose addTarget:self action:@selector(didClickCloseCommentView:) forControlEvents:UIControlEventTouchUpInside];
        [commentView addSubview:btnClose];
        
        CGRect frameWebView = frame;
        frameWebView.origin.y += 50;
        frameWebView.size.height -= 60;
        commentWebView = [[UIWebView alloc]initWithFrame:frameWebView];
        commentWebView.delegate = self;
        
        
        [commentView addSubview:commentWebView];
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            [currentVC.view addSubview:commentView];
        }else
        {    UIWindow *currentVC = [[UIApplication sharedApplication] keyWindow];
            [currentVC addSubview:commentView];
        }
        [commentWebView loadHTMLString:[NSString stringWithFormat:commentHTMLString,commentWebView.frame.size.width,facebookAppID,productURL ] baseURL:[NSURL URLWithString:productURL]];
    }
    
}

-(void) fbShareButtonClicked: (id) sender{
    if(productURL){
        FBSDKShareLinkContent *content = [[FBSDKShareLinkContent alloc] init];
            content.contentURL = [NSURL URLWithString:productURL];
        if ([product objectForKey:@"name"]) {
            content.contentTitle = [NSString stringWithFormat:@"%@",[product objectForKey:@"name"]];
        }
        NSMutableArray *arrayImage = (NSMutableArray *)[product objectForKey:@"images"];
        if (arrayImage.count > 0) {
            content.imageURL = [NSURL URLWithString:[[arrayImage objectAtIndex:0] objectForKey:@"url"]];
        }
        if ([product objectForKey:@"short_description"] && ![[product objectForKey:@"short_description"] isEqualToString:@""]) {
            content.contentDescription = [NSString stringWithFormat:@"%@",[product objectForKey:@"short_description"]];
        }
        
        [FBSDKShareDialog showFromViewController:currentlyViewController
                                     withContent:content
                                        delegate:nil];
    }
}



- (void)btnClearAllFacebookCookiesClicked:(id) sender
{
    NSHTTPCookieStorage* cookies = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    
    NSArray *allCookies = [cookies cookies];
    
    for(NSHTTPCookie *cookie in allCookies) {
        NSLog(@"%@",cookie);
        if([[cookie domain] rangeOfString:@"facebook.com"].location != NSNotFound) {
            [cookies deleteCookie:cookie];
        }
    }
    
    [commentWebView loadHTMLString:commentHTMLString baseURL:[NSURL URLWithString:productURL]];
}

-(void)didClickCloseCommentView: (id) sender
{
    UIViewController *currentVC = [(UITabBarController *)[[(SCAppDelegate *)[[UIApplication sharedApplication] delegate] window] rootViewController] selectedViewController];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [[currentVC.view.subviews lastObject] removeFromSuperview];
    }else
    {
//                [[currentVC.view.subviews lastObject] removeFromSuperview];
        UIButton* closeButton = (UIButton*) sender;
        UIView* commentView = closeButton.superview;
        [commentView removeFromSuperview];
    }
}

#pragma mark UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString *stringURL = [NSString stringWithFormat:@"%@",request.URL];
    if ([stringURL containsString:@"facebook.com/plugins/comments.php?api_key"]) {
        
    }else if([stringURL containsString:@"facebook.com/plugins/close_popup.php"]){
        [webView loadHTMLString:[NSString stringWithFormat:commentHTMLString,webView.frame.size.width,facebookAppID,productURL ] baseURL:[NSURL URLWithString:productURL]];
    }else if([stringURL containsString:productURL]){
        NSHTTPCookieStorage* cookies = [NSHTTPCookieStorage sharedHTTPCookieStorage];
        NSArray *allCookies = [cookies cookies];
        btnClearAllFacebookCookies.hidden = YES;
        for(NSHTTPCookie *cookie in allCookies) {
            if([[cookie domain] rangeOfString:@"facebook.com"].location != NSNotFound) {
                btnClearAllFacebookCookies.hidden = NO;
                return YES;
            }
        }
    }
    return YES;
}

-(void) webViewDidStartLoad:(UIWebView *)webView{
    UIActivityIndicatorView* loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [webView addSubview:loadingView];
    loadingView.center = webView.center;
    [loadingView startAnimating];
}

-(void) webViewDidFinishLoad:(UIWebView *)webView{
    for(UIView* view in webView.subviews){
        if([view isKindOfClass:[UIActivityIndicatorView class]]){
            [view removeFromSuperview];
        }
    }
}

#pragma mark FBSDKLoginButtonDelegate
-(void) loginButton:(FBSDKLoginButton *)loginButton didCompleteWithResult:(FBSDKLoginManagerLoginResult *)result error:(NSError *)error{
 
    if([[FBSDKAccessToken currentAccessToken] hasGranted:@"email"]){
        [self loginWithFacebookInfo];
    }else{
        [[FBSDKLoginManager alloc] logInWithReadPermissions:@[@"email"] fromViewController:loginViewController handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
            if([[FBSDKAccessToken currentAccessToken] hasGranted:@"email"]){
                [self loginWithFacebookInfo];
            }else{
                UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:SCLocalizedString(@"Sorry") message:SCLocalizedString(@"Couldn't get the user email") delegate:nil cancelButtonTitle:SCLocalizedString(@"OK") otherButtonTitles:nil, nil];
                [alertView show];
                [[FBSDKLoginManager alloc] logOut];
                [loginViewController.navigationController popViewControllerAnimated:YES];
            }
        }];
    }
}

-(void) loginButtonDidLogOut:(FBSDKLoginButton *)loginButton{

}

-(void) loginWithFacebookInfo{
    [[[FBSDKGraphRequest alloc] initWithGraphPath:@"/me?fields=id,email,first_name,last_name" parameters:nil]
     startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
         if (!error) {
             if([result isKindOfClass:[NSDictionary class]]){
                 NSString *email = [result objectForKey:@"email"];
                 NSString *firstName = [result objectForKey:@"first_name"];
                 NSString *lastName = [result objectForKey:@"last_name"];
                 if(customerModel == nil)
                     customerModel = [[SimiCustomerModel alloc] init];
                 if(email && firstName && lastName){
                     NSString* password = [[SimiGlobalVar sharedInstance] md5PassWordWithEmail:email];
                     [customerModel loginWithSocialEmail:email password:password firstName:firstName lastName:lastName];
                     NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
                     NSString *bundleIdentifier = [NSString stringWithFormat:@"%@", [info objectForKey:@"CFBundleIdentifier"]];
                     KeychainItemWrapper *wrapper = [[KeychainItemWrapper alloc] initWithIdentifier:bundleIdentifier accessGroup:nil];
                     [wrapper setObject:email forKey:(__bridge id)(kSecAttrAccount)];
                     [wrapper setObject:password forKey:(__bridge id)(kSecAttrDescription)];
                     
                     [[NSNotificationCenter defaultCenter] postNotificationName:SimiFaceBookWorker_StartLoginWithFaceBook object:nil];
                     [loginViewController startLoadingData];
                 }
             }
         }
     }];
}

//login and logout notification
-(void) didLogin:(NSNotification*) noti{
    [loginViewController stopLoadingData];
}

-(void) didLogout: (NSNotification* )noti{
    if([FBSDKAccessToken currentAccessToken]){
        [[FBSDKLoginManager alloc] logOut];
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

-(void) resetFacebookViewPosition:(NSNotification*) noti{
    if(isShowFacebookView){
        CGRect frame = fbView.frame;
        frame.origin.x += widthFacebookView;
        frame.size.width = 0;
        [UIView animateWithDuration:0.15f animations:^{
            [fbView setFrame:frame];
            [fbButton setTransform:CGAffineTransformMakeRotation(0)];
        } completion:^(BOOL finished) {
            
        }];
        isShowFacebookView = NO;
    }
}

@end
