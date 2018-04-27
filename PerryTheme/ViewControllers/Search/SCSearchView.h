//
//  SCSearchView.h
//  SimiCartPluginFW
//
//  Created by Hoang Van Trung on 3/13/18.
//  Copyright © 2018 Trueplus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCSearchTextField.h"

@protocol SCSearchViewDelegate
- (void)searchWithText:(NSString *)searchKey;
@end

@interface SCSearchView : UIView<UITextFieldDelegate,SCSearchTextFieldDelegate>
@property (strong, nonatomic) SCSearchTextField *searchTextField;
@property (strong, nonatomic) UIView *searchBackgroundView;
@property (weak, nonatomic) id<SCSearchViewDelegate>delegate;
@end
