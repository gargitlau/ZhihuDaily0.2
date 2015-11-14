//
//  ContentBottomView.m
//  ZhihuDaily0.2
//
//  Created by Gargit on 15/11/11315.
//  Copyright © 2015年 Gargit. All rights reserved.
//

#import "ContentBottomView.h"

@implementation ContentBottomView

- (IBAction)btnClick:(UIButton *)sender {
    if (self.delegate != nil) {
        if ([self.delegate respondsToSelector:@selector(ContentBottomView:clickButtomAtIndex:)]) {
            [self.delegate ContentBottomView:self clickButtomAtIndex:(sender.tag - 100)];
        }
    }
}

@end
