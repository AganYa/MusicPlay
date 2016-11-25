//
//  MusicViewController.m
//  阿甘播放器
//
//  Created by Agan on 16/9/1.
//  Copyright © 2016年 Agan. All rights reserved.
//

#import "MusicViewController.h"
#import "PlayingViewController.h"
#import "MusicTool.h"
#import "Music.h"
#import "MusicCell.h"
static long steps;
@interface MusicViewController ()
@property (nonatomic, strong) PlayingViewController *playingVc;

@property(nonatomic,assign) int Index;

// 定义一个属性，表示时钟动画
@property (nonatomic, strong) CADisplayLink *display;
@end

@implementation MusicViewController


- (PlayingViewController *)playingVc
{
    if (_playingVc == nil) {
        _playingVc = [[PlayingViewController alloc] initWithNibName:@"PlayingViewController" bundle:nil];
    }
    return _playingVc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor=[UIColor colorWithRed:10 green:20 blue:50 alpha:1];
    
    // 设置背景颜色
    self.view.backgroundColor = [UIColor colorWithRed:(87/255.0) green:(192/255.0) blue:(255/255.0) alpha:1];
    // 实例化时钟动画
    self.display = [CADisplayLink displayLinkWithTarget:self selector:@selector(update)];
    // 添加到运行循环
    [self.display addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    [self setupNavigation];
}
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
- (void)setupNavigation
{
    self.navigationItem.title = @"阿甘音乐播放器";
}

#pragma mark ----TableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSLog(@"%d",[MusicTool musics].count);
    return [MusicTool musics].count;
   
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MusicCell *cell = [MusicCell musicCellWithTableView:tableView];
    cell.music = [MusicTool musics][indexPath.row];
    
    return cell;
}

#pragma mark ----TableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [MusicTool setPlayingMusic:[MusicTool musics][indexPath.row]];
    
    Music *preMusic = [MusicTool musics][self.Index];
    preMusic.playing = NO;
    Music *music = [MusicTool musics][indexPath.row];
    music.playing = YES;
    NSArray *indexPaths = @[
                            [NSIndexPath indexPathForItem:self.Index inSection:0],
                            indexPath
                            ];
    [self.tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
    
    self.Index = (int)indexPath.row;
    
    [self.playingVc show];
}

@end
