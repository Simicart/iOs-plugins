//
//  FacebookConnect.m
//  SimiCartPluginFW
//
//  Created by NghiepLy on 6/7/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import "FacebookConnect.h"

@implementation FacebookConnect
@synthesize btnComment, btnCommentWithOtherAccount, btnShare;
@synthesize isShowFacebookView, isHideTabBar, isLoginWithComment, isShowComment;
@synthesize lblCountLike;
@synthesize tagFacebookView, section, productModel, productViewController, productViewControllerPad;
@synthesize stringFacebookAppID, stringHtml;
@synthesize tagView, facebookView, fbLikeControl, webComment, activityView;
@synthesize buttonFacebook;


- (instancetype)initWithObject:(id)object
{
    self = [super init];
    if (self) {
#pragma mark Event For Core & Matrix Theme
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"SCProductViewController-InitCellsAfter" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"InitializedProductCell-After" object:nil];
        
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"SCProductViewControllerPad-AfterConfigAddToCartButton" object:self.productViewControllerPad];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"SCProductViewController_Pad-ViewWillDisappear" object:self.productViewControllerPad];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"SCProductViewController_Pad-ViewWillAppear" object:self.productViewControllerPad];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"SCProductViewControllerPad_Theme01-DidGetProductInfomation" object:self.productViewController];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"ApplicationDidBecomeActive" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"ApplicationWillTerminate" object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"SimiFaceBookWorker_StartLoginWithFaceBook" object:nil];
        
#pragma mark Event For ZTheme
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotificationFromZTheme:) name:@"ZThemeProductViewController-ViewWillAppear" object:self.productViewController];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotificationFromZTheme:) name:@"ZThemeProductViewController_DidSetNewProductModel" object:self.productViewController];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotificationFromZTheme:) name:@"ZThemeProductViewController_BeginChangeProduct" object:self.productViewController];
        
        stringFacebookAppID = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"FacebookAppID"];
        isLoginWithComment = NO;
    }
    return self;
}

