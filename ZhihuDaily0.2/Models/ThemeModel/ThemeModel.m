//
//  ThemeModel.m
//  ZhihuDaily0.2
//
//  Created by Gargit on 15/11/12316.
//  Copyright © 2015年 Gargit. All rights reserved.
//

#import "ThemeModel.h"

@implementation ThemeModel

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    if (self) {
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
    } else if ([key isEqualToString:@"description"]) {
        self.desc = value;
    }
}

- (id)valueForUndefinedKey:(NSString *)key {
    return nil;
}

@end
