//
//  NGNTaskListDetailsViewController.m
//  TODOList
//
//  Created by Alex on 12.06.17.
//  Copyright © 2017 Alex. All rights reserved.
//

#import "NGNTaskListDetailsViewController.h"
#import "NGNTaskDetailsViewController.h"
#import "NSDate+NGNDateToStringConverter.h"
#import "NGNEditTaskViewController.h"
#import "NGNTask.h"
#import "NGNTaskList.h"
#import "NGNTaskService.h"
#import "NGNConstants.h"

@interface NGNTaskListDetailsViewController () <UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate>

@end

@implementation NGNTaskListDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    srand((unsigned int)time(NULL));
    
    [[NSNotificationCenter defaultCenter] addObserverForName:NGNNotificationNameTaskChange
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *notification) {
        NSDictionary *userInfo = notification.userInfo;
        NGNTask *task = userInfo[@"task"];
        [self.entringTaskList updateEntity:task];
        [self.tableView reloadData];
    }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:NGNNotificationNameTaskAdd
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *notification) {
        NSDictionary *userInfo = notification.userInfo;
        NGNTask *task = userInfo[@"task"];
        [self.entringTaskList addEntity:task];
        [self.tableView reloadData];
        [[NSNotificationCenter defaultCenter] postNotificationName:NGNNotificationNameTaskListChange
                                                            object:nil
                                                          userInfo:@{@"taskList": self.entringTaskList}];
    }];
    
    [self.tableView setEditing:NO animated:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    NGNTaskList *currentTaskList = [NGNTaskService sharedInstance].entityCollection[section];
    return [self.entringTaskList entityCollection].count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *taskCell = [tableView dequeueReusableCellWithIdentifier:NGNControllerTaskCellIdentifier
                                                                forIndexPath:indexPath];
    NGNTask *currentTask = self.entringTaskList.entityCollection[indexPath.row];
    
    taskCell.textLabel.text = currentTask.name;
    UILongPressGestureRecognizer *longPressRecognizer = [[UILongPressGestureRecognizer alloc]
                                                         initWithTarget:self
                                                         action:@selector(handleLongPress:)];
    longPressRecognizer.delegate = self;
    longPressRecognizer.delaysTouchesBegan = YES;
    [taskCell setGestureRecognizers:@[longPressRecognizer]];
    
    return taskCell;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NGNTask *currentTask = self.entringTaskList.entityCollection[indexPath.row];
        [self.entringTaskList removeEntity:currentTask];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        NSDictionary *userInfo = @{@"taskList": self.entringTaskList};
        [[NSNotificationCenter defaultCenter] postNotificationName:NGNNotificationNameTaskListChange
                                                            object:nil
                                                          userInfo:userInfo];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)aTableView
           editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

#pragma mark - section handling

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
//    NGNTaskList *currentList = [NGNTaskService sharedInstance].entityCollection[section];
    return [self entringTaskList].name;
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:NGNControllerSegueShowTaskDetail]) {
        NGNTaskDetailsViewController *taskDetailsViewController = segue.destinationViewController;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        NGNTask *task = self.entringTaskList.entityCollection[indexPath.row];
        taskDetailsViewController.entringTask = task;
    }
    if ([segue.identifier isEqualToString:NGNControllerSegueShowAddTask]) {
        NGNEditTaskViewController *editTaskViewController = segue.destinationViewController;
        editTaskViewController.navigationItem.title = @"Add task";
    }
}

#pragma mark - gestures handling

-(void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state != UIGestureRecognizerStateEnded) {
        return;
    }
    if (![gestureRecognizer.view isKindOfClass:[UITableViewCell class]]){
        NSLog(@"view isn't tableViewCell");
        return;
    }
    // get the cell at indexPath (the one you long pressed)
    UITableViewCell* cell = (UITableViewCell *)gestureRecognizer.view;
    // do stuff with the cell
    NSLog(@"%@, editingStyle: %ld", cell.textLabel.text, (long)cell.editingStyle);
    
    if (self.tableView.isEditing) {
        self.tableView.editing = NO;
    } else {
        self.tableView.editing = YES;
    }
}

@end
