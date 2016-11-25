//
//  MusicCell.h
//  阿甘播放器
//
//  Created by Agan on 16/9/1.
//  Copyright © 2016年 Agan. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Music;
@interface MusicCell : UITableViewCell
@property (nonatomic, strong) Music *music;

+ (instancetype)musicCellWithTableView:(UITableView *)tableView;
@end
