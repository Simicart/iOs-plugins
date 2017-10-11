//
//  SimiAddressAutofillModel.h
//  SimiCartPluginFW
//
//  Created by Liam on 9/8/16.
//  Copyright © 2016 Trueplus. All rights reserved.
//

#import <SimiCartBundle/SimiCartBundle.h>

@interface SimiAddressAutofillModel : SimiAddressModel

- (void)getAddressWithParams:(NSDictionary*)params;
@end
