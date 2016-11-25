//
//  PlayingViewController.m
//  阿甘播放器
//
//  Created by Agan on 16/9/1.
//  Copyright © 2016年 Agan. All rights reserved.
//

#import "PlayingViewController.h"
#import "UIView+Extension.h"
#import "Music.h"
#import <AVFoundation/AVFoundation.h>
#import "MusicTool.h"
#import "AudioManager.h"
#import "LrcView.h"
#import "UIView+AutoLayout.h"
#import <MediaPlayer/MediaPlayer.h>
static long steps;

@interface PlayingViewController ()<AVAudioPlayerDelegate>
@property (nonatomic, strong) CADisplayLink *display;
@property (nonatomic, strong) Music *playingMusic;
@property (nonatomic, strong) AVAudioPlayer *player;
/**
 *  显示播放进度条的定时器
 */
@property (nonatomic, strong) NSTimer *timer;
/**
 *  显示歌词的定时器
 */
@property (nonatomic, strong) CADisplayLink *lrcTimer;
/**
 *  判断歌曲播放过程中是否被电话等打断播放
 */
@property (nonatomic, assign) BOOL isInterruption;

@property (nonatomic, weak) LrcView *lrcView;

@property (weak, nonatomic) IBOutlet UIImageView *iconView;

@property (weak, nonatomic) IBOutlet UILabel *songLabel;
@property (weak, nonatomic) IBOutlet UILabel *singerLabel;
@property (weak, nonatomic) IBOutlet UIButton *showProgressLabel;
@property (weak, nonatomic) IBOutlet UIButton *playOrPauseButton;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIView *progressView;
@property (weak, nonatomic) IBOutlet UIButton *slider;

@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UIButton *exitBtn;
@property (weak, nonatomic) IBOutlet UIButton *lyricOrPhotoBtn;
- (IBAction)playOrPause:(id)sender;
- (IBAction)lyricOrPhoto:(id)sender;
- (IBAction)exit:(id)sender;

- (IBAction)panSlider:(UIPanGestureRecognizer *)sender;
- (IBAction)tapProgressView:(UITapGestureRecognizer *)sender;
- (IBAction)previous:(id)sender;
- (IBAction)next:(id)sender;


@end

@implementation PlayingViewController


/** 时钟动画更新的方法*/
- (void)update
{
    steps++;
    // 每秒执行六次下雪的方法
    if (steps % 10 == 0) {
        [self snow];
    }
}

/** 下雪的方法*/
- (void)snow
{
    // 添加一个雪花视图
    UIImageView *iconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"snow"]];
    // 缩小雪花，使用可动画属性实现
    [iconView.layer setValue:@(0.4) forKeyPath:@"transform.scale"];
    // 设置初始位置
    CGFloat startX = arc4random_uniform(self.view.bounds.size.width);
    CGFloat startY = - (iconView.bounds.size.height * 0.5);
    iconView.center = CGPointMake(startX, startY);
    // 添加到视图顶部
    [self.view addSubview:iconView];
    // 实现动画效果
    [UIView animateWithDuration:10.0f animations:^{
        // 设置终止位置
        CGFloat endX = arc4random_uniform(self.view.bounds.size.width);
        CGFloat endY = self.view.bounds.size.height + iconView.bounds.size.height;
        iconView.center = CGPointMake(endX, endY);
        
        // 改变雪花的旋转角度
        [iconView.layer setValue:@(M_PI) forKeyPath:@"transform.rotation"];
        // 改变雪花的透明度
        [iconView.layer setValue:@(0.4) forKey:@"opacity"];
        // 改变雪花的尺寸
        CGFloat scale = (arc4random_uniform(4) + 1)/ 10.0;
        [iconView.layer setValue:@(scale) forKeyPath:@"transform.scale"];
    } completion:^(BOOL finished) {
        // 从父视图中删除
        [iconView removeFromSuperview];
    }];
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // 设置背景颜色
    self.view.backgroundColor = [UIColor colorWithRed:(87/255.0) green:(192/255.0) blue:(255/255.0) alpha:1];
    // 实例化时钟动画
    self.display = [CADisplayLink displayLinkWithTarget:self selector:@selector(update)];
    // 添加到运行循环
    [self.display addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];


    self.view.backgroundColor = [UIColor redColor];
    
    [self.slider setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    self.slider.font = [UIFont systemFontOfSize:12];
    [self setupLrcView];
    
}

