//
//  LSTNetworkMonitor.m
//  AMK
//
//  Created by LoSenTrad on 2019/12/12.
//  Copyright © 2019 AMK. All rights reserved.
//

#import "LSTNetworkMonitor.h"
#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import "Reachability.h"


static LSTNetworkMonitor *singleInstance = nil;

@interface LSTNetworkMonitor ()

/** <#...#> */
@property (nonatomic, copy) LSTNetworkMonitorBlock networkChangeBlock;
/** <#.....#> */
@property (nonatomic,strong) Reachability *reach;

/** 当前网路状态 */
@property (nonatomic, assign) LSTNetworkStatus curNetwordStatus;

@end

@implementation LSTNetworkMonitor


+ (instancetype)sharedManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        singleInstance = [[LSTNetworkMonitor alloc] init];
    });
    return singleInstance;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        singleInstance = [super allocWithZone:zone];
        
        singleInstance.reach = [Reachability reachabilityWithHostName:@"www.apple.com"];
    });
    return singleInstance;
}


- (LSTNetworkStatus)getCurrentNetworkStatus {
    return [LSTNetworkMonitor getCurrentNetworkStatus];
}

+ (LSTNetworkStatus)getCurrentNetworkStatus{
   
    LSTNetworkMonitor *m = [LSTNetworkMonitor sharedManager];
    
    switch ([m.reach currentReachabilityStatus]) {
        case NotReachable:// 没有网络
        {
            return LSTNetworkStatusStatusNone;
        }
            break;
        case ReachableViaWiFi:// Wifi
        {
            return LSTNetworkStatusWiFi;
        }
            break;
        case ReachableViaWWAN:// 手机自带网络
        {
            // 获取手机网络类型
            NSArray *typeStrings2G = @[CTRadioAccessTechnologyEdge,
                                       CTRadioAccessTechnologyGPRS,
                                       CTRadioAccessTechnologyCDMA1x];
            NSArray *typeStrings3G = @[CTRadioAccessTechnologyHSDPA,
                                       CTRadioAccessTechnologyWCDMA,
                                       CTRadioAccessTechnologyHSUPA,
                                       CTRadioAccessTechnologyCDMAEVDORev0,
                                       CTRadioAccessTechnologyCDMAEVDORevA,
                                       CTRadioAccessTechnologyCDMAEVDORevB,
                                       CTRadioAccessTechnologyeHRPD];
            NSArray *typeStrings4G = @[CTRadioAccessTechnologyLTE];
            
            CTTelephonyNetworkInfo *info = [[CTTelephonyNetworkInfo alloc] init];
            NSString *currentStatus = info.currentRadioAccessTechnology;
            
            if ([typeStrings2G containsObject:currentStatus]) {
                return LSTNetworkStatus2G;
            }else if ([typeStrings3G containsObject:currentStatus]) {
                return LSTNetworkStatus3G;
            }else if ([typeStrings4G containsObject:currentStatus]) {
                return LSTNetworkStatus4G;
            }else {
                return LSTNetworkStatusUnknown;
            }
        }
            break;
        default:
            return LSTNetworkStatusUnknown;
            break;
    }
}



- (void)startMonitoring {
    
    LSTNetworkMonitor *m = [LSTNetworkMonitor sharedManager];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityChanged:)
                                                 name:kReachabilityChangedNotification
                                               object:nil];
    [m.reach startNotifier];
    
}

- (void)stopMonitoring {
    
    LSTNetworkMonitor *m = [LSTNetworkMonitor sharedManager];
    [m.reach stopNotifier];
}

- (void)reachabilityChanged:(NSNotificationCenter *)note
{
    LSTNetworkStatus s = [self getCurrentNetworkStatus];
    if (s!=self.curNetwordStatus) {
        self.curNetwordStatus = s;
        LSTNetworkMonitor *m = [LSTNetworkMonitor sharedManager];
        m.networkChangeBlock(s);
    }
}

- (void)networkStatusChangeBlock:(LSTNetworkMonitorBlock)block {
    LSTNetworkMonitor *m = [LSTNetworkMonitor sharedManager];
    m.networkChangeBlock = block;
}

+ (void)networkStatusChangeBlock:(LSTNetworkMonitorBlock)block {
    LSTNetworkMonitor *m = [LSTNetworkMonitor sharedManager];
    m.networkChangeBlock = block;
}



@end
