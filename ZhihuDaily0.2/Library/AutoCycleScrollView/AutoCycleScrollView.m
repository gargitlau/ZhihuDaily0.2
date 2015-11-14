//
//  AutoCycleScrollView.m
//  ZhihuDaily0.2
//
//  Created by Gargit on 15/11/8312.
//  Copyright © 2015年 Gargit. All rights reserved.
//

#import "AutoCycleScrollView.h"
#import <UIImageView+WebCache.h>
#import "GradientView.h"

#define kImageViewTag 1000

@interface AutoCycleScrollView() <UIScrollViewDelegate>

/**
 *  主要的视图
 */
@property (nonatomic, strong) UIScrollView *mainView;

/**
 *  保存UIImageView的数组
 */
@property (nonatomic, strong) NSMutableArray<UIImageView *> *imageViewList;

/**
 *  保存标题的列表
 */
@property (nonatomic, strong) NSMutableArray<UILabel *> *titleLabelList;

/**
 *  自动滚动的计时器
 */
@property (nonatomic, strong) NSTimer *timer;

/**
 *  下面小圆点
 */
@property (nonatomic, strong) UIPageControl *pageControl;

/**
 *  遮盖层
 */
@property (nonatomic, strong)  UIView *coverView;

/**
 *  y轴最大的偏移量
 */
@property (nonatomic, assign) CGFloat maxOffset;

/**
 *  原来的高度
 */
@property (nonatomic, assign) CGFloat originHeight;

/**
 *  上下的阴影
 */
@property (nonatomic, strong) GradientView *topBlur;
@property (nonatomic, strong) GradientView *bottomBlur;
@end

@implementation AutoCycleScrollView

- (void)initialization {
    self.autoScrollTimeInterval = 6.0;
    self.infiniteLoop = YES;
    self.autoScroll = YES;
}

- (instancetype)initWithFrame:(CGRect)frame maxOffset:(CGFloat)maxOffset titlesGroup:(NSArray *)titlesGroup{
    if (self = [super initWithFrame:frame]) {
        [self initialization];
        _maxOffset = maxOffset;
        _originHeight = frame.size.height;
        
        _mainView = [[UIScrollView alloc] initWithFrame:frame];
        _mainView.pagingEnabled = YES;
        _mainView.delegate = self;
        _mainView.showsHorizontalScrollIndicator = NO;
        _mainView.showsVerticalScrollIndicator = NO;
        [self addSubview:_mainView];
        
        _pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 30)];
        _pageControl.center = CGPointMake(frame.size.width / 2, frame.size.height - 15);
        _pageControl.numberOfPages = titlesGroup.count;
        _pageControl.userInteractionEnabled = NO;
        [self addSubview:_pageControl];

        self.titlesGroup = titlesGroup;
        
        _topBlur = [[GradientView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height / 3) type:TRANSPARENT_UPSIDE_GRADIENT_TYPE];
        [self addSubview:_topBlur];
        [self bringSubviewToFront:_topBlur];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame imagesGroup:(NSArray *)imagesGroup maxOffset:(CGFloat)maxOffset titlesGroup:(NSArray *)titlesGroup {
    if (self = [self initWithFrame:frame maxOffset:maxOffset titlesGroup:titlesGroup]) {
        self.imagesGroup = imagesGroup;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame imagesURLStringGroup:(NSArray *)imagesURLStrGroup maxOffset:(CGFloat)maxOffset titlesGroup:(NSArray *)titlesGroup {
    if (self = [self initWithFrame:frame maxOffset:maxOffset titlesGroup:titlesGroup]) {
        self.imagesURLStrGroup = imagesURLStrGroup;
    }
    return self;
}

+ (instancetype)autoCycleScrollViewWithFrame:(CGRect)frame imagesGroup:(NSArray *)imagesGroup maxOffset:(CGFloat)maxOffset titlesGroup:(NSArray *)titlesGroup{
    return [[self alloc] initWithFrame:frame imagesGroup:imagesGroup maxOffset:maxOffset titlesGroup:titlesGroup];
}

+ (instancetype)autoCycleScrollViewWithFrame:(CGRect)frame imagesURLStringGroup:(NSArray *)imagesURLStrGroup maxOffset:(CGFloat)maxOffset titlesGroup:(NSArray *)titlesGroup{
    return [[self alloc] initWithFrame:frame imagesURLStringGroup:imagesURLStrGroup maxOffset:maxOffset titlesGroup:titlesGroup];
}

/**
 *  创建所有imageview
 */
- (void)createImageViews:(NSInteger)imagesCount {
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    
    _pageControl.numberOfPages = imagesCount;
    
    // 创建的时候，把所有清空，顺便初始化数组
    [self.imageViewList removeAllObjects];
    
    for (int i = 0; i < imagesCount + 2; i++) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(width * i, 0, width, height + _maxOffset)];
        imageView.tag = kImageViewTag + (i + imagesCount - 1) % imagesCount;
        [_imageViewList addObject:imageView];
        [self.mainView addSubview:imageView];
        // 保证图片在最底部，不要遮住标题
        [self.mainView insertSubview:imageView atIndex:0];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapImage:)];
        imageView.userInteractionEnabled = YES;
        [imageView addGestureRecognizer:tapGesture];
    }
    self.mainView.contentSize = CGSizeMake(self.frame.size.width * self.imageViewList.count, self.frame.size.height);
    _bottomBlur = [[GradientView alloc] initWithFrame:CGRectMake(0, self.frame.size.height * 2 / 3, self.mainView.contentSize.width, self.frame.size.height / 3) type:TRANSPARENT_ANOTHER_GRADIENT_TYPE];
    [self.mainView addSubview:_bottomBlur];
    [self.mainView setContentOffset:CGPointMake(self.frame.size.width, 0) animated:NO];
}