#pragma mark ----setup系列方法

- (void)setupLrcView
{
    LrcView *lrcView = [[LrcView alloc] init];
    self.lrcView = lrcView;
    lrcView.hidden = YES;
    [self.topView addSubview:lrcView];
    [lrcView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(0, 0, - 50, 0)];
    [self.topView insertSubview:self.exitBtn aboveSubview:lrcView];
    [self.topView insertSubview:self.lyricOrPhotoBtn aboveSubview:lrcView];
}

- (void)show
{
    //    NSLog(@"%@",NSStringFromCGRect(self.view.frame));
    UIWindow *windows = [UIApplication sharedApplication].keyWindow;
    self.view.bounds = windows.bounds;
    [windows addSubview:self.view];
    self.view.y = self.view.height;
    self.view.hidden = NO;
    if (self.playingMusic != [MusicTool playingMusic]) {
        [self resetPlayingMusic];
    }
    
    windows.userInteractionEnabled = NO;         //以免在动画过程中用户多次点击，或者造成其他事件的发生
    [UIView animateWithDuration:0.25 animations:^{
        self.view.y = 0;
    }completion:^(BOOL finished) {
        windows.userInteractionEnabled = YES;
        [self startPlayingMusic];
    }];
}

#pragma mark ----音乐控制
//重置播放的歌曲
- (void)resetPlayingMusic
{
    // 重置界面数据
    self.iconView.image = [UIImage imageNamed:@"play_cover_pic_bg"];
    self.singerLabel.text = nil;
    self.songLabel.text = nil;
    self.timeLabel.text = [self stringWithTime:0];
    self.slider.x = 0;
    self.progressView.width = self.slider.center.x;
    [self.slider setTitle:[self stringWithTime:0] forState:UIControlStateNormal];
    
    //停止播放音乐
    [[AudioManager defaultMangers] stopMusic:self.playingMusic.filename];
    
    self.player = nil;
    
    //清空歌词
    self.lrcView.fileName = @"";
    self.lrcView.currentTime = 0;
    
    [self removeCurrentTimer];
    [self removeLrcTimer];
}

//开始播放音乐
- (void)startPlayingMusic
{
    if (self.playingMusic == [MusicTool playingMusic])  {
        [self addCurrentTimer];
        [self addLrcTimer];
        return;
    }
    
    // 设置所需要的数据
    self.playingMusic = [MusicTool playingMusic];
    self.iconView.image = [UIImage imageNamed:self.playingMusic.icon];
    self.songLabel.text = self.playingMusic.name;
    self.singerLabel.text = self.playingMusic.singer;
    
    //开发播放音乐
    self.player = [[AudioManager defaultMangers] playingMisuc:self.playingMusic.filename];
  
    self.player.delegate = self;
    
    self.timeLabel.text = [self stringWithTime:self.player.duration];
    
    [self addCurrentTimer];
    [self addLrcTimer];
    //切换歌词
    self.lrcView.fileName = self.playingMusic.lrcname;
    self.playOrPauseButton.selected = YES;
    
    //切换锁屏
    [self updateLockedScreenMusic];
}

#pragma mark ----进度条定时器处理
/**
 *  添加定时器
 */
- (void)addCurrentTimer
{
    if (![self.player isPlaying]) return;
    
    //在新增定时器之前，先移除之前的定时器
    [self removeCurrentTimer];
    
    [self updateCurrentTimer];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateCurrentTimer) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

/**
 *  移除定时器
 */
- (void)removeCurrentTimer
{
    [self.timer invalidate];
    self.timer = nil;
}

/**
 *  触发定时器
 */
- (void)updateCurrentTimer
{
    double temp = self.player.currentTime / self.player.duration;
    self.slider.x = temp * (self.view.width - self.slider.width);
    [self.slider setTitle:[self stringWithTime:self.player.currentTime] forState:UIControlStateNormal];
    self.progressView.width = self.slider.center.x;
}

#pragma mark ----歌词定时器

