//
//  ZThemeProductOptionViewController.h
//  SimiCartPluginFW
//
//  Created by NghiepLy on 6/2/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import <SimiCartBundle/SimiCartBundle.h>
#import <SimiCartBundle/SimiViewController.h>
#import <SimiCartBundle/SimiTableView.h>
#import <SimiCartBundle/SimiTable.h>
#import <SimiCartBundle/SCOptionGroupViewCell.h>

#import "ZThemeSection.h"
#import "ZThemeRow.h"
#import "SimiGlobalVar+ZTheme.h"

@protocol  ZThemeProductOptionViewController_Delegate <NSObject>
@optional
- (void)doneButtonTouch;
- (void)cancelButtonTouch;
@end

@interface ZThemeProductOptionViewController : SimiViewController<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property (strong, nonatomic) SimiTableView *tableViewOption;
@property (strong, nonatomic) SimiTable *cells;
@property (strong, nonatomic) SimiProductModel *product;
@property (strong, nonatomic) NSMutableDictionary *optionDict;
@property (strong, nonatomic) NSArray *allKeys;
@property (strong, nonatomic) NSMutableDictionary *selectedOptionPrice;
@property (weak, nonatomic) id<ZThemeProductOptionViewController_Delegate> delegate;
// Textfield and datetime options
@property (nonatomic) CGFloat widthTable;

// Done and Cancel button
@property (nonatomic, strong) UIButton *buttonCancel;
@property (nonatomic, strong) UIButton *buttonDone;

@end

@interface ProductOptionSelectCell : UITableViewCell
@property (nonatomic, strong) UILabel *lblNameOption;
@property (nonatomic, strong) UILabel *lblPriceInclTax;
@property (nonatomic, strong) UILabel *lblPriceExclTax;
@property (nonatomic, strong) UIImageView *imageSelect;
@property (nonatomic) BOOL isMultiSelect;
@property (nonatomic) BOOL isSelected;
@property (nonatomic, strong) NSDictionary * dataCell;
- (void)setDataForCell:(NSDictionary*)data;
@end

@interface ProductOptionTextCell : UITableViewCell
@property (nonatomic, strong) UITextField *textOption;
@end

@interface ProductOptionDateTimeCell : UITableViewCell
@property (nonatomic, strong) UIDatePicker *datePicker;
@end

