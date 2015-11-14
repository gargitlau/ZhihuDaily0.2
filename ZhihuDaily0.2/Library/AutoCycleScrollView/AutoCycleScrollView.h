//
//  AutoCycleScrollView.h
//  ZhihuDaily0.2
//
//  Created by Gargit on 15/11/8312.
//  Copyright © 2015年 Gargit. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AutoCycleScrollView;

@protocol AutoCycleScrollViewDelegate <NSObject>

@required
- (void)autoCycleScrollView:(AutoCycleScrollView *)autoCycleScrollView didSelectedItemAtIndex:(NSInteger)index;

@end

@interface AutoCycleScrollView : UIView

#pragma mark - 数据源接口
/**
 *  本地图片数组
 */
@property (nonatomic, strong) NSArray *imagesGroup;
/**
 *  网络图片 url string 数组
 */
@property (nonatomic, strong) NSArray *imagesURLStrGroup;

/**
 *  每张图片标题的数组
 */
@property (nonatomic, strong) NSArray *titlesGroup;

#pragma mark - 滚动控制接口
/**
 *  自动滚动间隔时间，默认6s
 */
@property (nonatomic, assign) CGFloat autoScrollTimeInterval;

/**
 *  是否无限循环，默认YES
 */
@property (nonatomic, assign, getter=isInfiniteLoop) BOOL infiniteLoop;

/**
 *  是否自动滚动，默认为YES
 */
@property (nonatomic, assign, getter=isAutoScroll) BOOL autoScroll;

/**
 *  设置代理
 */
@property (nonatomic, weak) id<AutoCycleScrollViewDelegate> delegate;

#pragma mark - 实例化方法
+ (instancetype)autoCycleScrollViewWithFrame:(CGRect)frame imagesGroup:(NSArray *)imagesGroup maxOffset:(CGFloat)maxOffset titlesGroup:(NSArray *)titlesGroup;

+ (instancetype)autoCycleScrollViewWithFrame:(CGRect)frame imagesURLStringGroup:(NSArray *)imagesURLStrGroup maxOffset:(CGFloat)maxOffset titlesGroup:(NSArray *)titlesGroup;

@end
