//
//  NGNGenericEntityContainer.m
//  TODOList
//
//  Created by Alex on 08.06.17.
//  Copyright © 2017 Alex. All rights reserved.
//

#import "NGNCommonEntityContainer.h"
#import "NGNStoredEntity.h"

@interface NGNCommonEntityContainer ()

@property (strong, nonatomic, readwrite) NSMutableArray<id<NGNStoreable>> *privateEntityCollection;

@end

@implementation NGNCommonEntityContainer


- (instancetype)init {
    if (self = [super init]) {
        _privateEntityCollection = [[NSMutableArray alloc]init];
    }
    return self;
}

- (NSMutableArray *)entityCollection {
    return [self.privateEntityCollection mutableCopy];
}

- (id<NGNStoreable>)entityById:(NSInteger)entityId {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.entityId == %dl", entityId];
    return [[self.entityCollection filteredArrayUsingPredicate:predicate]firstObject];
}

- (void)addEntity:(NGNStoredEntity *)entity {
    [self.privateEntityCollection addObject:entity];
}

- (void)pushEntity:(id<NGNStoreable>)entity {
    [self.privateEntityCollection insertObject:entity atIndex:0];
}

- (void)removeEntity:(NGNStoredEntity *)entity {
    [self.privateEntityCollection removeObject:entity];
}

- (void)updateEntity:(id<NGNStoreable>)entity {
    id oldEntity = [self entityById:entity.entityId];
    if (oldEntity) {
        self.privateEntityCollection[[self.entityCollection indexOfObject:oldEntity]] = entity;
    }
}

- (void)removeEntityById:(NSInteger)entityId {
    NGNStoredEntity *entityToRemove = [self entityById:entityId];
    [self removeEntity:entityToRemove];
}

- (void)relocateEntityAtIndex:(NSInteger)fromIndex withEntityAtIndex:(NSInteger)toIndex {
    NSMutableArray *testArray = [self.privateEntityCollection mutableCopy];
    [testArray exchangeObjectAtIndex:fromIndex withObjectAtIndex:toIndex];
    self.privateEntityCollection = testArray;
}

- (void)insertEntity:(id<NGNStoreable>)entity atIndex:(NSUInteger)index {
    [self.privateEntityCollection insertObject:entity atIndex:index];
}

- (void)sortEntityCollectionUsingComparator:(NSComparator NS_NOESCAPE)cmptr {
    [_privateEntityCollection sortUsingComparator:cmptr];
}

@end
