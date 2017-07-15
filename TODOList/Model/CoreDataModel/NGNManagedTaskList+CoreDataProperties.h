//
//  NGNManagedTaskList+CoreDataProperties.h
//  TODOList
//
//  Created by Alex on 06.07.17.
//  Copyright © 2017 Alex. All rights reserved.
//

#import "NGNManagedTaskList+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface NGNManagedTaskList (CoreDataProperties)

+ (NSFetchRequest<NGNManagedTaskList *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSDate *creationDate;
@property (nonatomic) int64_t entityId;
@property (nullable, nonatomic, copy) NSString *name;
@property (nullable, nonatomic, retain) NSOrderedSet<NGNManagedTask *> *entityCollection;
@property (nullable, nonatomic, retain) NSArray<NGNManagedTask *> *activeTasksList;

- (NGNManagedTask *)entityById:(NSInteger)entityId;
- (void)relocateEntityAtIndex:(NSInteger)fromIndex withEntityAtIndex:(NSInteger)toIndex;

@end

@interface NGNManagedTaskList (CoreDataGeneratedAccessors)

- (void)insertObject:(NGNManagedTask *)value inEntityCollectionAtIndex:(NSUInteger)idx;
- (void)removeObjectFromEntityCollectionAtIndex:(NSUInteger)idx;
- (void)insertEntityCollection:(NSArray<NGNManagedTask *> *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeEntityCollectionAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInEntityCollectionAtIndex:(NSUInteger)idx withObject:(NGNManagedTask *)value;
- (void)replaceEntityCollectionAtIndexes:(NSIndexSet *)indexes withEntityCollection:(NSArray<NGNManagedTask *> *)values;
- (void)addEntityCollectionObject:(NGNManagedTask *)value;
- (void)removeEntityCollectionObject:(NGNManagedTask *)value;
- (void)addEntityCollection:(NSOrderedSet<NGNManagedTask *> *)values;
- (void)removeEntityCollection:(NSOrderedSet<NGNManagedTask *> *)values;

@end

NS_ASSUME_NONNULL_END
