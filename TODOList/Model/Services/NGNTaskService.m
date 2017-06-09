//
//  NGNTaskService.m
//  TODOList
//
//  Created by Alex on 02.06.17.
//  Copyright © 2017 Alex. All rights reserved.
//

#import "NGNTaskService.h"
#import "NGNTask.h"
#import "NGNTaskList.h"

@interface NGNTaskService ()

@end

@implementation NGNTaskService

+ (instancetype)sharedInstance {
    static NGNTaskService *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
#warning hardcoded test datasource
        sharedInstance = [[NGNTaskService alloc] init];
        NGNTask *task1 = [NGNTask taskWithId:1 name:@"Make calculator 3.0"];
        NGNTask *task2 = [NGNTask taskWithId:2 name:@"Make TODO List 0.1"];
        NGNTask *task3 = [NGNTask taskWithId:3 name:@"Make somthing useful"];
        NGNTaskList *taskList = [[NGNTaskList alloc]initWithId:1 name:@"Test list"];
        [taskList addEntity:task1];
        [taskList addEntity:task2];
        [taskList addEntity:task3];
        [sharedInstance addEntity:taskList];
        
    });
    return sharedInstance;
}

- (NSArray *)allTasks {
    NSArray *unitedArray = [self.entityCollection valueForKeyPath:@"@unionOfArrays.self.entityCollection"];
    return unitedArray;
}

- (NSArray *)allActiveTasks {
    NSArray *activeTasks = [[self allTasks] filteredArrayUsingPredicate:
                            [NSPredicate predicateWithFormat:@"SELF.isCompleted == NO"]];
    return activeTasks;
}

@end
