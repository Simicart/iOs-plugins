//
//  SCVirtualHomeView_Theme01.m
//  SimiCartPluginFW
//
//  Created by Thanh Tung Mai on 10/7/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import "SCVirtualHomeView_Theme01.h"

@implementation SCVirtualHomeView_Theme01
@synthesize lastLocation;

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        lastLocation = self.center;
    }
    return self;
}

@end
