//
//  ContentCoverView.m
//  ZhihuDaily0.2
//
//  Created by Gargit on 15/11/11315.
//  Copyright © 2015年 Gargit. All rights reserved.
//

#import "ContentCoverView.h"
#import "GradientView.h"

@interface ContentCoverView()

@property (nonatomic, strong) GradientView *blur;

@end

@implementation ContentCoverView

- (instancetype)initWithFrame:(CGRect)frame maxOffset:(CGFloat)maxOffset
{
    self = [[[NSBundle mainBundle] loadNibNamed:@"ContentCoverView" owner:nil options:nil] firstObject];
    if (self) {
        self.frame = frame;
        self.clipsToBounds = NO;
        self.imageView = [UIImageView new];
        self.imageView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height + maxOffset);
        self.imageView.center = CGPointMake(frame.size.width / 2, frame.size.height / 2);
        [self addSubview:self.imageView];
        [self insertSubview:self.imageView atIndex:0];
        
        _blur = [[GradientView alloc] initWithFrame:CGRectMake(0, frame.size.height / 2, frame.size.width, frame.size.height / 2) type:TRANSPARENT_ANOTHER_GRADIENT_TYPE];
        [self insertSubview:_blur aboveSubview:self.imageView];
        
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.imageView.center = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2);
    _blur.frame = CGRectMake(0, self.frame.size.height - _blur.frame.size.height, _blur.frame.size.width, _blur.frame.size.height);
}

@end
