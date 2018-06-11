//
//  SCPOptionController.m
//  SimiCartPluginFW
//
//  Created by Liam on 6/5/18.
//  Copyright © 2018 Trueplus. All rights reserved.
//

#import "SCPOptionController.h"

@implementation SCPOptionController
- (void)parseConfigureOptions{
    self.configureData = [NSMutableDictionary new];
    if ([[[self.appOptions valueForKey:@"configurable_options"] valueForKey:@"attributes"] isKindOfClass:[NSDictionary class]]) {
        self.configureData = [[NSMutableDictionary alloc]initWithDictionary:[[self.appOptions valueForKey:@"configurable_options"] valueForKey:@"attributes"]];
    }
    if ([self.configureData count] > 0) {
        self.configureOptionsAllKey = [self.configureData allKeys];
        self.configureOptions = [NSMutableArray new];
        for (int i = 0; i < self.configureOptionsAllKey.count; i++) {
            NSString *key = [self.configureOptionsAllKey objectAtIndex:i];
            if ([[self.configureData valueForKey:key] isKindOfClass:[NSDictionary class]]) {
                SimiConfigurableOptionModel *configurableOptionModel = [[SimiConfigurableOptionModel alloc]initWithModelData:[self.configureData valueForKey:key]];
                [self.optionTitles addObject:configurableOptionModel.title];
                if ([[configurableOptionModel valueForKey:@"options"] isKindOfClass:[NSArray class]]) {
                    NSArray *options = [configurableOptionModel valueForKey:@"options"];
                    for (int j = 0; j < options.count; j++) {
                        SimiConfigurableOptionValueModel *valueModel = [[SimiConfigurableOptionValueModel alloc]initWithModelData:[options objectAtIndex:j]];
                        valueModel.attributeId = configurableOptionModel.optionId;
                        valueModel.hightLight = YES;
                        [configurableOptionModel.values addObject:valueModel];
                    }
                    [self.configureOptions addObject:configurableOptionModel];
                }
            }
        }
    }
    
    if (self.configureOptions.count > 0) {
        self.hasOption = YES;
    }
}

- (void)activeDependenceWithConfigurableValueModel:(SimiConfigurableOptionValueModel *)valueModel configurableOptioModel:(SimiConfigurableOptionModel *)optionModel{
    NSArray *dependenceOptionIds = valueModel.dependIds;
    NSMutableSet *depenceOptionSet = [NSMutableSet setWithArray:dependenceOptionIds];
    if (dependenceOptionIds.count > 0) {
        for (int i = 0; i < self.configureOptions.count; i++) {
            SimiConfigurableOptionModel *configurableOptionModel = [self.configureOptions objectAtIndex:i];
            if(![configurableOptionModel isEqual:optionModel]){
                configurableOptionModel.isSelected = NO;
                for (int j = 0; j < configurableOptionModel.values.count; j++) {
                    SimiConfigurableOptionValueModel *tempValueModel = [configurableOptionModel.values objectAtIndex:j];
                    NSMutableSet *tempSet = [NSMutableSet setWithArray:tempValueModel.dependIds];
                    [tempSet intersectSet:depenceOptionSet];
                    if ([[tempSet allObjects] count] > 0) {
                        tempValueModel.hightLight = YES;
                        if (tempValueModel.isSelected) {
                            depenceOptionSet = tempSet;
                            configurableOptionModel.isSelected = YES;
                        }
                    }else{
                        tempValueModel.hightLight = NO;
                    }
                }
//                if (configurableOptionModel.isSelected) {
//                    for (int j = 0; j < configurableOptionModel.values.count; j++) {
//                        SimiConfigurableOptionValueModel *tempValueModel = [configurableOptionModel.values objectAtIndex:j];
//                        tempValueModel.hightLight = NO;
//                    }
//                }
            }else{
//                for (int j = 0; j < configurableOptionModel.values.count; j++) {
//                    SimiConfigurableOptionValueModel *tempValueModel = [configurableOptionModel.values objectAtIndex:j];
//                    if (![tempValueModel.valueId isEqualToString:valueModel.valueId]) {
//                        tempValueModel.hightLight = NO;
//                    }
//                }
            }
        }
    }
}
@end
