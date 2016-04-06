//
//  YoutubeWorker.m
//  SimiCartPluginFW
//
//  Created by NghiepLy on 7/20/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import "SimizopimWorker.h"
#import "ChatStyling.h"
#import <SimiCartBundle/SimiSection.h>
#import <SimiCartBundle/SimiRow.h>
#import <SimiCartBundle/SCAppDelegate.h>
#import <SimiCartBundle/SCLeftMenuViewController.h>
#import <SimiCartBundle/SCNavigationBarPhone.h>
#import <SimiCartBundle/SCNavigationBarPad.h>

@implementation SimizopimWorker
{
    NSMutableArray * cells;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"SCLeftMenu_InitCellsAfter" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"SCLeftMenu_DidSelectRow" object:nil];
    }
    return self;
}

-(void)didReceiveNotification:(NSNotification *)noti
{
    if([noti.name isEqualToString:@"SCLeftMenu_InitCellsAfter"])
    {
        cells = noti.object;
        for (int i = 0; i < cells.count; i++) {
            SimiSection *section = [cells objectAtIndex:i];
            if ([section.identifier isEqualToString:LEFTMENU_SECTION_MORE]) {
                SimiRow *row = [[SimiRow alloc]initWithIdentifier:LEFTMENU_ROW_CHAT height:50 sortOrder:70];
                row.image = [UIImage imageNamed:@"ic_livechat"];
                row.title = SCLocalizedString(@"Live Chat");
                row.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                [section addObject:row];
                [section sortItems];
            }
        }
    }else if([noti.name isEqualToString:@"SCLeftMenu_DidSelectRow"])
    {
        NSLog(@"store config : %@", [[[SimiGlobalVar sharedInstance] store] valueForKeyPath:@"store_config"]);
        NSArray *zopimConfig = [[[[SimiGlobalVar sharedInstance] store] valueForKeyPath:@"store_config"] valueForKeyPath:@"zopim_config"];
        NSString *accountKey = [zopimConfig valueForKey:@"account_key"];
        NSString *showProfile = [zopimConfig valueForKey:@"show_profile"];
        NSString *name = [zopimConfig valueForKey:@"name"];
        NSString *email = [zopimConfig valueForKey:@"email"];
        NSString *phone = [zopimConfig valueForKey:@"phone"];
        SimiRow *row = [noti.userInfo valueForKey:@"simirow"];
        if(![showProfile isEqualToString:@"0"])
            showProfile = @"3";
        if ([row.identifier isEqualToString:LEFTMENU_ROW_CHAT]) {
            SCNavigationBarPhone *navi = noti.object;
            navi.isDiscontinue = YES;
            [self startZopimChat:accountKey showProfile:showProfile name:name email:email phone:phone];
        
        }
    }
}

- (void)startZopimChat:(NSString *)accountKey showProfile:(NSString *)showProfile name:(NSString *)name email:(NSString *)email phone:(NSString *)phone
{
    [self styleApp];
//    [ChatStyling applyStyling];
    [ZDCChat configure:^(ZDCConfig *defaults) {
        
        defaults.accountKey = accountKey;
        defaults.preChatDataRequirements.name = [name integerValue];
        defaults.preChatDataRequirements.email = [email integerValue];
        defaults.preChatDataRequirements.phone = [phone integerValue];
        defaults.preChatDataRequirements.department = [showProfile integerValue];
        defaults.preChatDataRequirements.message = ZDCPreChatDataOptional;
        defaults.emailTranscriptAction = ZDCEmailTranscriptActionNeverSend;

    }];
    
    [ZDCLog enable:YES];
    [ZDCLog setLogLevel:ZDCLogLevelWarn];
//    [[ZDCChat instance].session trackEvent:@"Chat button pressed: (all fields optional)"];
    
    // start a chat in a new modal
    // Lần click thứ 2 thì nó k call vào đây.
    [ZDCChat startChat:nil];
}

- (void) styleApp
{
    if ([ZDUUtil isVersionOrNewer:@(7)]) {
        
        // status bar
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
        
        // nav bar
        NSDictionary *navbarAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                          [UIColor whiteColor] ,UITextAttributeTextColor, nil];
        [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
        [[UINavigationBar appearance] setTitleTextAttributes:navbarAttributes];
//        [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:0.91f green:0.16f blue:0.16f alpha:1.0f]];
        [[UINavigationBar appearance] setBarTintColor:THEME_COLOR];
//        [[ZDCChatOverlay appearance] setBackgroundColor:THEME_COLOR];
//        [[ZDCChatOverlay appearance] setOverlayBackgroundImage:[UIImage imageNamed:@"icHome"]];
        [[ZDCChatOverlay appearance] setOverlayTintColor:THEME_BUTTON_BACKGROUND_COLOR];
        [[ZDCChatOverlay appearance] setMessageCountColor:THEME_BUTTON_TEXT_COLOR];
        
        if ([ZDUUtil isVersionOrNewer:@(8)]) {
            
            // For translucent nav bars set YES
            [[UINavigationBar appearance] setTranslucent:NO];
        }
        
        // For a completely transparent nav bar uncomment this and set 'translucent' above to YES
        // (you may also want to change the title text and tint colors above since they are white by default)
        //[[UINavigationBar appearance] setBarStyle:UIBarStyleDefault];
        //[[UINavigationBar appearance] setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
        //[[UINavigationBar appearance] setShadowImage:[UIImage new]];
        //[[UINavigationBar appearance] setBackgroundColor:[UIColor clearColor]];
        
    } else {
//        [[UINavigationBar appearance] setTintColor:[UIColor colorWithRed:0.91f green:0.16f blue:0.16f alpha:1.0f]];
        
        [[UINavigationBar appearance] setTintColor:THEME_COLOR];
//        [[ZDCChatOverlay appearance] setBackgroundColor:THEME_COLOR];
//        [[ZDCChatOverlay appearance] setOverlayBackgroundImage:[UIImage imageNamed:@"icHome"]];
        [[ZDCChatOverlay appearance] setOverlayTintColor:THEME_BUTTON_BACKGROUND_COLOR];
        [[ZDCChatOverlay appearance] setMessageCountColor:THEME_BUTTON_TEXT_COLOR];
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}
@end
