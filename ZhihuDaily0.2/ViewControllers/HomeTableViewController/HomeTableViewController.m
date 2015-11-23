//
//  HomeTableViewController.m
//  ZhihuDaily0.2
//
//  Created by Gargit on 15/11/7311.
//  Copyright © 2015年 Gargit. All rights reserved.
//

#import "HomeTableViewController.h"
#import "LaunchScreenViewController.h"
#import "AppDelegate.h"
#import "ParallaxHeaderView.h"
#import <UIImageView+WebCache.h>
#import "AutoCycleScrollView.h"
#import "Story.h"
#import "HomeTableViewCell.h"
#import <MJRefresh.h>
#import "WebContentController.h"
#import <SWRevealViewController.h>

@interface HomeTableViewController () <ParallaxHeaderViewDelegate, AutoCycleScrollViewDelegate>

@property (nonatomic, strong) ParallaxHeaderView *parallaxHeadView;

@property (nonatomic, strong) AutoCycleScrollView *autoCycleScrollView;

@property (nonatomic, strong) NSArray *imagesURL;

@property (nonatomic, strong) UIView *statusBarBGView;

@property (nonatomic, strong) UIView *navigationbarTitleBGView;

@property (nonatomic, strong) UIView *fakeNavigationbar;

@property (nonatomic, assign) CGRect tableViewOriginFrame;

@end

@implementation HomeTableViewController
{
    CGRect _screenBounds;
    BOOL _isLauncherAnimationCompleted;
    BOOL _isLoadData;
    AppDelegate *_appDelegate;
    UIView *_subViewControllerView;
    LaunchScreenViewController *_subViewController;
    CGFloat _hideNavigationbarTitleBGViewOffset;
    
    CGFloat _fakeNavigationbarAlpha;
    BOOL _isDraging;
    BOOL _shouldRefresh;
    
    CGFloat _orignRearViewRevealWidth;
    CGFloat _orignRearViewRevealOverdraw;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initialization];
    
    [self buildNavigationBar];
    
    [self initialViews];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateLastData) name:kTodayDataGet object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateData) name:kBeforeDataGet object:nil];
    
    if (_appDelegate.isFirstRun) {
        [self runSecondLaunchScreen];
    } else {
        _isLauncherAnimationCompleted = YES;
        [self loadData];
    }
}

/**
 *  创建一个假的导航栏。并将原来的导航栏颜色设为透明。
 */
- (void)buildNavigationBar {
    self.navigationItem.title = @"今日热闻";
    
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor]};
    
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    
    SWRevealViewController *revealVC = [self revealViewController];
    
    [revealVC panGestureRecognizer];
    [revealVC tapGestureRecognizer];
    
    _orignRearViewRevealOverdraw = revealVC.rearViewRevealOverdraw;
    _orignRearViewRevealWidth = revealVC.rearViewRevealWidth;
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"menu"] style:UIBarButtonItemStylePlain target:revealVC action:@selector(revealToggle:)];
    
    _fakeNavigationbar = [[UIView alloc] initWithFrame:CGRectMake(0, -20, _screenBounds.size.width, 64)];
    [self.navigationController.navigationBar addSubview:_fakeNavigationbar];
    
    _fakeNavigationbarAlpha = 0;
    
    // 避免遮住标题跟菜单按钮
    [self.navigationController.navigationBar insertSubview:_fakeNavigationbar atIndex:0];
    
    _statusBarBGView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _screenBounds.size.width, 20)];
    [_statusBarBGView setBackgroundColor:[UIColor colorWithRed:0.01 green:0.56 blue:0.84 alpha:1]];
    [_fakeNavigationbar addSubview:_statusBarBGView];
    
    _navigationbarTitleBGView = [[UIView alloc] initWithFrame:CGRectMake(0, 20, _screenBounds.size.width, 44)];
    [_navigationbarTitleBGView setBackgroundColor:_statusBarBGView.backgroundColor];
    [_fakeNavigationbar addSubview:_navigationbarTitleBGView];
}

