//
//  SCFacebookInitWorker.h
//  SimiCartPluginFW
//
//  Created by Hoang Van Trung on 8/24/16.
//  Copyright © 2016 Trueplus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <SimiCartBundle/SimiSection.h>
#import <SimiCartBundle/SimiViewController.h>
#import "SimiCustomerModel+Facebook.h"
#import <SimiCartBundle/KeychainItemWrapper.h>
#import <SimiCartBundle/SCProductMoreViewController.h>

@interface SCFacebookInitWorker : NSObject<FBSDKLoginButtonDelegate, UIWebViewDelegate>

@end
