//
//  ParallaxHeaderView.m
//  UITableViewHeader
//
//  Created by Gargit on 15/11/6310.
//  Copyright © 2015年 Gargit. All rights reserved.
//

#import "ParallaxHeaderView.h"

static CGFloat defaultBlurViewAlpha = 0.5;

@interface ParallaxHeaderView()

// 模糊效果View
@property (nonatomic, strong) UIVisualEffectView *blurView;

@property (nonatomic, assign) ParallaxHeaderViewStyle style;

@end

@implementation ParallaxHeaderView
{
    CGSize _originSize;
}

- (instancetype)initWithSytle:(ParallaxHeaderViewStyle)style subView:(UIView *)subView headerViewSize:(CGSize)size maxOffsetY:(CGFloat)maxOffsetY delegate:(id<ParallaxHeaderViewDelegate>)delegate {
    self = [super initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    
    if (self) {
        self.subView = subView;
        self.maxOffsetY = maxOffsetY < 0 ? maxOffsetY : -maxOffsetY;
        self.delegate = delegate;
        self.style = style;
        
        _originSize = size;
        
        subView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        
        self.clipsToBounds = NO;
        self.contentView = [[UIScrollView alloc] initWithFrame:self.bounds];
        
        [self.contentView addSubview:subView];
        self.contentView.clipsToBounds = YES;
        
        [self addSubview:self.contentView];
        
        [self setupStyle];
    }
    return self;
}

- (void)setupStyle {
    switch (self.style) {
        case ParallaxHeaderViewStyleDefault:
            break;
        case ParallaxHeaderViewStyleThumb:
            self.blurView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
            self.blurView.alpha = defaultBlurViewAlpha;
            self.blurView.frame = self.subView.frame;
            self.blurView.autoresizingMask = self.subView.autoresizingMask;
            
            [self.contentView addSubview:self.blurView];
            break;
        default:
            break;
    }
}

- (void)layoutHeaderViewWhenScroll:(CGPoint)offset {
    CGFloat delta = offset.y;
    
    if (delta < self.maxOffsetY) {
        [self.delegate lockScrollView:self.maxOffsetY];
    }
    else if (self.style == ParallaxHeaderViewStyleDefault){
        [self layoutDefaultViewWhenScroll:delta];
    } else if (self.style == ParallaxHeaderViewStyleThumb) {
        [self layoutThumbViewWhenScroll:delta];
    }
}

- (void)layoutDefaultViewWhenScroll:(CGFloat)delta {
    CGRect rect = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
    rect.origin.y += delta;
    rect.size.height -= delta;
    self.contentView.frame = rect;
}

- (void)layoutThumbViewWhenScroll:(CGFloat)delta {
    if (delta >= 0) {
        CGRect rect = self.frame;
        rect.origin.y = delta;
        self.contentView.frame = rect;
    }
    
    if (delta <= 0) {
        CGRect rect = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
        rect.origin.y += delta;
        rect.size.height -= delta;
        self.contentView.frame = rect;
        self.blurView.alpha = defaultBlurViewAlpha - (CGFloat)(delta / self.maxOffsetY) < 0 ? 0: defaultBlurViewAlpha - (CGFloat)(delta / self.maxOffsetY);
    }
}

@end
