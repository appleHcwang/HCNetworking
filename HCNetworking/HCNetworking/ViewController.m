//
//  ViewController.m
//  HCNetworking
//
//  Created by admin on 2020/4/3.
//  Copyright © 2020 admin. All rights reserved.
//

#import "ViewController.h"
#import "IFLYNetworking.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSString *path=[NSHomeDirectory() stringByAppendingString:[NSString stringWithFormat:@"/Documents/image.jpg"]];
    [IFLYNetworking downloadWithUrl:@"http://www.aomy.com/attach/2012-09/1347583576vgC6.jpg" saveToPath:path progress:^(int64_t bytesProgress, int64_t totalBytesProgress) {
        //封装方法里已经回到主线程，所有这里不用再调主线程了
        NSLog(@"%@",[NSString stringWithFormat:@"进度==%.2f",1.0 * bytesProgress/totalBytesProgress]);
    } success:^(id response) {
        NSLog(@"---------%@",response);
 
    } failure:^(NSError *error) {
        
    } showHUD:NO];

}


@end
