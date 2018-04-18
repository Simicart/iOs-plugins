//
//  SCPThemeConfigModel.h
//  SimiCartPluginFW
//
//  Created by Hoang Van Trung on 4/18/18.
//  Copyright © 2018 Trueplus. All rights reserved.
//

#import <SimiCartBundle/SimiCartBundle.h>

@interface SCPThemeConfigModel : SimiModel
@property (strong, nonatomic) NSString *menuBackgroudColor;
@property (strong, nonatomic) NSString *titleColor;
@property (strong, nonatomic) NSString *iconColor;
@property (strong, nonatomic) NSString *iconHighlightColor;
@property (strong, nonatomic) NSString *buttonTextColor;
@property (strong, nonatomic) NSString *buttonBackgroundColor;
@end
