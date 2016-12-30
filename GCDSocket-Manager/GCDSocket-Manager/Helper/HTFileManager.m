//
//  HTFileManager.m
//  HappyTreasure
//
//  Created by BST-Mars on 13-10-30.
//  Copyright (c) 2013年 Mars. All rights reserved.
//

#import "HTFileManager.h"

@implementation HTFileManager

/*
 *  返回Support路径
 */
+ (NSString*)archivePath {
    NSFileManager *fileManager = [NSFileManager defaultManager];
	NSURL *supportUrl = [fileManager URLForDirectory:NSApplicationSupportDirectory
                                            inDomain:NSUserDomainMask
                                   appropriateForURL:nil
                                              create:YES
                                               error:NULL];
    
    return [supportUrl path];
}

/*
 *  获取support下的filename路径
 */
+ (NSString*)getArchiveFilePath:(NSString*)filename {
    NSString *supportPath = [HTFileManager archivePath];
    if ([filename length] > 0)
        supportPath = [supportPath stringByAppendingPathComponent:filename];
    
    return supportPath;
}

+ (NSString*)getArchiveFilePath:(NSString*)filename extension:(NSString*)extension {
    NSString *supportPath = [HTFileManager archivePath];
    if ([filename length] > 0 && [extension length] > 0) {
        filename = [filename stringByAppendingPathExtension:extension];
        supportPath = [supportPath stringByAppendingPathComponent:filename];
    }
    
    return supportPath;
}

/*
 *  设置保存support下的filename路径
 */
+ (NSString*)setArchiveFilePath:(NSString*)filename {
    NSString *supportPath = [HTFileManager getArchiveFilePath:filename];
    
    BOOL isDirectory = YES;
    NSError *error = nil;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:supportPath isDirectory:&isDirectory]) {
        NSURL *url = [NSURL fileURLWithPath:supportPath isDirectory:YES];
        [fileManager createDirectoryAtURL:url withIntermediateDirectories:YES attributes:nil error:&error];
    }
    
    return supportPath;
}

+ (NSString*)setArchiveFilePath:(NSString*)filename extension:(NSString*)extension {
    NSString *supportPath = [HTFileManager getArchiveFilePath:filename extension:extension];
    
    BOOL isDirectory = YES;
    NSError *error = nil;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:supportPath isDirectory:&isDirectory]) {
        NSURL *url = [NSURL fileURLWithPath:supportPath isDirectory:YES];
        [fileManager createDirectoryAtURL:url withIntermediateDirectories:YES attributes:nil error:&error];
    }
    
    return supportPath;
}

@end
