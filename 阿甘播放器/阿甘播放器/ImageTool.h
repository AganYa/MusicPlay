//
//  ImageTool.h
//  阿甘播放器
//
//  Created by Agan on 16/9/1.
//  Copyright © 2016年 Agan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface ImageTool : NSObject
//压缩图片
+ (UIImage *)imageCompress:(UIImage *)img targetSize:(CGSize)targetSize;


//给一张图片添加文字描述
+ (UIImage *)addTextOnImage:(UIImage *)img mark:(NSString *)mark rect:(CGRect)rect font:(UIFont *)font color:(UIColor *)color;


//将图片裁剪为带边框圆形
+ (UIImage *)circleImageWithName:(NSString *)name borderWidth:(CGFloat)borderWidth borderColor:(UIColor *)borderColor;
@end
