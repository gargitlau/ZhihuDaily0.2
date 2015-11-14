//
//  ParallaxHeaderView.h
//  UITableViewHeader
//
//  Created by Gargit on 15/11/6310.
//  Copyright © 2015年 Gargit. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ParallaxHeaderViewDelegate <NSObject>

@required

- (void)lockScrollView:(CGFloat)maxOffset;

@end

typedef enum {
    ParallaxHeaderViewStyleDefault = 0,
    ParallaxHeaderViewStyleThumb
}ParallaxHeaderViewStyle;

@interface ParallaxHeaderView : UIView

@property (nonatomic, strong) UIView *subView;
@property (nonatomic, strong) UIScrollView *contentView;
// 最大的下拉限度
@property (nonatomic, assign) CGFloat maxOffsetY;
// 代理
@property (nonatomic, weak) id<ParallaxHeaderViewDelegate> delegate;

/**
 *  初始化
 */
- (instancetype)initWithSytle:(ParallaxHeaderViewStyle)style subView:(UIView *)subView headerViewSize:(CGSize)size maxOffsetY:(CGFloat)maxOffsetY delegate:(id<ParallaxHeaderViewDelegate>)delegate;

/**
 *  当滚动时调用该函数
 */
- (void)layoutHeaderViewWhenScroll:(CGPoint)offset;
@end
