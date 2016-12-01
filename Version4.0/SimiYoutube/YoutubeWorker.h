//
//  YoutubeWorker.h
//  SimiCartPluginFW
//
//  Created by NghiepLy on 7/20/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

static NSString *product_video_section = @"product_video_section";
static NSString *product_video_row = @"product_video_row";

#import <Foundation/Foundation.h>
@interface YoutubeWorker : NSObject<UITableViewDataSource, UITableViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource>
@property (nonatomic, strong) UIButton* buttonSimiVideo;
@end
