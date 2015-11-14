//
//  ContentCoverView.h
//  ZhihuDaily0.2
//
//  Created by Gargit on 15/11/11315.
//  Copyright © 2015年 Gargit. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ContentCoverView : UIView

@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UILabel *image_sourceLabel;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;

- (instancetype)initWithFrame:(CGRect)frame maxOffset:(CGFloat)maxOffset;

@end
