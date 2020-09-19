//
//  LSTNetworkTool.m
//  AMK
//
//  Created by LoSenTrad on 2019/12/12.
//  Copyright © 2019 AMK. All rights reserved.
//

#import "LSTNetworkTool.h"
#import "AFNetworkActivityIndicatorManager.h"
#import "AFNetworking.h"
#import <SystemConfiguration/CaptiveNetwork.h>
#import <CommonCrypto/CommonDigest.h>



@interface LSTNetworkTool ()

@end

@implementation LSTNetworkTool


static AFHTTPSessionManager *_sessionManager;
static NSMutableArray *_allSessionTask;

static NSDictionary *_baseParameters;
static NSArray *_cacheKeyfilter;

static LSTNetworkParametersHandle _parametersHandle;
static LSTNetworkHeadersHandle _headersHandle;
static LSTNetworkFinishHandle _finishHandle;
static LSTNetworkFailHandle _failHandle;


/*所有的请求task数组*/
+ (NSMutableArray *)allSessionTask{
    if (!_allSessionTask) {
        _allSessionTask = [NSMutableArray array];
    }
    return _allSessionTask;
}


+ (void)initialize{
    _sessionManager = [AFHTTPSessionManager manager];
    //设置请求超时时间
    _sessionManager.requestSerializer.timeoutInterval = 30.f;
    //设置服务器返回结果的类型:JSON(AFJSONResponseSerializer,AFHTTPResponseSerializer)
    _sessionManager.responseSerializer = [AFJSONResponseSerializer serializer];
    _sessionManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/html", @"text/json", @"text/plain", @"text/javascript", @"text/xml", @"image/*", nil];

    //开始监测网络状态
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    //打开状态栏菊花
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
}


+ (void)POSTWithURL:(NSString *)url
         parameters:(NSDictionary *)parameters
        cachePolicy:(LSTCachePolicy)cachePolicy
            success:(LSTHttpRequestSuccess)success
               fail:(LSTHttpRequestFail)fail {
    [self HTTPWithMethod:LSTRequestMethodPOST url:url parameters:parameters cachePolicy:cachePolicy success:success fail:fail];
}

+ (void)GETWithURL:(NSString *)url
         parameters:(NSDictionary *)parameters
        cachePolicy:(LSTCachePolicy)cachePolicy
            success:(LSTHttpRequestSuccess)success
               fail:(LSTHttpRequestFail)fail {
    
    [self HTTPWithMethod:LSTRequestMethodGET url:url parameters:parameters cachePolicy:cachePolicy success:success fail:fail];
}

+ (void)uploadImageURL:(NSString *)url
            parameters:(NSDictionary *)parameters
                images:(NSArray<UIImage *> *)images
                  name:(NSString *)name
              fileName:(NSString *)fileName
              mimeType:(NSString *)mimeType
              progress:(LSTHttpProgress)progress
               success:(LSTHttpRequestSuccess)success
                  fail:(LSTHttpRequestFail)fail {
    
    if (_baseParameters.count) {
        NSMutableDictionary * mutableBaseParameters = [NSMutableDictionary dictionaryWithDictionary:parameters];
        [mutableBaseParameters addEntriesFromDictionary:_baseParameters];
        parameters = [mutableBaseParameters copy];
    }
    
    if (_parametersHandle) {
        parameters = _parametersHandle(parameters);
    }
    
    //添加请求头
//    AFJSONRequestSerializer *requestSerializer = [AFJSONRequestSerializer serializer];
//    [requestSerializer setValue:[SQLiveUserTool isLogin]?[NSString stringWithFormat:@"Bearer %@",[SQLiveUserTool loadLiveAuth]]:nil forHTTPHeaderField:@"Authorization"];
//    [requestSerializer setValue:[SQLiveUserTool isLogin]?[SQLiveUserTool loadToken]:nil forHTTPHeaderField:@"X-DS-KEY"];
//    _sessionManager.requestSerializer = requestSerializer;
    NSDictionary *headersDic = [NSDictionary dictionary];
    if (_headersHandle) {
        headersDic = _parametersHandle(parameters);
    }
//
//    NSDictionary *dictionary = @{@"Authorization":[SQLiveUserTool isLogin]?[NSString stringWithFormat:@"Bearer %@",[SQLiveUserTool loadLiveAuth]]:@"",@"X-DS-KEY":[SQLiveUserTool isLogin]?[SQLiveUserTool loadToken]:@""};
    
//      NSString *liveAuth = ![SQLiveUserTool loadLiveAuth]?@"":[SQLiveUserTool loadLiveAuth];
    //    NSDictionary *dictionary = @{@"Authorization":[SQLiveUserTool isLogin]?[NSString stringWithFormat:@"Bearer %@",liveAuth]:@"",@"X-DS-KEY":[SQLiveUserTool isLogin]?[SQLiveUserTool loadToken]:@"",@"Accept":[NSString stringWithFormat:@"application/vnd.lumen.v%@+json",SQLiveAPIVersion]};
//
    NSURLSessionTask *sessionTask = [_sessionManager POST:url parameters:parameters headers:headersDic constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        //压缩-添加-上传图片
        [images enumerateObjectsUsingBlock:^(UIImage * _Nonnull image, NSUInteger idx, BOOL * _Nonnull stop) {
            NSData *imageData = UIImageJPEGRepresentation(image, 0.5);
            [formData appendPartWithFileData:imageData name:name fileName:[NSString stringWithFormat:@"%@%lu.%@",fileName,(unsigned long)idx,mimeType ? mimeType : @"jpeg"] mimeType:[NSString stringWithFormat:@"image/%@",mimeType ? mimeType : @"jpeg"]];
        }];
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        //上传进度
        dispatch_sync(dispatch_get_main_queue(), ^{
            progress ? progress(uploadProgress) : nil;
        });
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [[self allSessionTask] removeObject:task];
        success ? success(responseObject, NO) : nil;
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [[self allSessionTask] removeObject:task];
        fail ? fail(error, LSTNetworkMonitor.getCurrentNetworkStatus) : nil;
    }];
//    NSURLSessionTask *sessionTask = [_sessionManager POST:url parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
//        //压缩-添加-上传图片
//        [images enumerateObjectsUsingBlock:^(UIImage * _Nonnull image, NSUInteger idx, BOOL * _Nonnull stop) {
//            NSData *imageData = UIImageJPEGRepresentation(image, 0.5);
//            [formData appendPartWithFileData:imageData name:name fileName:[NSString stringWithFormat:@"%@%lu.%@",fileName,(unsigned long)idx,mimeType ? mimeType : @"jpeg"] mimeType:[NSString stringWithFormat:@"image/%@",mimeType ? mimeType : @"jpeg"]];
//        }];
//
//    } progress:^(NSProgress * _Nonnull uploadProgress) {
//        //上传进度
//        dispatch_sync(dispatch_get_main_queue(), ^{
//            progress ? progress(uploadProgress) : nil;
//        });
//    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//
//        [[self allSessionTask] removeObject:task];
//        success ? success(responseObject, NO) : nil;
//
//    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//
//        [[self allSessionTask] removeObject:task];
//         fail ? fail(error, LSTNetworkMonitor.getCurrentNetworkStatus) : nil;
//    }];
    //添加最新的sessionTask到数组
    sessionTask ? [[self allSessionTask] addObject:sessionTask] : nil;
    
}

+ (void)downloadWithURL:(NSString *)url
               fileDir:(NSString *)fileDir
               fileName:(NSString *)fileName
              progress:(LSTHttpProgress)progress
              callback:(LSTNetworkDownload)callback {
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    __block NSURLSessionDownloadTask *downloadTask = [_sessionManager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
//        if (_logEnabled) {
//            ATLog(@"下载进度:%.2f%%",100.0*downloadProgress.completedUnitCount / downloadProgress.totalUnitCount);
//        }
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            progress ? progress(downloadProgress) : nil;
        });
        
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        //拼接缓存目录
        NSString *downloadDir;
        
        if (fileDir.length>0) {
            downloadDir = fileDir;
        }else {
           downloadDir = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject]stringByAppendingPathComponent:@"Download"];
        }
        
        //打开文件管理器
        NSFileManager *fileManager = [NSFileManager defaultManager];
        //创建DownLoad目录
        [fileManager createDirectoryAtPath:downloadDir withIntermediateDirectories:YES attributes:nil error:nil];
        //拼接文件路径
        NSString *filePath = [downloadDir stringByAppendingPathComponent:fileName.length>0?fileName:response.suggestedFilename];
        
        return [NSURL fileURLWithPath:filePath];
        
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        [[self allSessionTask] removeObject:downloadTask];
        if (callback && error) {
            callback ? callback(nil, error) : nil;
            return;
        }
        callback ? callback(filePath.absoluteString, nil) : nil;
    }];
    //开始下载
    [downloadTask resume];
    
    //添加sessionTask到数组
    downloadTask ? [[self allSessionTask] addObject:downloadTask] : nil;
}


+ (void)HTTPWithMethod:(LSTRequestMethod)method
                   url:(NSString *)url
            parameters:(NSDictionary *)parameters
           cachePolicy:(LSTCachePolicy)cachePolicy
              success:(LSTHttpRequestSuccess)success
                  fail:(LSTHttpRequestFail)fail{
  

    [self httpWithMethod:method url:url parameters:parameters success:success fail:fail];

}

+(void)httpWithMethod:(LSTRequestMethod)method
                  url:(NSString *)url
           parameters:(NSDictionary *)parameters
              success:(LSTHttpRequestSuccess)success
                 fail:(LSTHttpRequestFail)fail{
    
    
    if (_baseParameters.count) {
        NSMutableDictionary * mutableBaseParameters = [NSMutableDictionary dictionaryWithDictionary:parameters];
        [mutableBaseParameters addEntriesFromDictionary:_baseParameters];
        parameters = [mutableBaseParameters copy];
    }
    
    
    if (_parametersHandle) {
        parameters = _parametersHandle(parameters);
    }
    
    //添加请求头
//    AFJSONRequestSerializer *requestSerializer = [AFJSONRequestSerializer serializer];
//    [requestSerializer setValue:[SQLiveUserTool isLogin]?[NSString stringWithFormat:@"Bearer %@",[SQLiveUserTool loadLiveAuth]]:nil forHTTPHeaderField:@"Authorization"];
//    [requestSerializer setValue:[SQLiveUserTool isLogin]?[SQLiveUserTool loadToken]:nil forHTTPHeaderField:@"X-DS-KEY"];
//    _sessionManager.requestSerializer = requestSerializer;
        
//    NSString *apiVersion = [NSString stringWithFormat:@"application/vnd.lumen.v%@+json",SQLiveAPIVersion];
//    [requestSerializer setValue:apiVersion forHTTPHeaderField:@"Accept"];
//      _sessionManager.requestSerializer = requestSerializer;
    
    NSDictionary *headersDic = [NSDictionary dictionary];
    if (_headersHandle) {
        headersDic = _parametersHandle(parameters);
    }
    
//    NSString *liveAuth = ![SQLiveUserTool loadLiveAuth]?@"":[SQLiveUserTool loadLiveAuth];
//    NSDictionary *dictionary = @{@"Authorization":[SQLiveUserTool isLogin]?[NSString stringWithFormat:@"Bearer %@",liveAuth]:@"",@"X-DS-KEY":[SQLiveUserTool isLogin]?[SQLiveUserTool loadToken]:@"",@"Accept":[NSString stringWithFormat:@"application/vnd.lumen.v%@+json",SQLiveAPIVersion]};

    [self dataTaskWithHTTPMethod:method
                             url:url
                         headers:headersDic
                      parameters:parameters
                        callback:^(NSURLSessionDataTask * _Nonnull task, id _Nullable responseObject) {
        
        if (_finishHandle) {
            _finishHandle(responseObject);
        }
        [[self allSessionTask] removeObject:task];
        success ? success(responseObject, NO) : nil;
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        if (_failHandle) {
            _failHandle(error);
        }
        fail ? fail(error, LSTNetworkMonitor.getCurrentNetworkStatus) : nil;
        [[self allSessionTask] removeObject:task];
    }];
    
}


+(void)dataTaskWithHTTPMethod:(LSTRequestMethod)method url:(NSString *)url
                      headers:(NSDictionary *)headers
                   parameters:(NSDictionary *)parameters
                      callback:(void (^)(NSURLSessionDataTask * _Nonnull, id _Nullable))callback
                      failure:(void (^)(NSURLSessionDataTask * _Nullable, NSError * _Nonnull))failure
{
    
    NSURLSessionTask *sessionTask;
    if (method == LSTRequestMethodGET){
        
        sessionTask = [_sessionManager GET:url parameters:parameters headers:headers progress:nil success:callback failure:failure];
    }else if (method == LSTRequestMethodPOST) {
        sessionTask = [_sessionManager POST:url parameters:parameters headers:headers progress:nil success:callback failure:failure];
    }else if (method == LSTRequestMethodHEAD) {
        sessionTask = [_sessionManager HEAD:url parameters:parameters headers:headers success:nil failure:failure];
    }else if (method == LSTRequestMethodPUT) {
        sessionTask = [_sessionManager PUT:url parameters:parameters headers:headers success:nil failure:failure];
    }else if (method == LSTRequestMethodPATCH) {
        sessionTask = [_sessionManager PATCH:url parameters:parameters headers:headers success:nil failure:failure];
    }else if (method == LSTRequestMethodDELETE) {
        sessionTask = [_sessionManager DELETE:url parameters:parameters headers:headers success:nil failure:failure];
    }
    //添加最新的sessionTask到数组
    sessionTask ? [[self allSessionTask] addObject:sessionTask] : nil;
}


/**过滤缓存Key*/
+ (void)setCacheKeyfilter:(NSArray *)cacheKeyfilter {
    _cacheKeyfilter = cacheKeyfilter;
}
/**设置接口基本参数(如:用户ID, Token)*/
+ (void)setBaseParameters:(NSDictionary *)parameters {
    _baseParameters = parameters;
}

+ (void)parametersWillHandle:(LSTNetworkParametersHandle)block {
    
    _parametersHandle = block;
}

+ (void)finishHandle:(LSTNetworkFinishHandle)block {
    _finishHandle = block;
}

+ (void)failHandle:(LSTNetworkFailHandle)block {
    _failHandle = block;
}


@end
