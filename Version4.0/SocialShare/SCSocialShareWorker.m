//
//  SCSocialShareWorker.m
//  SimiCartPluginFW
//
//  Created by Hoang Van Trung on 9/12/17.
//  Copyright © 2017 Trueplus. All rights reserved.
//

#import "SCSocialShareWorker.h"
#import <SimiCartBundle/SCProductMoreViewController.h>
#import <SimiCartBundle/SCProductSecondDesignViewController.h>

@implementation SCSocialShareWorker {
    MoreActionView* moreActionView;
    SimiProductModel *product;
    SimiViewController *viewController;
    UIButton *shareButton;
}
- (id)init {
    if(self == [super init]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(initViewMoreAction:) name:SCProductMoreViewControllerInitViewMoreAction object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(beforeTouchMoreAction:) name:SCProductMoreViewControllerBeforeTouchMoreAction object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(initViewMoreAction:) name:SCProductViewControllerInitViewMoreAction object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(beforeTouchMoreAction:) name:SCProductViewControllerBeforeTouchMoreAction object:nil];
    }
    return self;
}
- (void)initViewMoreAction: (NSNotification *)noti {
    moreActionView = noti.object;
    float sizeButton = 50;
    shareButton = [UIButton new];
    [shareButton setImage:[UIImage imageNamed:@"ic_share"] forState:UIControlStateNormal];
    [shareButton setImageEdgeInsets:UIEdgeInsetsMake(9, 9, 9, 9)];
    [shareButton.layer setCornerRadius:sizeButton/2.0f];
    [shareButton.layer setShadowOffset:CGSizeMake(1, 1)];
    [shareButton.layer setShadowRadius:2];
    shareButton.layer.shadowOpacity = 0.5;
    [shareButton setBackgroundColor:THEME_APP_BACKGROUND_COLOR];
    [shareButton addTarget:self action:@selector(didTouchShareButton:) forControlEvents:UIControlEventTouchUpInside];
    shareButton.tag = 2000;
    moreActionView.numberIcon += 1;
    [moreActionView.arrayIcon addObject:shareButton];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(afterInitViewMore:) name:SCProductMoreViewControllerAfterInitViewMore object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(afterInitViewMore:) name:SCProductViewControllerAfterInitViewMore object:nil];
}

- (void)afterInitViewMore: (NSNotification *)noti {
    [self removeObserverForNotification:noti];
    product = [noti.userInfo valueForKey:@"productModel"];
    viewController = [noti.userInfo valueForKey:@"controller"];
}

- (void)didTouchShareButton: (id)sender {
    if (product.name != nil && product.entityId != nil && product.sku != nil){
        [[NSNotificationCenter defaultCenter]postNotificationName:TRACKINGEVENT object:@"product_action" userInfo:@{@"action":@"clicked_share_button",@"product_name":product.name,@"product_id":product.entityId,@"sku":product.sku,@"qty":@"1",@"theme":[viewController isKindOfClass:[SCProductSecondDesignViewController class]]?@"cherry":@"default"}];
    }
    NSURL *productURL = nil;
    if ([product valueForKey:@"url_path"]) {
        productURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",kBaseURL, [product valueForKey:@"url_path"]]];
    }else{
        productURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@catalog/product/view/id/%@",kBaseURL,product.entityId]];
    }
    if (productURL != nil) {
        UIActivityViewController *activityViewController =
        [[UIActivityViewController alloc] initWithActivityItems:@[productURL]
                                          applicationActivities:nil];
        activityViewController.popoverPresentationController.sourceView = shareButton;
        [viewController.navigationController presentViewController:activityViewController
                                                          animated:YES
                                                        completion:^{
                                                            // ...
                                                        }];
    }
}

- (void)beforeTouchMoreAction: (NSNotification *)noti {
    
}
@end
