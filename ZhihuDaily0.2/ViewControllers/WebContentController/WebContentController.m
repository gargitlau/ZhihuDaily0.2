//
//  WebContentController.m
//  ZhihuDaily0.2
//
//  Created by Gargit on 15/11/10314.
//  Copyright © 2015年 Gargit. All rights reserved.
//

#import "WebContentController.h"
#import <AFNetworking.h>
#import "Content.h"
#import "ParallaxHeaderView.h"
#import <UIImageView+WebCache.h>
#import "ContentCoverView.h"
#import "RecommenderView.h"
#import "ContentBottomView.h"
#import "StoryExtra.h"
#import "AppDelegate.h"
#import <SWRevealViewController.h>
#import "ThemeDetail.h"

#define kStoryURL @"http://news-at.zhihu.com/api/4/story/%@"
#define kStoryExtraURL @"http://news-at.zhihu.com/api/4/story-extra/%@"
#define kRecomenderViewTag 299

typedef enum {
    RefreshTypePreviousPage = 1,
    RefreshTypeNextPage = -1
}RefreshType;

@interface WebContentController ()<UIGestureRecognizerDelegate, UIScrollViewDelegate, ParallaxHeaderViewDelegate, ContentBottomViewDelegate>

/**
 *  主界面就是一个webView
 */
@property (nonatomic, strong) UIWebView *mainView;

/**
 *  statusBar状态标志位
 */
@property (nonatomic, assign) BOOL statusBarFlag;

/**
 *  当前页面的内容
 */
@property (nonatomic, strong) Content *content;

/**
 *  头部视图
 */
@property (nonatomic, strong) ParallaxHeaderView *headView;

/**
 *  脚部视图
 */
@property (nonatomic, strong) ContentBottomView *bottomView;

/**
 *  额外信息,点赞数等等
 */
@property (nonatomic, strong) StoryExtra *storyExtra;

@property (nonatomic, weak) AppDelegate *appdelegate;

/**
 *  下拉加载提示
 */
@property (nonatomic, strong) UILabel *upLabel;
@property (nonatomic, strong) UIButton *upArrow;

/**
 *  上拉加载提示
 */
@property (nonatomic, strong) UILabel *downLabel;
@property (nonatomic, strong) UIButton *downArrow;

@end

@implementation WebContentController
{
    UIView *whiteView;
    CGRect _screenBounds;
    RefreshType _refreshType;
    BOOL _isDraging;
    BOOL _shouldRefresh;
}

/**
 *  默认不是theme
 */
- (instancetype)init
{
    self = [super init];
    if (self) {
        _isTheme = NO;
    }
    return self;
}

#pragma mark - 生命周期
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    _screenBounds = [UIScreen mainScreen].bounds;
    _appdelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;

    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self initView];
}

/**
 *  监听scrollview的contentSize以定位下拉刷新
 */
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"contentSize"]) {
        _downLabel.center = CGPointMake(_downLabel.center.x, _mainView.scrollView.contentSize.height + 40);
        _downArrow.center = CGPointMake(_downArrow.center.x, _downLabel.center.y);
    }
}

/**
 *  移除KVO，否则退出时程序会崩溃
 */
- (void)dealloc {
    [_mainView.scrollView removeObserver:self forKeyPath:@"contentSize"];
}

- (void)initView {
    
    _mainView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, _screenBounds.size.width, _screenBounds.size.height - 40)];
    
    [_mainView.scrollView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:nil];
    
    [_mainView.scrollView setBackgroundColor:[UIColor whiteColor]];
    
    _mainView.scrollView.delegate = self;
    
    [self.view addSubview:_mainView];
    
    _bottomView = [[[NSBundle mainBundle] loadNibNamed:@"ContentBottomView" owner:nil options:nil] firstObject];
    
    _bottomView.delegate = self;
    
    _bottomView.frame = CGRectMake(0, CGRectGetMaxY(_mainView.frame), _screenBounds.size.width, 40);
    
    [self.view addSubview:_bottomView];
    
    whiteView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 20)];
    
    [whiteView setBackgroundColor:[UIColor whiteColor]];
    
    [self.view addSubview:whiteView];
    
    _isDraging = NO;
}

