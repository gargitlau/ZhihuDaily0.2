//
//  RecommenderView.h
//  ZhihuDaily0.2
//
//  Created by Gargit on 15/11/11315.
//  Copyright © 2015年 Gargit. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RecommenderView : UIView

@property (weak, nonatomic) IBOutlet UIView *avaterView;

- (void)loadRecommenders:(NSArray *)recommenders;

@end
