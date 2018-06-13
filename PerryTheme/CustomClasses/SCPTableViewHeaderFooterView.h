//
//  SCPTableViewHeaderFooterView.h
//  SimiCartPluginFW
//
//  Created by Liam on 6/11/18.
//  Copyright © 2018 Trueplus. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SCPTableViewHeaderFooterView : UITableViewHeaderFooterView
@property (nonatomic, strong) UIView *simiContentView;
@property (nonatomic, strong) SimiLabel *titleLabel;
@property (nonatomic, strong) UIImageView *iconImageView;
@end
