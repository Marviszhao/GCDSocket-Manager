//
//  receiverManager.m
//  GCDSocket-Manager
//
//  Created by MARVIS on 16/9/23.
//  Copyright © 2016年 MARVIS. All rights reserved.
//

#import "ReceiverManager.h"
static ReceiverManager *receiverManager = nil;


@interface ReceiverManager ()

@end

@implementation ReceiverManager

+ (instancetype)shareInstance{
    @synchronized (self) {
        if (receiverManager == nil) {
            receiverManager = [[ReceiverManager alloc] init];
        }
    }
    return receiverManager;
}

+ (instancetype)allocWithZone:(NSZone *)zone{
    @synchronized (self) {
        if (receiverManager == nil) {
            receiverManager = [super allocWithZone:zone];
        }
        return receiverManager;
    }
    return nil;
}




@end
