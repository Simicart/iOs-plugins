//
//  DownloadModelCollection.m
//  SimiCartPluginFW
//
//  Created by NghiepLy on 9/9/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import "DownloadModelCollection.h"

@implementation DownloadModelCollection
- (void)getDownloadItemsWithParams:(NSDictionary *)params{
    notificationName = DidGetDownloadItems;
    self.parseKey = @"downloadableproducts";
    [self preDoRequest];
    [[DownloadAPI new] getDownloadItemsWithParams:params target:self selector:@selector(didGetResponseFromNetwork:)];
}
@end
