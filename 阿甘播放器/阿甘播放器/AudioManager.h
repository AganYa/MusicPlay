//
//  AudioManager.h
//  阿甘播放器
//
//  Created by Agan on 16/9/1.
//  Copyright © 2016年 Agan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
@interface AudioManager : NSObject

+(instancetype)defaultMangers;

//播放音乐
- (AVAudioPlayer *)playingMisuc:(NSString *)filename;
- (void)pauseMusic:(NSString *)filename;
- (void)stopMusic:(NSString *)filename;
 //播放音效
- (void)playSound:(NSString *)filename;
- (void)disposeSound:(NSString *)filename;
@end
