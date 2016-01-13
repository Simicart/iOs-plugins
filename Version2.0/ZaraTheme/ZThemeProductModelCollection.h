//
//  ZThemeProductModelCollection.h
//  SimiCartPluginFW
//
//  Created by Nghieply91 on 5/8/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import <SimiCartBundle/SimiCartBundle.h>
#import <SimiCartBundle/SimiProductModelCollection.h>

@interface ZThemeProductModelCollection : SimiProductModelCollection
- (void)getSpotProductsWithKey:(NSString*)key limit:(NSString*)limit ofset:(NSString*)ofset width:(NSString*)width height:(NSString*)height sortOption:(NSInteger)sortOption;
@end
