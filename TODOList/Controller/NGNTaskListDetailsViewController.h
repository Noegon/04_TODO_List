//
//  NGNTaskListDetailsViewController.h
//  TODOList
//
//  Created by Alex on 12.06.17.
//  Copyright © 2017 Alex. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NGNTaskList;

@interface NGNTaskListDetailsViewController : UITableViewController

@property (strong, nonatomic) NGNTaskList *entringTaskList;

@end
