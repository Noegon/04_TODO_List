//
//  NGNTaskCollection.m
//  TODOList
//
//  Created by Alex on 07.06.17.
//  Copyright © 2017 Alex. All rights reserved.
//

#import "NGNTaskList.h"
#import "NGNTask.h"

@interface NGNTaskList ()

@end

@implementation NGNTaskList

- (instancetype)initWithId:(NSInteger)entityId name:(NSString *)name creationDate:(NSDate *)creationDate {
    if (self = [super init]) {
        _entityId = entityId;
        _name = name;
        _creationDate = creationDate;
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
#warning could be some problems with types
    NSArray *activeTasks = [self.entityCollection filteredArrayUsingPredicate:
                            [NSPredicate predicateWithFormat:@"SELF.isCompleted == NO"]];
    return activeTasks;
}

@end
