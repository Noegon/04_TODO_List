//
//  NGNTaskCollection.h
//  TODOList
//
//  Created by Alex on 07.06.17.
//  Copyright © 2017 Alex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NGNContainable.h"

@class NGNTask;

@interface NGNTaskList: NSObject <NGNStoreable, NGNContainable, NSCoding>

@property (assign, nonatomic) NSInteger entityId;
@property (copy, nonatomic) NSString *name;
@property (strong, nonatomic) NSDate *creationDate;
@property (strong, nonatomic, readwrite) NSMutableArray<id<NGNStoreable>> *entityCollection;

- (instancetype)initWithId:(NSInteger)entityId name:(NSString *)name;
- (instancetype)initWithId:(NSInteger)entityId name:(NSString *)name creationDate:(NSDate *)creationDate;

- (NSArray *)activeTasksList;

@end
