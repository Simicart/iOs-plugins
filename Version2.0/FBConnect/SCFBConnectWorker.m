//
//  SCFBConnectWorker.m
//  SimiCartPluginFW
//
//  Created by Nghieply91 on 11/18/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import "SCFBConnectWorker.h"
#import "FacebookConnect.h"
@implementation SCFBConnectWorker
- (instancetype)init
{
    self = [super init];
    if (self) {
        _facebookLogin = [SimiFacebookWorker new];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"SCProductViewController-ViewDidLoad" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"SCProductViewController_Pad-ViewDidLoad" object:nil];
    }
    return self;
}

- (void)didReceiveNotification:(NSNotification*)noti
{
    
    FacebookConnect *facebookConnect = [[FacebookConnect alloc]initWithObject:noti.object];
    if ([noti.name isEqualToString:@"SCProductViewController-ViewDidLoad"]) {
        facebookConnect.productViewController = noti.object;
    }else
    {
        facebookConnect.productViewControllerPad = noti.object;
    }
    if (self.arrayFacebookConnect == nil) {
        self.arrayFacebookConnect = [[NSMutableArray array]init];
    }
    [self.arrayFacebookConnect addObject:facebookConnect];
}


#pragma mark Dead Log
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}
@end
