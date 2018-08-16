//
//  SCCustomizeRegisterViewController.h
//  SimiCartPluginFW
//
//  Created by Liam on 3/12/18.
//  Copyright © 2018 Trueplus. All rights reserved.
//

#import <SimiCartBundle/SCRegisterViewController.h>

@interface SCCustomizeRegisterViewController : SCRegisterViewController
@property (strong, nonatomic) SimiFormSelect *country;
@property (strong, nonatomic) SimiFormText *stateName;
@property (strong, nonatomic) SimiFormSelect *stateId;
@property (strong, nonatomic) NSArray *states;
@property (strong, nonatomic) NSArray *countries;
@end
