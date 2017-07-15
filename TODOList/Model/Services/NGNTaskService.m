//
//  NGNTaskService.m
//  TODOList
//
//  Created by Alex on 02.06.17.
//  Copyright © 2017 Alex. All rights reserved.
//
#import <CoreData/CoreData.h>

#import "NGNTaskService.h"
#import "NSDate+NGNDateToStringConverter.h"
#import "NGNConstants.h"
#import "AppDelegate.h"
#import "NGNManagedTask+CoreDataProperties.h"
#import "NGNManagedTaskList+CoreDataProperties.h"

@interface NGNTaskService ()

@property (strong, nonatomic, readwrite) NSMutableArray<NGNManagedTaskList *> *privateEntityCollection;
@property (readwrite, strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end

@implementation NGNTaskService

+ (instancetype)sharedInstance {
    static NGNTaskService *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[NGNTaskService alloc] init];
        [sharedInstance loadCollection];
        if (!sharedInstance.privateEntityCollection || sharedInstance.privateEntityCollection.count == 0) {
            NGNManagedTaskList *inboxTaskList =
            [NSEntityDescription insertNewObjectForEntityForName:@"NGNManagedTaskList"
                                          inManagedObjectContext:sharedInstance.managedObjectContext];
            inboxTaskList.entityId = 999;
            inboxTaskList.name = @"Inbox";
            [sharedInstance addEntity:inboxTaskList];
        }
        NSLog(@"%ld", [sharedInstance.entityCollection count]);
    });
    return sharedInstance;
}

- (NSMutableArray *)privateEntityCollection {
    [self loadCollection];
    return _privateEntityCollection;
}

- (NSArray *)entityCollection {
    return [[self privateEntityCollection] copy];
}

- (NSManagedObjectContext *)managedObjectContext {
    if (!_managedObjectContext) {
        _managedObjectContext = ((AppDelegate*)UIApplication.sharedApplication.delegate).managedObjectContext;
    }
    return _managedObjectContext;
}

@end

@implementation NGNTaskService(NGNCollectionMaintenance)

- (NSArray *)allTasks {
    NSArray *unitedArray = [self.entityCollection valueForKeyPath:@"@unionOfArrays.self.entityCollection"];
    return unitedArray;
}

- (NSArray *)allActiveTasks {
    NSArray *activeTasks = [[self allTasks] filteredArrayUsingPredicate:
                            [NSPredicate predicateWithFormat:@"SELF.completed == NO"]];
    return activeTasks;
}

- (NSArray *)allCompletedTasks {
    NSArray *completedTasks = [[self allTasks] filteredArrayUsingPredicate:
                               [NSPredicate predicateWithFormat:@"SELF.completed == YES"]];
    return completedTasks;
}

- (NSArray *)allActiveTasksGroupedByStartDate {
    NSMutableArray *groupedByStartDateTasks = [[NSMutableArray alloc] init];
    NSMutableArray *stringfiedDatesArray = [[NSMutableArray alloc] init];
    for (NGNManagedTask *task in [self allActiveTasks]) {
        NSString *stringfiedDate = [NSDate ngn_formattedStringFromDate:task.startedAt
                                                            withFormat:NGNModelDateFormatForComparison];
        [stringfiedDatesArray addObject:stringfiedDate];
    }
    stringfiedDatesArray = [stringfiedDatesArray valueForKeyPath:@"@distinctUnionOfObjects.self"];
    for (int i = 0; i < stringfiedDatesArray.count; i++) {
        NSPredicate *predicate =
        [NSPredicate predicateWithFormat:@"SELF.startedAt.description contains[cd] %@", stringfiedDatesArray[i]];
        NSArray<NGNManagedTask *> *currentStartDateTasks =
        [[self allActiveTasks] filteredArrayUsingPredicate:predicate];
        [groupedByStartDateTasks addObject:[currentStartDateTasks mutableCopy]];
    }
    return groupedByStartDateTasks;
}

- (NSArray *)allActiveTaskLists {
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(NGNManagedTaskList *taskList, NSDictionary *bind) {
        return (taskList.entityCollection.count != 0) && ([taskList activeTasksList].count != 0);
    }];
    return [self.privateEntityCollection filteredArrayUsingPredicate:predicate];
}

- (void)removeTask:(NGNManagedTask *)taskToRemove {
    for (NGNManagedTaskList *list in self.entityCollection) {
        NSLog(@"%@", list.name);
        if ([list.entityCollection containsObject:taskToRemove]) {
            [list removeEntityCollectionObject:taskToRemove];
            [self.managedObjectContext deleteObject:taskToRemove];
            break;
        }
    }
    [self saveCollection];
}

- (void)saveCollection {
    [((AppDelegate*)UIApplication.sharedApplication.delegate) saveContext];
}

- (void)loadCollection {
    if (!_managedObjectContext) {
        [self managedObjectContext];
    }
    NSFetchRequest<NGNManagedTaskList *> *fetchRequest = [NGNManagedTaskList fetchRequest];
    
    NSError *error = nil;
    if (![self.managedObjectContext executeFetchRequest:fetchRequest error:&error]) {
        NSLog(@"Unresolved error %@, %@", error, error.userInfo);
#warning do not use abort() in release!!! For debug only!!! Handle this error!!!
        abort();
    } else {
        self.privateEntityCollection =
            [[self.managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
    }
}

@end

@implementation NGNTaskService(NGNContainable)

- (NGNManagedTaskList *)entityById:(NSInteger)entityId {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"NGNManagedTaskList"];
    request.predicate = [NSPredicate predicateWithFormat:@"SELF.entityId == %dl", entityId];
    NSError *error = nil;
    NGNManagedTaskList *taskList = nil;
    if (![self.managedObjectContext executeRequest:request error:&error]) {
        NSLog(@"Unresolved error %@, %@", error, error.userInfo);
#warning do not use abort() in release!!! For debug only!!! Handle this error!!!
        abort();
    } else {
        taskList = [[self.managedObjectContext executeFetchRequest:request
                                                             error:nil] lastObject];
    }
    return taskList;
}

- (void)addEntity:(NGNManagedTaskList *)entity {
    [self.managedObjectContext insertObject:entity];
    [self saveCollection];
}

- (void)removeEntity:(NGNManagedTaskList *)entity {
    [self.managedObjectContext deleteObject:entity];
    [self saveCollection];
}

- (void)updateEntity:(NGNManagedTaskList *)entity {
    NGNManagedTaskList *oldEntity = [self entityById:entity.entityId];
    if (oldEntity) {
        self.privateEntityCollection[[self.entityCollection indexOfObject:oldEntity]] = entity;
    }
    [self saveCollection];
}

- (void)removeEntityById:(NSInteger)entityId {
    NGNManagedTaskList *taskToRemove = [self entityById:entityId];
    [self removeEntity:taskToRemove];
}

- (void)sortEntityCollectionUsingComparator:(NSComparator NS_NOESCAPE)cmptr {
    [_privateEntityCollection sortUsingComparator:cmptr];
    NSMutableOrderedSet *set = [[NSMutableOrderedSet alloc] init];
    [set sortUsingComparator:cmptr];
    [self saveCollection];
}

@end
