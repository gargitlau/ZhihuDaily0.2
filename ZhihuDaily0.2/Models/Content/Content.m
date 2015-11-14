//
//  Content.m
//  ZhihuDaily0.2
//
//  Created by Gargit on 15/11/11315.
//  Copyright © 2015年 Gargit. All rights reserved.
//

#import "Content.h"

@implementation Recommender

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    
}

- (id)valueForUndefinedKey:(NSString *)key {
    return nil;
}

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    if (self = [super init]) {
        [self setValuesForKeysWithDictionary:dict];
    }
    return self;
}

+ (instancetype)recommenderWithDictionary:(NSDictionary *)dict {
    return [[self alloc] initWithDictionary:dict];
}

@end

@implementation Theme

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    if (self = [super init]) {
        [self setValuesForKeysWithDictionary:dict];
    }
    return self;
}

+ (instancetype)themeWithDictionary:(NSDictionary *)dict {
    return [[self alloc] initWithDictionary:dict];
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    if ([key isEqualToString:@"id"]) {
        self.identity = value;
    }
}

- (id)valueForUndefinedKey:(NSString *)key {
    return nil;
}

@end

@implementation Content

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    if ([key isEqualToString:@"id"]) {
        self.identity = value;
    }
}

- (void)setValue:(id)value forKey:(NSString *)key {
    if ([key isEqualToString:@"recommenders"]) {
        for (NSDictionary *dict in value) {
            [self.recommenders addObject:[Recommender recommenderWithDictionary:dict]];
        }
    } else if ([key isEqualToString:@"theme"]) {
        self.theme = [Theme themeWithDictionary:value];
    } else {
        [super setValue:value forKey:key];
    }
}

- (NSMutableArray *)recommenders {
    if (_recommenders == nil) {
        _recommenders = [[NSMutableArray alloc] init];
    }
    return _recommenders;
}

- (id)valueForUndefinedKey:(NSString *)key {
    return nil;
}

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    if (self = [super init]) {
        [self setValuesForKeysWithDictionary:dict];
    }
    return self;
}

+ (instancetype)contentWithDictionary:(NSDictionary *)dict {
    return [[self alloc] initWithDictionary:dict];
}

@end