/**
 *  初始化配置
 */
- (void)initialization {
    _tableViewOriginFrame = self.tableView.frame;
    
    _isLauncherAnimationCompleted = NO;
    _isLoadData = NO;
    _isDraging = NO;
    _shouldRefresh = NO;
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.showsHorizontalScrollIndicator = NO;
    
    _appDelegate = (AppDelegate *)([UIApplication sharedApplication].delegate);
    
    _screenBounds = [UIScreen mainScreen].bounds;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"HomeTableViewCell" bundle:nil] forCellReuseIdentifier:kHomeTableViewCellID];
    self.tableView.rowHeight = 100;
}

- (void)updateLastData {
    _isLoadData = YES;
    if ([_appDelegate isFirstRun]) {
        [self dismissSecondLaunchScreen];
    } else {
        [self loadData];
    }
}

- (void)updateData {
    if (_isLauncherAnimationCompleted) {
        [self loadData];
    }
}

/**
 *  加载数据
 */
- (void)loadData {
    NSMutableArray *imageURLs = [[NSMutableArray alloc] init];
    NSMutableArray *titlesArray = [[NSMutableArray alloc] init];
    
    for (Story *story in _appDelegate.topStories) {
        [imageURLs addObject:story.image];
        [titlesArray addObject:story.title];
    }
    
    [_autoCycleScrollView setImagesURLStrGroup:imageURLs];
    [_autoCycleScrollView setTitlesGroup:titlesArray];
    
    _hideNavigationbarTitleBGViewOffset = _screenBounds.size.height / 3 + 100 * _appDelegate.stories.count - 20;
    
    [self.tableView reloadData];
}

/**
 *  运行第二个启动页
 */
- (void)runSecondLaunchScreen {
    // 禁止启动页时能右滑显示菜单栏
    self.revealViewController.rearViewRevealWidth = 0;
    self.revealViewController.rearViewRevealOverdraw = 0;
    
    self.navigationController.navigationBarHidden = YES;
    self.tableView.scrollEnabled = NO;
    _subViewControllerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    
    _subViewController = [[LaunchScreenViewController alloc] initWithNibName:@"LaunchScreenViewController" bundle:nil];
    
    [self addChildViewController:_subViewController];
    
    [_subViewController.view setFrame:_screenBounds];
    
    [_subViewControllerView addSubview:_subViewController.view];
    
    self.tableView.tableHeaderView  = _subViewControllerView;
    
    [UIView animateWithDuration:2.5 animations:^{
        CGAffineTransform transform = CGAffineTransformMakeScale(1.12, 1.12);
        _subViewController.startImageView.transform = transform;
    } completion:^(BOOL finished) {
        _isLauncherAnimationCompleted = YES;
        [self dismissSecondLaunchScreen];
    }];
}

- (void)dismissSecondLaunchScreen {
    if (_isLauncherAnimationCompleted == YES && _isLoadData == YES) {
        self.revealViewController.rearViewRevealWidth = _orignRearViewRevealWidth;
        self.revealViewController.rearViewRevealOverdraw = _orignRearViewRevealOverdraw;
        [UIView animateWithDuration:0.5 animations:^{
            _subViewControllerView.alpha = 0;
        } completion:^(BOOL finished) {
            self.tableView.tableHeaderView = _parallaxHeadView;
            self.navigationController.navigationBarHidden = NO;
            _fakeNavigationbar.alpha = 0;
            _appDelegate.isFirstRun = NO;
            [_subViewControllerView removeFromSuperview];
            [_subViewController removeFromParentViewController];
            self.tableView.scrollEnabled = YES;
            
            [self loadData];
        }];
    }
}

/**
 *  创建视图
 */
