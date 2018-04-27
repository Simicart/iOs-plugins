//
//  SCSearchTextField.h
//  SimiCartPluginFW
//
//  Created by Hoang Van Trung on 3/14/18.
//  Copyright © 2018 Trueplus. All rights reserved.
//

#import <SimiCartBundle/SimiCartBundle.h>

@protocol SCSearchTextFieldDelegate;

@interface SCSearchTextField : UITextField
@property (weak, nonatomic) id<SCSearchTextFieldDelegate>searchDelegate;
@end

@protocol SCSearchTextFieldDelegate
- (void)searchTextField:(SCSearchTextField *)searchTextField didSetSearchText:(NSString *)searchText;
@end


