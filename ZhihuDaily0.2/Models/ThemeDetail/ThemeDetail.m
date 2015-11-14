//
//  ThemeDetail.m
//  ZhihuDaily0.2
//
//  Created by Gargit on 15/11/13317.
//  Copyright © 2015年 Gargit. All rights reserved.
//

#import "ThemeDetail.h"
#import "Story.h"

@implementation Editor

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        [self setValuesForKeysWithDictionary:dict];
    }
    return self;
}

+ (instancetype)editorWithDictionary:(NSDictionary *)dict {
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

@implementation ThemeDetail

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        [self setValuesForKeysWithDictionary:dict];
    }
    return self;
}

+ (instancetype)themeDetailWithDictionary:(NSDictionary *)dict {
    return [[self alloc] initWithDictionary:dict];
}

- (void)setValue:(id)value forKey:(NSString *)key {
    if ([key isEqualToString:@"stories"]) {
        for (NSDictionary *dict in value) {
            [self.stories addObject:[Story storyWithDictionary:dict]];
        }
    } else if ([key isEqualToString:@"editors"]) {
        for (NSDictionary *dict in value) {
            [self.editors addObject:[Editor editorWithDictionary:dict]];
        }
    } else {
        [super setValue:value forKey:key];
    }
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    if ([key isEqualToString:@"description"]) {
        self.desc = value;
    }
}

- (id)valueForUndefinedKey:(NSString *)key {
    return nil;
}

- (NSMutableArray<Story *> *)stories {
    if (_stories == nil) {
        _stories = [[NSMutableArray alloc] init];
    }
    return _stories;
}

- (NSMutableArray<Editor *> *)editors {
    if (_editors == nil) {
        _editors = [[NSMutableArray alloc] init];
    }
    return _editors;
}

@end
