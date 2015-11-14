//
//  HomeTableViewCell.h
//  ZhihuDaily0.2
//
//  Created by Gargit on 15/11/9313.
//  Copyright © 2015年 Gargit. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kHomeTableViewCellID @"HomeTableViewCellID"

@class Story;

@interface HomeTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *coverImageView;
@property (weak, nonatomic) IBOutlet UIImageView *homeMorePic;

- (void)loadStory:(Story *)story;

@end
