//
//  NGNTaskCollection.m
//  TODOList
//
//  Created by Alex on 07.06.17.
//  Copyright © 2017 Alex. All rights reserved.
//

#import "NGNTaskList.h"
#import "NGNTask.h"
#import "NGNTaskService.h"

@interface NGNTaskList ()

@property (strong, nonatomic, readwrite) NSMutableArray<id<NGNStoreable>> *privateEntityCollection;

@end

@implementation NGNTaskList

- (instancetype)initWithId:(NSInteger)entityId name:(NSString *)name creationDate:(NSDate *)creationDate {
    if (self = [super init]) {
        _entityId = entityId;
        _name = name;
        _creationDate = creationDate;
        _privateEntityCollection = [[NSMutableArray alloc] init];
    }
    return self;
}

- (instancetype)initWithId:(NSInteger)entityId name:(NSString *)name {
    return [self initWithId:entityId name:name creationDate:[NSDate date]];
}

- (instancetype)init {
    return [self initWithId:0 name:nil];
}

- (NSArray *)activeTasksList {
    NSArray *activeTasks = [self.entityCollection filteredArrayUsingPredicate:
                            [NSPredicate predicateWithFormat:@"SELF.isCompleted == NO"]];
    return activeTasks;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%ld;%@;%@", self.entityId, self.name, self.privateEntityCollection];
}

#pragma mark - NSCoding protocol

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        _entityId = ((NSNumber *)[aDecoder decodeObjectForKey:@"entityId"]).integerValue;
        _name = [aDecoder decodeObjectForKey:@"name"];
        _creationDate = [aDecoder decodeObjectForKey:@"creationDate"];
        _privateEntityCollection = [aDecoder decodeObjectForKey:@"privateEntityCollection"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:@(self.entityId) forKey:@"entityId"];
    [coder encodeObject:self.name forKey:@"name"];
    [coder encodeObject:self.creationDate forKey:@"creationDate"];
    [coder encodeObject:self.privateEntityCollection forKey:@"privateEntityCollection"];
}

#pragma mark - NGNContainable protocol

- (NSMutableArray *)entityCollection {
    return [self.privateEntityCollection mutableCopy];
}

- (id<NGNStoreable>)entityById:(NSInteger)entityId {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.entityId == %dl", entityId];
    return [[self.entityCollection filteredArrayUsingPredicate:predicate]firstObject];
}

- (void)addEntity:(NGNTask *)entity {
    [self.privateEntityCollection addObject:entity];
    [[NGNTaskService sharedInstance] saveCollection];
}

- (void)pushEntity:(NGNTask *)entity {
    [self.privateEntityCollection insertObject:entity atIndex:0];
    [[NGNTaskService sharedInstance] saveCollection];
}

- (void)removeEntity:(NGNTask *)entity {
    [self.privateEntityCollection removeObject:entity];
    [[NGNTaskService sharedInstance] saveCollection];
}

- (void)updateEntity:(NGNTask *)entity {
    id oldEntity = [self entityById:entity.entityId];
    if (oldEntity) {
        NSUInteger index = [self.privateEntityCollection indexOfObject:oldEntity];
        [self.privateEntityCollection replaceObjectAtIndex:index withObject:entity];
        [[NGNTaskService sharedInstance] saveCollection];
    }
}

- (void)removeEntityById:(NSInteger)entityId {
    NGNTask *taskToRemove = (NGNTask *)[self entityById:entityId];
    [self removeEntity:taskToRemove];
    [[NGNTaskService sharedInstance] saveCollection];
}

- (void)relocateEntityAtIndex:(NSInteger)fromIndex withEntityAtIndex:(NSInteger)toIndex {
    NSMutableArray *testArray = [self.privateEntityCollection mutableCopy];
    [testArray exchangeObjectAtIndex:fromIndex withObjectAtIndex:toIndex];
    self.privateEntityCollection = testArray;
    [[NGNTaskService sharedInstance] saveCollection];
}

- (void)insertEntity:(NGNTask *)entity atIndex:(NSUInteger)index {
    [self.privateEntityCollection insertObject:entity atIndex:index];
    [[NGNTaskService sharedInstance] saveCollection];
}

- (void)sortEntityCollectionUsingComparator:(NSComparator NS_NOESCAPE)cmptr {
    [_privateEntityCollection sortUsingComparator:cmptr];
    [[NGNTaskService sharedInstance] saveCollection];
}

@end
