//
//  MusicTool.m
//  阿甘播放器
//
//  Created by Agan on 16/9/1.
//  Copyright © 2016年 Agan. All rights reserved.
//

#import "MusicTool.h"
#import "Music.h"
#import "MJExtension.h"
static NSArray *_musics;
static Music *_playingMusic;
@implementation MusicTool



+ (NSArray *)musics{
    if (_musics==nil) {
        _musics = [Music objectArrayWithFilename:@"Musics.plist"];
    }
    return _musics;
}

+ (Music *)playingMusic
{
    return _playingMusic;
}

+ (void)setPlayingMusic:(Music *)playingMusic
{
    if (playingMusic == nil || ![_musics containsObject:playingMusic] || playingMusic == _playingMusic) {
        return;
    }
    _playingMusic = playingMusic;
}


+ (Music *)nextMusic
{
    int nextIndex = 0;
    if (_playingMusic) {
        int playingIndex = (int)[[self musics] indexOfObject:_playingMusic];
        nextIndex = playingIndex + 1;
        if (nextIndex >= [self musics].count) {
            nextIndex = 0;
        }
    }
    return [self musics][nextIndex];
}

+ (Music *)previousMusic
{
    int previousIndex = 0;
    if (_playingMusic) {
        int playingIndex = (int)[[self musics] indexOfObject:_playingMusic];
        previousIndex = playingIndex - 1;
        if (previousIndex < 0) {
            previousIndex = (int)[self musics].count - 1;
        }
    }
    return [self musics][previousIndex];
}

@end
