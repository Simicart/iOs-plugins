//
//  SimiTagModel.m
//  SimiCartPluginFW
//
//  Created by Hoang Van Trung on 10/10/17.
//  Copyright © 2017 Trueplus. All rights reserved.
//

#import "SimiTagModel.h"

@implementation SimiTagModel
- (void)parseData{
    [super parseData];
    self.tagId = [NSString stringWithFormat:@"%@",[self.modelData objectForKey:@"tag_id"]];
    self.simistorelocatorId = [NSString stringWithFormat:@"%@",[self.modelData objectForKey:@"simistorelocator_id"]];
    self.value = [NSString stringWithFormat:@"%@",[self.modelData objectForKey:@"value"]];
}
@end
