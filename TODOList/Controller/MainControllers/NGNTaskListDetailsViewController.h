//
//  NGNTaskListDetailsViewController.h
//  TODOList
//
//  Created by Alex on 12.06.17.
//  Copyright © 2017 Alex. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "NGNAbstractTableViewController.h"

@class NGNManagedTaskList;

@interface NGNTaskListDetailsViewController: NGNAbstractTableViewController

@property (strong, nonatomic) NGNManagedTaskList *entringTaskList;

@end
