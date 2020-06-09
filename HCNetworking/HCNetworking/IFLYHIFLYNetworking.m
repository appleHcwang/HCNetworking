//
//  HCNetworking.m
//  HCNetworking
//
//  Created by admin on 2020/4/3.
//  Copyright © 2020 admin. All rights reserved.
//
#ifdef DEBUG
#   define DLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#   define DLog(...)
#endif

#import "IFLYHIFLYNetworking.h"
#import "IFLYHAFNetworkActivityIndicatorManager.h"
#import "IFLYHAFNetworking.h"
#import "IFLYHAFHTTPSessionManager.h"
static NSMutableArray *tasks;
@implementation IFLYHIFLYNetworking

+ (IFLYHIFLYNetworking *)sharedIFLYHIFLYNetworking {
    static IFLYHIFLYNetworking *handler = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        handler = [[IFLYHIFLYNetworking alloc] init];
    });
    return handler;
}

+(NSMutableArray *)tasks{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
    //    DLog(@"创建数组");
        tasks = [[NSMutableArray alloc] init];
    });
    return tasks;
}

+(IFLYHAFHTTPSessionManager *)getAFManager {
    [IFLYHAFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    IFLYHAFHTTPSessionManager *manager = manager = [IFLYHAFHTTPSessionManager manager];
    manager.requestSerializer = [IFLYHAFJSONRequestSerializer serializer];//设置请求数据为json
    manager.responseSerializer = [IFLYHAFJSONResponseSerializer serializer];//设置返回数据为json
    manager.requestSerializer.stringEncoding = NSUTF8StringEncoding;
    manager.requestSerializer.timeoutInterval=10;
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithArray:@[@"application/json",
                                                                              @"text/html",
                                                                              @"text/json",
                                                                              @"text/plain",
                                                                              @"text/javascript",
                                                                              @"text/xml",
                                                                              @"image/*"]];
    
    return manager;
    
}

/**
 *GET请求
 */
+(IFLYURLSessionTask *)getWithUrl:(NSString *)url
                         params:(NSDictionary *)params
                        success:(ResponseSuccess)success
                           fail:(ResponseFail)fail
                        showHUD:(BOOL)showHUD{
    
    return [self baseRequestType:@"GET" url:url params:params success:success fail:fail showHUD:showHUD];
    
}

/**
 *POST请求
 */
+(IFLYURLSessionTask *)postWithUrl:(NSString *)url
                          params:(NSDictionary *)params
                         success:(ResponseSuccess)success
                            fail:(ResponseFail)fail
                         showHUD:(BOOL)showHUD{
   return [self baseRequestType:@"POST" url:url params:params success:success fail:fail showHUD:showHUD];
}

/**
 *基础
 */
+(IFLYURLSessionTask *)baseRequestType:(NSString *)type
                                 url:(NSString *)url
                              params:(NSDictionary *)params
                             success:(ResponseSuccess)success
                                fail:(ResponseFail)fail
                               showHUD:(BOOL)showHUD {
    if (url==nil) {
        return nil;
    }
    if (showHUD==YES) {
           
    }
    //检查地址中是否有中文
    NSString *urlStr=[NSURL URLWithString:url]?url:[self strUTF8Encoding:url];
    IFLYHAFHTTPSessionManager *manager=[self getAFManager];
    IFLYURLSessionTask *sessionTask=nil;
    if ([type isEqualToString:@"GET"]) {
        sessionTask = [manager GET:urlStr parameters:params progress:^(NSProgress * _Nonnull downloadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            //  DLog(@"请求结果=%@",responseObject);
            if (success) {
                success(responseObject);
            }
            [[self tasks] removeObject:sessionTask];
            if (showHUD==YES) {
                 
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            //    DLog(@"error=%@",error);
            if (fail) {
                fail(error);
            }
            [[self tasks] removeObject:sessionTask];
            if (showHUD==YES) {
                 
            }
        }];
    } else{
        sessionTask = [manager POST:url parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            //     DLog(@"请求成功=%@",responseObject);
            if (success) {
                success(responseObject);
            }
            [[self tasks] removeObject:sessionTask];
            
            if (showHUD==YES) {
                 
            }
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            //   DLog(@"error=%@",error);
            if (fail) {
                fail(error);
            }
            
            [[self tasks] removeObject:sessionTask];
            
            if (showHUD==YES) {
                 
            }
            
        }];
    }
    if (sessionTask) {
        [[self tasks] addObject:sessionTask];
    }
    return sessionTask;
}

