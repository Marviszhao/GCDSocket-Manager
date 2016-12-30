//
//  HTFileManager.h
//  HappyTreasure
//
//  Created by BST-Mars on 13-10-30.
//  Copyright (c) 2013年 Mars. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HTFileManager : NSObject

+ (NSString*)archivePath;
+ (NSString*)getArchiveFilePath:(NSString*)filename;
+ (NSString*)getArchiveFilePath:(NSString*)filename extension:(NSString*)extension;
+ (NSString*)setArchiveFilePath:(NSString*)filepath;
+ (NSString*)setArchiveFilePath:(NSString*)filename extension:(NSString*)extension;

@end
