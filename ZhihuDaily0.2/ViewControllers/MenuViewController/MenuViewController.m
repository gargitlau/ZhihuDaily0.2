//
//  MenuViewController.m
//  ZhihuDaily0.2
//
//  Created by Gargit on 15/11/12316.
//  Copyright © 2015年 Gargit. All rights reserved.
//

#import "MenuViewController.h"
#import "MenuHomeTableViewCell.h"
#import "MenuTableViewCell.h"
#import "AppDelegate.h"
#import "ThemeModel.h"
#import <SWRevealViewController.h>
#import "KKNavigationController.h"
#import "HomeTableViewController.h"
#import "ThemeTableViewController.h"

@interface MenuViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *avater;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, weak) AppDelegate *appdelegate;
@end

@implementation MenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _appdelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    // 头像改为圆角
    _avater.layer.cornerRadius = _avater.frame.size.width / 2;
    _avater.layer.masksToBounds = YES;
    
    // 注册Cell
    [_tableView registerNib:[UINib nibWithNibName:@"MenuHomeTableViewCell" bundle:nil] forCellReuseIdentifier:kMenuHomeTableViewCellID];
    [_tableView registerNib:[UINib nibWithNibName:@"MenuTableViewCell" bundle:nil] forCellReuseIdentifier:kMenuTableViewCellID];
    
    _tableView.rowHeight = 60;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getData) name:kThemeDataGet object:nil];
}

- (void)getData {

    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource, UITableViewDelegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        MenuHomeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kMenuHomeTableViewCellID forIndexPath:indexPath];
        [tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
        return cell;
    }
    MenuTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kMenuTableViewCellID forIndexPath:indexPath];
    cell.titleLabel.text = [(ThemeModel *)_appdelegate.themeList[indexPath.row - 1] name];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _appdelegate.themeList.count + 1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        HomeTableViewController *homeTableVC = [[HomeTableViewController alloc] init];
        
        KKNavigationController *navigation = [[KKNavigationController alloc] initWithRootViewController:homeTableVC];
        [self.revealViewController pushFrontViewController:navigation animated:YES];
    } else {
        ThemeTableViewController * themeTableVC = [[ThemeTableViewController alloc] init];
        themeTableVC.theme = _appdelegate.themeList[indexPath.row - 1];
        KKNavigationController *navigation = [[KKNavigationController alloc] initWithRootViewController:themeTableVC];
        [self.revealViewController pushFrontViewController:navigation animated:YES];
    }
}

@end
