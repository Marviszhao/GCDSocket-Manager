//
//  SendTerminal.h
//  GCDSocket-Manager
//
//  Created by MARVIS on 16/9/23.
//  Copyright © 2016年 MARVIS. All rights reserved.
//  发送端，类似于客户端

#import <Foundation/Foundation.h>
#import "TransferConstants.h"
@class SendTerminal;

@protocol SendTerminalDelegate <NSObject>

- (void)sendTerminal:(SendTerminal *)sendTer didReadData:(NSData *)data;

@end

@interface SendTerminal : NSObject

@property (nonatomic, weak) id<SendTerminalDelegate> delegate;
    
- (instancetype)initWithRemoteAddress:(NSString *)address onPort:(UInt16)port;

- (void)sendOriginData:(NSData *)data;

//重新开启长连接，连接服务器
-(void)reConnect;
// 关闭所有连接，移除所有代理
-(void)disConnect;

@end
