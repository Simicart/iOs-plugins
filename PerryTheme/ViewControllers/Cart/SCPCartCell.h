//
//  SCPCartCell.h
//  SimiCartPluginFW
//
//  Created by Hoang Van Trung on 6/4/18.
//  Copyright © 2018 Trueplus. All rights reserved.
//

#import <SimiCartBundle/SimiCartBundle.h>
#import <SimiCartBundle/SCCartCell.h>

@interface SCPCartCell : SCCartCell{
    float contentWidth;
    float contentHeight;
    float qtyViewHeight;
    float qtyViewWidth, priceWidth;
    float paddingX, paddingY;
}

@end
