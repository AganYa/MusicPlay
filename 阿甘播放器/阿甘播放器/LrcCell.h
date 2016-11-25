//
//  LrcCell.h
//  阿甘播放器
//
//  Created by Agan on 16/9/1.
//  Copyright © 2016年 Agan. All rights reserved.
//

#import <UIKit/UIKit.h>
@class LrcLine;
@interface LrcCell : UITableViewCell
@property (nonatomic, strong) LrcLine *lrcLine;

+ (instancetype)lrcCellWithTableView:(UITableView *)tableView;
@end
