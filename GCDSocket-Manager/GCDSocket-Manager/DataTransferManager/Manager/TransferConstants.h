//
//  TransferConstants.h
//  GCDSocket-Manager
//
//  Created by MARVIS on 16/9/29.
//  Copyright © 2016年 MARVIS. All rights reserved.
//

#ifndef TransferConstants_h
#define TransferConstants_h

#define Log_INFO(FORMAT, ...) printf("-%s-%s-%d----->%s\n\n" , [[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String], __func__, __LINE__, [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String])
#define Log_C(FORMAT, ...) Log_INFO(FORMAT, ##__VA_ARGS__);
// 日志打印(DEBUG级别)
#define Log_D(FORMAT, ...) Log_INFO(FORMAT, ##__VA_ARGS__);
// 日志打印(INFO级别)
#define Log_I(FORMAT, ...) Log_INFO(FORMAT, ##__VA_ARGS__);
// 日志打印(Warning级别)
#define Log_W(FORMAT, ...) Log_INFO(FORMAT, ##__VA_ARGS__);
// 日志打印(Error级别)
#define Log_E(FORMAT, ...) Log_INFO(FORMAT, ##__VA_ARGS__);

//请求命令类型取值范围：1-999
//应答命令类型取值：1000+对应请求命令类型取值

/**
 *  会话代码
 */
typedef NS_ENUM(int, SESSION_TYPE){
    /**
     *
     */
    SESSION_TYPE_NONE = -1,
    /**
     *  连接初始化请求
     */
    SESSION_TYPE_CONNINIT_REQ = 100,
    /**
     *  连接初始化响应
     */
    SESSION_TYPE_CONNINIT_RSP = 1100,
    /**
     *  连接关闭请求
     */
    SESSION_TYPE_DISCONN_REQ = 101,
    /**
     *  连接关闭应答
     */
    SESSION_TYPE_DISCONN_RSP = 1101,
    /**
     *  传输任务开始请求
     */
    SESSION_TYPE_TASK_BEGIN_REQ = 1,
    /**
     *  传输任务开始应答
     */
    SESSION_TYPE_TASK_BEGIN_RSP = 1001,
    /**
     *  传输任务结束请求
     */
    SESSION_TYPE_ENDTASK_REQ = 2,
    /**
     *  传输任务结束应答
     */
    SESSION_TYPE_ENDTASK_RSP = 1002,
    /**
     *  文件传输请求
     */
    SESSION_TYPE_FILE_BEGIN_REQ = 11,
    /**
     *  文件传输应答
     */
    SESSION_TYPE_FILE_BEGIN_RSP = 1011,
    /**
     *  文件接收完成请求
     */
    SESSION_TYPE_ENDFILE_REQ = 12,
    /**
     *  文件接收完成应答
     */
    SESSION_TYPE_ENDFILE_RSP = 1012,
    /**
     *  心跳请求请求
     */
    SESSION_TYPE_HEARTBREAK_REQ = 102,
    
    /**
     *  心跳请求应答
     */
    SESSION_TYPE_HEARTBREAK_RSP = 1102
};



/********(常量)*******/
/**
 *  服务器端口
 */
#define RECEIVE_PORT 50001

/**
 *  数据流读取长度
 */
#define DATA_READ_LENGTH 1024*16

/**
 *  数据流写入长度
 */
#define DATA_WRITE_LENGTH 1024*16
/**
 *  消息头一个单元长度
 */
#define INT_LENGTH 4
/**
 *  读取超时时间
 */
#define TIME_OUT 20

/**
 *  /重连时间间隔
 */
#define RECONNECT_DELAY 10

/**
 *  重连次数
 */
#define RECONNECT_COUNT 5




#endif /* TransferConstants_h */
