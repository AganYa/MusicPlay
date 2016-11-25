//
//  LrcLine.m
//  阿甘播放器
//
//  Created by Agan on 16/9/1.
//  Copyright © 2016年 Agan. All rights reserved.
//

#import "LrcLine.h"

@implementation LrcLine

+(NSMutableArray *)lrcLinesWithFileName:(NSString *)fileName{
        
        NSMutableArray *lrcLines=[NSMutableArray array];
        
        NSURL *url=[[NSBundle mainBundle] URLForResource:fileName withExtension:nil];
        
        NSString *lrcStr=[NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
        
        NSArray *lrcCmps=[lrcStr componentsSeparatedByString:@"\n"];
        
        [lrcCmps enumerateObjectsUsingBlock:^(NSString *lineStr, NSUInteger idx, BOOL * _Nonnull stop) {
            LrcLine *lrcLine=[[LrcLine alloc] init];
            
            [lrcLines addObject:lrcLine];
            
            if ([lineStr hasPrefix:@"[ti:"] || [lineStr hasPrefix:@"[ar:"] || [lineStr hasPrefix:@"[al:"]) {
                NSString *word=[[lineStr componentsSeparatedByString:@":"] lastObject];

                lrcLine.word=[word substringToIndex:word.length-1];
                
            }else if([lineStr hasPrefix:@"["]){
                NSArray *array=[lineStr componentsSeparatedByString:@"]"];
                lrcLine.time=[[array firstObject] substringFromIndex:1];
                lrcLine.word=[array lastObject];
            }
            
        }];
        if (lrcLines.count==0) {
            return nil;
        }else{
            return lrcLines;
    }
}
@end
