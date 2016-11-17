//
//  SCFacebookInitWorker.m
//  SimiCartPluginFW
//
//  Created by Hoang Van Trung on 8/24/16.
//  Copyright © 2016 Trueplus. All rights reserved.
//

#import "SCFacebookInitWorker.h"
#import <SimiCartBundle/SCAppDelegate.h>
//Product More View notifications
#define SCProductMoreViewController_ViewDidLoadBefore @"SCProductViewMoreController-ViewDidLoadBefore"
#define SCProductMoreViewController_InitViewMoreAction @"SCProductMoreViewController_InitViewMoreAction"
#define SCProductMoreViewController_BeforeTouchMoreAction @"SCProductMoreViewController-BeforeTouchMoreAction"
//Login view controller notifications
#define SCLoginViewController_InitCellsAfter @"SCLoginViewController_InitCellsAfter"
#define ApplicationOpenURL @"ApplicationOpenURL"
#define SCLoginViewController_InitCellAfter @"SCLoginViewController_InitCellAfter"
#define FacebookLoginCell @"FacebookLoginCell"
#define SimiFaceBookWorker_StartLoginWithFaceBook @"SimiFaceBookWorker_StartLoginWithFaceBook"

#define COMMENT_VIEW_TAG 0
#define COMMENT_HTML @"\
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
                    "

