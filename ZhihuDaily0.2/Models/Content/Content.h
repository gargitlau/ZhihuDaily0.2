//
//  Content.h
//  ZhihuDaily0.2
//
//  Created by Gargit on 15/11/11315.
//  Copyright © 2015年 Gargit. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Recommender : NSObject

@property (nonatomic, copy) NSString *avatar;

- (instancetype)initWithDictionary:(NSDictionary *)dict;

+ (instancetype)recommenderWithDictionary:(NSDictionary *)dict;

@end

@interface Theme : NSObject

@property (nonatomic, copy) NSString *thumbnail;
@property (nonatomic, copy) NSNumber *identity;
@property (nonatomic, copy) NSString *name;

- (instancetype)initWithDictionary:(NSDictionary *)dict;

+ (instancetype)themeWithDictionary:(NSDictionary *)dict;

@end

@interface Content : NSObject

@property (nonatomic, copy) NSString *body;
@property (nonatomic, copy) NSString *image_source;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *image;
@property (nonatomic, copy) NSString *share_url;
@property (nonatomic, strong) NSMutableArray *recommenders;
@property (nonatomic, copy) NSString *ga_prefix;
@property (nonatomic, copy) NSNumber *type;
@property (nonatomic, strong) Theme *theme;
@property (nonatomic, copy) NSNumber *identity;
@property (nonatomic, strong) NSMutableArray *css;

- (instancetype)initWithDictionary:(NSDictionary *)dict;

+ (instancetype)contentWithDictionary:(NSDictionary *)dict;

@end
