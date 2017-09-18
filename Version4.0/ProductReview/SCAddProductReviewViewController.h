//
//  SCAddProductReviewViewController.h
//  SimiCartPluginFW
//
//  Created by Hoang Van Trung on 10/14/16.
//  Copyright © 2016 Trueplus. All rights reserved.
//

#import <SimiCartBundle/SimiCartBundle.h>

@interface SCAddProductReviewViewController : SimiViewController<UITextFieldDelegate,UITextViewDelegate, UIScrollViewDelegate>
@property SimiProductModel* productModel;
@end
