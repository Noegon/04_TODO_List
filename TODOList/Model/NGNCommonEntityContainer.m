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

- (void)removeEntity:(NGNStoredEntity *)entity {
    [self.privateEntityCollection removeObject:entity];
}

- (void)updateEntity:(id<NGNStoreable>)entity {
    id oldEntity = [self entityById:entity.entityId];
    if (oldEntity) {
        self.privateEntityCollection[[self.entityCollection indexOfObject:oldEntity]] = entity;
    }
    else {
        [self addEntity:entity];
    }
}

- (void)removeEntityById:(NSInteger)entityId {
    NGNStoredEntity *entityToRemove = [self entityById:entityId];
    [self removeEntity:entityToRemove];
}

@end
