//
//  SCAppWishlistViewController_Pad.m
//  SimiCartPluginFW
//
//  Created by SimiCommerce on 12/9/14.
//  Copyright (c) 2014 Trueplus. All rights reserved.
//

#import "SCAppWishlistViewController_Pad.h"
#import "SimiGlobalVar+WishlistVar.h"
#import "SCAppWishlistModel.h"
#import "SCAppWishlistCell.h"

@interface SCAppWishlistViewController_Pad ()

@end


@implementation SCAppWishlistViewController_Pad

@synthesize shareWishlistAnchor
;

-(void)viewDidLoad
{
    [super viewDidLoad];
    [self.listEmptyText removeFromSuperview];
    shareWishlistAnchor = [[UIView alloc]initWithFrame:CGRectMake(SCREEN_HEIGHT-100, SCREEN_WIDTH - 110, 10, 10)];
}

-(SimiTableView *)createTableView
{ 
    SimiTableView * a =   [[SimiTableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
    if(SIMI_SYSTEM_IOS >= 9){
        a.cellLayoutMarginsFollowReadableWidth = NO;
    }

    return a;
}

- (void)didGetWishlistProducts:(NSNotification *)noti
{
    [super didGetWishlistProducts:noti];
    [globalAppWishlistiPadViewController didGetWishlist:noti];
    [self updateIpadProductDetailsViews];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)presentViewController:(UIViewController *)viewControllerToPresent animated: (BOOL)flag completion:(void (^)(void))completion NS_AVAILABLE_IOS(5_0)
{

    if (globalAppWishlistiPadViewController!=nil) {
        if (viewControllerToPresent.popoverPresentationController.sourceView == nil) {
        viewControllerToPresent.popoverPresentationController.sourceView = globalAppWishlistiPadViewController.shareWishlistAnchor;
        }
        [globalAppWishlistiPadViewController presentViewController:viewControllerToPresent animated:flag completion:nil];
    }
    
}

- (void)didRemoveProductFromWishlist: (NSNotification *)noti
{
    [super didRemoveProductFromWishlist:noti];
    
    SimiResponder *responder = [noti.userInfo valueForKey:@"responder"];
    
    if ([[responder.status uppercaseString] isEqualToString:@"SUCCESS"]) {
        
        
        [globalAppWishlistiPadViewController.view makeToast:SCLocalizedString(@"Removed from Wishlist")
                duration:2.0
                position:[NSValue valueWithCGPoint:CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2)]
         ];
        
        
        
        if (self.currentExpandingOption == self.selectedRow) {
            if (self.currentExpandingOption == [self.wishlistItemCount intValue]) {
                self.currentExpandingOption = 0;
                self.selectedRow = 0;
            }
            SCAppWishlistModel *product = [self.productCollection objectAtIndex:self.currentExpandingOption];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"DidSelectMyWishlistCellAtIndexPath" object:[product objectForKey:@"product_id"]  userInfo:@{@"app_wishlist_view_controller": self}];
        }
        [(SCAppWishlistCell *)[self.tableViewProductCollection cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.currentExpandingOption inSection:0]] showButtons];
        
        [globalAppWishlistiPadViewController createHeader];
        [self updateIpadProductDetailsViews];
    }
    
}



-(void) updateIpadProductDetailsViews
{
    
    for (SCProductViewController_Pad * a in ipadProductDetailsViews) {
        if (!(a.isViewLoaded && a.view.window)) {
            [a getProduct];
        }
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
