//
//  MRPositionUpdateTask.m
//  MRDLNA_Example
//
//  Created by youma001 on 2019/6/14.
//  Copyright © 2019 MQL9011. All rights reserved.
//

#import "MRPositionUpdateTask.h"

@interface MRPositionUpdateTask ()
@property (nonatomic, strong) NSThread *timerThread;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) NSTimeInterval interval;

@end

@implementation MRPositionUpdateTask
- (void)dealloc {
    NSLog(@"%s",__FUNCTION__);
}

#pragma mark - life cycle
- (instancetype)initWithTimeInterval:(NSTimeInterval)interval target:(id)target selector:(SEL)selector {
    if (self = [super init]) {
        self.interval = interval;
        self.target = target;
        self.selector = selector;
        
        self.timerThread = [[NSThread alloc] initWithTarget:self selector:@selector(repeatResponseAction) object:nil];
        [self.timerThread start];
    }
    return self;
}

#pragma mark - Thread Action
- (void)repeatResponseAction {
    @autoreleasepool {
        [self startTimer];
    }
}

#pragma mark - Timer Action
- (void)timerAction {
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong typeof(self) sself = weakSelf;
        if(!sself) {
            return;
        }
        if(sself.target == nil) {
            return;
        }
        id target = sself.target;
        SEL selector = sself.selector;
        if([target respondsToSelector:selector]) {
            [target performSelectorOnMainThread:selector withObject:nil waitUntilDone:YES];
        }
    });
}

#pragma mark - Timer Methods
- (void)startTimer {
    self.timer = [NSTimer timerWithTimeInterval:self.interval
                                         target:self
                                       selector:@selector(timerAction)
                                       userInfo:nil
                                        repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
    [[NSRunLoop currentRunLoop] run];
}

- (void)pauseTimer {
    if (self.timer) {
        [self.timer setFireDate:[NSDate distantFuture]];
    }
}

- (void)resumeTimer {
    if (self.timer) {
        [self.timer setFireDate:[NSDate distantPast]];
    }
}

- (void)stopTimer {
    if (self.timer) {
        [self performSelector:@selector(invalidationTimer) onThread:self.timerThread withObject:nil waitUntilDone:YES];
        [self.timerThread cancel];
        _timerThread = nil;
    }
}

- (void)invalidationTimer {
    if ([self.timer isValid]) {
        [self.timer invalidate];
    }
    _timer = nil;
}


@end