- (void)reloadData {
    _content = nil;
    __block CGAffineTransform transform = CGAffineTransformMakeTranslation(0, _refreshType * _screenBounds.size.height);
    [UIView animateWithDuration:0.5 animations:^{
        _mainView.transform = transform;
        [self.view viewWithTag:kRecomenderViewTag].transform = transform;
        _bottomView.transform = transform;
        
    } completion:^(BOOL finished) {
        [_mainView.scrollView removeObserver:self forKeyPath:@"contentSize"];
        [self.view.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [obj removeFromSuperview];
            obj = nil;
        }];
        [self initView];
        [self loadData];
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    self.navigationItem.hidesBackButton = YES;
    [self loadData];
}

- (void)setStatusBarFlag:(BOOL)statusBarFlag {
    _statusBarFlag = statusBarFlag;
    if (statusBarFlag) {
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
        whiteView.alpha = 0;
    } else {
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
        whiteView.alpha = 1;
    }
}

- (void)loadData {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    NSString *urlStr = [NSString stringWithFormat:kStoryURL, self.currentStory.identity];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    [manager GET:urlStr parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        self.content = [Content contentWithDictionary:responseObject];
        [self fixUI];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        NSLog(@"网络内容请求失败");
    }];
    
    NSString *storyExtraURLStr = [NSString stringWithFormat:kStoryExtraURL, self.currentStory.identity];
    
    [manager GET:storyExtraURLStr parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        self.storyExtra = [StoryExtra storyExtraWithDictionary:responseObject];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        NSLog(@"额外数据网络内容请求失败");
    }];
}

- (void)setStoryExtra:(StoryExtra *)storyExtra {
    _storyExtra = storyExtra;
    if (_bottomView != nil) {
        _bottomView.commentLabel.text = storyExtra.comments.description;
        _bottomView.voteNumberLabel.text = storyExtra.popularity.description;
    }
}

- (void)fixUI {
    
    _upLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, -80, _screenBounds.size.width, 20)];
    _upLabel.textColor = [UIColor whiteColor];
    if ([self isFirstStory]) {
        _upLabel.text = @"已经是第一篇";
        _upArrow = nil;
        [_upLabel sizeToFit];
        _upLabel.center = CGPointMake(_screenBounds.size.width / 2, _upLabel.center.y);
    } else {
        _upLabel.text = @"载入上一篇";
        
        [_upLabel sizeToFit];
        _upLabel.center = CGPointMake(_screenBounds.size.width / 2 + 15, _upLabel.center.y);
        
        _upArrow = [[UIButton alloc] initWithFrame:CGRectMake(0, -80, 20, 20)];
        _upArrow.tintColor = [UIColor whiteColor];
        [_upArrow setImage:[[UIImage imageNamed:@"ZHAnswerViewPrevIcon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        _upArrow.frame = CGRectMake(_upLabel.frame.origin.x - 30, _upLabel.center.y - 10, 20, 20);
        [_mainView.scrollView addSubview:_upArrow];
    }
    [_mainView.scrollView addSubview:_upLabel];

    _downLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 700, _screenBounds.size.width, 20)];
    _downLabel.textColor = [UIColor lightGrayColor];
    if ([self isLastStory]) {
        _downLabel.text = @"已经是最后一篇";
        [_downLabel sizeToFit];
        _downLabel.center = CGPointMake(_screenBounds.size.width / 2, _downLabel.center.y);
    } else {
        _downLabel.text = @"载入下一篇";
        [_downLabel sizeToFit];
        _downLabel.center = CGPointMake(_screenBounds.size.width / 2 + 20, _downLabel.center.y);
        _downArrow = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
        [_downArrow setTintColor:[UIColor lightGrayColor]];
        [_downArrow setImage:[UIImage imageNamed:@"ZHAnswerViewPrevIcon"] forState:UIControlStateNormal];
        _downArrow.frame = CGRectMake(_downLabel.frame.origin.x - 30, _downLabel.center.y - 10, 20, 20);
        [self.mainView.scrollView addSubview:_downArrow];
    }
    [_mainView.scrollView addSubview:_downLabel];
    
    if (_content.image != nil) {
        self.statusBarFlag = YES;
        
        ContentCoverView *coverView = [[ContentCoverView alloc] initWithFrame:CGRectMake(0, 0, _screenBounds.size.width, 200) maxOffset:130];
        
        coverView.image_sourceLabel.text = [NSString stringWithFormat:@"图片：%@", _content.image_source];
        
        coverView.titleLabel.text = _content.title;
        
        [coverView.imageView sd_setImageWithURL:[NSURL URLWithString:_content.image]];
        
        _headView = [[ParallaxHeaderView alloc] initWithSytle:ParallaxHeaderViewStyleDefault subView:coverView headerViewSize:coverView.frame.size maxOffsetY:130 delegate:self];
        
        [_mainView.scrollView addSubview:_headView];
        
        if (_content.recommenders.count > 0) {
            [_mainView.scrollView.subviews[0] setFrame:CGRectMake(0, 50, [_mainView.scrollView.subviews[0] frame].size.width, [_mainView.scrollView.subviews[0] frame].size.height)];
            RecommenderView *recommenderView = [[[NSBundle mainBundle] loadNibNamed:@"RecommenderView" owner:nil options:nil] firstObject];
            recommenderView.frame = CGRectMake(0, 200, recommenderView.frame.size.width, recommenderView.frame.size.height);
            [recommenderView loadRecommenders:_content.recommenders];
            [_mainView.scrollView addSubview:recommenderView];
        }
        
    } else {
        _upArrow.tintColor = [UIColor lightGrayColor];
        _upLabel.textColor = [UIColor lightGrayColor];
        
        if (_content.recommenders.count > 0) {
            self.statusBarFlag = NO;
            RecommenderView *recommenderView = [[[NSBundle mainBundle] loadNibNamed:@"RecommenderView" owner:nil options:nil] firstObject];
            recommenderView.frame = CGRectMake(0, 20, recommenderView.frame.size.width, recommenderView.frame.size.height);
            recommenderView.tag = kRecomenderViewTag;
            [recommenderView loadRecommenders:_content.recommenders];
            [self.view addSubview:recommenderView];
            
            CGFloat deltaY = CGRectGetMaxY(recommenderView.frame);
            _mainView.frame = CGRectMake(_mainView.frame.origin.x, deltaY, _mainView.frame.size.width, _mainView.frame.size.height - deltaY);
        }
    }
    
    if (_content.body != nil) {
        [_mainView loadHTMLString:[self fixBodyString] baseURL:nil];
    } else {
        [_mainView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_content.share_url]]];
    }
    
}

