//
//  SimiStoreLocatorPopup.h
//  SimiCartPluginFW
//
//  Created by NghiepLy on 7/1/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import <SimiCartBundle/SimiCartBundle.h>
#import <SimiCartBundle/SimiView.h>
#import <SimiCartBundle/UIImageView+WebCache.h>
#import <SimiCartBundle/UILabelDynamicSize.h>
#import <MapKit/MapKit.h>
#import <SimiCartBundle/SimiModel.h>
#import "SimiStoreLocatorModel.h"
@protocol SimiStoreLocatorPopupDelegate <NSObject>

@end
@interface SimiStoreLocatorPopup : SimiView

@property (nonatomic, weak) id<SimiStoreLocatorPopupDelegate> delegate;
@property (nonatomic, strong)   UIImageView *imageStore;
@property (nonatomic, strong)   UIImageView *imageBackGround;
@property (nonatomic, strong)   UIImageView *imageIconAddress;
@property (nonatomic, strong)   UIImageView *imagePopup;
@property (nonatomic, strong)   UILabel* lblStoreName;
@property (nonatomic, strong)   UILabel* lblStoreAddress;
@property (nonatomic, strong) SimiStoreLocatorModel *storeLocatorModel;


- (void)setContentForPopup;
@end
