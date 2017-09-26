//
//  SCStoreListTableViewCell.m
//  SimiCartPluginFW
//
//  Created by SimiCommerce on 6/26/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import "SCStoreListTableViewCell.h"
#import <SimiCartBundle/UIImageView+WebCache.h>
#import <SimiCartBundle/UILabelDynamicSize.h>

@implementation SCStoreListTableViewCell
{
    float cellWidth;
    float imageSize;
    float imagePaddingLeft;
    float imagePaddingTop;
    float labelPaddingLeft;
    float labelHeight;
    float labelPaddingRight;
    float labelWidth;
    float labelDistanceWidth;
}
@synthesize lblStoreAddress, lblStoreDistance, lblStoreName, lblCall, lblMap, btnMap;
@synthesize imgStoreImage, btnCall, delegate, storeLocatorModel, imgBackground;


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier andStoreData:(SimiModel*)storeLocatorModel_;
{
    cellWidth = SCREEN_WIDTH;
    if (PADDEVICE) {
        cellWidth = 420;
    }
    imageSize = 70;
    imagePaddingLeft = 5;
    imagePaddingTop = 15;
    labelPaddingLeft = imageSize + imagePaddingLeft + 10;;
    labelPaddingRight = 15;
    labelHeight = 20;
    labelWidth = cellWidth - labelPaddingLeft - labelPaddingRight;
    labelDistanceWidth = 85;
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.storeLocatorModel = storeLocatorModel_;
        
        lblStoreName = [[UILabel alloc]initWithFrame:CGRectMake(labelPaddingLeft , 5, labelWidth - labelDistanceWidth, labelHeight)];
        [lblStoreName setFont:[UIFont fontWithName:THEME_FONT_NAME_REGULAR size:THEME_FONT_SIZE - 2]];
        [lblStoreName setText:[storeLocatorModel valueForKey:@"name"]];
        [lblStoreName setTextColor:[[SimiGlobalVar sharedInstance]colorWithHexString:@"#393939"]];
        [self addSubview:lblStoreName];
        
        lblStoreAddress = [[UILabel alloc]initWithFrame:CGRectMake(labelPaddingLeft, 25, labelWidth, 35)];
        [lblStoreAddress setFont:[UIFont fontWithName:THEME_FONT_NAME size:THEME_FONT_SIZE - 3]];
        [lblStoreAddress setTextColor:[[SimiGlobalVar sharedInstance]colorWithHexString:@"#393939"]];
        NSString *stringAddress = @"";
        if ([storeLocatorModel valueForKey:@"address"]) {
            stringAddress = [NSString stringWithFormat:@"%@",[storeLocatorModel valueForKey:@"address"]];
        }
        if ([storeLocatorModel valueForKey:@"city"]) {
            stringAddress = [NSString stringWithFormat:@"%@, %@",stringAddress, [storeLocatorModel valueForKey:@"city"]];
        }
        if ([storeLocatorModel valueForKey:@"state"]) {
            stringAddress = [NSString stringWithFormat:@"%@, %@", stringAddress, [storeLocatorModel valueForKey:@"state"]];
        }
        if ([storeLocatorModel valueForKey:@"zipcode"]) {
            stringAddress = [NSString stringWithFormat:@"%@, %@", stringAddress, [storeLocatorModel valueForKey:@"zipcode"]];
        }
        if ([storeLocatorModel valueForKey:@"country_name"]) {
            stringAddress = [NSString stringWithFormat:@"%@, %@", stringAddress, [storeLocatorModel valueForKey:@"country_name"]];
        }
        [lblStoreAddress setText:stringAddress];
        float heightContent = [lblStoreAddress resizLabelToFit];
        [self addSubview:lblStoreAddress];
        
        lblStoreDistance = [[UILabel alloc]initWithFrame:CGRectMake(cellWidth - labelDistanceWidth, 5, labelDistanceWidth, labelHeight)];
        [lblStoreDistance setTextColor:[[SimiGlobalVar sharedInstance]colorWithHexString:@"#393939"]];
        [lblStoreDistance setFont:[UIFont fontWithName:THEME_FONT_NAME size:THEME_FONT_SIZE - 3]];
        float distance = [[NSString stringWithFormat:@"%@",[storeLocatorModel valueForKey:@"distance"]]floatValue]/1000;
        NSString *stringlblStoreDistance = [NSString stringWithFormat:@"%0.2f %@",distance, SCLocalizedString(@"km")];
        [lblStoreDistance setText:stringlblStoreDistance];
        [self addSubview:lblStoreDistance];
        
        imgBackground = [[UIImageView alloc]initWithFrame:CGRectMake(imagePaddingLeft, imagePaddingTop, imageSize, imageSize)];
        [imgBackground setImage:[UIImage imageNamed:@"storelocator_Bg_icon_store.png"]];
        
        imgStoreImage = [[UIImageView alloc]initWithFrame:imgBackground.frame];
        [imgStoreImage setContentMode:UIViewContentModeScaleAspectFit];
        if (![[storeLocatorModel valueForKey:@"image"] isEqualToString:@""]) {
            [imgStoreImage sd_setImageWithURL:[storeLocatorModel valueForKey:@"image"] placeholderImage:[UIImage imageNamed:@"storelocator_icon_store"]];
            [self addSubview:imgStoreImage];
            [self addSubview:imgBackground];
        }else
        {
            [imgStoreImage setImage:[UIImage imageNamed:@"storelocator_icon_store"]];
            [self addSubview:imgStoreImage];
        }
        
        _viewButton = [[UIView alloc]initWithFrame:CGRectMake(labelPaddingLeft, heightContent, labelWidth, 40)];
        [self addSubview:_viewButton];
        btnCall = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, labelWidth/2, 40)];
        [btnCall setImage:[UIImage imageNamed:@"Call"] forState:UIControlStateNormal];
        [btnCall.imageView setContentMode:UIViewContentModeScaleAspectFit];
        [btnCall setImageEdgeInsets:UIEdgeInsetsMake(10, 0, 10, 10)];
        [btnCall addTarget:self action:@selector(btnCall_Click:) forControlEvents:UIControlEventTouchUpInside];
        [btnCall setTitle:SCLocalizedString(@"Gọi điện") forState:UIControlStateNormal];
        [btnCall setTitleEdgeInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
        btnCall.titleLabel.font = [UIFont fontWithName:THEME_FONT_NAME_REGULAR size:THEME_FONT_SIZE - 2];
        [btnCall setTitleColor:THEME_CONTENT_COLOR forState:UIControlStateNormal];
        [btnCall setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        [_viewButton addSubview:btnCall];
        if (![storeLocatorModel valueForKey:@"phone"]) {
            [btnCall setEnabled:NO];
        }
        
        btnMap = [[UIButton alloc] initWithFrame:CGRectMake(labelWidth/2, 0, labelWidth/2, 40)];
        [btnMap setImage:[UIImage imageNamed:@"Locations"] forState:UIControlStateNormal];
        [btnMap.imageView setContentMode:UIViewContentModeScaleAspectFit];
        [btnMap setImageEdgeInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
        [btnMap addTarget:self action:@selector(btnMap_Click:) forControlEvents:UIControlEventTouchUpInside];
        [btnMap setTitle:SCLocalizedString(@"Bản đồ") forState:UIControlStateNormal];
        [btnMap setTitleEdgeInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
        btnMap.titleLabel.font = [UIFont fontWithName:THEME_FONT_NAME_REGULAR size:THEME_FONT_SIZE - 2];
        [btnMap setTitleColor:THEME_CONTENT_COLOR forState:UIControlStateNormal];
        [btnMap setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        [_viewButton addSubview:btnMap];
    }
    [SimiGlobalVar sortViewForRTL:_viewButton andWidth:labelWidth];
    [SimiGlobalVar sortViewForRTL:self andWidth:cellWidth];
    return self;
}

- (void)btnCall_Click:(id)sender
{
    NSString *phNo = [NSString  stringWithFormat:@"telprompt:%@",[storeLocatorModel valueForKey:@"phone"]];
    NSURL *phoneUrl = [[NSURL alloc]initWithString:[phNo stringByReplacingOccurrencesOfString:@" " withString:@""]];
    [[NSNotificationCenter defaultCenter]postNotificationName:TRACKINGEVENT object:@"store_locator_action" userInfo:@{@"action":@"call_to_store",@"store_name":[self.storeLocatorModel valueForKey:@"name"]}];
    if ([[UIApplication sharedApplication] canOpenURL:phoneUrl]) {
        [[UIApplication sharedApplication] openURL:phoneUrl];
    } else
    {
        UIAlertView* calert = [[UIAlertView alloc]initWithTitle:SCLocalizedString(@"Warning") message:SCLocalizedString(@"Call facility is not available") delegate:nil cancelButtonTitle:SCLocalizedString(@"Ok") otherButtonTitles:nil, nil];
        [calert show];
    }
}
- (void)btnMail_Click:(id)sender
{
    [[NSNotificationCenter defaultCenter]postNotificationName:TRACKINGEVENT object:@"store_locator_action" userInfo:@{@"action":@"email_to_store",@"store_name":[self.storeLocatorModel valueForKey:@"name"]}];
    NSString *email = [storeLocatorModel valueForKeyPath:@"email"];
    NSString *emailContent = @"Content";
    [self.delegate sendEmailToStoreWithEmail:email andEmailContent:emailContent];
}
- (void)btnMap_Click:(id)sender
{
    [self.delegate choiceStoreLocatorWithStoreLocatorModel:self.storeLocatorModel];
    [[NSNotificationCenter defaultCenter]postNotificationName:TRACKINGEVENT object:@"store_locator_action" userInfo:@{@"action":@"view_store_map",@"store_name":[self.storeLocatorModel valueForKey:@"name"]}];
}

#pragma mark Modify UIColor

- (UIColor*) colorWithStringHex:(NSString*)stringHex
{
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:stringHex];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}
@end
