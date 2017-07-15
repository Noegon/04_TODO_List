//
//  NGNManagedTaskList+CoreDataProperties.m
//  TODOList
//
//  Created by Alex on 06.07.17.
//  Copyright © 2017 Alex. All rights reserved.
//

#import "NGNManagedTaskList+CoreDataProperties.h"
#import "NGNManagedTask+CoreDataProperties.h"

@implementation NGNManagedTaskList (CoreDataProperties)

+ (NSFetchRequest<NGNManagedTaskList *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"NGNManagedTaskList"];
}

@dynamic creationDate;
@dynamic entityId;
@dynamic name;
@dynamic entityCollection;
@dynamic activeTasksList;

- (NSArray *)activeTasksList {
    NSArray *allTasks = [self.entityCollection array];
    NSArray *activeTasks = [allTasks filteredArrayUsingPredicate:
                            [NSPredicate predicateWithFormat:@"SELF.completed == NO"]];
    return activeTasks;
}

- (NGNManagedTask *)entityById:(NSInteger)entityId {
    NSArray *allTasks = [self.entityCollection array];
    NGNManagedTask *currentTask = [[allTasks filteredArrayUsingPredicate:
                                    [NSPredicate predicateWithFormat:@"SELF.entityId == %ld", entityId]] firstObject];
    return currentTask;
}

- (void)relocateEntityAtIndex:(NSInteger)fromIndex withEntityAtIndex:(NSInteger)toIndex {
    NSMutableOrderedSet *orderedSet = [self.entityCollection mutableCopy];
    [orderedSet exchangeObjectAtIndex:fromIndex withObjectAtIndex:toIndex];
    self.entityCollection = orderedSet;
}

@end
