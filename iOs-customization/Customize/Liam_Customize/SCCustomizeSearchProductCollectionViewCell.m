//
//  SCCustomizeSearchProductCollectionViewCell.m
//  SimiCartPluginFW
//
//  Created by Liam on 4/26/18.
//  Copyright © 2018 Trueplus. All rights reserved.
//

#import "SCCustomizeSearchProductCollectionViewCell.h"

@implementation SCCustomizeSearchProductCollectionViewCell
- (void)setProductModelForCell:(SimiProductModel *)productModel{
    
}

- (void)updateProductDataForCell:(NSDictionary *)data{
    if (![self.productData isEqualToDictionary:data]) {
        self.productData = data;
        if ([[self.productData valueForKey:@"title"] isKindOfClass:[NSString class]]) {
            [self.lblNameProduct setText:[self.productData valueForKey:@"title"]];
            [self.lblNameProduct setFont:[UIFont fontWithName:THEME_FONT_NAME size:FONT_SIZE_MEDIUM]];
            [self.lblNameProduct resizLabelToFit];
        }
        if ([[self.productData valueForKey:@"image_link"] isKindOfClass:[NSString class]]) {
            [self.imageProduct sd_setImageWithURL:[NSURL URLWithString:[self.productData valueForKey:@"image_link"]]placeholderImage:[UIImage imageNamed:@"logo"]];
        }
    }
}
@end
