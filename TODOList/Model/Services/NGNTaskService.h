//
//  NGNTaskService.h
//  TODOList
//
//  Created by Alex on 02.06.17.
//  Copyright © 2017 Alex. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NGNManagedTask;
@class NGNManagedTaskList;
@class NSManagedObjectContext;

@interface NGNTaskService: NSObject

@property (strong, nonatomic, readwrite) NSMutableArray<NGNManagedTaskList *> *entityCollection;

#pragma mark - core data maintanance
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;

+ (instancetype)sharedInstance;

@end

@interface NGNTaskService (NGNCollectionMaintenance)

- (NSArray *)allTasks;
- (NSArray *)allActiveTasks;
- (NSArray *)allCompletedTasks;
- (NSArray *)allActiveTasksGroupedByStartDate;
- (NSArray *)allActiveTaskLists;
- (void)removeTask:(NGNManagedTask *)taskToRemove;
- (void)saveCollection;
- (void)loadCollection;

@end

@interface NGNTaskService (NGNContainable)

- (NGNManagedTaskList *)entityById:(NSInteger)entityId;
- (void)addEntity:(NGNManagedTaskList *)entity;
- (void)removeEntity:(NGNManagedTaskList *)entity;
- (void)updateEntity:(NGNManagedTaskList *)entity;
- (void)removeEntityById:(NSInteger)entityId;
- (void)sortEntityCollectionUsingComparator:(NSComparator NS_NOESCAPE)cmptr;

@end
