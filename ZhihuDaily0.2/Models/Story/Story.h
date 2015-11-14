//
//  Story.h
//  ZhihuDaily0.2
//
//  Created by Gargit on 15/11/7311.
//  Copyright © 2015年 Gargit. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Story : NSObject

@property (nonatomic, strong) NSArray *images;
@property (nonatomic, copy) NSString *image;
@property (nonatomic, copy) NSNumber *type;
@property (nonatomic, assign) BOOL multipic;
@property (nonatomic, copy) NSNumber *identity;
@property (nonatomic, copy) NSString *ga_prefix;
@property (nonatomic, copy) NSString *title;

- (instancetype)initWithDictionary:(NSDictionary *)dict;

+ (instancetype)storyWithDictionary:(NSDictionary *)dict;

@end
