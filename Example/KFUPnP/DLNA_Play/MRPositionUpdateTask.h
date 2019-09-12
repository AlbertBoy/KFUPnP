//
//  MRPositionUpdateTask.h
//  MRDLNA_Example
//
//  Created by youma001 on 2019/6/14.
//  Copyright © 2019 MQL9011. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MRPositionUpdateTask : NSObject

@property (nonatomic, weak) id target;
@property (nonatomic, assign) SEL selector;

- (instancetype)initWithTimeInterval:(NSTimeInterval)interval target:(id)target selector:(SEL)selector;

- (void)pauseTimer;
- (void)resumeTimer;
- (void)stopTimer;
@end

NS_ASSUME_NONNULL_END
