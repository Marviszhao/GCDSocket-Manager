//
//  ReceiveTerminal.h
//  GCDSocket-Manager
//
//  Created by MARVIS on 16/9/23.
//  Copyright © 2016年 MARVIS. All rights reserved.
//  接收端，类似于服务器端

#import <Foundation/Foundation.h>
#import "TransferConstants.h"

@class ReceiveTerminal;
@protocol ReceiveTerminalDelegate <NSObject>
    
- (void)receiver:(ReceiveTerminal *)receTerminal didReceiveData:(NSData *)data num:(NSInteger)i;

@end


@interface ReceiveTerminal : NSObject
    
@property(nonatomic,weak) id<ReceiveTerminalDelegate> delegate;
    
-(instancetype)initWithPort:(NSUInteger)port;
//重新开启监听连接
-(void)reConnect;
// 关闭所有连接，移除所有代理
-(void)disConnect;
    
@end
