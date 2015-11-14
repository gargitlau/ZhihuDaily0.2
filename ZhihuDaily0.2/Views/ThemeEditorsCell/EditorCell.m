//
//  EditorCell.m
//  ZhihuDaily0.2
//
//  Created by Gargit on 15/11/13317.
//  Copyright © 2015年 Gargit. All rights reserved.
//

#import "EditorCell.h"
#import "ThemeDetail.h"
#import <UIImageView+WebCache.h>

@interface EditorCell()

@property (weak, nonatomic) IBOutlet UIView *editorsView;

@end

@implementation EditorCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)loadEditors:(NSArray<Editor *> *)editors {
    for (int i = 0; i < editors.count; i++) {
        UIImageView *editor = [[UIImageView alloc] initWithFrame:CGRectMake(i * 40, 0, 30, 30)];
        editor.layer.cornerRadius = 15;
        editor.layer.masksToBounds = YES;
        [editor sd_setImageWithURL:[NSURL URLWithString:editors[i].avatar]];
        [self.editorsView addSubview:editor];
    }
}

@end