/**
 *  创建标题的label
 */
- (void)createTitleLabelsWithCount:(NSInteger)count {
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    
    _pageControl.numberOfPages = count;
    
    [self.titleLabelList removeAllObjects];
    for (int i = 0; i < count + 2; i++) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(width * i + 20, 0, width - 40, height - 30)];
        label.font = [UIFont boldSystemFontOfSize:18];
        label.textColor = [UIColor whiteColor];
        label.numberOfLines = 0;
        [self.mainView addSubview:label];
        [_titleLabelList addObject:label];
    }
}

/**
 *  设置图片URL并设置图片
 */
- (void)setImagesURLStrGroup:(NSArray *)imagesURLStrGroup {
    if (0 == imagesURLStrGroup.count) {
        return;
    }
    _imagesURLStrGroup = imagesURLStrGroup;
    if (_imageViewList.count - 2 != imagesURLStrGroup.count) {
        [self createImageViews:imagesURLStrGroup.count];
    }
    // 加载网络图片
    for (UIImageView *imageView in self.imageViewList) {
        [imageView sd_setImageWithURL:[NSURL URLWithString:self.imagesURLStrGroup[imageView.tag - kImageViewTag]]];
    }
}

/**
 *  设置本地图片
 */
- (void)setImagesGroup:(NSArray *)imagesGroup {
    if (0 == imagesGroup.count) {
        return;
    }
    _imagesGroup = imagesGroup;
    if (_imageViewList.count - 2 != imagesGroup.count) {
        [self createImageViews:imagesGroup.count];
    }
    // 加载本地图片
    for (UIImageView * imageView in self.imageViewList) {
        imageView.image = imagesGroup[imageView.tag - kImageViewTag];
    }
}

/**
 *  设置自动滚动时间间隔时，需要重新设置定时器
 */
- (void)setAutoScrollTimeInterval:(CGFloat)autoScrollTimeInterval {
    _autoScrollTimeInterval = autoScrollTimeInterval;
    [self createTimer];
}

- (void)setTitlesGroup:(NSArray *)titlesGroup {
    if (titlesGroup.count == 0) {
        return;
    }
    _titlesGroup = titlesGroup;
    if (titlesGroup.count != _titleLabelList.count - 2) {
        [self createTitleLabelsWithCount:titlesGroup.count];
    }
    [_titleLabelList enumerateObjectsUsingBlock:^(UILabel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.text = titlesGroup[(idx + titlesGroup.count - 1) % titlesGroup.count];
        [obj sizeToFit];
        obj.frame = CGRectMake(self.frame.size.width * idx + 20, self.frame.size.height - 30 - obj.frame.size.height, obj.frame.size.width, obj.frame.size.height);
    }];
}

