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

- (instancetype)initWithId:(NSInteger)entityId name:(NSString *)name {
    if (self = [super init]) {
        _entityId = entityId;
        _name = name;
        _creationDate = [NSDate date];
    }
    return self;
}

- (instancetype)init {
    if (self = [super init]) {
        _creationDate = [NSDate date];
    }
    return self;
}

- (NSArray *)activeTasksList {
#warning could be some problems with types
    NSArray *activeTasks = [self.entityCollection filteredArrayUsingPredicate:
                            [NSPredicate predicateWithFormat:@"SELF.isCompleted == NO"]];
    return activeTasks;
}

@end
