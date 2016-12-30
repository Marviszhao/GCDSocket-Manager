//
//  MACommon.h
//  GCDSocket-Manager
//
//  Created by MARVIS on 16/10/10.
//  Copyright © 2016年 MARVIS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MACommon : NSObject
//小段转大段 ARM芯片默认采用小端，Java是平台无关的，默认是大端。在网络上传输数据普遍采用的都是大端。
+(void) writeIntToBytes:(int)num array:(Byte[])data;
//大段转小段
+ (int) get4BytesToInt:(Byte[]) data;

+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString;

+ (NSString*)jsonStringWithDictionary:(NSDictionary *)dic;

@end