#pragma mark Notification Facebook for Core & Matrix Theme
- (void)didReceiveNotification:(NSNotification *)noti
{
    if ([noti.name isEqualToString:@"SCProductViewController-InitCellsAfter"]) {
        if ([productViewController isEqual:(SCProductViewController*)[noti.userInfo valueForKey:@"controller"]]) {
            NSMutableArray *cells = noti.object;
            section = [cells objectAtIndex:0];
            SimiRow *row = [[SimiRow alloc]initWithIdentifier:@"FaceBookSocial-Cell" height:40 sortOrder:101];
            [section addObject:row];
            [section sortItems];
        }
    }else if([noti.name isEqualToString:@"SCProductViewControllerPad-AfterConfigAddToCartButton"])
    {
        if ([productViewControllerPad isEqual:(SCProductViewController_Pad*)noti.object]) {
            productModel = productViewControllerPad.product;
            tagView = 2000;
            tagFacebookView = 2001;
            for (UIView *view in productViewControllerPad.scrollView.subviews) {
                if (view.tag == tagView || view.tag == tagFacebookView) {
                    [view removeFromSuperview];
                }
            }
            if ( facebookView == nil) {
                facebookView = [[UIView alloc]init];
                facebookView.tag = tagView;
                
                fbLikeControl = [[FBLikeControl alloc]initWithFrame:CGRectMake(0, 5, 50, 20)];
                fbLikeControl.likeControlStyle = FBLikeControlStyleButton;
                [facebookView addSubview:fbLikeControl];
                
                lblCountLike = [[UILabel alloc]initWithFrame:CGRectMake(70, 0, 30, 40)];
                [lblCountLike setTextColor:[UIColor darkGrayColor]];
                [lblCountLike setFont:[UIFont fontWithName:THEME_FONT_NAME size:10]];
                [lblCountLike setTextAlignment:NSTextAlignmentCenter];
                [facebookView addSubview:lblCountLike];
                
                UIImageView *imageCountLike = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"facebookconnect_countlike"]];
                [imageCountLike setFrame:CGRectMake(70, 10, 30, 20)];
                [facebookView addSubview:imageCountLike];
                
                btnComment = [[UIButton alloc]initWithFrame:CGRectMake(115, 0, 70, 40)];
                [btnComment setImage:[UIImage imageNamed:@"facebookconnect_comment"] forState:UIControlStateNormal];
                [btnComment setBackgroundImage:[UIImage imageNamed:@"facebookconnect_backgroundbutton"] forState:UIControlStateHighlighted];
                [btnComment setImageEdgeInsets:UIEdgeInsetsMake(5, 15, 5, 15)];
                [btnComment addTarget:self action:@selector(didClickCommentButton) forControlEvents:UIControlEventTouchUpInside];
                [facebookView addSubview:btnComment];
                
                btnShare = [[UIButton alloc]initWithFrame:CGRectMake(220, 0, 60, 40)];
                [btnShare setImage:[UIImage imageNamed:@"facebookconnect_share"] forState:UIControlStateNormal];
                [btnShare setBackgroundImage:[UIImage imageNamed:@"facebookconnect_backgroundbutton"] forState:UIControlStateHighlighted];
                [btnShare setImageEdgeInsets:UIEdgeInsetsMake(8, 18, 8, 18)];
                [btnShare addTarget:self action:@selector(didClickShareButton) forControlEvents:UIControlEventTouchUpInside];
                [facebookView addSubview:btnShare];
            }
            
            CGRect frame = productViewControllerPad.btaddToCart.frame;
            frame.origin.y = productViewControllerPad.scrollHeightContent;
            frame.size.width = 300;
            frame.size.height = 50;
            productViewControllerPad.scrollHeightContent += 50;
            facebookView .frame = frame;
            fbLikeControl.objectID = [productModel valueForKey:@"product_url"];
            
            [productViewControllerPad.scrollView addSubview:facebookView];
            [self getDataFaceBookDataOnOtherThread];
        }
    }else if ([noti.name isEqualToString:@"InitializedProductCell-After"])
    {
        if ([productViewController isEqual:(SCProductViewController*)[noti.userInfo valueForKey:@"controller"]]) {
            NSIndexPath *indexPath = [noti.userInfo valueForKey:@"indexPath"];
            SimiRow *row = [section.rows objectAtIndex:indexPath.row];
            if ([row.identifier isEqualToString:@"FaceBookSocial-Cell"]) {
                productModel = [noti.userInfo valueForKey:@"productmodel"];
                productViewController = [noti.userInfo valueForKey:@"controller"];
                UITableViewCell *cell = noti.object;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                if (fbLikeControl == nil) {
                    fbLikeControl = [[FBLikeControl alloc]initWithFrame:CGRectMake(15, 5, 50, 20)];
                    fbLikeControl.likeControlStyle = FBLikeControlStyleButton;
                }
                fbLikeControl.objectID = [productModel valueForKey:@"product_url"];
                [cell addSubview:fbLikeControl];
                
                lblCountLike = [[UILabel alloc]initWithFrame:CGRectMake(90, 0, 30, 40)];
                [lblCountLike setTextColor:[UIColor darkGrayColor]];
                [lblCountLike setFont:[UIFont fontWithName:THEME_FONT_NAME size:10]];
                [lblCountLike setTextAlignment:NSTextAlignmentCenter];
                [cell addSubview:lblCountLike];
                
                UIImageView *imageCountLike = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"facebookconnect_countlike"]];
                [imageCountLike setFrame:CGRectMake(90, 10, 30, 20)];
                [cell addSubview:imageCountLike];
                
                btnComment = [[UIButton alloc]initWithFrame:CGRectMake(160, 0, 70, 40)];
                [btnComment setImage:[UIImage imageNamed:@"facebookconnect_comment"] forState:UIControlStateNormal];
                [btnComment setBackgroundImage:[UIImage imageNamed:@"facebookconnect_backgroundbutton"] forState:UIControlStateHighlighted];
                [btnComment setImageEdgeInsets:UIEdgeInsetsMake(5, 15, 5, 15)];
                [btnComment addTarget:self action:@selector(didClickCommentButton) forControlEvents:UIControlEventTouchUpInside];
                [cell addSubview:btnComment];
                
                btnShare = [[UIButton alloc]initWithFrame:CGRectMake(250, 0, 60, 40)];
                [btnShare setImage:[UIImage imageNamed:@"facebookconnect_share"] forState:UIControlStateNormal];
                [btnShare setBackgroundImage:[UIImage imageNamed:@"facebookconnect_backgroundbutton"] forState:UIControlStateHighlighted];
                [btnShare setImageEdgeInsets:UIEdgeInsetsMake(8, 18, 8, 18)];
                [btnShare addTarget:self action:@selector(didClickShareButton) forControlEvents:UIControlEventTouchUpInside];
                [cell addSubview:btnShare];
                [self getDataFaceBookDataOnOtherThread];
            }
        }
    }else if([noti.name isEqualToString:@"SCProductViewController_Pad-ViewWillDisappear"])
    {
        if (isShowComment) {
            isShowComment = !isShowComment;
            [self didClickClose];
        }
    }else if ([noti.name isEqualToString:@"ApplicationDidBecomeActive"])
    {
        [self getDataFaceBookDataOnOtherThread];
    }else if([noti.name isEqualToString:@"SCProductViewController_Pad-ViewWillAppear"])
    {
        productViewControllerPad = noti.object;
    }else if ([noti.name isEqualToString:@"ApplicationWillTerminate"])
    {
        NSHTTPCookieStorage* cookies = [NSHTTPCookieStorage sharedHTTPCookieStorage];
        NSArray* facebookCookies = [cookies cookiesForURL:
                                    [NSURL URLWithString:@"https://facebook.com"]];
        for (NSHTTPCookie* cookie in facebookCookies) {
            [cookies deleteCookie:cookie];
        }
    }else if([noti.name isEqualToString:@"SimiFaceBookWorker_StartLoginWithFaceBook"])
    {
        isLoginWithComment = NO;
        [btnCommentWithOtherAccount setHidden:YES];
    }else if ([noti.name isEqualToString:@"SCProductViewControllerPad_Theme01-DidGetProductInfomation"])
    {
        if ([self.productViewController isEqual:(SCProductViewController*)noti.object]) {
            productModel = [noti.userInfo valueForKey:@"productmodel"];
            tagView = 2000;
            tagFacebookView = 2001;
            if (facebookView == nil) {
                facebookView = [[UIView alloc]init];
                facebookView.tag = tagView;
                
                fbLikeControl = [[FBLikeControl alloc]initWithFrame:CGRectMake(0, 5, 50, 20)];
                fbLikeControl.likeControlStyle = FBLikeControlStyleButton;
                [facebookView addSubview:fbLikeControl];
                
                lblCountLike = [[UILabel alloc]initWithFrame:CGRectMake(70, 0, 30, 40)];
                [lblCountLike setTextColor:[UIColor darkGrayColor]];
                [lblCountLike setFont:[UIFont fontWithName:THEME_FONT_NAME size:10]];
                [lblCountLike setTextAlignment:NSTextAlignmentCenter];
                [facebookView addSubview:lblCountLike];
                
                UIImageView *imageCountLike = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"facebookconnect_countlike"]];
                [imageCountLike setFrame:CGRectMake(70, 10, 30, 20)];
                [facebookView addSubview:imageCountLike];
                
                btnComment = [[UIButton alloc]initWithFrame:CGRectMake(115, 0, 70, 40)];
                [btnComment setImage:[UIImage imageNamed:@"facebookconnect_comment"] forState:UIControlStateNormal];
                [btnComment setBackgroundImage:[UIImage imageNamed:@"facebookconnect_backgroundbutton"] forState:UIControlStateHighlighted];
                [btnComment setImageEdgeInsets:UIEdgeInsetsMake(5, 15, 5, 15)];
                [btnComment addTarget:self action:@selector(didClickCommentButton) forControlEvents:UIControlEventTouchUpInside];
                [facebookView addSubview:btnComment];
                
                btnShare = [[UIButton alloc]initWithFrame:CGRectMake(220, 0, 60, 40)];
                [btnShare setImage:[UIImage imageNamed:@"facebookconnect_share"] forState:UIControlStateNormal];
                [btnShare setBackgroundImage:[UIImage imageNamed:@"facebookconnect_backgroundbutton"] forState:UIControlStateHighlighted];
                [btnShare setImageEdgeInsets:UIEdgeInsetsMake(8, 18, 8, 18)];
                [btnShare addTarget:self action:@selector(didClickShareButton) forControlEvents:UIControlEventTouchUpInside];
                [facebookView addSubview:btnShare];
            }
            
            CGRect frame = CGRectMake(135, 660, 300, 50);
            facebookView .frame = frame;
            fbLikeControl.objectID = [productModel valueForKey:@"product_url"];
    
            [self.productViewController.view addSubview:facebookView];
            [self getDataFaceBookDataOnOtherThread];
        }
    }
}
#pragma mark Facebook Action
- (void)getDataFaceBookDataOnOtherThread
{
    NSThread* myThread = [[NSThread alloc] initWithTarget:self
                                                 selector:@selector(getFaceBookInfomation)
                                                   object:nil];
    [myThread start];
}

