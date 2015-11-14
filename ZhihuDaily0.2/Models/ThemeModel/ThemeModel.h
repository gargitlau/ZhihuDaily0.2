//
//  ThemeModel.h
//  ZhihuDaily0.2
//
//  Created by Gargit on 15/11/12316.
//  Copyright © 2015年 Gargit. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ThemeModel : NSObject

@property (nonatomic, copy) NSNumber *color;
@property (nonatomic, copy) NSString *thumbnail;
@property (nonatomic, copy) NSString *desc;
@property (nonatomic, copy) NSNumber *identity;
@property (nonatomic, copy) NSString *name;

- (instancetype)initWithDictionary:(NSDictionary *)dict;

+ (instancetype)themeWithDictionary:(NSDictionary *)dict;

@end
