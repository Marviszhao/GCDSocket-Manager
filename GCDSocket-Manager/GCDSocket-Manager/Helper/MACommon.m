//
//  MACommon.m
//  GCDSocket-Manager
//
//  Created by MARVIS on 16/10/10.
//  Copyright © 2016年 MARVIS. All rights reserved.
//

#import "MACommon.h"

@implementation MACommon

+(void) writeIntToBytes:(int)num array:(Byte[])data
{
    data[0] = (Byte) ((num >> 24) & 0xFF);
    data[1] = (Byte) ((num >> 16) & 0xFF);
    data[2] = (Byte) ((num >> 8) & 0xFF);
    data[3] = (Byte) (num  & 0xFF);
}

+ (int) get4BytesToInt:(Byte[]) data
{
    return ( (data[0] & 0xFF) << 24)
    | ((data[1] & 0xFF)<< 16)
    | ((data[2] & 0xFF) << 8)
    | (data[3] & 0xFF);
}

+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString{
    if (jsonString == nil) {
        NSLog(@"jsonString can not be nil or @"" !!!");
        return nil;
    }
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err) {
        NSLog(@"json parse failed：%@",err);
        return nil;
    }
    return dic;
    
}

+ (NSString*)jsonStringWithDictionary:(NSDictionary *)dic{
    NSError *parseError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&parseError];
    if (parseError) {
        NSLog(@"parse json  Error--->>%@",parseError.description);
    }
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
}


@end
