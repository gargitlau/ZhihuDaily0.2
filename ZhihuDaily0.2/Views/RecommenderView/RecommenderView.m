//
//  RecommenderView.m
//  ZhihuDaily0.2
//
//  Created by Gargit on 15/11/11315.
//  Copyright © 2015年 Gargit. All rights reserved.
//

#import "RecommenderView.h"
#import "Content.h"
#import <UIImageView+WebCache.h>

@implementation RecommenderView

- (void)loadRecommenders:(NSArray *)recommenders {
    [self.avaterView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromSuperview];
    }];
    for (int i = 0; i < recommenders.count; i++) {
        UIImageView *avatar = [[UIImageView alloc] initWithFrame:CGRectMake(i * 40, 0, 30, 30)];
        avatar.layer.cornerRadius = 15;
        avatar.layer.masksToBounds = YES;
        [avatar sd_setImageWithURL:[NSURL URLWithString:[(Recommender *)recommenders[i] avatar]]];
        [self.avaterView addSubview:avatar];
    }
}

@end
