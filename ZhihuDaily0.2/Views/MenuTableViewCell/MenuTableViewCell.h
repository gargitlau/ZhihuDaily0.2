//
//  MenuTableViewCell.h
//  ZhihuDaily0.2
//
//  Created by Gargit on 15/11/12316.
//  Copyright © 2015年 Gargit. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kMenuTableViewCellID @"MenuTableViewCellID"

@interface MenuTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (nonatomic, assign, getter=isHighLighted) BOOL highLighted;

@end