- (void)getFaceBookInfomation
{
    if ([productModel valueForKey:@"product_url"] && ![[productModel valueForKey:@"product_url"] isEqualToString:@""]) {
        NSString *stringURLPath = [NSString stringWithFormat:@"http://graph.facebook.com/fql?q=SELECT+total_count+FROM+link_stat+WHERE+url='%@'",[productModel valueForKey:@"product_url"]];
        NSURL *url = [NSURL URLWithString:stringURLPath];
        NSData *jsonData = [NSData dataWithContentsOfURL:url];
        if(jsonData != nil)
        {
            NSError *error = nil;
            id result = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
            if (error == nil)
                [self performSelectorOnMainThread:@selector(didGetFacebookData:) withObject:result waitUntilDone:NO];
        }
    }
}

- (void)didGetFacebookData:(id)result
{
    NSDictionary *data = (NSDictionary*)result;
    NSMutableArray *array = (NSMutableArray*)[data valueForKey:@"data"];
    if (array.count > 0) {
        NSDictionary *fbData = (NSDictionary*)[array objectAtIndex:0];
        int countLike = [[fbData valueForKey:@"total_count"] intValue];
        if (countLike < 1000) {
            lblCountLike.text = [NSString stringWithFormat:@"%@",[fbData valueForKey:@"total_count"]];
        }else
        {
            float floatCount = ((float)countLike)/1000;
            lblCountLike.text = [NSString stringWithFormat:@"%.1fk",floatCount];
        }
    }
}