- (void)initialViews {
    [self buildTableHeadView];
    
    __weak typeof(self) weakSelf = self;
    __weak typeof(_fakeNavigationbar) weakFakeNavigationbar = _fakeNavigationbar;
    
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [_appDelegate clearAllData];
        [_appDelegate loadData];
    }];
    [header setTitle:@"" forState:MJRefreshStatePulling];
    [header setTitle:@"" forState:MJRefreshStateRefreshing];
    [header setTitle:@"" forState:MJRefreshStateWillRefresh];
    header.lastUpdatedTimeLabel.hidden = YES;

    self.tableView.mj_header = header;
    
    /**
     *  隐藏刷新
     */
    [self.tableView insertSubview:self.tableView.mj_header atIndex:0];

    [_appDelegate setHeaderEndRefreshBlock:^(){
        [weakSelf.tableView.mj_header endRefreshing];
        weakFakeNavigationbar.alpha = 0;
        [weakSelf.tableView setContentOffset:CGPointMake(0, 0)];
    }];
    
    self.tableView.mj_footer = [MJRefreshAutoFooter footerWithRefreshingBlock:^{
        [_appDelegate loadBeforeData];
    }];
    
    [_appDelegate setFooterEndRefreshBlock:^(){
        [weakSelf.tableView.mj_footer endRefreshing];
    }];
}

/**
 *  创建轮播图头部
 */
- (void)buildTableHeadView {
    _autoCycleScrollView = [AutoCycleScrollView autoCycleScrollViewWithFrame:CGRectMake(0, 0, _screenBounds.size.width, _screenBounds.size.height / 3) imagesURLStringGroup:nil maxOffset:100 titlesGroup:nil];
    
    _autoCycleScrollView.delegate = self;
    
    self.parallaxHeadView = [[ParallaxHeaderView alloc] initWithSytle:ParallaxHeaderViewStyleDefault subView:_autoCycleScrollView headerViewSize:_autoCycleScrollView.bounds.size maxOffsetY:100 delegate:self];
    
    self.tableView.tableHeaderView = self.parallaxHeadView;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    _fakeNavigationbarAlpha = _fakeNavigationbar.alpha;
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (!_appDelegate.isFirstRun) {
        self.navigationController.navigationBarHidden = NO;
    }
    _fakeNavigationbar.alpha = _fakeNavigationbarAlpha;
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
}

- (NSString *)transformDateFormat:(NSString *)dateStr {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    [formatter setDateFormat:@"yyyyMMdd"];
    
    NSDate *longLongBeforeDate = [formatter dateFromString:@"20100103"];
    
    NSDate *date = [formatter dateFromString:dateStr];
    
    NSTimeInterval timeInterValSinceDate = [date timeIntervalSinceDate:longLongBeforeDate];
    
    int weekDay = (long long)timeInterValSinceDate / 3600 / 24 % 7;
    
    NSString *weekDayString;
    
    switch (weekDay) {
        case 0:
            weekDayString = @"星期日";
            break;
        case 1:
            weekDayString = @"星期一";
            break;
        case 2:
            weekDayString = @"星期二";
            break;
        case 3:
            weekDayString = @"星期三";
            break;
        case 4:
            weekDayString = @"星期四";
            break;
        case 5:
            weekDayString = @"星期五";
            break;
        case 6:
            weekDayString = @"星期六";
            break;
        default:
            break;
    }
    
    [formatter setDateFormat:@"MM月dd日"];
    NSString *formatStr = [formatter stringFromDate:date];
    
    return [NSString stringWithFormat:@"%@ %@", formatStr, weekDayString];
}

#pragma mark - ImagePlayerViewDelegate
- (NSInteger)numberOfItems {
    return self.imagesURL.count;
}