/**
 *  设置定时器
 */
- (void)createTimer {
    [_timer invalidate];
    _timer = nil;
    _timer = [NSTimer scheduledTimerWithTimeInterval:self.autoScrollTimeInterval target:self selector:@selector(autoScrollImage) userInfo:nil repeats:YES];
}

/**
 *  自动滚动
 */
- (void)autoScrollImage {
    [_mainView setContentOffset:CGPointMake(self.frame.size.width * (_pageControl.currentPage + 2), 0) animated:YES];
}

/**
 *  设置是否自动滚动
 */
- (void)setAutoScroll:(BOOL)autoScroll {
    _autoScroll = autoScroll;
    if (autoScroll == NO) {
        [_timer invalidate];
        _timer = nil;
    } else {
        [self createTimer];
    }
}
/**
 *  懒加载
 */
- (NSMutableArray *)imageViewList {
    if (_imageViewList == nil) {
        _imageViewList = [[NSMutableArray alloc] init];
    }
    return _imageViewList;
}

- (NSMutableArray<UILabel *> *)titleLabelList {
    if (_titleLabelList == nil) {
        _titleLabelList = [[NSMutableArray alloc] init];
    }
    return _titleLabelList;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.mainView.frame = self.frame;
    self.mainView.contentSize = CGSizeMake(self.frame.size.width * self.imageViewList.count, self.frame.size.height);
    
    [self.imageViewList enumerateObjectsUsingBlock:^(UIImageView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.center = CGPointMake(self.frame.size.width * (2 * idx + 1) / 2, self.frame.size.height / 2);
    }];
    
    [self.titleLabelList enumerateObjectsUsingBlock:^(UILabel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.frame = CGRectMake(self.frame.size.width * idx + 20, self.frame.size.height - 30 - obj.frame.size.height, obj.frame.size.width, obj.frame.size.height);
        if (self.frame.size.height < _originHeight) {
            obj.alpha = self.frame.size.height / _originHeight < 0 ? 0 : self.frame.size.height / _originHeight;
        } else {
            obj.alpha = 1;
        }
    }];
    
    _pageControl.center = CGPointMake(self.frame.size.width / 2, self.frame.size.height - 15);
    
    _topBlur.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, _topBlur.frame.size.width, _topBlur.frame.size.height);
    _bottomBlur.frame = CGRectMake(self.frame.origin.x, self.frame.size.height - _bottomBlur.frame.size.height, _bottomBlur.frame.size.width, _bottomBlur.frame.size.height);
}

#pragma mark - UIScrollViewDelegate
// 无限轮播
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (_autoScroll) {
        if (scrollView.contentOffset.x >= scrollView.contentSize.width - scrollView.frame.size.width) {
            [scrollView setContentOffset:CGPointMake(scrollView.frame.size.width, 0) animated:NO];
        } else if (scrollView.contentOffset.x == 0) {
            [scrollView setContentOffset:CGPointMake(scrollView.contentSize.width - self.frame.size.width * 2, 0) animated:NO];
        }
    } else {
        if (scrollView.contentOffset.x > scrollView.contentSize.width - scrollView.frame.size.width * 2) {
            [scrollView setContentOffset:CGPointMake(scrollView.contentSize.width - scrollView.frame.size.width * 2, 0) animated:NO];
        } else if (scrollView.contentOffset.x < scrollView.frame.size.width) {
            [scrollView setContentOffset:CGPointMake(scrollView.frame.size.width, 0) animated:NO];
        }
    }
    
    NSInteger index = scrollView.contentOffset.x / scrollView.frame.size.width - 1;
    _pageControl.currentPage = index;
}

#pragma mark - 点击事件
- (void)tapImage:(UITapGestureRecognizer *)gesture {
    if (self.delegate != nil) {
        [self.delegate autoCycleScrollView:self didSelectedItemAtIndex:(gesture.view.tag - kImageViewTag)];
    }
}


@end
