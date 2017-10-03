//
//  SCWishlistViewController.h
//  SimiCartPluginFW
//
//  Created by Hoang Van Trung on 8/25/16.
//  Copyright © 2016 Trueplus. All rights reserved.
//

#import <SimiCartBundle/SimiCartBundle.h>
#import <SimiCartBundle/SCProductViewControllerPad.h>
#import "SCWishlistModelCollection.h"
#import "SCWishlistCollectionViewCell.h"

@interface SCWishlistViewController : SimiViewController<UICollectionViewDelegate, UICollectionViewDataSource, SCWishlistCollectionViewCellDelegate>
@end
