//
//  LrcCell.m
//  阿甘播放器
//
//  Created by Agan on 16/9/1.
//  Copyright © 2016年 Agan. All rights reserved.
//

#import "LrcCell.h"
#import "LrcLine.h"
static NSString *_identifier = @"LrcCell";
@implementation LrcCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    
}
+ (instancetype)lrcCellWithTableView:(UITableView *)tableView
{
    LrcCell *cell = [tableView dequeueReusableCellWithIdentifier:_identifier];
    if (cell == nil) {
        cell = [[self alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:_identifier];
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:_identifier]) {
        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.textLabel.textColor = [UIColor colorWithRed:10 green:10 blue:10 alpha:1];
        self.textLabel.textAlignment = NSTextAlignmentCenter;
        self.textLabel.font = [UIFont systemFontOfSize:13];
        self.textLabel.numberOfLines = 0;
    }
    return self;
}

- (void)setLrcLine:(LrcLine *)lrcLine
{
    _lrcLine = lrcLine;
    self.textLabel.text = lrcLine.word;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.textLabel.bounds = self.bounds;
}

@end