@implementation SCFacebookInitWorker
{
    SimiViewController* loginViewController, *currentlyViewController;
    NSDictionary* product;
    NSArray* cells;
    SimiCustomerModel* customerModel;
    NSString* facebookAppID;
    MoreActionView* moreActionView;
    float widthFacebookView;
    UIView *commentView;
    UIView* fbView;
    FBSDKLikeControl* fbLikeControl;
    UIButton* fbButton;
    float fbButtonSize;
    UIButton* fbShareButton, *fbCommentButton;
    BOOL isShowFacebookView, isShowCommentView, isHideTabBar;
    UIActivityIndicatorView* activityView;
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
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:SCLoginViewController_InitCellsAfter object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:ApplicationOpenURL object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:SCLoginViewController_InitCellAfter object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didLogin:) name:DidLogin object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didLogout:) name:DidLogout object:nil];
        
        
        facebookAppID = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"FacebookAppID"];
        fbButtonSize = 50;
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
    }else if([noti.name isEqualToString:SCLoginViewController_InitCellAfter]){
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

- (void)initViewMoreAction:(NSNotification*)noti
{
    moreActionView = noti.object;
    if(!fbButton ){
        fbButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, fbButtonSize, fbButtonSize)];
        [fbButton setImage:[UIImage imageNamed:@"facebookconnect_ic_detail"] forState:UIControlStateNormal];
        [fbButton setImageEdgeInsets:UIEdgeInsetsMake(9, 9, 9, 9)];
        [fbButton.layer setCornerRadius:fbButtonSize/2.0f];
        [fbButton.layer setShadowOffset:CGSizeMake(1, 1)];
        [fbButton.layer setShadowRadius:2];
        fbButton.layer.shadowOpacity = 0.5;
        [fbButton setBackgroundColor:[UIColor whiteColor]];
        [fbButton addTarget:self action:@selector(fbButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
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
    
    if (fbLikeControl == nil) {
        fbLikeControl = [[FBSDKLikeControl alloc]initWithFrame:CGRectMake(0,likeViewSize/5,likeViewSize, likeViewSize)];
        fbLikeControl.transform = CGAffineTransformMakeScale(0.7, 0.7);
        fbLikeControl.likeControlStyle = FBSDKLikeControlStyleBoxCount;
    }
    fbLikeControl.objectID = productURL;
    
    [facebookLikeView addSubview:fbLikeBackgroundImageView];
    [facebookLikeView addSubview:fbLikeControl];
    [facebookLikeView setBackgroundColor:[UIColor clearColor]];
    
    //fbComment button
    fbCommentButton = [[UIButton alloc]initWithFrame:CGRectMake([SimiGlobalVar scaleValue:92], 5, fbButtonSize, fbButtonSize)];
    [fbCommentButton setImage:[UIImage imageNamed:@"facebookconnect_comment"] forState:UIControlStateNormal];
    [fbCommentButton setImageEdgeInsets:UIEdgeInsetsMake(9, 9, 9, 9)];
    [fbCommentButton.layer setCornerRadius:fbButtonSize/2.0f];
    [fbCommentButton.layer setShadowOffset:CGSizeMake(1, 1)];
    [fbCommentButton.layer setShadowRadius:2];
    fbCommentButton.layer.shadowOpacity = 0.5;
    [fbCommentButton setBackgroundColor:[UIColor whiteColor]];
    [fbCommentButton addTarget:self action:@selector(fbCommentButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    fbShareButton = [[UIButton alloc]initWithFrame:CGRectMake([SimiGlobalVar scaleValue:170], 5, fbButtonSize, fbButtonSize)];
    [fbShareButton setImage:[UIImage imageNamed:@"facebookconnect_share"] forState:UIControlStateNormal];
    [fbShareButton setImageEdgeInsets:UIEdgeInsetsMake(9, 9, 9, 9)];
    [fbShareButton.layer setCornerRadius:fbButtonSize/2.0f];
    [fbShareButton.layer setShadowOffset:CGSizeMake(1, 1)];
    [fbShareButton.layer setShadowRadius:2];
    fbShareButton.layer.shadowOpacity = 0.5;
    [fbShareButton setBackgroundColor:[UIColor whiteColor]];
    [fbShareButton addTarget:self action:@selector(fbShareButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        widthFacebookView = SCREEN_WIDTH - fbButton.frame.size.width - 30;
    else
        widthFacebookView = 250;
    
    fbView = [UIView new];
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        fbView.frame =  CGRectMake(SCREEN_WIDTH - fbButton.frame.size.width - 15, moreActionView.frame.origin.y - moreActionView.heightMoreView + fbButton.frame.origin.y -5, 0, fbButton.frame.size.height+10);
    else if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        fbView.frame =  CGRectMake(CGRectGetWidth(currentlyViewController.view.frame) - fbButton.frame.size.width - 15, moreActionView.frame.origin.y - moreActionView.heightMoreView + fbButton.frame.origin.y -5, 0, fbButton.frame.size.height+10);
    [fbView addSubview:facebookLikeView];
    [fbView addSubview:fbCommentButton];
    [fbView addSubview:fbShareButton];
    
    [currentlyViewController.view addSubview:fbView];
    fbView.clipsToBounds = YES;
}

- (void)beforeTouchMoreAction:(NSNotification*)noti
{
    if(moreActionView.isShowViewMoreAction && isShowFacebookView){
        CGRect frame = fbView.frame;
        frame.origin.x += widthFacebookView;
        frame.size.width = 0;
        [UIView animateWithDuration:0.15f animations:^{
            [fbView setFrame:frame];
            [fbButton setTransform:CGAffineTransformMakeRotation(0)];
        } completion:^(BOOL finished) {
            
        }];
        isShowFacebookView = !isShowFacebookView;
    }
}

//Handling button clicking
-(void) fbButtonClicked: (id) sender{
    if (!isShowFacebookView) {
        CGRect frame = fbView.frame;
        frame.origin.x -= widthFacebookView;
        frame.size.width = widthFacebookView;
        [UIView animateWithDuration:0.15f animations:^{
            [fbView setFrame:frame];
            [fbButton setTransform:CGAffineTransformMakeRotation(M_PI_4)];
        } completion:^(BOOL finished) {
            
        }];
    }else
    {
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
        isShowCommentView = YES;
        if(!commentView){
            commentView = [[UIView alloc]init];
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
            [btnClearAllFacebookCookies setTitle:@"Logout your facebook account" forState:UIControlStateNormal];
            [btnClearAllFacebookCookies setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [btnClearAllFacebookCookies setBackgroundColor:[UIColor colorWithRed:70.0/255 green:98.0/255 blue:158.0/255 alpha:1.0]];
            [btnClearAllFacebookCookies.layer setCornerRadius:5.0f];
            [btnClearAllFacebookCookies.layer setMasksToBounds:YES];
            [btnClearAllFacebookCookies addTarget:self action:@selector(btnClearAllFacebookCookiesClicked:) forControlEvents:UIControlEventTouchUpInside];
            [btnClearAllFacebookCookies.titleLabel setFont:[UIFont fontWithName:THEME_FONT_NAME size:THEME_FONT_SIZE]];
            [commentView addSubview:btnClearAllFacebookCookies];
            
            
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
                    if (currentVC.tabBarController.tabBar.isHidden) {
                        isHideTabBar = YES;
                    }
                    currentVC.tabBarController.tabBar.hidden = YES;
                    [currentVC.view addSubview:commentView];
                }else
                {    UIWindow *currentVC = [[UIApplication sharedApplication] keyWindow];
                    [currentVC addSubview:commentView];
                }
        }
        if(!activityView){
            activityView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
            activityView.frame = commentWebView.frame;
            activityView.hidesWhenStopped = YES;
            [commentView addSubview:activityView];
        }
            
        commentHTMLString = [NSString stringWithFormat:COMMENT_HTML,commentWebView.frame.size.width,facebookAppID,productURL ];
            [commentWebView loadHTMLString:commentHTMLString baseURL:[NSURL URLWithString:productURL]];
            
        [activityView startAnimating];
        
        commentWebView.alpha = 1.0;
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
        if (!isHideTabBar) {
            currentVC.tabBarController.tabBar.hidden = YES;
        }
    }else
    {
        //        [[currentVC.view.subviews lastObject] removeFromSuperview];
        [commentView removeFromSuperview];
    }
}

#pragma mark UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString *stringURL = [NSString stringWithFormat:@"%@",request.URL];
    if ([stringURL containsString:@"facebook.com/plugins/comments.php?api_key"]) {
        [activityView stopAnimating];
        [activityView removeFromSuperview];
    }else if([stringURL containsString:@"facebook.com/plugins/close_popup.php"]){
        [commentWebView loadHTMLString:commentHTMLString baseURL:[NSURL URLWithString:productURL]];
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



#pragma mark FBSDKLoginButtonDelegate
-(void) loginButton:(FBSDKLoginButton *)loginButton didCompleteWithResult:(FBSDKLoginManagerLoginResult *)result error:(NSError *)error{
 
    if([[FBSDKAccessToken currentAccessToken] hasGranted:@"email"]){
        [self loginWithFacebookInfo];
    }else{
        [[FBSDKLoginManager alloc] logInWithReadPermissions:@[@"email"] fromViewController:loginViewController handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
            if([[FBSDKAccessToken currentAccessToken] hasGranted:@"email"]){
                [self loginWithFacebookInfo];
            }else{
                UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:SCLocalizedString(@"Opps") message:SCLocalizedString(@"Something went wrong") delegate:nil cancelButtonTitle:SCLocalizedString(@"OK") otherButtonTitles:nil, nil];
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

@end
