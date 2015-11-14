//
//  ContentBottomView.h
//  ZhihuDaily0.2
//
//  Created by Gargit on 15/11/11315.
//  Copyright © 2015年 Gargit. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ContentBottomView;

@protocol ContentBottomViewDelegate <NSObject>

- (void)ContentBottomView:(ContentBottomView *)contentBottomView clickButtomAtIndex:(NSInteger)index;

@end

@interface ContentBottomView : UIView

@property (weak, nonatomic) IBOutlet UILabel *commentLabel;
@property (weak, nonatomic) IBOutlet UILabel *voteNumberLabel;

@property (nonatomic, weak) id<ContentBottomViewDelegate> delegate;

@end
