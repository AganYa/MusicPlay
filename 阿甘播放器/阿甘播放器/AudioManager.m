//
//  AudioManager.m
//  阿甘播放器
//
//  Created by Agan on 16/9/1.
//  Copyright © 2016年 Agan. All rights reserved.
//

#import "AudioManager.h"
static AudioManager *_instance=nil;
@interface AudioManager ()
@property(nonatomic,strong) NSMutableDictionary *musicPlayers;
@property(nonatomic,strong) NSMutableDictionary *soundIDs;

@end

@implementation AudioManager

+(void)initialize{
    //音频会话
    AVAudioSession *session = [AVAudioSession sharedInstance];
    
    //设置会话模式
    [session setCategory:AVAudioSessionCategoryPlayback error:nil];
    
    //激活会话
    [session setActive:YES error:nil];
  
}

+ (instancetype)defaultMangers{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,^{
        _instance = [[self alloc] init];
    });
    return _instance;
}
-(instancetype)init{
    __block AudioManager *temp=self;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if ((temp = [super init]) != nil) {
            _musicPlayers = [NSMutableDictionary dictionary];
            _soundIDs = [NSMutableDictionary dictionary];
        }
    });
    self = temp;
    return self;
}

+(instancetype)allocWithZone:(struct _NSZone *)zone{
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken,^{
        
        _instance = [super allocWithZone:zone];
    });
    return _instance;
}

//播放音乐
-(AVAudioPlayer *)playingMisuc:(NSString *)filename{
    if (filename == nil || filename.length == 0)
        return nil;
        //先查询对象是否缓存了
        AVAudioPlayer *player=self.musicPlayers[filename];
        
        if (!player) {
            NSURL *url=[[NSBundle mainBundle] URLForResource:filename withExtension:nil];
            if (!url){
                return nil;
            }
                player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
                
            if (![player prepareToPlay]) {
                return nil;
            }
            //对象是最新创建的，那么对它进行一次缓存
            self.musicPlayers[filename]=player;
        }
        
        //如果没有正在播放，那么开始播放，如果正在播放，那么不需要改变什么
        if (![player isPlaying]) {
            [player play];
        }
        
        return player;
}

- (void)pauseMusic:(NSString *)filename
{
    if (filename == nil || filename.length == 0)  return;
    
    AVAudioPlayer *player = self.musicPlayers[filename];
    
    if ([player isPlaying]) {
        [player pause];
    }
}
- (void)stopMusic:(NSString *)filename
{
    if (filename == nil || filename.length == 0)  return;
    
    AVAudioPlayer *player = self.musicPlayers[filename];
    
    [player stop];
    
    [self.musicPlayers removeObjectForKey:filename];
}
//播放音效
-(void)playSound:(NSString *)filename{
    if (!filename) {
        return;
    }
    SystemSoundID soundID=(int)[self.soundIDs[filename]unsignedLongValue];
    if (!soundID) {
        NSURL *url = [[NSBundle mainBundle] URLForResource:filename withExtension:nil];
        if(!url)
            return;
        
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)(url), &soundID);
        
        self.soundIDs[filename] = @(soundID);
    }
    //播放
     AudioServicesPlaySystemSound(soundID);
}
//摧毁音效
- (void)disposeSound:(NSString *)filename
{
    if (!filename) return;
    
    
    SystemSoundID soundID = (int)[self.soundIDs[filename] unsignedLongValue];
    
    if (soundID) {
        AudioServicesDisposeSystemSoundID(soundID);
        
        [self.soundIDs removeObjectForKey:filename];    //音效被摧毁，那么对应的对象应该从缓存中移除
    }
}

@end





















