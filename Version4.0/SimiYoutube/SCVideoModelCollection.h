//
//  SCVideoModelCollecion.h
//  SimiCartPluginFW
//
//  Created by Hoang Van Trung on 8/29/16.
//  Copyright © 2016 Trueplus. All rights reserved.
//

#import <SimiCartBundle/SimiCartBundle.h>

#define DidGetVideosForProduct @"DidGetVideosForProduct"

@interface SCVideoModelCollection : SimiModelCollection
-(void) getVideosForProductWithID:(NSString*) productID;
@end