#pragma mark - ParallaxHeaderViewDelegate
- (void)lockScrollView:(CGFloat)maxOffset {
    [self.tableView setContentOffset:CGPointMake(self.tableView.contentOffset.x, maxOffset) animated:NO];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.parallaxHeadView layoutHeaderViewWhenScroll:scrollView.contentOffset];
   
    if (!_isDraging) {
        if (scrollView.contentOffset.y < - 90) {
            _shouldRefresh = YES;
        } else {
            _shouldRefresh = NO;
        }
    }
    
    if (scrollView.contentOffset.y < 0) {
        _fakeNavigationbar.alpha = 0;
    } else if (scrollView.contentOffset.y < 64) {
        _fakeNavigationbar.alpha = scrollView.contentOffset.y / 64;
    } else {
        _fakeNavigationbar.alpha = 1;
        self.automaticallyAdjustsScrollViewInsets = YES;
    }
    
    if (scrollView.contentOffset.y > _hideNavigationbarTitleBGViewOffset) {
        _navigationbarTitleBGView.hidden = YES;
        self.navigationItem.title = nil;
        self.tableView.contentInset = UIEdgeInsetsMake(20, 0, 0, 0);
    } else {
        _navigationbarTitleBGView.hidden = NO;
        self.navigationItem.title = @"今日热闻";
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    }
    
    if (scrollView.contentOffset.y > scrollView.contentSize.height - _screenBounds.size.height * 2) {
        [self.tableView.mj_footer beginRefreshing];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    _isDraging = YES;
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    _isDraging = NO;
    if (_shouldRefresh) {
        [self.tableView.mj_header beginRefreshing];
        _shouldRefresh = NO;
    }
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (0 == section) {
        return _appDelegate.stories.count;
    } else {
        return [_appDelegate.oldStories[section - 1] count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HomeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kHomeTableViewCellID forIndexPath:indexPath];
    if (0 == indexPath.section) {
        [cell loadStory:_appDelegate.stories[indexPath.row]];
    } else {
        [cell loadStory:_appDelegate.oldStories[indexPath.section - 1][indexPath.row]];
    }
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _appDelegate.oldStories.count + 1;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _screenBounds.size.width, 44)];
    
    [headView setBackgroundColor:[UIColor colorWithRed:0.01 green:0.56 blue:0.84 alpha:1]];
    
    UILabel * label = [[UILabel alloc] initWithFrame:headView.frame];
    
    label.text = [self transformDateFormat:_appDelegate.oldStoryDates[section - 1]];
    label.textAlignment = NSTextAlignmentCenter;
    [label sizeToFit];
    label.center = headView.center;
    label.textColor = [UIColor whiteColor];
    [headView addSubview:label];
    
    return headView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 0;
    } else {
        return 44;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    WebContentController *webController = [[WebContentController alloc] init];
    if (indexPath.section == 0) {
        webController.currentStory = _appDelegate.stories[indexPath.row];
    } else {
        webController.currentStory = _appDelegate.oldStories[indexPath.section - 1][indexPath.row];
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:@(YES) forKey:webController.currentStory.identity.description];
    
    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    
    [self.navigationController pushViewController:webController animated:YES];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark - AutoCycleScrollViewDelegate
- (void)autoCycleScrollView:(AutoCycleScrollView *)autoCycleScrollView didSelectedItemAtIndex:(NSInteger)index {
    WebContentController *webController = [[WebContentController alloc] init];

    for (Story *story in _appDelegate.stories) {
        if ([story.identity isEqualToNumber:[(Story *)_appDelegate.topStories[index] identity]]) {
            webController.currentStory = story;
            break;
        }
    }
    
    if (webController.currentStory == nil) {
        for (NSArray *arr in _appDelegate.oldStories) {
            for (Story *story in arr) {
                if ([story.identity isEqualToNumber:[(Story *)_appDelegate.topStories[index] identity]]) {
                    webController.currentStory = story;
                    break;
                }
            }
            if (webController.currentStory != nil) {
                break;
            }
        }
    }

    [self.navigationController pushViewController:webController animated:YES];
}
@end