//
//  NGNTask.m
//  TODOList
//
//  Created by Alex on 02.06.17.
//  Copyright © 2017 Alex. All rights reserved.
//

#import "NGNTask.h"

@implementation NGNTask

+ (instancetype)taskWithId:(NSInteger)taskId name:(NSString *)name {
    return [[self alloc] initWithId:taskId name:name];
}

+ (instancetype)taskWithId:(NSInteger)taskId name:(NSString *)name startDate:(NSDate *)startDate notes:(NSString *)notes {
    return [[self alloc] initWithId:taskId name:name startDate:startDate notes:notes];
}

- (instancetype)initWithId:(NSInteger)entityId name:(NSString *)name {
    return [self initWithId:entityId name:name startDate:[NSDate date] notes:@""];
}

- (instancetype)initWithId:(NSInteger)entityId name:(NSString *)name startDate:(NSDate *)startDate notes:(NSString *)notes {
    if (self = [self init]) {
        _entityId = entityId;
        _name = name;
        _startedAt = startDate;
        _notes = notes;
    }
    return self;
}

- (BOOL)isEqual:(id)other {
    NGNTask *tmpOther = (NGNTask *)other;
    if (other == self) {
        return YES;
    } else if (![super isEqual:other]) {
        return NO;
    } else {
        return (self.entityId == tmpOther.entityId);
    }
}

- (NSUInteger)hash {
    NSUInteger prime = 31;
    NSUInteger result = 1;
    result = prime * result + (int) (self.entityId ^ (self.entityId >> 32));
    return result;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%ld;%@;%@", self.entityId, self.name, self.startedAt];
}

#pragma mark - NSCoding protocol

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        _entityId = ((NSNumber *)[aDecoder decodeObjectForKey:@"entityId"]).integerValue;
        _name = [aDecoder decodeObjectForKey:@"name"];
        _startedAt = [aDecoder decodeObjectForKey:@"startedAt"];
        _finishedAt = [aDecoder decodeObjectForKey:@"finishedAt"];
        _notes = [aDecoder decodeObjectForKey:@"notes"];
        _shouldRemindOnDay = (BOOL)((NSNumber *)[aDecoder decodeObjectForKey:@"shouldRemindOnDay"]).integerValue;
        _priority = ((NSNumber *)[aDecoder decodeObjectForKey:@"priority"]).integerValue;
        _completed = (BOOL)((NSNumber *)[aDecoder decodeObjectForKey:@"completed"]).integerValue;
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:@(self.entityId) forKey:@"entityId"];
    [coder encodeObject:self.name forKey:@"name"];
    [coder encodeObject:self.startedAt forKey:@"startedAt"];
    [coder encodeObject:self.finishedAt forKey:@"finishedAt"];
    [coder encodeObject:self.notes forKey:@"notes"];
    [coder encodeObject:@(self.shouldRemindOnDay) forKey:@"shouldRemindOnDay"];
    [coder encodeObject:@(self.priority) forKey:@"priority"];
    [coder encodeObject:@(self.completed) forKey:@"completed"];
}

@end
