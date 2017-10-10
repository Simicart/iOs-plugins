//
//  SimiTagModel.h
//  SimiCartPluginFW
//
//  Created by Hoang Van Trung on 10/10/17.
//  Copyright © 2017 Trueplus. All rights reserved.
//

#import <SimiCartBundle/SimiCartBundle.h>

@interface SimiTagModel : SimiModel
@property (strong, nonatomic) NSString *tagId;
@property (strong, nonatomic) NSString *simistorelocatorId;
@property (strong, nonatomic) NSString *value;
@end
