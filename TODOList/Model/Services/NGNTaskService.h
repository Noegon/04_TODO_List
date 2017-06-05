//
//  NGNTaskService.h
//  TODOList
//
//  Created by Alex on 02.06.17.
//  Copyright © 2017 Alex. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NGNTask;
@interface NGNTaskService : NSObject

@property (strong, nonatomic, readonly) NSArray *taskList;

- (NGNTask *)taskById:(NSString *)taskId;
- (void)addTask:(NGNTask *)task;
- (void)removeTask:(NGNTask *)task;
- (void)updateTask:(NGNTask *)task;
- (void)removeTaskById:(NSString *)taskId;

@end
