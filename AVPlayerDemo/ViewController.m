//
//  ViewController.m
//  AVPlayerDemo
//
//  Created by vicczhang on 2017/11/8.
//  Copyright © 2017年 vic. All rights reserved.
//

#import "ViewController.h"
#import "AVPlayerManager.h"
#import "MusicModel.h"

@interface ViewController (){
    AVPlayerManager* manager;
}
@property (weak, nonatomic) IBOutlet UILabel *startTime;
@property (weak, nonatomic) IBOutlet UILabel *endTime;
@property (weak, nonatomic) IBOutlet UISlider *slProgress;

@property (weak, nonatomic) IBOutlet UIButton *playButton;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self avplayerSetting];
    
    //button click
    [[_playButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        if (manager.isPlaying) {
            [manager pause];
        }else{
            [manager play];
        }
        
    }];
    //UISlider value change
    [[_slProgress rac_signalForControlEvents:UIControlEventValueChanged] subscribeNext:^(id x) {
        if (manager.isPlaying) {
            CMTime dragedCMTime = CMTimeMake(_slProgress.value, 1);
            [manager setToTime:dragedCMTime];
        }
    }];
    
}

#pragma mark --- Http player

- (void)avplayerSetting{
    manager = [AVPlayerManager manager];
    MusicModel* model = [[MusicModel alloc] init];
    //@"http://fdfs.xmcdn.com/group4/M02/28/FA/wKgDtFM052_jBsKhAAvPQEMti4w713.mp3"
    model.musicURL = [[[NSBundle mainBundle] URLForResource:@"bz" withExtension:@"mp3"] absoluteString];
    [manager playArray:@[model] index:0];
    
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:status_key object:nil] subscribeNext:^(NSNotification *notification) {
        self.startTime.text = manager.currentTime;
        self.endTime.text = manager.duration;
        [self.slProgress setValue:manager.progress animated:YES];
        if (manager.isPlaying) {
            [self.playButton setTitle:@"暂停" forState:UIControlStateNormal];
        }else{
            [self.playButton setTitle:@"播放" forState:UIControlStateNormal];
        }
    }];
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:refresh_key object:nil] subscribeNext:^(NSNotification *notification) {
        
        self.startTime.text = manager.currentTime;
        self.endTime.text = manager.duration;
        self.slProgress.maximumValue = manager.totalProgress;
        [self.slProgress setValue:manager.progress animated:YES];
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
