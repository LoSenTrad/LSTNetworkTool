//
//  LSTNetworkTool.h
//  AMK
//
//  Created by LoSenTrad on 2019/12/12.
//  Copyright © 2019 AMK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LSTNetworkMonitor.h"
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN


/**请求的Block*/
typedef void(^LSTHttpRequestSuccess)(id responseObject, BOOL isCache);
/**请求的Block*/
typedef void(^LSTHttpRequestFail)(NSError *error,LSTNetworkStatus networkStatus);

/*上传或者下载的进度*/
typedef void(^LSTHttpProgress)(NSProgress *progress);

typedef NSDictionary *(^LSTNetworkParametersHandle)(NSDictionary *parameters);
typedef NSDictionary *(^LSTNetworkHeadersHandle)(NSDictionary *parameters);
/** 请求结束的block*/
typedef NSDictionary *(^LSTNetworkFinishHandle)(id responseObject);
/** 请求失败的block*/
typedef NSDictionary *(^LSTNetworkFailHandle)(NSError *error);
/**下载的Block*/
typedef void(^LSTNetworkDownload)(NSString *path, NSError *error);

@interface LSTNetworkTool : NSObject


typedef NS_ENUM(NSUInteger, LSTCachePolicy){
    /**只从网络获取数据，且数据不会缓存在本地*/
    LSTCachePolicyIgnoreCache = 0,
    /**只从缓存读数据，如果缓存没有数据，返回一个空*/
    LSTCachePolicyCacheOnly = 1,
    /**先从网络获取数据，同时会在本地缓存数据*/
    LSTCachePolicyNetworkOnly = 2,
    /**先从缓存读取数据，如果没有再从网络获取*/
    LSTCachePolicyCacheElseNetwork = 3,
    /**先从网络获取数据，如果没有在从缓存获取，此处的没有可以理解为访问网络失败，再从缓存读取*/
    LSTCachePolicyNetworkElseCache = 4,
    /**先从缓存读取数据，然后在从网络获取并且缓存，在这种情况下，Block将产生两次调用*/
    LSTCachePolicyCacheThenNetwork = 5
};

/**请求方式*/
typedef NS_ENUM(NSUInteger, LSTRequestMethod){
    /**GET请求方式*/
    LSTRequestMethodGET = 0,
    /**POST请求方式*/
    LSTRequestMethodPOST,
    /**HEAD请求方式*/
    LSTRequestMethodHEAD,
    /**PUT请求方式*/
    LSTRequestMethodPUT,
    /**PATCH请求方式*/
    LSTRequestMethodPATCH,
    /**DELETE请求方式*/
    LSTRequestMethodDELETE
};



+ (void)setTimeout:(NSTimeInterval)timeout;


+ (void)cancelAllRequest;

+ (void)cancelRequestWithURL:(NSString *)url;

/**是否打开网络加载菊花(默认打开)*/
+ (void)openNetworkActivityIndicator:(BOOL)open;

/**过滤缓存Key*/
+ (void)setCacheKeyfilter:(NSArray *)cacheKeyfilter;
/**设置接口基本参数(如:用户ID, Token)*/
+ (void)setBaseParameters:(NSDictionary *)parameters;

/** 请求参数处理前调用 */
+ (void)parametersWillHandle:(LSTNetworkParametersHandle)block;
/** 请求头处理前调用 */
+ (void)headersWillHandle:(LSTNetworkParametersHandle)block;


/** 请求结束后回调*/
+ (void)finishHandle:(LSTNetworkFinishHandle)block;
/** 请求错误后回调*/
+ (void)failHandle:(LSTNetworkFailHandle)block;

/** POST请求 */
+ (void)POSTWithURL:(NSString *)url
         parameters:(NSDictionary *)parameters
        cachePolicy:(LSTCachePolicy)cachePolicy
            success:(LSTHttpRequestSuccess)success
               fail:(LSTHttpRequestFail)fail;

/** GET请求 */
+ (void)GETWithURL:(NSString *)url
        parameters:(NSDictionary *)parameters
       cachePolicy:(LSTCachePolicy)cachePolicy
           success:(LSTHttpRequestSuccess)success
              fail:(LSTHttpRequestFail)fail;

/**
 上传图片文件

 @param url 请求地址
 @param parameters 请求参数
 @param images 图片数组
 @param name 文件对应服务器上的字段
 @param fileName 文件名
 @param mimeType 图片文件类型：png/jpeg(默认类型)
 @param progress 上传进度

 */
+ (void)uploadImageURL:(NSString *)url
            parameters:(NSDictionary *)parameters
                images:(NSArray<UIImage *> *)images
                  name:(NSString *)name
              fileName:(NSString *)fileName
              mimeType:(NSString *)mimeType
              progress:(LSTHttpProgress)progress
               success:(LSTHttpRequestSuccess)success
                  fail:(LSTHttpRequestFail)fail;


/**
 下载文件

 @param url 请求地址
 @param fileDir 文件存储的目录(默认存储目录为Download)
 @param progress 文件下载的进度信息
 @param callback 请求回调
 */
+(void)downloadWithURL:(NSString *)url
               fileDir:(NSString *)fileDir
              fileName:(NSString *)fileName
              progress:(LSTHttpProgress)progress
              callback:(LSTNetworkDownload)callback;


@end

NS_ASSUME_NONNULL_END
