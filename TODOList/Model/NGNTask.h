//
//  NGNTask.h
//  TODOList
//
//  Created by Alex on 02.06.17.
//  Copyright © 2017 Alex. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NGNTask : NSObject

@property (copy, nonatomic) NSString *taskId;
@property (copy, nonatomic) NSString *name;
@property (strong, nonatomic) NSDate *startedAt;
@property (strong, nonatomic) NSDate *finishedAt;
@property (copy, nonatomic) NSString *notes;
@property (assign, nonatomic) BOOL completed;

+ (instancetype)taskWithId:(NSString *)taskId name:(NSString *)name;
- (instancetype)initWithId:(NSString *)taskId name:(NSString *)name;

@end
