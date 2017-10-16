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
@synthesize lblStoreAddress, lblStoreDistance, lblStoreName, lblCall, lblMail, lblMap, btnMap;
@synthesize imgStoreImage, btnCall, btnMail, delegate, storeLocatorModel, imgBackground;
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier andStoreData:(SimiStoreLocatorModel*)storeLocatorModel_;
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
        [lblStoreName setTextColor:COLOR_WITH_HEX(@"#393939")];
        [self addSubview:lblStoreName];
        
        lblStoreAddress = [[UILabel alloc]initWithFrame:CGRectMake(labelPaddingLeft, 25, labelWidth, 35)];
        [lblStoreAddress setFont:[UIFont fontWithName:THEME_FONT_NAME size:THEME_FONT_SIZE - 3]];
        [lblStoreAddress setTextColor:COLOR_WITH_HEX(@"#393939")];
        NSString *stringAddress = @"";
        if (storeLocatorModel.address) {
            stringAddress = [NSString stringWithFormat:@"%@",storeLocatorModel.address];
        }
        if (storeLocatorModel.city) {
            stringAddress = [NSString stringWithFormat:@"%@, %@",stringAddress, storeLocatorModel.city];
        }
        if (storeLocatorModel.state) {
            stringAddress = [NSString stringWithFormat:@"%@, %@", stringAddress, storeLocatorModel.state];
        }
        if (storeLocatorModel.zipcode) {
            stringAddress = [NSString stringWithFormat:@"%@, %@", stringAddress, storeLocatorModel.zipcode];
        }
        if (storeLocatorModel.countryName) {
            stringAddress = [NSString stringWithFormat:@"%@, %@", stringAddress, storeLocatorModel.countryName];
        }
        [lblStoreAddress setText:stringAddress];
        float heightContent = [lblStoreAddress resizLabelToFit];
        [self addSubview:lblStoreAddress];
        
        lblStoreDistance = [[UILabel alloc]initWithFrame:CGRectMake(cellWidth - labelDistanceWidth, 5, labelDistanceWidth, labelHeight)];
        [lblStoreDistance setTextColor:COLOR_WITH_HEX(@"#393939")];
        [lblStoreDistance setFont:[UIFont fontWithName:THEME_FONT_NAME size:THEME_FONT_SIZE - 3]];
        float distance = storeLocatorModel.distance/1000;
        NSString *stringlblStoreDistance = [NSString stringWithFormat:@"%0.2f %@",distance, SCLocalizedString(@"km")];
        [lblStoreDistance setText:stringlblStoreDistance];
        [self addSubview:lblStoreDistance];
        
        imgBackground = [[UIImageView alloc]initWithFrame:CGRectMake(imagePaddingLeft, imagePaddingTop, imageSize, imageSize)];
        [imgBackground setImage:[UIImage imageNamed:@"storelocator_Bg_icon_store.png"]];
        
        imgStoreImage = [[UIImageView alloc]initWithFrame:imgBackground.frame];
        [imgStoreImage setContentMode:UIViewContentModeScaleAspectFit];
        if (![storeLocatorModel.image isEqualToString:@""]) {
            [imgStoreImage sd_setImageWithURL:[NSURL URLWithString:storeLocatorModel.image] placeholderImage:[UIImage imageNamed:@"storelocator_icon_store"]];
            [self addSubview:imgStoreImage];
            [self addSubview:imgBackground];
        }else
        {
            [imgStoreImage setImage:[UIImage imageNamed:@"storelocator_icon_store"]];
            [self addSubview:imgStoreImage];
        }
        
        _viewButton = [[UIView alloc]initWithFrame:CGRectMake(labelDistanceWidth, heightContent, cellWidth - labelDistanceWidth, 34)];
        [self addSubview:_viewButton];
        btnCall = [UIButton new];
        [btnCall setImage:[UIImage imageNamed:@"storelocator_ic_call_iphone"] forState:UIControlStateNormal];
        [btnCall setImageEdgeInsets:UIEdgeInsetsMake(13, 0, 0, 0)];
        [btnCall addTarget:self action:@selector(btnCall_Click:) forControlEvents:UIControlEventTouchUpInside];
        lblCall = [UILabel new];
        [lblCall setText:SCLocalizedString(@"Call")];
        [lblCall setTextColor:[UIColor blackColor]];
        [lblCall setFont:[UIFont fontWithName:THEME_FONT_NAME size:12]];
        [lblCall setBackgroundColor:[UIColor clearColor]];
        if (PHONEDEVICE) {
            [btnCall setFrame:CGRectMake(0, 0, 70, 34)];
            [lblCall setFrame:CGRectMake(35, 13, 35, 21)];
            [btnCall addSubview:lblCall];
            [_viewButton addSubview:btnCall];
            if (![storeLocatorModel valueForKey:@"phone"]) {
                [btnCall setEnabled:NO];
            }
        }
        
        btnMail = [UIButton new];
        [btnMail setImage:[UIImage imageNamed:@"storelocator_ic_mail_iphone"] forState:UIControlStateNormal];
        [btnMail setImageEdgeInsets:UIEdgeInsetsMake(13, 0, 0, 0)];
        [btnMail addTarget:self action:@selector(btnMail_Click:) forControlEvents:UIControlEventTouchUpInside];
        lblMail = [UILabel new];
        [lblMail setText:SCLocalizedString(@"Email")];
        [lblMail setTextColor:[UIColor blackColor]];
        [lblMail setFont:[UIFont fontWithName:THEME_FONT_NAME size:12]];
        [lblMail setBackgroundColor:[UIColor clearColor]];
        if (PHONEDEVICE) {
            [btnMail setFrame:CGRectMake(75, 0, 70, 34)];
            [lblMail setFrame:CGRectMake(35, 13, 35, 21)];
            [btnMail addSubview:lblMail];
            [_viewButton addSubview:btnMail];
            if (storeLocatorModel.email == nil) {
                [btnMail setEnabled:NO];
            }
        }else
        {
            [btnMail setFrame:CGRectMake(0, 0, 70, 34)];
            [lblMail setFrame:CGRectMake(35, 13, 35, 21)];
            [btnMail addSubview:lblMail];
            [_viewButton addSubview:btnMail];
            if (storeLocatorModel.email == nil) {
                [btnMail setEnabled:NO];
            }
        }
        
        btnMap = [UIButton new];
        [btnMap setImage:[UIImage imageNamed:@"storelocator_ic_map_iphone"] forState:UIControlStateNormal];
        [btnMap setImageEdgeInsets:UIEdgeInsetsMake(13, 0, 0, 0)];
        [btnMap addTarget:self action:@selector(btnMap_Click:) forControlEvents:UIControlEventTouchUpInside];
        
        lblMap = [UILabel new];
        [lblMap setText:SCLocalizedString(@"Map")];
        [lblMap setTextColor:[UIColor blackColor]];
        [lblMap setFont:[UIFont fontWithName:THEME_FONT_NAME size:12]];
        [lblMap setBackgroundColor:[UIColor clearColor]];
        if (PHONEDEVICE) {
            [btnMap setFrame:CGRectMake(150, 0, 70, 34)];
            [lblMap setFrame:CGRectMake(35, 13, 35, 21)];
            [btnMap addSubview:lblMap];
            [_viewButton addSubview:btnMap];
        }else
        {
            [btnMap setFrame:CGRectMake(75, 0, 70, 34)];
            [lblMap setFrame:CGRectMake(35, 13, 35, 21)];
            [btnMap addSubview:lblMap];
            [_viewButton addSubview:btnMap];
        }
    }
    [SimiGlobalFunction sortViewForRTL:_viewButton andWidth:cellWidth - labelDistanceWidth];
    [SimiGlobalFunction sortViewForRTL:self andWidth:cellWidth];
    return self;
}

