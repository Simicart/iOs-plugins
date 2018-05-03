//
//  SCPPriceView.h
//  SimiCartPluginFW
//
//  Created by Liam on 5/2/18.
//  Copyright © 2018 Trueplus. All rights reserved.
//

#import <SimiCartBundle/SCPriceView.h>

@interface SCPPriceView : SCPriceView{
    float fontSize;
}
- (void)showPriceWithProduct:(SimiProductModel *)product widthView:(float)width fontSize:(float)value;
@end
