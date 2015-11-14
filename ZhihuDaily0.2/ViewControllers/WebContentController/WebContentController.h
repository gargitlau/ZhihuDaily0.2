//
//  WebContentController.h
//  ZhihuDaily0.2
//
//  Created by Gargit on 15/11/10314.
//  Copyright © 2015年 Gargit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Story.h"
#import "HomeTableViewController.h"

@interface WebContentController : UIViewController

@property (nonatomic, strong) Story *currentStory;
@property (nonatomic, assign) BOOL isTheme;

@end