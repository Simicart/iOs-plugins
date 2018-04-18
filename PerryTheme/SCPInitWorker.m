//
//  SCPInitWorker.m
//  SimiCartPluginFW
//
//  Created by Liam on 4/18/18.
//  Copyright © 2018 Trueplus. All rights reserved.
//

#import "SCPInitWorker.h"
#import <SimiCartBundle/InitWorker.h>

@implementation SCPInitWorker
- (id)init{
    if(self == [super init]){
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(initializedRootController:) name:Simi_InitializedRootController object:nil];
    }
    return self;
}
- (void)initializedRootController:(NSNotification *)noti{
    if([GLOBALVAR.appConfigModel objectForKey:@"‘perry_theme’"]){
        InitWorker *initWorker = noti.object;
        initWorker.isDiscontinue = YES;
        //Init the root view
    }
}
@end
