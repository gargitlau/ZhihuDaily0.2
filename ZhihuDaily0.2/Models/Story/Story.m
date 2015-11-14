//
//  Story.m
//  ZhihuDaily0.2
//
//  Created by Gargit on 15/11/7311.
//  Copyright © 2015年 Gargit. All rights reserved.
//

#import "Story.h"

@implementation Story

- (instancetype)initWithDictionary:(NSDictionary *)dict
{
    self = [super init];
    if (self) {
        [self setValuesForKeysWithDictionary:dict];
    }
    return self;
}

+ (instancetype)storyWithDictionary:(NSDictionary *)dict {
    return [[self alloc] initWithDictionary:dict];
}

- (id)valueForUndefinedKey:(NSString *)key {
    return nil;
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    if ([key isEqualToString:@"id"]) {
        self.identity = value;
    }
}


@end