- (void)btnCall_Click:(id)sender
{
    NSString *phNo = [NSString  stringWithFormat:@"telprompt:%@",storeLocatorModel.phone];
    NSURL *phoneUrl = [[NSURL alloc]initWithString:[phNo stringByReplacingOccurrencesOfString:@" " withString:@""]];
    [[NSNotificationCenter defaultCenter]postNotificationName:TRACKINGEVENT object:@"store_locator_action" userInfo:@{@"action":@"call_to_store",@"store_name":self.storeLocatorModel.name}];
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
    [[NSNotificationCenter defaultCenter]postNotificationName:TRACKINGEVENT object:@"store_locator_action" userInfo:@{@"action":@"email_to_store",@"store_name":self.storeLocatorModel.name}];
    NSString *email = storeLocatorModel.email;
    NSString *emailContent = @"Content";
    [self.delegate sendEmailToStoreWithEmail:email andEmailContent:emailContent];
}
- (void)btnMap_Click:(id)sender
{
    [self.delegate choiceStoreLocatorWithStoreLocatorModel:self.storeLocatorModel];
    [[NSNotificationCenter defaultCenter]postNotificationName:TRACKINGEVENT object:@"store_locator_action" userInfo:@{@"action":@"view_store_map",@"store_name":self.storeLocatorModel.name}];
}
@end
