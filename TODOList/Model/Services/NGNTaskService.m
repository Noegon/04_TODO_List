//
//  NGNTaskService.m
//  TODOList
//
//  Created by Alex on 02.06.17.
//  Copyright © 2017 Alex. All rights reserved.
//

#import "NGNTaskService.h"
#import "NGNTask.h"
#import "NGNTaskList.h"
#import "NSDate+NGNDateToStringConverter.h"
#import "NGNConstants.h"

@interface NGNTaskService ()

@property (strong, nonatomic, readwrite) NSMutableArray<id<NGNStoreable>> *privateEntityCollection;

@end

@implementation NGNTaskService

+ (instancetype)sharedInstance {
    static NGNTaskService *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[NGNTaskService alloc] init];
        [sharedInstance loadCollection];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if (![fileManager fileExistsAtPath:[sharedInstance filePath]]) {
            [fileManager createFileAtPath:[sharedInstance filePath]
                                 contents:[NSData new]
                               attributes:nil];
        }
        if (!sharedInstance.privateEntityCollection || sharedInstance.privateEntityCollection.count == 0) {
            sharedInstance.privateEntityCollection = [[NSMutableArray alloc] init];
            NGNTaskList *inboxTaskList = [[NGNTaskList alloc]initWithId:999 name:@"Inbox"];
            [sharedInstance addEntity:inboxTaskList];
            [sharedInstance loadCollection];
        }
    });
    return sharedInstance;
}

- (NSArray *)allTasks {
    NSArray *unitedArray = [self.entityCollection valueForKeyPath:@"@unionOfArrays.self.entityCollection"];
    return unitedArray;
}

- (NSArray *)allActiveTasks {
    NSArray *activeTasks = [[self allTasks] filteredArrayUsingPredicate:
                            [NSPredicate predicateWithFormat:@"SELF.isCompleted == NO"]];
    return activeTasks;
}

- (NSArray *)allCompletedTasks {
    NSArray *completedTasks = [[self allTasks] filteredArrayUsingPredicate:
                               [NSPredicate predicateWithFormat:@"SELF.isCompleted == YES"]];
    return completedTasks;
}

- (NSArray *)allActiveTasksGroupedByStartDate {
    NSMutableArray *groupedByStartDateTasks = [[NSMutableArray alloc] init];
    NSMutableArray *stringfiedDatesArray = [[NSMutableArray alloc] init];
    for (NGNTask *task in [self allActiveTasks]) {
        NSString *stringfiedDate = [NSDate ngn_formattedStringFromDate:task.startedAt
                                                            withFormat:NGNModelDateFormatForComparison];
        [stringfiedDatesArray addObject:stringfiedDate];
    }
    stringfiedDatesArray = [stringfiedDatesArray valueForKeyPath:@"@distinctUnionOfObjects.self"];
    for (int i = 0; i < stringfiedDatesArray.count; i++) {
        NSPredicate *predicate =
            [NSPredicate predicateWithFormat:@"SELF.startedAt.description contains[cd] %@", stringfiedDatesArray[i]];
        NSArray<id<NGNStoreable>> *currentStartDateTasks =
            [[self allActiveTasks] filteredArrayUsingPredicate:predicate];
        [groupedByStartDateTasks addObject:[currentStartDateTasks mutableCopy]];
    }
    return groupedByStartDateTasks;
}

- (NSArray *)allActiveTaskLists {
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(NGNTaskList *taskList, NSDictionary *bind) {
        return taskList.entityCollection.count != 0;
    }];
    return [self.entityCollection filteredArrayUsingPredicate:predicate];
}

- (void)removeTask:(NGNTask *)taskToRemove {
    for (NGNTaskList *list in self.entityCollection) {
        if ([list entityById:taskToRemove.entityId]) {
            [list removeEntity:taskToRemove];
        }
    }
    [self saveCollection];
}

- (void)updateTask:(NGNTask *)taskToUpdate {
    for (NGNTaskList *list in self.entityCollection) {
        if ([list entityById:taskToUpdate.entityId]) {
            [list updateEntity:taskToUpdate];
        }
    }
    [self saveCollection];
}

#pragma mark - NGNContainable protocol

- (NSMutableArray *)entityCollection {
    return [self.privateEntityCollection mutableCopy];
}

- (id<NGNStoreable>)entityById:(NSInteger)entityId {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.entityId == %dl", entityId];
    return [[self.entityCollection filteredArrayUsingPredicate:predicate]firstObject];
}

- (void)addEntity:(NGNTaskList *)entity {
    [self.privateEntityCollection addObject:entity];
    [self saveCollection];
}

- (void)pushEntity:(NGNTaskList *)entity {
    [self.privateEntityCollection insertObject:entity atIndex:0];
    [self saveCollection];
}

- (void)removeEntity:(NGNTaskList *)entity {
    [self.privateEntityCollection removeObject:entity];
    [self saveCollection];
}

- (void)updateEntity:(NGNTaskList *)entity {
    id oldEntity = [self entityById:entity.entityId];
    if (oldEntity) {
        self.privateEntityCollection[[self.entityCollection indexOfObject:oldEntity]] = entity;
    }
    [self saveCollection];
}

- (void)removeEntityById:(NSInteger)entityId {
    NGNTaskList *taskToRemove = (NGNTaskList *)[self entityById:entityId];
    [self removeEntity:taskToRemove];
    [self saveCollection];
}

- (void)relocateEntityAtIndex:(NSInteger)fromIndex withEntityAtIndex:(NSInteger)toIndex {
    NSMutableArray *testArray = [self.privateEntityCollection mutableCopy];
    [testArray exchangeObjectAtIndex:fromIndex withObjectAtIndex:toIndex];
    self.privateEntityCollection = testArray;
    [self saveCollection];
}

- (void)insertEntity:(NGNTaskList *)entity atIndex:(NSUInteger)index {
    [self.privateEntityCollection insertObject:entity atIndex:index];
    [self saveCollection];
}

- (void)sortEntityCollectionUsingComparator:(NSComparator NS_NOESCAPE)cmptr {
    [_privateEntityCollection sortUsingComparator:cmptr];
    [self saveCollection];
}

@end


@implementation NGNTaskService (NGNSerializableContainer)

- (void)saveCollection {
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.privateEntityCollection];
    [[NSFileManager defaultManager] createFileAtPath:[self filePath]
                                            contents:data
                                          attributes:nil];
}

- (void)loadCollection {
    NSData *data = [[NSFileManager defaultManager] contentsAtPath:[self filePath]];
    self.privateEntityCollection = [NSKeyedUnarchiver unarchiveObjectWithData:data];
}

- (NSString *)filePath {
    NSString *destinationDir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    return [destinationDir stringByAppendingPathComponent:@"myTasks.txt"];
}

@end