- (void)didClickShareButton
{
    FBLinkShareParams *params = [[FBLinkShareParams alloc] init];
    if ([productModel valueForKey:@"product_url"]) {
        params.link = [NSURL URLWithString:[productModel valueForKey:@"product_url"]];
    }
    if ([productModel valueForKey:@"product_name"]) {
        params.name = [NSString stringWithFormat:@"%@",[productModel valueForKey:@"product_name"]];
    }
    NSMutableArray *arrayImage = (NSMutableArray *)[productModel valueForKey:@"product_images"];
    if (arrayImage.count > 0) {
        params.picture = [NSURL URLWithString:[arrayImage objectAtIndex:0]];
    }
    if ([productModel valueForKey:@"product_short_description"] && ![[productModel valueForKey:@"product_short_description"] isEqualToString:@""]) {
        params.linkDescription = [NSString stringWithFormat:@"%@",[productModel valueForKey:@"product_short_description"]];
    }
    if ([FBDialogs canPresentShareDialogWithParams:params]) {
        [FBDialogs presentShareDialogWithParams:params clientState:@{} handler:^(FBAppCall *call,NSDictionary *results, NSError *error)
         {
             if(error) {
                 // An error occurred, we need to handle the error
                 // See: https://developers.facebook.com/docs/ios/errors
                 NSLog(@"Error publishing story: %@", error.description);
             } else {
                 // Success
                 NSLog(@"result %@", results);
             }
         }];
        // If the Facebook app is NOT installed and we can't present the share dialog
    }else {
        // FALLBACK: publish just a link using the Feed dialog
        
        // Put together the dialog parameters
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       [productModel valueForKey:@"product_name"], @"name",
                                       [NSString stringWithFormat:@"%@",[productModel valueForKey:@"product_short_description"]], @"description",
                                       [productModel valueForKey:@"product_url"], @"link",
                                       [arrayImage objectAtIndex:0], @"picture",
                                       nil];
        
        // Show the feed dialog
        [FBWebDialogs presentFeedDialogModallyWithSession:nil
                                               parameters:params
                                                  handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
                                                      if (error) {
                                                          // An error occurred, we need to handle the error
                                                          // See: https://developers.facebook.com/docs/ios/errors
                                                          NSLog(@"Error publishing story: %@", error.description);
                                                      } else {
                                                          if (result == FBWebDialogResultDialogNotCompleted) {
                                                              // User canceled.
                                                              NSLog(@"User cancelled.");
                                                          } else {
                                                              // Handle the publish feed callback
                                                              NSDictionary *urlParams = [self parseURLParams:[resultURL query]];
                                                              
                                                              if (![urlParams valueForKey:@"post_id"]) {
                                                                  // User canceled.
                                                                  NSLog(@"User cancelled.");
                                                                  
                                                              } else {
                                                                  // User clicked the Share button
                                                                  NSString *result = [NSString stringWithFormat: @"Posted story, id: %@", [urlParams valueForKey:@"post_id"]];
                                                                  NSLog(@"result %@", result);
                                                              }
                                                          }
                                                      }
                                                  }];
    }
    
}

