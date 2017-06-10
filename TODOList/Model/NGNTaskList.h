//
//  NGNTaskCollection.h
//  TODOList
//
//  Created by Alex on 07.06.17.
//  Copyright © 2017 Alex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NGNCommonEntityContainer.h"

@class NGNTask;

@interface NGNTaskList : NGNCommonEntityContainer <NGNStoreable>

@property (assign, nonatomic) NSInteger entityId;
@property (copy, nonatomic) NSString *name;
@property (strong, nonatomic) NSDate *creationDate;

- (instancetype)initWithId:(NSInteger)entityId name:(NSString *)name;
- (instancetype)initWithId:(NSInteger)entityId name:(NSString *)name creationDate:(NSDate *)creationDate;

- (NSArray *)activeTasksList;

@end
