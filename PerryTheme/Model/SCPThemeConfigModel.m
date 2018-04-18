//
//  SCPThemeConfigModel.m
//  SimiCartPluginFW
//
//  Created by Hoang Van Trung on 4/18/18.
//  Copyright © 2018 Trueplus. All rights reserved.
//

#import "SCPThemeConfigModel.h"

@implementation SCPThemeConfigModel
- (void)parseData{
    [super parseData];
    if([[self.modelData objectForKey:@"menu_background_color"] isKindOfClass:[NSString class]]){
        self.menuBackgroudColor = [self.modelData objectForKey:@"menu_background_color"];
    }else{
        self.menuBackgroudColor = @"#fff";
    }
    if([[self.modelData objectForKey:@"title_color"] isKindOfClass:[NSString class]]){
        self.titleColor = [self.modelData objectForKey:@"title_color"];
    }else{
        self.titleColor = @"#fff";
    }
    if([[self.modelData objectForKey:@"icon_color"] isKindOfClass:[NSString class]]){
        self.iconColor = [self.modelData objectForKey:@"icon_color"];
    }else{
        self.iconColor = @"#000";
    }
    if([[self.modelData objectForKey:@"icon_highlight_color"] isKindOfClass:[NSString class]]){
        self.iconHighlightColor = [self.modelData objectForKey:@"icon_highlight_color"];
    }else{
        self.iconHighlightColor = @"#fff";
    }
    if([[self.modelData objectForKey:@"button_text_color"] isKindOfClass:[NSString class]]){
        self.buttonTextColor = [self.modelData objectForKey:@"button_text_color"];
    }else{
        self.buttonTextColor = @"#fff";
    }
    if([[self.modelData objectForKey:@"button_background_color"] isKindOfClass:[NSString class]]){
        self.buttonBackgroundColor = [self.modelData objectForKey:@"button_background_color"];
    }else{
        self.buttonBackgroundColor = @"#fff";
    }
}

@end
