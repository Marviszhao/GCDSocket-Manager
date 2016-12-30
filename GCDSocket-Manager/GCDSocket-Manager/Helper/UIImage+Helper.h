//
//  UIImage+Helper.h
//  HappyTreasure
//
//  Created by BST-Mars on 13-10-30.
//  Copyright (c) 2013年 Mars. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Helper)

- (UIImage *)reSizeImage:(CGSize)reSize;
- (UIImage *)getScreenImage:(CGRect)rect;
- (UIImage *)scaleToSize:(CGSize)size;

- (UIImage *)imageByScalingProportionallyToMinimumSize:(CGSize)targetSize;
- (UIImage *)imageByScalingProportionallyToSize:(CGSize)targetSize;
- (UIImage *)imageByScalingToSize:(CGSize)targetSize;
- (UIImage *)imageRotatedByRadians:(CGFloat)radians;


- (UIImage *)imageWithTintColor:(UIColor *)tintColor;
- (UIImage *)imageWithGradientTintColor:(UIColor *)tintColor;

@end