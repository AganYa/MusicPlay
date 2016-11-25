//
//  MusicTool.h
//  阿甘播放器
//
//  Created by Agan on 16/9/1.
//  Copyright © 2016年 Agan. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Music;
@interface MusicTool : NSObject
//正在播放的歌曲
+ (Music *)playingMusic;

//重设歌曲
+ (void)setPlayingMusic:(Music *)playingMusic;

//所有歌曲
+ (NSArray *)musics;

//下一首
+ (Music *)nextMusic;

//上一首
+ (Music *)previousMusic;
@end
