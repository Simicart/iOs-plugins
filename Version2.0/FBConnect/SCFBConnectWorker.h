//
//  SCFBConnectWorker.h
//  SimiCartPluginFW
//
//  Created by Nghieply91 on 11/18/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SimiFacebookWorker.h"
@interface SCFBConnectWorker : NSObject<UIWebViewDelegate>
@property (nonatomic, strong) SimiFacebookWorker *facebookLogin;
@property (nonatomic, strong) NSMutableArray *arrayFacebookConnect;
@end
