//
//  sendManager.m
//  GCDSocket-Manager
//
//  Created by MARVIS on 16/9/23.
//  Copyright © 2016年 MARVIS. All rights reserved.
//

#import "SendManager.h"
static SendManager *sendManager = nil;

@interface SendManager ()

@end

@implementation SendManager

+ (instancetype)shareInstance{
    @synchronized (self) {
        if (sendManager == nil) {
            sendManager = [[SendManager alloc] init];
        }
    }
    return sendManager;
}

+ (instancetype)allocWithZone:(NSZone *)zone{
    @synchronized (self) {
        if (sendManager == nil) {
            sendManager = [super allocWithZone:zone];
        }
        return sendManager;
    }
    return nil;
}




@end
