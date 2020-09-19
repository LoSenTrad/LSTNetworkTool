//
//  LSTNetworkMonitor.h
//  AMK
//
//  Created by LoSenTrad on 2019/12/12.
//  Copyright © 2019 AMK. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN



typedef NS_ENUM(NSInteger, LSTNetworkStatus) {
    LSTNetworkStatusUnknown          = -1,//未知网络
    LSTNetworkStatusStatusNone     = 0,//没有网络
    LSTNetworkStatus2G = 1,//2G网络
    LSTNetworkStatus3G = 2,//3G网络
    LSTNetworkStatus4G = 3,//4G网络
    LSTNetworkStatusWiFi = 4,//无线网络
};

typedef void(^LSTNetworkMonitorBlock)(LSTNetworkStatus status);


@interface LSTNetworkMonitor : NSObject



+ (instancetype)sharedManager;


- (LSTNetworkStatus)getCurrentNetworkStatus;
+ (LSTNetworkStatus)getCurrentNetworkStatus;

- (void)startMonitoring;
- (void)stopMonitoring;

- (void)networkStatusChangeBlock:(LSTNetworkMonitorBlock)block;
+ (void)networkStatusChangeBlock:(LSTNetworkMonitorBlock)block;




@end

NS_ASSUME_NONNULL_END
