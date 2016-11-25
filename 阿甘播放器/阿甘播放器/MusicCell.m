//
//  MusicCell.m
//  阿甘播放器
//
//  Created by Agan on 16/9/1.
//  Copyright © 2016年 Agan. All rights reserved.
//

#import "MusicCell.h"
#import "Music.h"
#import "ImageTool.h"
#import "Colours.h"
static NSString *_identifier=nil;
@implementation MusicCell



+ (instancetype)musicCellWithTableView:(UITableView *)tableView
{
    MusicCell *cell = [tableView dequeueReusableCellWithIdentifier:_identifier];
    if (cell == nil) {
        cell = [[MusicCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:_identifier];
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:_identifier]) {
        
    }
    return self;
}

- (void)setMusic:(Music *)music
{
    _music = music;
    self.textLabel.text = music.name;
    self.detailTextLabel.text = music.singer;
    
    if (music.isPlaying) {
        self.imageView.image = [ImageTool circleImageWithName:music.singerIcon borderWidth:2.0 borderColor:[UIColor eggshellColor]];
    }
    else{
        self.imageView.image = [ImageTool circleImageWithName:music.singerIcon borderWidth:2.0 borderColor:[UIColor pinkColor]] ;
    }
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    
}

@end
