//
//  StoryExtra.m
//  ZhihuDaily0.2
//
//  Created by Gargit on 15/11/12316.
//  Copyright © 2015年 Gargit. All rights reserved.
//

#import "StoryExtra.h"

@implementation StoryExtra

- (instancetype)initWithDictionary:(NSDictionary *)dict
{
    self = [super init];
    if (self) {
        [self setValuesForKeysWithDictionary:dict];
    }
    return self;
}

+ (instancetype)storyExtraWithDictionary:(NSDictionary *)dict {
    return [[self alloc] initWithDictionary:dict];
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    
}

- (id)valueForUndefinedKey:(NSString *)key {
    return nil;
}

@end
