//
//  NGNTaskService.h
//  TODOList
//
//  Created by Alex on 02.06.17.
//  Copyright © 2017 Alex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NGNCommonEntityContainer.h"

@class NGNTask;
@class NGNTaskList;

@interface NGNTaskService : NGNCommonEntityContainer

+ (instancetype)sharedInstance;

- (NSArray *)allTasks;
- (NSArray *)allActiveTasks;
- (NSMutableArray *)allActiveTasksGroupedByStartDate;
- (void)removeTask:(NGNTask *)taskToRemove;

@end
