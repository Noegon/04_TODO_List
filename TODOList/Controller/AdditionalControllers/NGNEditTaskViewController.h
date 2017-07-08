//
//  NGNEditTaskViewController.h
//  TODOList
//
//  Created by Alex on 11.06.17.
//  Copyright © 2017 Alex. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NGNManagedTask;
@class NGNManagedTaskList;

@interface NGNEditTaskViewController : UITableViewController

@property (strong, nonatomic) NGNManagedTask *entringTask;
@property (strong, nonatomic) NGNManagedTaskList *entringTaskList;

@end
