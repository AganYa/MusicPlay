//
//  Music.h
//  阿甘播放器
//
//  Created by Agan on 16/9/1.
//  Copyright © 2016年 Agan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Music : NSObject
//歌曲名字
@property (nonatomic,copy) NSString *name;
//歌曲大图
@property (nonatomic,copy) NSString *icon;
//歌曲的文件名
@property (nonatomic,copy) NSString *filename;
//歌词文件名
@property (nonatomic,copy) NSString *lrcname;
//歌手
@property (nonatomic,copy) NSString *singer;
//歌手图标
@property (nonatomic,copy) NSString *singerIcon;
//是否正在播放
@property (nonatomic,assign,getter=isPlaying) BOOL playing;

@end
