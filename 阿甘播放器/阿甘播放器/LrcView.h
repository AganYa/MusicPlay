//
//  LrcView.h
//  阿甘播放器
//
//  Created by Agan on 16/9/1.
//  Copyright © 2016年 Agan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LrcView : UIImageView
@property (nonatomic, assign) NSTimeInterval currentTime;
@property (nonatomic, copy) NSString *fileName;
@end
