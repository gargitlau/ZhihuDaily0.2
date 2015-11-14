//
//  StoryExtra.h
//  ZhihuDaily0.2
//
//  Created by Gargit on 15/11/12316.
//  Copyright © 2015年 Gargit. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StoryExtra : NSObject

@property (nonatomic, strong) NSNumber *long_comments;
@property (nonatomic, strong) NSNumber *popularity;
@property (nonatomic, strong) NSNumber *short_comments;
@property (nonatomic, strong) NSNumber *comments;

- (instancetype)initWithDictionary:(NSDictionary *)dict;

+ (instancetype)storyExtraWithDictionary:(NSDictionary *)dict;

@end
