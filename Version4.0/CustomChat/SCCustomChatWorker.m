//
//  SCFreshChatWorker.m
//  SimiCartPluginFW
//
//  Created by MAC on 8/15/18.
//  Copyright © 2018 Trueplus. All rights reserved.
//

#import "SCCustomChatWorker.h"

@implementation SCCustomChatWorker
- (instancetype)init{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(initRightItemEndBarPhone:) name:SCNavigationBarPhoneInitRightItemsEnd object:nil];
    }
    return self;
}

- (void)initRightItemEndBarPhone:(NSNotification *)noti{
    UIButton *chatButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
    [chatButton setImage:[[UIImage imageNamed:@"ic_freshchat"] imageWithColor:THEME_NAVIGATION_ICON_COLOR] forState:UIControlStateNormal];
    [chatButton setContentMode:UIViewContentModeScaleAspectFit];
    [chatButton addTarget:self action:@selector(didSelectChatBarItem:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *chatItem = [[UIBarButtonItem alloc] initWithCustomView:chatButton];
    chatItem.sortOrder = navigationbar_phone_chat_sort_order;
    NSMutableArray *rightButtonItems = noti.object;
    [rightButtonItems addObject:chatItem];
}

- (void)didSelectChatBarItem:(UIButton *)sender{
    [[SCAppController sharedInstance] openURL:[NSString stringWithFormat:@"%@%@", kBaseURL,@"simiconnector/customchat/index"] withNavigationController:GLOBALVAR.currentlyNavigationController];
}
@end