- (NSDictionary*)parseURLParams:(NSString *)query {
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    for (NSString *pair in pairs) {
        NSArray *kv = [pair componentsSeparatedByString:@"="];
        NSString *val =
        [kv[1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        params[kv[0]] = val;
    }
    return params;
}

- (void)didClickCommentButton
{
    isShowComment = YES;
    UIView *viewBackGround = [[UIView alloc]init];
    viewBackGround.tag = tagView;
    UIViewController *currentVC = [(UITabBarController *)[[(SCAppDelegate *)[[UIApplication sharedApplication] delegate] window] rootViewController] selectedViewController];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        viewBackGround.frame = [UIScreen mainScreen].bounds;
    }else
    {
        if (productViewControllerPad) {
            viewBackGround.frame = productViewControllerPad.view.bounds;
        }else
        {
            viewBackGround.frame = currentVC.view.bounds;
        }
    }
    [viewBackGround setBackgroundColor:[UIColor clearColor]];
    UIImageView *imgBackground = [[UIImageView alloc]initWithFrame:viewBackGround.bounds];
    [imgBackground setBackgroundColor:[UIColor blackColor]];
    [imgBackground setAlpha:0.5];
    imgBackground.userInteractionEnabled = YES;
    [viewBackGround addSubview:imgBackground];
    
    CGRect frame = viewBackGround.bounds;
    frame.origin.x += 10;
    frame.origin.y += 20;
    frame.size.width -= 20;
    frame.size.height -= 30;
    UIView *viewContent = [[UIView alloc]initWithFrame:frame];
    [viewContent setBackgroundColor:[UIColor whiteColor]];
    [viewContent.layer setCornerRadius:10.0f];
    [viewContent.layer setMasksToBounds:YES];
    [viewBackGround addSubview:viewContent];
    
    btnCommentWithOtherAccount = [[UIButton alloc]initWithFrame:CGRectMake(20, 25, frame.size.width - 60, 35)];
    [btnCommentWithOtherAccount setTitle:@" Comment with another account" forState:UIControlStateNormal];
    [btnCommentWithOtherAccount setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnCommentWithOtherAccount setBackgroundColor:[UIColor colorWithRed:70.0/255 green:98.0/255 blue:158.0/255 alpha:1.0]];
    [btnCommentWithOtherAccount.layer setCornerRadius:5.0f];
    [btnCommentWithOtherAccount.layer setMasksToBounds:YES];
    [btnCommentWithOtherAccount addTarget:self action:@selector(didClickChangeAccount) forControlEvents:UIControlEventTouchUpInside];
    [btnCommentWithOtherAccount.titleLabel setFont:[UIFont fontWithName:THEME_FONT_NAME size:THEME_FONT_SIZE]];
    [viewBackGround addSubview:btnCommentWithOtherAccount];
    if (isLoginWithComment) {
        [btnCommentWithOtherAccount setHidden:NO];
    }else
    {
        [btnCommentWithOtherAccount setHidden:YES];
    }
    
    UIButton *btnClose = [[UIButton alloc]initWithFrame:CGRectMake(frame.size.width - 40, 20, 50, 50)];
    [btnClose setImage:[UIImage imageNamed:@"facebookconnect_close"] forState:UIControlStateNormal];
    [btnClose setImageEdgeInsets:UIEdgeInsetsMake(10, 26, 26, 10)];
    [btnClose setBackgroundColor:[UIColor clearColor]];
    [btnClose addTarget:self action:@selector(didClickClose) forControlEvents:UIControlEventTouchUpInside];
    [viewBackGround addSubview:btnClose];
    
    CGRect frameWebView = frame;
    frameWebView.origin.y += 50;
    frameWebView.size.height -= 60;
    webComment = [[UIWebView alloc]initWithFrame:frameWebView];
    webComment.delegate = self;
    stringHtml = @"\
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
    stringHtml = [NSString stringWithFormat:stringHtml,frameWebView.size.width,stringFacebookAppID,[productModel valueForKey:@"product_url"] ];
    [webComment loadHTMLString:stringHtml baseURL:[NSURL URLWithString:[productModel valueForKey:@"product_url"]]];
    [viewBackGround addSubview:webComment];
    
    activityView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    activityView.frame = webComment.frame;
    activityView.hidesWhenStopped = YES;
    [viewBackGround addSubview:activityView];
    [activityView startAnimating];
    
    webComment.alpha = 1.0;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        UIViewController *currentVC = [(UITabBarController *)[[(SCAppDelegate *)[[UIApplication sharedApplication] delegate] window] rootViewController] selectedViewController];
        if (currentVC.tabBarController.tabBar.isHidden) {
            isHideTabBar = YES;
        }
        currentVC.tabBarController.tabBar.hidden = YES;
        [currentVC.view addSubview:viewBackGround];
    }else
    {
        if (productViewControllerPad) {
            [productViewControllerPad.view addSubview:viewBackGround];
        }else
        {
            [currentVC.view addSubview:viewBackGround];
        }
    }
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString *stringURL = [NSString stringWithFormat:@"%@",request.URL];
    if ([stringURL containsString:@"https://m.facebook.com/plugins/login_success.php?refsrc"] || [stringURL containsString:@"https://m.facebook.com/plugins/login_success.php?_rdr"]) {
        [webComment loadHTMLString:stringHtml baseURL:[NSURL URLWithString:[productModel valueForKey:@"product_url"]]];
        isLoginWithComment = YES;
        [btnCommentWithOtherAccount setHidden:NO];
        return NO;
    }
    
    if ([stringURL containsString:@"https://m.facebook.com/plugins/comments.php?api_key"]) {
        [activityView stopAnimating];
        [activityView removeFromSuperview];
    }
    return YES;
}

