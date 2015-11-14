//
//  HomeTableViewCell.m
//  ZhihuDaily0.2
//
//  Created by Gargit on 15/11/9313.
//  Copyright © 2015年 Gargit. All rights reserved.
//

#import "HomeTableViewCell.h"
#import "Story.h"
#import <UIImageView+WebCache.h>

@interface HomeTableViewCell()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *coverImageButtomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *coverImageTopConstraint;
@end

@implementation HomeTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)loadStory:(Story *)story {
    self.titleLabel.text = story.title;
    if ([[NSUserDefaults standardUserDefaults] objectForKey:story.identity.description]) {
        self.titleLabel.textColor = [UIColor lightGrayColor];
    } else {
        self.titleLabel.textColor = [UIColor blackColor];
    }
    
    if (story.images.count > 0) {
        _coverImageButtomConstraint.constant = _coverImageTopConstraint.constant;
        [self.coverImageView sd_setImageWithURL:[NSURL URLWithString:[story.images firstObject]]];
        if (story.multipic) {
            self.homeMorePic.hidden = NO;
        } else {
            self.homeMorePic.hidden = YES;
        }
    } else {
        _coverImageButtomConstraint.constant = _coverImageButtomConstraint.constant + self.coverImageView.frame.size.height - 1;
        self.homeMorePic.hidden = YES;
    }
    
    
}

@end