/**
 *  将获取到的body修复为正常显示的UI
 */
- (NSString *)fixBodyString {
    NSMutableString * string = [[NSMutableString alloc] init];
    
    [string appendString:@"<html>"];
    [string appendString:@"<head>"];
    [string appendString:@"<link rel=\"stylesheet\" href="];
    [string appendString:self.content.css.firstObject];
    [string appendString:@"></head>"];
    [string appendString:@"<body>"];
    [string appendString:self.content.body];
    [string appendString:@"</body>"];
    [string appendString:@"</html>"];
    
    return string;
}

#pragma mark - ParallaxHeaderViewDelegate
- (void)lockScrollView:(CGFloat)maxOffset {
    [_mainView.scrollView setContentOffset:CGPointMake(0, maxOffset)];
}

#pragma mark - ContentBottomViewDelegate
- (void)ContentBottomView:(ContentBottomView *)contentBottomView clickButtomAtIndex:(NSInteger)index {
    if (1 == index) {
        [self nextStory];
    } else if (0 == index) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - 加载上下文
/**
 *  加载下一篇文章
 */
- (void)nextStory {
    if ([self isLastStory]) {
        return;
    }
    
    if (!_isTheme) {
        if ([_appdelegate.stories containsObject:_currentStory]) {
            NSInteger index = [_appdelegate.stories indexOfObject:_currentStory];
            if (![_currentStory isEqual:_appdelegate.stories.lastObject]) {
                _currentStory = _appdelegate.stories[index + 1];
            }else {
                _currentStory = _appdelegate.oldStories[0][0];
            }
        } else {
            for (int i = 0; i < _appdelegate.oldStories.count; i++) {
                NSArray<Story *> *array = _appdelegate.oldStories[i];
                if ([array containsObject:_currentStory]) {
                    NSInteger index = [array indexOfObject:_currentStory];
                    if (index < array.count - 1) {
                        _currentStory = [array objectAtIndex:index + 1];
                        break;
                    } else {
                        _currentStory = _appdelegate.oldStories[i + 1][0];
                        // 加载到最后一天的数据时，再获取三天数据
                        if (i == _appdelegate.oldStories.count - 2) {
                            [_appdelegate loadBeforeData];
                        }
                    }
                }
            }
        }
    } else {    // 是主题的文章
        NSArray<Story *> *storys = _appdelegate.themeDetail.stories;
        NSInteger index = [storys indexOfObject:_currentStory];

        _currentStory = storys[index + 1];
            
        // 剩下三篇的时候，加载新的
        if (index > storys.count - 4) {
            [_appdelegate loadBeforeThemeData:_content.theme.identity];
        }
    }
    _refreshType = RefreshTypeNextPage;
    [self reloadData];
}

- (void)prevStory {
    if ([self isFirstStory]) {
        return;
    }
    _refreshType = RefreshTypePreviousPage;
    if (!_isTheme) {
        if ([_appdelegate.stories containsObject:_currentStory]) {
            NSInteger index = [_appdelegate.stories indexOfObject:_currentStory];
            _currentStory = _appdelegate.stories[index - 1];
        } else {
            for (int i = 0; i < _appdelegate.oldStories.count; i++) {
                NSArray<Story *> *array = _appdelegate.oldStories[i];
                if ([array containsObject:_currentStory]) {
                    NSInteger index = [array indexOfObject:_currentStory];
                    if (index > 0) {
                        _currentStory = array[index - 1];
                    } else {
                        if (i == 0) {
                            _currentStory = _appdelegate.stories.lastObject;
                        } else {
                            _currentStory = [_appdelegate.oldStories[i - 1] lastObject];
                        }
                    }
                    break;
                }
            }
        }
    } else {
        NSInteger index = [_appdelegate.themeDetail.stories indexOfObject:_currentStory];
        _currentStory = _appdelegate.themeDetail.stories[index - 1];
        NSLog(@"%ld", [_appdelegate.themeDetail.stories indexOfObject:_currentStory]);
    }
    [self reloadData];
}

/**
 *  判断是否第一篇文章
 */
- (BOOL)isFirstStory {
    if (!_isTheme) {
        if ([_currentStory isEqual:_appdelegate.stories.firstObject]) {
            return YES;
        }
    } else {
        if ([_currentStory isEqual:_appdelegate.themeDetail.stories.firstObject]) {
            return YES;
        }
    }
    return NO;
}

/**
 *  判断是否最后一篇文章
 */
- (BOOL)isLastStory {
    if (!_isTheme) {
        if ([_currentStory isEqual:[_appdelegate.oldStories.lastObject lastObject]]) {
            return YES;
        }
    } else {
        if ([_currentStory isEqual:_appdelegate.themeDetail.stories.lastObject]) {
            return YES;
        }
    }
    return NO;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [_headView layoutHeaderViewWhenScroll:scrollView.contentOffset];
    
    [self.mainView.scrollView bringSubviewToFront:_upArrow];
    [self.mainView.scrollView bringSubviewToFront:_upLabel];
    
    if (_headView != nil) {
        if (scrollView.contentOffset.y > _headView.frame.size.height - 20) {
            self.statusBarFlag = NO;
        } else {
            self.statusBarFlag = YES;
        }
    }
    if (_isDraging) {
        // 下拉
        // 不添加这个判断会导致上下拉相互影响其标志位
        if (scrollView.contentOffset.y < 0) {
            if (scrollView.contentOffset.y < - 100) {
                CGAffineTransform transform = CGAffineTransformMakeRotation(M_PI);
                _shouldRefresh = YES;
                [UIView animateWithDuration:0.2 animations:^{
                    _upArrow.transform = transform;
                }];
            } else {
                _shouldRefresh = NO;
                [UIView animateWithDuration:0.2 animations:^{
                    _upArrow.transform = CGAffineTransformIdentity;
                }];
            }
        } else {    // 上拉
            if (scrollView.contentOffset.y > scrollView.contentSize.height - scrollView.frame.size.height + 60) {
                [UIView animateWithDuration:0.2 animations:^{
                    _downArrow.transform = CGAffineTransformIdentity;
                    _shouldRefresh = YES;
                }];
            } else {
                [UIView animateWithDuration:0.2 animations:^{
                    _downArrow.transform = CGAffineTransformMakeRotation(M_PI);
                    _shouldRefresh = NO;
                }];
            }
        }
    }
    if (!_isDraging && _shouldRefresh) {
        _shouldRefresh = false;
        if (![self isFirstStory] && scrollView.contentOffset.y < 0) {
            [self prevStory];
        } else if (![self isLastStory] && scrollView.contentOffset.y > 0) {
            [self nextStory];
        }
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    _isDraging = YES;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    _isDraging = NO;
}

@end