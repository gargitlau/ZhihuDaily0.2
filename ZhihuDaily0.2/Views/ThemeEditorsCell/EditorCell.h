//
//  EditorCell.h
//  ZhihuDaily0.2
//
//  Created by Gargit on 15/11/13317.
//  Copyright © 2015年 Gargit. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kEditorCellID @"EditorCellID"

@class Editor;

@interface EditorCell : UITableViewCell

- (void)loadEditors:(NSArray<Editor *> *)editors;

@end