+(IFLYURLSessionTask *)uploadWithImage:(UIImage *)image
                                 url:(NSString *)url
                            filename:(NSString *)filename
                                name:(NSString *)name
                              params:(NSDictionary *)params
                            progress:(UploadProgress)progress
                             success:(ResponseSuccess)success
                                fail:(ResponseFail)fail
                             showHUD:(BOOL)showHUD {
    
    DLog(@"请求地址----%@\n    请求参数----%@",url,params);
    if (url==nil) {
        return nil;
    }
    
    if (showHUD==YES) {
           
    }
    
    //检查地址中是否有中文
    NSString *urlStr=[NSURL URLWithString:url]?url:[self strUTF8Encoding:url];
    
    IFLYHAFHTTPSessionManager *manager=[self getAFManager];
    
    __block IFLYURLSessionTask *sessionTask = [manager POST:urlStr parameters:params constructingBodyWithBlock:^(id<IFLYHAFMultipartFormData>  _Nonnull formData) {
        //压缩图片
        NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
        NSString *imageFileName = filename;
        if (filename == nil || ![filename isKindOfClass:[NSString class]] || filename.length == 0) {
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            formatter.dateFormat = @"yyyyMMddHHmmss";
            NSString *str = [formatter stringFromDate:[NSDate date]];
            imageFileName = [NSString stringWithFormat:@"%@.jpg", str];
        }
        // 上传图片，以文件流的格式
        [formData appendPartWithFileData:imageData name:name fileName:imageFileName mimeType:@"image/jpeg"];
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        DLog(@"上传进度--%lld,总进度---%lld",uploadProgress.completedUnitCount,uploadProgress.totalUnitCount);
        if (progress) {
            progress(uploadProgress.completedUnitCount, uploadProgress.totalUnitCount);
        }
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        DLog(@"上传图片成功=%@",responseObject);
        if (success) {
            success(responseObject);
        }
        [[self tasks] removeObject:sessionTask];
        if (showHUD==YES) {
             
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        DLog(@"error=%@",error);
        if (fail) {
            fail(error);
        }
        [[self tasks] removeObject:sessionTask];
        if (showHUD==YES) {
             
        }
    }];

    if (sessionTask) {
        [[self tasks] addObject:sessionTask];
    }
    
    return sessionTask;
}

+ (IFLYURLSessionTask *)downloadWithUrl:(NSString *)url
                            saveToPath:(NSString *)saveToPath
                              progress:(DownloadProgress)progressBlock
                               success:(ResponseSuccess)success
                               failure:(ResponseFail)fail
                                showHUD:(BOOL)showHUD {
    
    DLog(@"请求地址----%@\n    ",url);
    if (url==nil) {
        return nil;
    }
    if (showHUD==YES) {
           
    }
    NSURLRequest *downloadRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    IFLYHAFHTTPSessionManager *manager = [self getAFManager];
    IFLYURLSessionTask *sessionTask = nil;
    sessionTask = [manager downloadTaskWithRequest:downloadRequest progress:^(NSProgress * _Nonnull downloadProgress) {
        DLog(@"下载进度--%.1f",1.0 * downloadProgress.completedUnitCount/downloadProgress.totalUnitCount);
        //回到主线程刷新UI
        dispatch_async(dispatch_get_main_queue(), ^{
            if (progressBlock) {
                progressBlock(downloadProgress.completedUnitCount, downloadProgress.totalUnitCount);
            }
        });
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        if (!saveToPath) {
            NSURL *downloadURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
            DLog(@"默认路径--%@",downloadURL);
            return [downloadURL URLByAppendingPathComponent:[response suggestedFilename]];
            
        } else {
            return [NSURL fileURLWithPath:saveToPath];
        }
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        DLog(@"下载文件成功");
        [[self tasks] removeObject:sessionTask];
        if (error == nil) {
            if (success) {
                success([filePath path]);//返回完整路径
            }
        } else {
            if (fail) {
                fail(error);
            }
        }
        if (showHUD==YES) {
             
        }
    }];
    //开始启动任务
    [sessionTask resume];
    if (sessionTask) {
        [[self tasks] addObject:sessionTask];
    }
    return sessionTask;
}

#pragma makr - 开始监听网络连接
+ (void)startMonitoring {
    // 1.获得网络监控的管理者
    IFLYHAFNetworkReachabilityManager *mgr = [IFLYHAFNetworkReachabilityManager sharedManager];
    // 2.设置网络状态改变后的处理
    [mgr setReachabilityStatusChangeBlock:^(IFLYHAFNetworkReachabilityStatus status) {
        // 当网络状态改变了, 就会调用这个block
        switch (status) {
            case IFLYHAFNetworkReachabilityStatusUnknown: // 未知网络
                //(@"未知网络");
                [IFLYHIFLYNetworking sharedIFLYHIFLYNetworking].networkStats=IFLYHStatusUnknown;
                break;
            case IFLYHAFNetworkReachabilityStatusNotReachable: // 没有网络(断网)
                // DLog(@"没有网络");
                [IFLYHIFLYNetworking sharedIFLYHIFLYNetworking].networkStats=IFLYHStatusNotReachable;
                break;
            case IFLYHAFNetworkReachabilityStatusReachableViaWWAN: // 手机自带网络
                //  DLog(@"手机自带网络");
                [IFLYHIFLYNetworking sharedIFLYHIFLYNetworking].networkStats=IFLYHStatusReachableViaWWAN;
                break;
            case IFLYHAFNetworkReachabilityStatusReachableViaWiFi: // WIFI
                [IFLYHIFLYNetworking sharedIFLYHIFLYNetworking].networkStats=IFLYHStatusReachableViaWiFi;
                //  DLog(@"WIFI--%d",[LXNetworking sharedLXNetworking].networkStats);
                break;
        }
    }];
    [mgr startMonitoring];
}

+(NSString *)strUTF8Encoding:(NSString *)str {
    
    //ios 9 之后
    return  [str stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    //iOS 8
    // return [str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

@end
