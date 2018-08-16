//
//  SCCustomizeSearchProductTableViewCell.m
//  SimiCartPluginFW
//
//  Created by Liam on 4/26/18.
//  Copyright © 2018 Trueplus. All rights reserved.
//

#import "SCCustomizeSearchProductTableViewCell.h"

@implementation SCCustomizeSearchProductTableViewCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier productData:(NSDictionary *)data{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    self.productData = data;
    float padding = 15;
    float cellWidth = SCREEN_WIDTH;
    UIImageView *productImageView = [[UIImageView alloc]initWithFrame:CGRectMake(padding, 10, 60, 60)];
    productImageView.contentMode = UIViewContentModeScaleAspectFit;
    if ([[self.productData valueForKey:@"image_link"] isKindOfClass:[NSString class]]) {
        [productImageView sd_setImageWithURL:[NSURL URLWithString:[self.productData valueForKey:@"image_link"]]placeholderImage:[UIImage imageNamed:@"logo"]];
    }
    [self.contentView addSubview:productImageView];
    
    SimiLabel *nameLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(padding*2 + 60, 10, cellWidth - padding*4 - 60, 60) andFont:[UIFont fontWithName:THEME_FONT_NAME size:FONT_SIZE_MEDIUM]];
    nameLabel.numberOfLines = 0;
    if ([[self.productData valueForKey:@"title"] isKindOfClass:[NSString class]]) {
        [nameLabel setText:[self.productData valueForKey:@"title"]];
    }
    [self.contentView addSubview:nameLabel];
    return self;
}
@end
