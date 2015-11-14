//
//  LaunchScreenViewController.m
//  ZhihuDaily0.2
//
//  Created by Gargit on 15/11/7311.
//  Copyright © 2015年 Gargit. All rights reserved.
//

#import "LaunchScreenViewController.h"
#import <AFNetworking.h>

#define kStartImageURL @"http://news-at.zhihu.com/api/4/start-image/1080*1776"
#define kImageKey @"startImage"

@interface LaunchScreenViewController ()

@end

@implementation LaunchScreenViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.startImageView setImage:[self getImage]];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    [manager GET:kStartImageURL parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        NSString * imgURLStr = [responseObject objectForKey:@"img"];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
        
        NSURLSessionDataTask * dataTask = [session dataTaskWithURL:[NSURL URLWithString:imgURLStr] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if (!error) {
                [[NSUserDefaults standardUserDefaults] setObject:data forKey:kImageKey];
            }
        }];
        
        [dataTask resume];
    } failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
        
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIImage *)getImage {
    NSData *data;
    if ((data = [[NSUserDefaults standardUserDefaults] dataForKey:kImageKey])) {
        return [UIImage imageWithData:data];
    }
    
    return [UIImage imageNamed:@"DemoLaunchImage"];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
