//
//  NGNManagedTask+CoreDataProperties.m
//  TODOList
//
//  Created by Alex on 06.07.17.
//  Copyright © 2017 Alex. All rights reserved.
//

#import "NGNManagedTask+CoreDataProperties.h"

@implementation NGNManagedTask (CoreDataProperties)

+ (NSFetchRequest<NGNManagedTask *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"NGNManagedTask"];
}

@dynamic completed;
@dynamic entityId;
@dynamic name;
@dynamic notes;
@dynamic priority;
@dynamic shouldRemindOnDay;
@dynamic startedAt;
@dynamic finishedAt;

- (void)updateEntity {
    NSBatchUpdateRequest *updateRequest =
    [NSBatchUpdateRequest batchUpdateRequestWithEntityName:@"NGNManagedTask"];
    updateRequest.predicate = [NSPredicate predicateWithFormat:@"entityId == %lld", self.entityId];
    id finishedAt = self.finishedAt ? self.finishedAt : [NSNull new];
    updateRequest.propertiesToUpdate = @{@"name": self.name,
                                         @"notes": self.notes,
                                         @"priority": @(self.priority),
                                         @"finishedAt": finishedAt,
                                         @"startedAt": self.startedAt,
                                         @"completed": @(self.completed),
                                         @"shouldRemindOnDay": @(self.shouldRemindOnDay)};
    NSError *error = nil;
    if (![self.managedObjectContext executeRequest:updateRequest error:&error]) {
        NSLog(@"Unresolved error %@, %@", error, error.userInfo);
#warning do not use abort() in release!!! For debug only!!! Handle this error!!!
        abort();
    }
}

@end
