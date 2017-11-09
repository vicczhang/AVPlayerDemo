//
//  AVPlayerManager.h
//  AVPlayerDemo
//
//  Created by vicczhang on 2017/11/8.
//  Copyright © 2017年 vic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ReactiveCocoa.h>

@interface AVPlayerManager : NSObject

@property (nonatomic, strong)AVPlayer *player;
//当前播放时间(00:00)
@property (nonatomic, copy)NSString* currentTime;
//总时长(00:00)
@property (nonatomic, copy)NSString* duration;

//播放进度
@property (nonatomic, assign)float progress;
//播放总进度
@property (nonatomic, assign)float totalProgress;
//播放状态
@property (nonatomic, assign)BOOL isPlaying;

+ (instancetype)manager;
/**
 播放器数据传入
 @param array 传入所有数据model数组
 @param index 传入当前model在数组的下标
 */
- (void)playArray:(NSArray *)array index:(NSInteger)index;
//开始播放
- (void)play;
//暂停播放
- (void)pause;
//上一曲
- (void)previous;
//下一曲
- (void)next;

//设置播放哪个时间段
- (void)setToTime:(CMTime)time;
//快进15秒
- (void)stepForward15Seconds;
//快退15秒
- (void)stepReverse15Senconds;
//速率 rate 0.5~2.0
- (void)setPlayerSpeed:(float)rate;

@end
