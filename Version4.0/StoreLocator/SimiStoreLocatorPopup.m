//
//  SimiStoreLocatorPopup.m
//  SimiCartPluginFW
//
//  Created by NghiepLy on 7/1/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import "SimiStoreLocatorPopup.h"

@implementation SimiStoreLocatorPopup
@synthesize delegate, lblStoreAddress, lblStoreName, imageStore, storeLocatorModel, imageBackGround;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        float width = 265;
        if (PADDEVICE) {
            width = 300;
        }
        _imagePopup = [[UIImageView alloc]initWithFrame:self.bounds];
        [_imagePopup setImage:[UIImage imageNamed:@"storelocator_popup"]];
        [self addSubview:_imagePopup];
        
        imageStore = [[UIImageView alloc]initWithFrame:CGRectMake(5, 5, 60, 60)];
        [self addSubview:imageStore];
        
        imageBackGround = [[UIImageView alloc] initWithFrame:imageStore.frame];
        [imageBackGround setImage:[UIImage imageNamed:@"storelocator_Bg_icon_store"]];
        [self addSubview:imageBackGround];
        
        _imageIconAddress = [[UIImageView alloc]initWithFrame:CGRectMake(65, 30, 20, 20)];
        [_imageIconAddress setImage:[UIImage imageNamed:@"storelocator_locator"]];
        [self addSubview:_imageIconAddress];
        
        lblStoreName = [UILabel new];
        lblStoreName.textColor = [UIColor redColor];
        [lblStoreName setFont:[UIFont fontWithName:[NSString stringWithFormat:@"%@-%@",THEME_FONT_NAME,@"Bold"] size:FONT_SIZE_LARGE]];
        
        lblStoreAddress = [UILabel new];
        lblStoreAddress.textColor = COLOR_WITH_HEX(@"#393939");
        [lblStoreAddress setFont:[UIFont fontWithName:THEME_FONT_NAME size:FONT_SIZE_MEDIUM]];
        if (PHONEDEVICE) {
            [lblStoreName setFrame:CGRectMake(80, 5, 175, 20)];
            [lblStoreAddress setFrame:CGRectMake(85, 30, 170, 20)];
        }else
        {
            [lblStoreName setFrame:CGRectMake(85, 10, 205, 20)];
            [lblStoreAddress setFrame:CGRectMake(85, 35, 205, 20)];
        }
        [self addSubview:lblStoreName];
        [self addSubview:lblStoreAddress];
        [SimiGlobalFunction sortViewForRTL:self andWidth:width];
    }
    return self;
}

- (void)setContentForPopup
{
    lblStoreName.text = SCLocalizedString([storeLocatorModel valueForKey:@"name"]);
    
    lblStoreAddress.text = [NSString stringWithFormat:@"%@, %@, %@",storeLocatorModel.address,storeLocatorModel.city,storeLocatorModel.countryName];
    [lblStoreAddress resizLabelToFit];
    
    if (lblStoreAddress.frame.size.height > 40 ) {
        CGRect frame = lblStoreAddress.frame;
        frame.size.height = 40;
        [lblStoreAddress setFrame:frame];
    }
    if (![storeLocatorModel.image isEqualToString:@""]) {
        [imageStore sd_setImageWithURL:[NSURL URLWithString:storeLocatorModel.image]];
        [self addSubview:imageBackGround];
    }else
    {
        [imageStore setImage:[UIImage imageNamed:@"storelocator_icon_store.png"]];
        [imageBackGround removeFromSuperview];
    }
}
@end
