//
//  AppDelegate.h
//  ZhihuDaily0.2
//
//  Created by Gargit on 15/11/6310.
//  Copyright © 2015年 Gargit. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kTodayDataGet @"TodayDataGet"
#define kBeforeDataGet @"BeforeDataGet"
#define kThemeDataGet @"ThemeDataGet"
#define kThemeDetailGet @"ThemeDetailGet"

typedef void(^LoadDataCompleted)(void);
typedef void(^LoadBeforeDataCompleted)(void);

typedef void(^LoadThemeDataCompleted)(void);
typedef void(^LoadThemeBeforeDataCompleted)(void);

@class ThemeDetail;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, assign) BOOL isFirstRun;

@property (nonatomic, strong) NSMutableArray *stories;
@property (nonatomic, strong) NSMutableArray *topStories;
@property (nonatomic, copy) NSString *lastDate;

@property (nonatomic, strong) NSMutableArray *oldStories;
@property (nonatomic, strong) NSMutableArray *oldStoryDates;

@property (nonatomic, copy)  LoadDataCompleted headerEndRefreshBlock;
@property (nonatomic, copy) LoadBeforeDataCompleted footerEndRefreshBlock;

@property (nonatomic, strong) NSMutableArray *themeList;
@property (nonatomic, strong) ThemeDetail *themeDetail;

@property (nonatomic, copy)  LoadThemeDataCompleted themeHeaderEndRefreshBlock;
@property (nonatomic, copy) LoadThemeBeforeDataCompleted themeFooterEndRefreshBlock;

/**
 *  获取今天数据
 */
- (void)loadData;

/**
 *  每次获取过去三天数据
 */
- (void)loadBeforeData;

/**
 *  清除所有数据
 */
- (void)clearAllData;

/**
 *  加载主题信息列表
 *
 *  @param identity 主题的id
 */
- (void)loadThemeDetail:(NSNumber *)identity;

/**
 *  获取之前的数据
 *
 *  @param identity 主题的id
 */
- (void)loadBeforeThemeData:(NSNumber *)identity;

@end