- (void)didClickChangeAccount
{
    isLoginWithComment = NO;
    [btnCommentWithOtherAccount setHidden:YES];
    NSHTTPCookieStorage* cookies = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSArray* facebookCookies = [cookies cookiesForURL:
                                [NSURL URLWithString:@"https://facebook.com"]];
    for (NSHTTPCookie* cookie in facebookCookies) {
        [cookies deleteCookie:cookie];
    }
    [webComment loadHTMLString:stringHtml baseURL:[NSURL URLWithString:[productModel valueForKey:@"product_url"]]];
}

-(void)didClickClose
{
    UIViewController *currentVC = [(UITabBarController *)[[(SCAppDelegate *)[[UIApplication sharedApplication] delegate] window] rootViewController] selectedViewController];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [[currentVC.view.subviews lastObject] removeFromSuperview];
        if (!isHideTabBar) {
            currentVC.tabBarController.tabBar.hidden = NO;
        }
    }else
    {
        if (productViewControllerPad)
        {
            UIView *subView = [productViewControllerPad.view.subviews lastObject];
            if (subView.tag == tagView) {
                [[productViewControllerPad.view.subviews lastObject]removeFromSuperview];
            }
        }else
        {
            [[currentVC.view.subviews lastObject] removeFromSuperview];
        }
    }
}
#pragma mark Facebook For ZTheme
- (void)didReceiveNotificationFromZTheme:(NSNotification *)noti
{
    if ([self.productViewController isEqual:(SCProductViewController*)noti.object]) {
        if ([noti.name isEqualToString:@"ZThemeProductViewController-ViewWillAppear"]) {
            if (buttonFacebook == nil) {
                if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
                    buttonFacebook = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetWidth(self.productViewController.view.frame) - 65, 40, 65, 65)];
                    [buttonFacebook setImageEdgeInsets:UIEdgeInsetsMake(15, 15, 15, 15)];
                }else
                {
                    buttonFacebook = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetWidth(self.productViewController.view.frame) - 90, 70, 65, 65)];
                    [buttonFacebook setImageEdgeInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
                }
                [buttonFacebook setBackgroundColor:[UIColor clearColor]];
                [buttonFacebook setImage:[UIImage imageNamed:@"facebookconnect_ic_detail"] forState:UIControlStateNormal];
                [buttonFacebook addTarget:self action:@selector(didTouchButtonFacebook:) forControlEvents:UIControlEventTouchUpInside];
                [buttonFacebook setHidden:YES];
                [productViewController.view addSubview:buttonFacebook];
                
                if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
                    facebookView = [[UIView alloc]initWithFrame:CGRectMake(CGRectGetWidth(self.productViewController.view.frame), 105, 0, 0)];
                }else
                {
                    facebookView = [[UIView alloc]initWithFrame:CGRectMake(CGRectGetWidth(self.productViewController.view.frame), 135, 0, 0)];
                }
                [facebookView setBackgroundColor:[UIColor colorWithWhite:1.0 alpha:0.4]];
                facebookView.clipsToBounds = YES;
                
                fbLikeControl = [[FBLikeControl alloc]initWithFrame:CGRectMake(15, 5, 50, 20)];
                fbLikeControl.likeControlStyle = FBLikeControlStyleButton;
                fbLikeControl.objectID = @"";
                [facebookView addSubview:fbLikeControl];
                
                lblCountLike = [[UILabel alloc]initWithFrame:CGRectMake(90, 0, 30, 40)];
                [lblCountLike setTextColor:[UIColor darkGrayColor]];
                [lblCountLike setFont:[UIFont fontWithName:THEME_FONT_NAME size:10]];
                [lblCountLike setTextAlignment:NSTextAlignmentCenter];
                [facebookView addSubview:lblCountLike];
                
                UIImageView *imageCountLike = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"facebookconnect_countlike"]];
                [imageCountLike setFrame:CGRectMake(90, 10, 30, 20)];
                [facebookView addSubview:imageCountLike];
                
                btnComment = [[UIButton alloc]initWithFrame:CGRectMake(160, 0, 70, 40)];
                [btnComment setImage:[UIImage imageNamed:@"facebookconnect_comment"] forState:UIControlStateNormal];
                [btnComment setBackgroundImage:[UIImage imageNamed:@"facebookconnect_backgroundbutton"] forState:UIControlStateHighlighted];
                [btnComment setImageEdgeInsets:UIEdgeInsetsMake(5, 15, 5, 15)];
                [btnComment addTarget:self action:@selector(didClickCommentButton) forControlEvents:UIControlEventTouchUpInside];
                [facebookView addSubview:btnComment];
                
                btnShare = [[UIButton alloc]initWithFrame:CGRectMake(250, 0, 60, 40)];
                [btnShare setImage:[UIImage imageNamed:@"facebookconnect_share"] forState:UIControlStateNormal];
                [btnShare setBackgroundImage:[UIImage imageNamed:@"facebookconnect_backgroundbutton"] forState:UIControlStateHighlighted];
                [btnShare setImageEdgeInsets:UIEdgeInsetsMake(8, 18, 8, 18)];
                [btnShare addTarget:self action:@selector(didClickShareButton) forControlEvents:UIControlEventTouchUpInside];
                [facebookView addSubview:btnShare];
                [productViewController.view addSubview:facebookView];
            }
        }else if ([noti.name isEqualToString:@"ZThemeProductViewController_DidSetNewProductModel"])
        {
            [buttonFacebook setHidden:NO];
            productModel = [noti.userInfo valueForKey:@"productmodel"];
            fbLikeControl.objectID = [productModel valueForKey:@"product_url"];
            [self getDataFaceBookDataOnOtherThread];
        }else if ([noti.name isEqualToString:@"ZThemeProductViewController_BeginChangeProduct"])
        {
            [buttonFacebook setHidden:YES];
            [UIView animateWithDuration:0.2
                                  delay:0
                                options:UIViewAnimationOptionCurveEaseOut
                             animations:^{
                                 if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
                                     [facebookView setFrame:CGRectMake(CGRectGetWidth(self.productViewController.view.frame), 105, 0, 40)];
                                 }else
                                 {
                                     [facebookView setFrame:CGRectMake(CGRectGetWidth(self.productViewController.view.frame), 135, 0, 40)];
                                 }
                             }
                             completion:^(BOOL finished) {
                             }];
            self.isShowFacebookView = NO;
        }
    }
}

- (void)didTouchButtonFacebook:(id)sender
{
    if (!isShowFacebookView) {
        [UIView animateWithDuration:0.2
                              delay:0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
                                 [facebookView setFrame:CGRectMake(CGRectGetWidth(self.productViewController.view.frame) - 320, 105, 320, 40)];
                             }else
                             {
                                 [facebookView setFrame:CGRectMake(CGRectGetWidth(self.productViewController.view.frame) - 320, 135, 320, 40)];
                             }
                         }
                         completion:^(BOOL finished) {
                         }];
    }else
    {
        [UIView animateWithDuration:0.2
                              delay:0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
                                 [facebookView setFrame:CGRectMake(CGRectGetWidth(self.productViewController.view.frame), 105, 0, 40)];
                             }else
                             {
                                 [facebookView setFrame:CGRectMake(CGRectGetWidth(self.productViewController.view.frame), 135, 0, 40)];
                             }
                         }
                         completion:^(BOOL finished) {
                         }];
    }
    
    isShowFacebookView = !isShowFacebookView;
    
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}
@end
