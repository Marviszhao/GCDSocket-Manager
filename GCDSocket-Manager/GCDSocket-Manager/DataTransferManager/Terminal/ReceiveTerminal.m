//
//  ReceiveTerminal.m
//  GCDSocket-Manager
//
//  Created by MARVIS on 16/9/23.
//  Copyright © 2016年 MARVIS. All rights reserved.
//

#import "ReceiveTerminal.h"
#import "GCDAsyncSocket.h"
#import "MACommon.h"

@interface ReceiveTerminal ()<GCDAsyncSocketDelegate>
    
@property (nonatomic, assign) NSUInteger port;
    
@property (nonatomic, strong) GCDAsyncSocket *receiveSocket;
    
@property(nonatomic,strong)NSMutableArray *aNewSocketArr;

@property (nonatomic, strong) GCDAsyncSocket *clientSocket;

@end

@implementation ReceiveTerminal

-(instancetype)initWithPort:(NSUInteger)port{
    self=[super init];
    if (self) {
        self.port=port;
        [self reConnect];
    }
    
    return self;
}

-(void)reConnect{
    [self disConnect];
    self.receiveSocket =[[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    if (![_receiveSocket isConnected]) {
        NSError *error = nil;
        if (![_receiveSocket acceptOnPort:self.port error:&error]) {
            Log_E(@"%@",error);
        }
    }
}

-(void)disConnect{
//   1 关闭客户端长连接
    if (self.clientSocket) {
        @try {
            self.clientSocket.delegate = nil;
            [self.clientSocket disconnect];
        }
        @catch (NSException *exception) {
            Log_I(@"关闭异常");
        }
        @finally {
            self.clientSocket = nil;
        }
    }
//   2 关闭服务端长连接
    if (self.receiveSocket) {
        self.receiveSocket.delegate = nil;
        [self.receiveSocket disconnect];
        self.receiveSocket = nil;
    }
}
    
#pragma mark - GCDAsyncSocketDelegate
#pragma mark 
- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket{//新的socket肯定是跟原来的不一样，原来的负责监听远端的socket长连接，监听到后会默认创建一个新的连接返回回来，要使用这个远端的socket中读取发送来的数据
    
    self.clientSocket = newSocket;
    Log_I(@"sock:%@----%d",newSocket.connectedHost,newSocket.connectedPort);
    [self.aNewSocketArr addObject:newSocket];
    newSocket.delegate = self;

    //        读取4个字节的长度，以便知道传输数据的总长度下次直接读取完毕,tag 只是当前的标示并不能传输，连上之后就要开始准备读数据，包括长度什么的，都要开始读。
    NSUInteger length = sizeof(int);
    NSMutableData *buffer = [NSMutableData data];
    [self.clientSocket readDataToLength:length
                          withTimeout:-1
                               buffer:buffer
                         bufferOffset:0
                                  tag:1111];
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag{
    Log_I(@" sock : %@ ,%ld", sock,tag);
    if (1111 == tag){
        Byte len[sizeof(int)];
        [data getBytes:&len length:sizeof(int)];
//       大段转小段
        int dataLen = [MACommon get4BytesToInt:len];
        Log_I(@"接收到的头数据:%@，长度为：%d",data,dataLen);
        NSMutableData *buffer = [NSMutableData data];
        //        获取新的字符串长度。
        [self.clientSocket readDataToLength:dataLen withTimeout:-1 buffer:buffer bufferOffset:0 tag:9999];
    }
    else if (9999 == tag){
        if (self.delegate && [self.delegate respondsToSelector:@selector(receiver:didReceiveData:num:)]){
            [self.delegate receiver:self didReceiveData:data num:[self.aNewSocketArr indexOfObject:sock]];
        }
        
        NSUInteger length = sizeof(int);
        NSMutableData *buffer = [NSMutableData data];
        //        读取一个字节的长度，以便知道传输数据的总长度下次直接读取完毕
        [self.clientSocket readDataToLength:length
                              withTimeout:-1
                                   buffer:buffer
                             bufferOffset:0
                                      tag:1111];
    }
}
    
- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(nullable NSError *)err{
    Log_I(@"sock : %@ ,err:%@", sock,err);
}


@end
