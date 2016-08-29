//
//  SimiCustomerModel+Facebook.m
//  SimiCartPluginFW
//
//  Created by Tan Hoang on 3/20/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import "SimiCustomerModel+Facebook.h"
#define DidLogin @"DidLogin"
#define soicialLoginURL @"simiconnector/rest/v2/customers/sociallogin"

@implementation SimiCustomerModel (Facebook)

- (void)loginWithFacebookEmail:(NSString *)email firstName:(NSString *)firstName lastName:(NSString *)lastName{
    currentNotificationName = DidLogin;
    modelActionType = ModelActionTypeGet;
    NSDictionary* params = @{@"email":email, @"firstname":firstName,@"lastname":lastName};
    NSString* url = [NSString stringWithFormat:@"%@%@",kBaseURL,soicialLoginURL];
    
    [[self getAPI] requestWithMethod:@"GET" URL:url params:params target:self selector:@selector(didFinishRequest:responder:) header:nil];
}

@end
