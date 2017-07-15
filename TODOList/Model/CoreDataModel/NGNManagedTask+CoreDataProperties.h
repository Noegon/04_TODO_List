//
//  NGNManagedTask+CoreDataProperties.h
//  TODOList
//
//  Created by Alex on 06.07.17.
//  Copyright © 2017 Alex. All rights reserved.
//

#import "NGNManagedTask+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface NGNManagedTask (CoreDataProperties)

+ (NSFetchRequest<NGNManagedTask *> *)fetchRequest;

@property (nonatomic) BOOL completed;
@property (nonatomic) int64_t entityId;
@property (nullable, nonatomic, copy) NSString *name;
@property (nullable, nonatomic, copy) NSString *notes;
@property (nonatomic) int64_t priority;
@property (nonatomic) BOOL shouldRemindOnDay;
@property (nullable, nonatomic, copy) NSDate *startedAt;
@property (nullable, nonatomic, copy) NSDate *finishedAt;

- (void)updateEntity;

@end

NS_ASSUME_NONNULL_END