- (void)addLrcTimer
{
    if (self.lrcView.hidden == YES) return;
    
    if (self.player.isPlaying == NO && self.lrcTimer) {
        [self updateLrcTimer];
        return;
    }
    
    [self removeLrcTimer];
    
    [self updateLrcTimer];
    
    self.lrcTimer = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateLrcTimer)];
    [self.lrcTimer addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)removeLrcTimer
{
    [self.lrcTimer invalidate];
    self.lrcTimer = nil;
}

- (void)updateLrcTimer
{
    self.lrcView.currentTime = self.player.currentTime;
}
#pragma mark ----私有方法
/**
 *  将时间转化为合适的字符串
 *
 */
- (NSString *)stringWithTime:(NSTimeInterval)time
{
    int minute = time / 60;
    int second = (int)time % 60;
    return [NSString stringWithFormat:@"%02d:%02d",minute, second];
}


#pragma mark ----控件方法
/**
 *  显示歌词或者图片
 *
 */
- (IBAction)lyricOrPhoto:(UIButton *)sender {
    if (self.lrcView.isHidden) { // 显示歌词，盖住图片
        self.lrcView.hidden = NO;
        sender.selected = YES;
        
        [self addLrcTimer];
    } else { // 隐藏歌词，显示图片
        self.lrcView.hidden = YES;
        sender.selected = NO;
        
        [self removeLrcTimer];
    }
}


/**
 *  将控制器退下
 *
 */
- (IBAction)exit:(id)sender {
    
    UIWindow *windows = [UIApplication sharedApplication].keyWindow;
    windows.userInteractionEnabled = NO;
    
    [UIView animateWithDuration:0.25 animations:^{
        self.view.y = self.view.height;
    }completion:^(BOOL finished) {
        self.view.hidden = YES;            //view看不到了，将之隐藏掉，可以减少性能的消耗
        [self removeCurrentTimer];
        [self removeLrcTimer];
        windows.userInteractionEnabled = YES;
    }];
}

/**
 *  拖动滑块，要做的事情
 *
 */
- (IBAction)panSlider:(UIPanGestureRecognizer *)sender {
    //得到挪动距离
    CGPoint point = [sender translationInView:sender.view];
    //将translation清空，免得重复叠加
    [sender setTranslation:CGPointZero inView:sender.view];
    
    CGFloat maxX = self.view.width - sender.view.width;
    sender.view.x += point.x;
    
    if (sender.view.x < 0) {
        sender.view.x = 0;
    }
    else if (sender.view.x > maxX){
        sender.view.x = maxX;
    }
    CGFloat time = (sender.view.x / (self.view.width - sender.view.width)) * self.player.duration;
    [self.showProgressLabel setTitle:[self stringWithTime:time] forState:UIControlStateNormal];
    [self.slider setTitle:[self stringWithTime:time] forState:UIControlStateNormal];
    self.progressView.width = sender.view.center.x;
    self.showProgressLabel.x = self.slider.x;
    
    if (sender.state == UIGestureRecognizerStateBegan) {
        [self removeCurrentTimer];
        [self removeLrcTimer];
        self.showProgressLabel.hidden = NO;
        self.showProgressLabel.y = self.showProgressLabel.superview.height - 15 - self.showProgressLabel.height;
    }
    else if (sender.state == UIGestureRecognizerStateEnded)
    {
        self.player.currentTime = time ;
        [self addCurrentTimer];
        [self addLrcTimer];
        self.showProgressLabel.hidden = YES;
    }
}

/**
 *  轻击progressView，使得滑块走到对应位置
 *
 */
- (IBAction)tapProgressView:(UITapGestureRecognizer *)sender {
    CGPoint point = [sender locationInView:sender.view];
    
    self.player.currentTime = (point.x / sender.view.width) * self.player.duration;
    
    [self updateCurrentTimer];
    [self updateLrcTimer];
}

/**
 *  播放或者暂停
 *
 */
- (IBAction)playOrPause:(id)sender {
    if (self.playOrPauseButton.isSelected == NO) {
        self.playOrPauseButton.selected = YES;
        [[AudioManager defaultMangers] playingMisuc:self.playingMusic.filename];
       
        [self addCurrentTimer];
        [self addLrcTimer];
    }
    else{
        self.playOrPauseButton.selected = NO;
         [[AudioManager defaultMangers] pauseMusic:self.playingMusic.filename];
        [self removeCurrentTimer];
        [self removeLrcTimer];
    }
}
/**
 *  前一首
 *
 */
