//
//  ThemeTableViewController.m
//  ZhihuDaily0.2
//
//  Created by Gargit on 15/11/13317.
//  Copyright © 2015年 Gargit. All rights reserved.
//

#import "ThemeTableViewController.h"
#import "AppDelegate.h"
#import <SWRevealViewController.h>
#import "ParallaxHeaderView.h"
#import "HomeTableViewCell.h"
#import "EditorCell.h"
#import "ThemeDetail.h"
#import <UIImageView+WebCache.h>
#import "WebContentController.h"
#import <MJRefresh.h>

@interface ThemeTableViewController ()<ParallaxHeaderViewDelegate>

@property (nonatomic, weak) AppDelegate *appDelegate;
@property (nonatomic, strong) ParallaxHeaderView *headView;
@property (nonatomic, strong)  UIImageView *headImageView;

@end

@implementation ThemeTableViewController
{
    CGRect _screenBounds;
    BOOL _isDrag;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    _appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    _screenBounds = [UIScreen mainScreen].bounds;
    _isDrag = NO;
    
    [_appDelegate loadThemeDetail:self.theme.identity];
    
    self.navigationItem.title = self.theme.name;
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor]};
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    UIBarButtonItem *leftBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Back_White"] style:UIBarButtonItemStylePlain target:[self revealViewController] action:@selector(revealToggle:)];
    self.navigationItem.leftBarButtonItem = leftBtn;
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"EditorCell" bundle:nil] forCellReuseIdentifier:kEditorCellID];
    [self.tableView registerNib:[UINib nibWithNibName:@"HomeTableViewCell" bundle:nil] forCellReuseIdentifier:kHomeTableViewCellID];
    
    self.tableView.showsHorizontalScrollIndicator = NO;
    self.tableView.showsVerticalScrollIndicator = NO;
    
    
    _headImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, _screenBounds.size.width, 64)];
    _headImageView.contentMode = UIViewContentModeCenter;
    
    _headView = [[ParallaxHeaderView alloc] initWithSytle:ParallaxHeaderViewStyleThumb subView:_headImageView headerViewSize:_headImageView.bounds.size maxOffsetY:80 delegate:self];
    
    self.tableView.tableHeaderView = _headView;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadDatas) name:kThemeDetailGet object:nil];
    
    [self setFresh];
}

- (void)setFresh {
    __weak typeof(self) weakSelf = self;
    
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [_appDelegate loadThemeDetail:self.theme.identity];
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
    
    [_appDelegate setThemeHeaderEndRefreshBlock:^(){
        [weakSelf.tableView.mj_header endRefreshing];
        [weakSelf.tableView setContentOffset:CGPointMake(0, 0) animated:YES];
    }];
    
    self.tableView.mj_footer = [MJRefreshAutoFooter footerWithRefreshingBlock:^{
        [_appDelegate loadBeforeThemeData:self.theme.identity];
    }];
    
    [_appDelegate setThemeFooterEndRefreshBlock:^(){
        [weakSelf.tableView.mj_footer endRefreshing];
        [weakSelf.tableView reloadData];
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
}

- (void)loadDatas {
    [_headImageView sd_setImageWithURL:[NSURL URLWithString:_appDelegate.themeDetail.background]];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_appDelegate.themeDetail == nil) {
        return 0;
    }
    return _appDelegate.themeDetail.stories.count + (_appDelegate.themeDetail.editors.count > 0? 1 : 0);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_appDelegate.themeDetail.editors.count > 0) {
        if (indexPath.row == 0) {
            EditorCell *cell = [tableView dequeueReusableCellWithIdentifier:kEditorCellID forIndexPath:indexPath];
            [cell loadEditors:_appDelegate.themeDetail.editors];
            return cell;
        }
    }
    HomeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kHomeTableViewCellID forIndexPath:indexPath];
        [cell loadStory:_appDelegate.themeDetail.stories[indexPath.row - (_appDelegate.themeDetail.editors.count > 0 ? 1 : 0)]];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        if (_appDelegate.themeDetail.editors.count > 0) {
            return 50;
        }
    }
    return 100;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    WebContentController *webContentController = [[WebContentController alloc] init];
    if (_appDelegate.themeDetail.editors.count > 0) {
        if (indexPath.row == 0) {
            return;
        } else {
            webContentController.currentStory = _appDelegate.themeDetail.stories[indexPath.row - 1];
        }
    } else {
        webContentController.currentStory = _appDelegate.themeDetail.stories[indexPath.row];
    }
    
    webContentController.isTheme = YES;
    
    
    [[NSUserDefaults standardUserDefaults] setObject:@(YES) forKey:webContentController.currentStory.identity.description];
    
    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];

    
    [self.navigationController pushViewController:webContentController animated:YES];
}

#pragma mark - ParallaxHeaderViewDelegate
- (void)lockScrollView:(CGFloat)maxOffset {
    [self.tableView setContentOffset:CGPointMake(0, maxOffset) animated:NO];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.contentOffset.y < -60) {
        if (!_isDrag) {
            [self.tableView.mj_header beginRefreshing];
        }
    }
    [self.headView layoutHeaderViewWhenScroll:scrollView.contentOffset];
    
    if (scrollView.contentOffset.y > scrollView.contentSize.height - _screenBounds.size.height * 2) {
        [self.tableView.mj_footer beginRefreshing];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    _isDrag = YES;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    _isDrag = NO;
}
@end