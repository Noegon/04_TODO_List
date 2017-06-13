//
//  NGNTaskDetailsViewController.h
//  TODOList
//
//  Created by Alex on 04.06.17.
//  Copyright © 2017 Alex. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NGNTask;
@class NGNTaskList;

@interface NGNTaskDetailsViewController : UITableViewController

@property (strong, nonatomic) NGNTask *entringTask;
@property (strong, nonatomic) NGNTaskList *entringTaskList;

@end
