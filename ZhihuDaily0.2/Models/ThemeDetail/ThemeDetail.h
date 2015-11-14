//
//  ThemeDetail.h
//  ZhihuDaily0.2
//
//  Created by Gargit on 15/11/13317.
//  Copyright © 2015年 Gargit. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Story;

@interface Editor : NSObject

@property (nonatomic, copy) NSString *url;
@property (nonatomic, copy) NSString *bio;
@property (nonatomic, strong) NSNumber *identity;
@property (nonatomic, copy) NSString *avatar;
@property (nonatomic, copy) NSString *name;

- (instancetype)initWithDictionary:(NSDictionary *)dict;

+ (instancetype)editorWithDictionary:(NSDictionary *)dict;

@end

@interface ThemeDetail : NSObject

@property (nonatomic, strong) NSMutableArray<Story *> *stories;
@property (nonatomic, copy) NSString *desc;
@property (nonatomic, copy) NSString *background;
@property (nonatomic, strong) NSNumber *color;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *image;
@property (nonatomic, strong) NSMutableArray<Editor *> *editors;
@property (nonatomic, copy) NSString *image_source;

- (instancetype)initWithDictionary:(NSDictionary *)dict;

+ (instancetype)themeDetailWithDictionary:(NSDictionary *)dict;

@end
