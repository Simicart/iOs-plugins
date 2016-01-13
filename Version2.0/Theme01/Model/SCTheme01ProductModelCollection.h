//
//  SCTheme01ProductModelCollection.h
//  SimiCartPluginFW
//
//  Created by Nghieply91 on 8/15/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import <SimiCartBundle/SimiCartBundle.h>
#import <SimiCartBundle/SimiProductModelCollection.h>

@interface SCTheme01ProductModelCollection : SimiProductModelCollection
- (void)getSpotProductsWithKey:(NSString*)key limit:(NSString*)limit ofset:(NSString*)ofset width:(NSString*)width height:(NSString*)height sortOption:(NSInteger)sortOption;
@end