- (IBAction)previous:(id)sender {
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    window.userInteractionEnabled = NO;
    [[AudioManager defaultMangers] stopMusic:self.playingMusic.filename];
    [MusicTool setPlayingMusic:[MusicTool previousMusic]];
    [self removeCurrentTimer];
    [self removeLrcTimer];
    [self startPlayingMusic];
    window.userInteractionEnabled = YES;
}
/**
 *  下一首
 *
 */
- (IBAction)next:(id)sender {
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    window.userInteractionEnabled = NO;
    [[AudioManager defaultMangers] stopMusic:self.playingMusic.filename];
    [MusicTool setPlayingMusic:[MusicTool nextMusic]];
    [self removeCurrentTimer];
    [self removeLrcTimer];
    [self startPlayingMusic];
    window.userInteractionEnabled = YES;
}



#pragma mark ----AVAudioPlayerDelegate

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    [self next:nil];
}
/**
 *  当电话给过来时，进行相应的操作
 *
 */
- (void)audioPlayerBeginInterruption:(AVAudioPlayer *)player
{
    if ([self.player isPlaying]) {
        [self playOrPause:nil];
        self.isInterruption = YES;
    }
}
/**
 *  打断结束，做相应的操作
 *
 */
- (void)audioPlayerEndInterruption:(AVAudioPlayer *)player
{
    if (self.isInterruption) {
        self.isInterruption = NO;
        [self playOrPause:nil];
    }
}

#pragma mark ----锁屏时候的设置，效果需要在真机上才可以看到
- (void)updateLockedScreenMusic
{
    // 播放信息中心
    MPNowPlayingInfoCenter *center = [MPNowPlayingInfoCenter defaultCenter];
    
    // 初始化播放信息
    NSMutableDictionary *info = [NSMutableDictionary dictionary];
    // 专辑名称
    info[MPMediaItemPropertyAlbumTitle] = self.playingMusic.name;
    // 歌手
    info[MPMediaItemPropertyArtist] = self.playingMusic.singer;
    // 歌曲名称
    info[MPMediaItemPropertyTitle] = self.playingMusic.name;
    // 设置图片
    info[MPMediaItemPropertyArtwork] = [[MPMediaItemArtwork alloc] initWithImage:[UIImage imageNamed:self.playingMusic.icon]];
    // 设置持续时间（歌曲的总时间）
    info[MPMediaItemPropertyPlaybackDuration] = @(self.player.duration);
    // 设置当前播放进度
    info[MPNowPlayingInfoPropertyElapsedPlaybackTime] = @(self.player.currentTime);
    
    // 切换播放信息
    center.nowPlayingInfo = info;
    
    // 远程控制事件 Remote Control Event
    // 加速计事件 Motion Event
    // 触摸事件 Touch Event
    
    // 开始监听远程控制事件
    // 成为第一响应者（必备条件）
    [self becomeFirstResponder];
    // 开始监控
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
}

#pragma mark - 远程控制事件监听
- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (void)remoteControlReceivedWithEvent:(UIEvent *)event
{
    //    event.type; // 事件类型
    //    event.subtype; // 事件的子类型
    //    UIEventSubtypeRemoteControlPlay                 = 100,
    //    UIEventSubtypeRemoteControlPause                = 101,
    //    UIEventSubtypeRemoteControlStop                 = 102,
    //    UIEventSubtypeRemoteControlTogglePlayPause      = 103,
    //    UIEventSubtypeRemoteControlNextTrack            = 104,
    //    UIEventSubtypeRemoteControlPreviousTrack        = 105,
    //    UIEventSubtypeRemoteControlBeginSeekingBackward = 106,
    //    UIEventSubtypeRemoteControlEndSeekingBackward   = 107,
    //    UIEventSubtypeRemoteControlBeginSeekingForward  = 108,
    //    UIEventSubtypeRemoteControlEndSeekingForward    = 109,
    switch (event.subtype) {
        case UIEventSubtypeRemoteControlPlay:
        case UIEventSubtypeRemoteControlPause:
            [self playOrPause:nil];
            break;
            
        case UIEventSubtypeRemoteControlNextTrack:
            [self next:nil];
            break;
            
        case UIEventSubtypeRemoteControlPreviousTrack:
            [self previous:nil];
            
        default:
            break;
    }
}
@end
