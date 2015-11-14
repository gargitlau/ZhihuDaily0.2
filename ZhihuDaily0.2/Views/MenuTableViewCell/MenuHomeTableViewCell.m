//
//  MenuHomeTableViewCell.m
//  ZhihuDaily0.2
//
//  Created by Gargit on 15/11/12316.
//  Copyright © 2015年 Gargit. All rights reserved.
//

#import "MenuHomeTableViewCell.h"

@interface MenuHomeTableViewCell()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;

@end

@implementation MenuHomeTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    self.highLighted = selected;
}

- (void)setHighLighted:(BOOL)highLighted {
    _highLighted = highLighted;
    if (highLighted) {
        self.contentView.backgroundColor = [UIColor colorWithRed:0.1 green:0.13 blue:0.16 alpha:1];
        self.iconImageView.highlighted = YES;
        self.titleLabel.textColor = [UIColor whiteColor];
    } else {
        self.contentView.backgroundColor = [UIColor colorWithRed:0.13 green:0.16 blue:0.2 alpha:1];
        self.iconImageView.highlighted = NO;
        self.titleLabel.textColor = [UIColor lightGrayColor];
    }
}

@end
