//
//  AVPlayerManager.m
//  AVPlayerDemo
//
//  Created by vicczhang on 2017/11/8.
//  Copyright © 2017年 vic. All rights reserved.
//

#import "AVPlayerManager.h"
#import "MusicModel.h"

@interface AVPlayerManager(){
    AVPlayerItem *playerItem;
    id _playTimeObserver;
    NSInteger _index;
    BOOL isRemoveNot;
    
    MusicModel *_playingModel; // 正在播放的model
}

@property (nonatomic, strong)NSMutableArray* musicList;
@end

@implementation AVPlayerManager

- (NSMutableArray *)musicList{
    if (!_musicList) {
        _musicList = [NSMutableArray array];
    }
    return _musicList;
}

+ (instancetype)manager{
    static AVPlayerManager * manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[AVPlayerManager alloc] init];
        manager.player = [[AVPlayer alloc] init];
        
        AVAudioSession *session = [AVAudioSession sharedInstance];
        [session setActive:YES error:nil];
        [session setCategory:AVAudioSessionCategoryPlayback error:nil];
    });
    return manager;
}

- (void)playArray:(NSArray *)array index:(NSInteger)index{
    _index = index;
    self.musicList = [array mutableCopy];
    [self updateAVPlayer];
}

- (void)updateAVPlayer{
    if (isRemoveNot) {
        [self removeObserverNotify];
        isRemoveNot = NO;
    }
    MusicModel *model;
    model = self.musicList[_index];
    _playingModel = model;
    playerItem = [AVPlayerItem playerItemWithURL:[NSURL URLWithString:_playingModel.musicURL]];
    [self.player replaceCurrentItemWithPlayerItem:playerItem];
    [playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    // 监听播放状态
    @weakify(self);
    @weakify(playerItem);
    _playTimeObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 20) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        @strongify(self);
        @strongify(playerItem);
        float current = CMTimeGetSeconds(time);
        float total = CMTimeGetSeconds(playerItem.duration);
        if (current) {
            self.progress = current;
            self.totalProgress = total;
            notify_refresh
        }
    }];
    
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:AVPlayerItemDidPlayToEndTimeNotification object:nil] subscribeNext:^(NSNotification *notification) {
        DebugLog(@"music play end!");
        [self next];
        [self pause];
    }];
    isRemoveNot = YES;
}

#pragma mark - 移除通知&KVO
- (void)removeObserverNotify{
    [self.player replaceCurrentItemWithPlayerItem:nil];
    [playerItem removeObserver:self forKeyPath:@"status"];
    [self.player removeTimeObserver:_playTimeObserver];
    _playTimeObserver = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
}

#pragma mark - KVO - status
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    if ([keyPath isEqualToString:@"status"]) {
        if ([playerItem status] == AVPlayerStatusReadyToPlay) {
            DebugLog(@"ReadyToPlay...");
            [self play];
        }else if([playerItem status] == AVPlayerStatusFailed) {
            DebugLog(@"Failed");
            [self pause];
        }
    }
}

- (void)play{
    _isPlaying = YES;
    [self.player play];
    notify_status
}

- (void)pause{
    _isPlaying = NO;
    [self.player pause];
    notify_status
}

- (void)next{
    [self nextIndex];
    [self updateAVPlayer];
}

- (void)previous{
    [self previousIndex];
    [self updateAVPlayer];
}

- (void)nextIndex{
    _index++;
    if (_index == self.musicList.count) {
        _index = 0;
    }
}

- (void)previousIndex{
    _index--;
    if (_index < 0) {
        _index = self.musicList.count -1;
    }
}

- (void)setToTime:(CMTime)time{
    [playerItem seekToTime:time];
}

//快进15秒
- (void)stepForward15Seconds{
    [self.player.currentItem seekToTime:CMTimeMakeWithSeconds(self.player.currentItem.currentTime.value/self.player.currentItem.currentTime.timescale + 15, self.player.currentItem.currentTime.timescale) toleranceBefore:CMTimeMake(1, self.player.currentItem.currentTime.timescale) toleranceAfter:CMTimeMake(1, self.player.currentItem.currentTime.timescale)];
}
//快退15秒
- (void)stepReverse15Senconds{
    [self.player.currentItem seekToTime:CMTimeMakeWithSeconds(self.player.currentItem.currentTime.value/self.player.currentItem.currentTime.timescale - 15, self.player.currentItem.currentTime.timescale)];
}
//速率 rate 0.5~2.0 default 1
- (void)setPlayerSpeed:(float)rate{
    [self.player setRate:rate];
}

- (NSString *)currentTime{
    return [self durationToString:_progress];
}

- (NSString *)duration{
    return [self durationToString:_totalProgress];
}

- (NSString *)durationToString:(float)duration{
    int m = duration/60.0;
    int s = duration - m*60;
    NSString* m_placeholder = m>9 ? @"":@"0";
    NSString* s_placeholder = s>9 ? @"":@"0";
    
    NSString* min = [NSString stringWithFormat:@"%@%d",m_placeholder,m];
    NSString* sec = [NSString stringWithFormat:@"%@%d",s_placeholder,s];
    
    return [NSString stringWithFormat:@"%@:%@",min, sec];
}

//#pragma mark - 后台UI设置
- (void)backgroundSetting:(MusicModel*)model{
    NSMutableDictionary *musicInfo = [NSMutableDictionary dictionary];
    // 设置Singer
    [musicInfo setObject:model.author forKey:MPMediaItemPropertyArtist];
    // 设置歌曲名
    [musicInfo setObject:model.musicName forKey:MPMediaItemPropertyTitle];
    // 设置封面 下载image->设置
//    MPMediaItemArtwork *artwork = [[MPMediaItemArtwork alloc] initWithImage:image];
//    [musicInfo setObject:artwork forKey:MPMediaItemPropertyArtwork];
    //音乐剩余时长
    [musicInfo setObject:@(_totalProgress) forKey:MPMediaItemPropertyPlaybackDuration];
    //音乐当前播放时间
    [musicInfo setObject:@(_progress) forKey:MPNowPlayingInfoPropertyElapsedPlaybackTime];
    [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:musicInfo];
}

@end
