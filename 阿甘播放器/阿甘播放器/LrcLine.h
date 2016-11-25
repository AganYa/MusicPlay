//
//  LrcLine.h
//  阿甘播放器
//
//  Created by Agan on 16/9/1.
//  Copyright © 2016年 Agan. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Music;
@interface LrcLine : NSObject
//时间点
@property (nonatomic,copy) NSString *time;
//歌词
@property (nonatomic,copy) NSString *word;
//返回所有歌词model
+(NSMutableArray *)lrcLinesWithFileName:(NSString *)fileName;

@end
