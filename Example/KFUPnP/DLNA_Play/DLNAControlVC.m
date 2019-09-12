//
//  DLNAControlVC.m
//  YSTThirdSDK_Example
//
//  Created by MccRee on 2018/2/11.
//  Copyright © 2018年 MQL9011. All rights reserved.
//

#import "DLNAControlVC.h"
#import <KFUPnP/MRDLNA.h>
#import "MRPositionUpdateTask.h"


//屏幕高度
#define H [UIScreen mainScreen].bounds.size.height
#define W [UIScreen mainScreen].bounds.size.width


@interface DLNAControlVC ()<DLNADelegate>
{
     BOOL _isPlaying;
}

@property(nonatomic, strong) MRDLNA *dlnaManager;
@property (weak, nonatomic) IBOutlet UISlider *processSlider;
@property (nonatomic, assign) BOOL isFirstStartPlay;  //!< 是否第一次开始播放
@property (nonatomic, assign) BOOL isSeekTime;   //!< 是否拖拽
@property (nonatomic, strong) NSThread *timerThread;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) MRPositionUpdateTask *updateTask;

@end

@implementation DLNAControlVC

- (void)dealloc {
    [self.updateTask stopTimer];
    NSLog(@"%s",__FUNCTION__);
}

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupBaseData];
    [self setupDLNAManager];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
//    [self stopTimer];
    [self.dlnaManager endDLNA];
}

#pragma mark - Initail

- (void)setupBaseData {
    _isPlaying = YES;
    _isFirstStartPlay = YES;
    _isSeekTime = NO;
}

- (void)setupDLNAManager {
    self.dlnaManager = [MRDLNA sharedMRDLNAManager];
    self.dlnaManager.delegate = self;
    [self.dlnaManager startDLNA];
}

#pragma mark - 播放控制

/**
 退出
 */
- (IBAction)closeAction:(id)sender {
    [self.dlnaManager endDLNA];
}


/**
 播放/暂停
 */
- (IBAction)playOrPause:(id)sender {
    if (_isPlaying) {
        [self.dlnaManager dlnaPause];
    }else{
        [self.dlnaManager dlnaPlay];
    }
//    _isPlaying = !_isPlaying;
}

- (IBAction)currentPosition:(UIButton *)sender {
    [self.dlnaManager dlnaPositionInfo];
}

/**
 进度条
 */
- (IBAction)seekChanged:(UISlider *)sender{
//    NSInteger sec = sender.value; //* 60 * 60;
//    NSLog(@"播放进度条======>: %zd",sec);
//    [self.dlnaManager seekChanged:sec];
}
- (IBAction)seekTouchDone:(UISlider *)sender {
    NSLog(@"seekDone");
    self.isSeekTime = YES;
//    [self pauseTimer];
    [self.updateTask pauseTimer];
}

- (IBAction)seekTouchUpInside:(UISlider *)sender {
    NSLog(@"seekTouchUpInside");
    self.isSeekTime = NO;
    NSInteger sec = sender.value; //* 60 * 60;
    NSLog(@"播放进度条======>: %zd",sec);
    [self.dlnaManager seekChanged:sec];
}


/**
 音量
 */
- (IBAction)volumeChange:(UISlider *)sender {
    NSString *vol = [NSString stringWithFormat:@"%.f",sender.value * 100];
    NSLog(@"音量========>: %@",vol);
    [self.dlnaManager volumeChanged:vol];
}


/**
 切集
 */
- (IBAction)playNext:(id)sender {
    NSString *testVideo = @"https://56.com-t-56.com/20190602/23126_43452c92/index.m3u8";//@"https://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4";//@"http://wvideo.spriteapp.cn/video/2016/0328/56f8ec01d9bfe_wpd.mp4";
    [self.dlnaManager playTheURL:testVideo];
}


- (void)updateSliderValue {
    if (!self.isSeekTime && _isPlaying) {
        [self.dlnaManager dlnaPositionInfo];
    }
}

//#pragma mark - Thread Action
//- (void)repeatResponseAction {
//    @autoreleasepool {
//        [self startTimer];
//    }
//}
//
//#pragma mark - Timer Action
//- (void)timerAction {
//    //播放状态以及未拖动状态下获取进度信息
//    if (!self.isSeekTime && _isPlaying) {
//        [self.dlnaManager dlnaPositionInfo];
//    }
//}
//
//#pragma mark - Timer Methods
//- (void)startTimer {
//    self.timer = [NSTimer timerWithTimeInterval:2
//                                         target:self
//                                       selector:@selector(timerAction)
//                                       userInfo:nil
//                                        repeats:YES];
////    [self.timer fire];
//    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
//    [[NSRunLoop currentRunLoop] run];
//}
//
//- (void)pauseTimer {
//    if (self.timer) {
//        [self.timer setFireDate:[NSDate distantFuture]];
//    }
//}
//
//- (void)resumeTimer {
//    if (self.timer) {
//        [self.timer setFireDate:[NSDate distantPast]];
//    }
//}
//
//- (void)stopTimer {
//    if (self.timer) {
//        [self.timer invalidate];
//        _timer = nil;
//        [self.timerThread cancel];
//        _timerThread = nil;
//    }
//}

#pragma mark -  DLNADelegate Methods
- (void)dlnaStartPlay{
    CLLog(@"投屏成功 开始播放");
    if (self.isFirstStartPlay) {
        self.isFirstStartPlay = NO;
//        self.timerThread = [[NSThread alloc] initWithTarget:self selector:@selector(repeatResponseAction) object:nil];
//        [self.timerThread start];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.updateTask = [[MRPositionUpdateTask alloc] initWithTimeInterval:2.f target:self selector:@selector(updateSliderValue)];
        });
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        self.processSlider.userInteractionEnabled = YES;
    });
    _isPlaying = YES;
}

- (void)dlnaUpnpGetPositionInfoResponse:(CLUPnPAVPositionInfo *)info {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (info.trackDuration != 0 && info.trackDuration <= info.relTime + 1) {//结束
            [self.dlnaManager endDLNA];
        }else {
            self.processSlider.maximumValue = info.trackDuration;
            self.processSlider.value = info.relTime;
        }
    });
}

- (void)dlnaPauseResponse {
    CLLog(@"PauseResponse\n");
    dispatch_async(dispatch_get_main_queue(), ^{
        self.processSlider.userInteractionEnabled = NO;
    });
    _isPlaying = NO;
}

- (void)dlnaStopResponse {
    CLLog(@"StopResponse\n");
    _isPlaying = NO;
    dispatch_async(dispatch_get_main_queue(), ^{
        self.processSlider.value = 0.f;
    });
}

- (void)dlnaSeekResponse {
    CLLog(@"SeekResponse\n");
//    [self resumeTimer];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.updateTask resumeTimer];
    });
}

- (void)dlnaUndefinedResponse:(NSString *)resXML postXML:(NSString *)postXML {
    if ([postXML containsString:@"SetAVTransportURI"]) {
        CLLog(@"SetAVTransportURI Failure\n");
        [self dlnaStartPlay];
    }
}

@end
