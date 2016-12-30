//
//  SendTerminal.m
//  GCDSocket-Manager
//
//  Created by MARVIS on 16/9/23.
//  Copyright © 2016年 MARVIS. All rights reserved.
//

#import "SendTerminal.h"
#import "GCDAsyncSocket.h"
#import "MACommon.h"

@interface SendTerminal ()<GCDAsyncSocketDelegate>
@property (nonatomic, strong) GCDAsyncSocket *sendSocket;

@property(nonatomic,strong) NSString *address;
@property(nonatomic,assign) UInt16 port;

@end

@implementation SendTerminal

- (instancetype)initWithRemoteAddress:(NSString *)address onPort:(UInt16)port{
    
    self=[super init];
    if (self) {
        self.address=address;
        self.port=port;
        [self reConnect];
    
    }
    return self;
}

-(void)reConnect{
    [self disConnect];
    self.sendSocket=[[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    NSError *error = nil;
    [self.sendSocket connectToHost:self.address onPort:self.port withTimeout:-1 error:&error];
    
    if (error == nil) {
        Log_I(@"连接成功！！！");
    } else {
        Log_E(@"error---%@",error.description);
    }
}

-(void)disConnect{
    if (self.sendSocket) {
        self.sendSocket.delegate = nil;
        [self.sendSocket disconnect];
        self.sendSocket = nil;
    }
}

- (void)sendOriginData:(NSData *)data{
    if (self.sendSocket.isConnected == NO) {
        Log_E(@"sendSocket is not connected!!!");
        [self reConnect];
        return;
    }
    int length = (int)([data length] + 100);
    Byte dataLen[4];
    [MACommon writeIntToBytes:length array:dataLen];
    NSMutableData *mixData = [[NSMutableData alloc] initWithBytes:dataLen length:sizeof(int)];
    Log_D(@"发送的头数据－－%@,长度：%d", mixData,length);
    [mixData appendData:data];
    Log_D(@"发送的数据流－－%@", mixData);
    [self.sendSocket writeData:mixData withTimeout:-1 tag:100];
}
// 苹果与苹果之间传输数据使用该方法可以相互传递数据，因为用的都是小端
//-(NSData *)pareData:(NSData *) data{
//    
//    NSUInteger length=[data length];
//    NSMutableData *sendData=[[NSMutableData alloc] init];
//    [sendData appendBytes:&length length:sizeof(NSUInteger)];
//    [sendData appendData:data];
//    
//    return sendData;
//}

#pragma mark - GCDAsyncSocketDelegate
#pragma mark 
- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port{
    Log_I(@"sock--%@,host:%@,port:%d",sock,host,port);
    //        读取4个字节的长度，以便知道传输数据的总长度下次直接读取完毕,tag 只是当前的标示并不能传输，连上之后就要开始准备读数据，包括长度什么的，都要开始读。
    NSUInteger length = sizeof(int);
    NSMutableData *buffer = [NSMutableData data];
    [self.sendSocket readDataToLength:length
                            withTimeout:-1
                                 buffer:buffer
                           bufferOffset:0
                                    tag:1111];
}

- (void)socket:(GCDAsyncSocket *)sock didConnectToUrl:(NSURL *)url{
    Log_I(@"sock : %@ ，url:%@", sock,url);
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag{
    Log_I(@" sock : %@ ,%ld", sock,tag);
    if (1111 == tag){
        Byte len[sizeof(int)];
        [data getBytes:&len length:sizeof(int)];
        int dataLen = [MACommon get4BytesToInt:len];
        Log_I(@"接收到的头数据:%@，长度为：%d",data,dataLen);
        NSMutableData *buffer = [NSMutableData data];
        //        获取新的字符串长度。
        [self.sendSocket readDataToLength:dataLen withTimeout:-1 buffer:buffer bufferOffset:0 tag:9999];
    }
    else if (9999 == tag){
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(sendTerminal:didReadData:)]){
            [self.delegate sendTerminal:self didReadData:data];
        }
        
        NSUInteger length = sizeof(int);
        NSMutableData *buffer = [NSMutableData data];
        //        读取一个字节的长度，以便知道传输数据的总长度下次直接读取完毕
        [self.sendSocket readDataToLength:length
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
