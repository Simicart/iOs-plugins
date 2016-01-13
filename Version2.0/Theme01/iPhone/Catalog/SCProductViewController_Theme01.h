//
//  SCProductViewController_Theme01.h
//  SimiCartPluginFW
//
//  Created by Tan Hoang on 2/12/14.
//  Copyright (c) 2014 SimiTeam. All rights reserved.
//

#import <SimiCartBundle/SimiTableView.h>
#import <SimiCartBundle/ScrollViewCell.h>
#import <SimiCartBundle/SCProductViewController.h>

#import "SimiGlobalVar+Theme01.h"
#import "SCProductInfoView_Theme01.h"
#import "SCTheme01ProductModelCollection.h"
#import "SCCollectionViewCell_Theme01.h"

static NSString *PRODUCT_DESCRIPTION_CELL_ID        = @"ProductDescriptionIdentifier";

@interface SCProductViewController_Theme01 : SCProductViewController<UITableViewDelegate, UITableViewDataSource, ScrollViewCellDelegate, UITextFieldDelegate, SCProductInfoView_Theme01_Delegate,UIScrollViewDelegate>
{
    SCProductInfoView_Theme01 *productInfoViewTheme01;
}

/*
 The function tableView cellForRowAtIndexPath raise notification name: "InitializedProductCell-After" after created a cell.
 The function tableView didSelectRowAtIndexPath raise notification name: "DidSelectProductCellAtIndexPath" before TO-DO list in the function.
 */

@property (strong, nonatomic) NSString *arrowImageName;
@end
