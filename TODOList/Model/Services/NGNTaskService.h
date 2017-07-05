//
//  NGNTaskService.h
//  TODOList
//
//  Created by Alex on 02.06.17.
//  Copyright © 2017 Alex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NGNContainable.h"

@class NGNTask;
@class NGNTaskList;

@interface NGNTaskService: NSObject <NGNContainable>

@property (strong, nonatomic, readwrite) NSMutableArray<id<NGNStoreable>> *entityCollection;

+ (instancetype)sharedInstance;

- (NSArray *)allTasks;
- (NSArray *)allActiveTasks;
- (NSArray *)allCompletedTasks;
- (NSArray *)allActiveTasksGroupedByStartDate;
- (NSArray *)allActiveTaskLists;
- (void)removeTask:(NGNTask *)taskToRemove;
- (void)updateTask:(NGNTask *)taskToUpdate;

@end

@interface NGNTaskService (NGNSerializableContainer)

- (void)saveCollection;
- (void)loadCollection;
- (NSString *)filePath;

@end
