//
//  HCNetworking.h
//  HCNetworking
//
//  Created by admin on 2020/4/3.
//  Copyright © 2020 admin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IFLYHAFNetworking.h"
NS_ASSUME_NONNULL_BEGIN
typedef enum {
    IFLYHStatusUnknown           = -1, //未知网络
    IFLYHStatusNotReachable      = 0,    //没有网络
    IFLYHStatusReachableViaWWAN  = 1,    //手机自带网络
    IFLYHStatusReachableViaWiFi  = 2     //wifi
} IFLYHNetworkStatus;

typedef void( ^ ResponseSuccess)(id response);
typedef void( ^ ResponseFail)(NSError *error);
typedef void( ^ UploadProgress)(int64_t bytesProgress,
                                  int64_t totalBytesProgress);
typedef void( ^ DownloadProgress)(int64_t bytesProgress,
                                   int64_t totalBytesProgress);

typedef NSURLSessionTask IFLYURLSessionTask;

@interface IFLYHIFLYNetworking : NSObject

/**
 *  单例
 *
 *
 */
+ (IFLYHIFLYNetworking *)sharedIFLYHIFLYNetworking;

/**
 *  获取网络
 */
@property (nonatomic,assign)IFLYHNetworkStatus networkStats;

/**
 *  开启网络监测
 */
+ (void)startMonitoring;

/**
 *  get请求方法,block回调
 *
 *  @param url     请求连接，根路径
 *  @param params  参数
 *  @param success 请求成功返回数据
 *  @param fail    请求失败
 *  @param showHUD 是否显示HUD
 */
+(IFLYURLSessionTask *)getWithUrl:(NSString *)url
           params:(NSDictionary *)params
          success:(ResponseSuccess)success
             fail:(ResponseFail)fail
          showHUD:(BOOL)showHUD;

/**
 *  post请求方法,block回调
 *
 *  @param url     请求连接，根路径
 *  @param params  参数
 *  @param success 请求成功返回数据
 *  @param fail    请求失败
 *  @param showHUD 是否显示HUD
 */
+(IFLYURLSessionTask *)postWithUrl:(NSString *)url
           params:(NSDictionary *)params
          success:(ResponseSuccess)success
              fail:(ResponseFail)fail
           showHUD:(BOOL)showHUD;

/**
 *  上传图片方法
 *
 *  @param image      上传的图片
 *  @param url        请求连接，根路径
 *  @param filename   图片的名称(如果不传则以当时间命名)
 *  @param name       上传图片时填写的图片对应的参数
 *  @param params     参数
 *  @param progress   上传进度
 *  @param success    请求成功返回数据
 *  @param fail       请求失败
 *  @param showHUD    是否显示HUD
 */
+ (IFLYURLSessionTask *)uploadWithImage:(UIImage *)image
                    url:(NSString *)url
               filename:(NSString *)filename
                   name:(NSString *)name
                 params:(NSDictionary *)params
               progress:(UploadProgress)progress
                success:(ResponseSuccess)success
                   fail:(ResponseFail)fail
                showHUD:(BOOL)showHUD;

/**
 *  下载文件方法
 *
 *  @param url           下载地址
 *  @param saveToPath    文件保存的路径,如果不传则保存到Documents目录下，以文件本来的名字命名
 *  @param progressBlock 下载进度回调
 *  @param success       下载完成
 *  @param fail          失败
 *  @param showHUD       是否显示HUD
 *  @return 返回请求任务对象，便于操作
 */
+ (IFLYURLSessionTask *)downloadWithUrl:(NSString *)url
                           saveToPath:(NSString *)saveToPath
                             progress:(DownloadProgress )progressBlock
                              success:(ResponseSuccess )success
                              failure:(ResponseFail )fail
                              showHUD:(BOOL)showHUD;



@end

NS_ASSUME_NONNULL_END
