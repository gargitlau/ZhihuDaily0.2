//
//  AppDelegate.m
//  ZhihuDaily0.2
//
//  Created by Gargit on 15/11/6310.
//  Copyright © 2015年 Gargit. All rights reserved.
//

#import "AppDelegate.h"
#import "HomeTableViewController.h"
#import <AFNetworking.h>
#import "Story.h"
#import "ThemeModel.h"
#import "ThemeDetail.h"
#import <SWRevealViewController.h>
#import "MenuViewController.h"
#import "KKNavigationController.h"

/**
 *  获取今天信息URL
 */
#define kLastStoriesURL @"http://news-at.zhihu.com/api/4/stories/latest?client=0"

/**
 *  获取旧信息的URL
 */
#define kBeforeStoriesURL @"http://news-at.zhihu.com/api/4/stories/before/%@?client=0"

/**
 *  获取主题的URL
 */
#define kThemeURL @"http://news-at.zhihu.com/api/4/themes"

/**
 *  获取主题的信息
 */
#define kThemeDetailURL @"http://news-at.zhihu.com/api/4/theme/%@"

/**
 *  获取该主题更多信息
 */
#define kThemeGetMoreURL @"http://news-at.zhihu.com/api/4/theme/%@/before/%@"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    // 第一次运行，用来第二个启动页
    self.isFirstRun = YES;
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    // 设置navigationbar为透明
    [[UINavigationBar appearance] setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setShadowImage:[UIImage new]];
    
    HomeTableViewController *homeTableVC = [[HomeTableViewController alloc] init];
    
    KKNavigationController *navigation = [[KKNavigationController alloc] initWithRootViewController:homeTableVC];
    
    MenuViewController *menuVC = [[MenuViewController alloc] initWithNibName:@"MenuViewController" bundle:nil];
    
    SWRevealViewController *revealViewController = [[SWRevealViewController alloc] initWithRearViewController:menuVC frontViewController:navigation];
    
    revealViewController.rearViewRevealWidth = 225;
    
    self.window.rootViewController = revealViewController;
    
    [self loadData];
    
    [self loadTheme];
    
    return YES;
}

/**
 *  获取今天数据
 */
- (void)loadData {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [manager GET:kLastStoriesURL parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        _lastDate = responseObject[@"date"];
        
        for (NSDictionary *dict in responseObject[@"stories"]) {
            [self.stories addObject:[Story storyWithDictionary:dict]];
        }
        
        for (NSDictionary *dict in responseObject[@"top_stories"]) {
            [self.topStories addObject:[Story storyWithDictionary:dict]];
        }
        
        // 发通知告诉视图控制器可以关闭第二个欢迎LaunchScreen
        [[NSNotificationCenter defaultCenter] postNotificationName:kTodayDataGet object:nil];
        
        if (self.headerEndRefreshBlock) {
            self.headerEndRefreshBlock();
        }
        
        [self loadBeforeData];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    }];
}

/**
 *  每次获取过去三天数据
 */
- (void)loadBeforeData {
    NSString *url;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    if (self.oldStoryDates.count == 0) {
        url = [NSString stringWithFormat:kBeforeStoriesURL, _lastDate];
    } else {
        url = [NSString stringWithFormat:kBeforeStoriesURL, [self.oldStoryDates lastObject]];
    }
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager GET:url parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        NSMutableArray *beforeData = [[NSMutableArray alloc] init];
        [self.oldStoryDates addObject:responseObject[@"date"]];
        for (NSDictionary *dict in responseObject[@"stories"]) {
            [beforeData addObject:[Story storyWithDictionary:dict]];
        }
        [self.oldStories addObject:[NSArray arrayWithArray:beforeData]];
        
        // 当获取够三天信息以后，则退出。
        if (self.oldStories.count % 3 == 0) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kBeforeDataGet object:nil];
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            if (self.oldStories.count > 3) {
                if (self.footerEndRefreshBlock) {
                    self.footerEndRefreshBlock();
                }
            }
        } else {
            [self loadBeforeData];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
}

/**
 *  加载主题
 */
- (void)loadTheme {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager GET:kThemeURL parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        [self.themeList removeAllObjects];
        for (NSDictionary *dict in responseObject[@"others"]) {
            [self.themeList addObject:[ThemeModel themeWithDictionary:dict]];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:kThemeDataGet object:nil];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    }];
}

/**
 *  加载主题信息列表
 *
 *  @param identity 主题的id
 */
- (void)loadThemeDetail:(NSNumber *)identity {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    NSString *urlStr = [NSString stringWithFormat:kThemeDetailURL, identity];
    [manager GET:urlStr parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        self.themeDetail = [ThemeDetail themeDetailWithDictionary:responseObject];
        if (self.themeHeaderEndRefreshBlock) {
            self.themeHeaderEndRefreshBlock();
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:kThemeDetailGet object:nil];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        if (self.themeHeaderEndRefreshBlock) {
            self.themeHeaderEndRefreshBlock();
        }
    }];
}

/**
 *  获取之前的数据
 *
 *  @param identity 主题的id
 */
- (void)loadBeforeThemeData:(NSNumber *)identity {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    NSString *urlStr = [NSString stringWithFormat:kThemeGetMoreURL, identity, _themeDetail.stories.lastObject.identity];
    [manager GET:urlStr parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        for (NSDictionary *dict in responseObject[@"stories"]) {
            [self.themeDetail.stories addObject:[Story storyWithDictionary:dict]];
        }
        if (self.themeFooterEndRefreshBlock) {
            self.themeFooterEndRefreshBlock();
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        if (self.themeFooterEndRefreshBlock) {
            self.themeFooterEndRefreshBlock();
        }
    }];
}

/**
 *  清除所有数据
 */
- (void)clearAllData {
    [self.stories removeAllObjects];
    [self.topStories removeAllObjects];
    [self.oldStories removeAllObjects];
    [self.oldStoryDates removeAllObjects];
}

#pragma mark - 懒加载
- (NSMutableArray *)stories {
    if (_stories == nil) {
        _stories = [[NSMutableArray alloc] init];
    }
    return _stories;
}

- (NSMutableArray *)topStories {
    if (_topStories == nil) {
        _topStories = [[NSMutableArray alloc] init];
    }
    return _topStories;
}

- (NSMutableArray *)oldStories {
    if (_oldStories == nil) {
        _oldStories = [[NSMutableArray alloc] init];
    }
    return _oldStories;
}

- (NSMutableArray *)oldStoryDates {
    if (_oldStoryDates == nil) {
        _oldStoryDates = [[NSMutableArray alloc] init];
    }
    return _oldStoryDates;
}

- (NSMutableArray *)themeList {
    if (_themeList == nil) {
        _themeList = [[NSMutableArray alloc] init];
    }
    return _themeList;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
