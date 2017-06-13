//
//  NGNTodayTasksViewController.m
//  TODOList
//
//  Created by Alex on 02.06.17.
//  Copyright © 2017 Alex. All rights reserved.
//

#import "NGNTodayTasksViewController.h"
#import "NGNTaskDetailsViewController.h"
#import "NSDate+NGNDateToStringConverter.h"
#import "NGNEditTaskViewController.h"
#import "NGNTask.h"
#import "NGNTaskList.h"
#import "NGNTaskService.h"
#import "NGNConstants.h"

@interface NGNTodayTasksViewController () <UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate>

- (IBAction)editBarButtonTapped:(UIBarButtonItem *)sender;
- (IBAction)doneBarButtonTapped:(UIBarButtonItem *)sender;

@end

@implementation NGNTodayTasksViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    srand((unsigned int)time(NULL));
    
    [[NSNotificationCenter defaultCenter] addObserverForName:NGNNotificationNameTaskChange
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *notification) {
                                                      [self.tableView reloadData];
                                                  }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:NGNNotificationNameTaskAdd
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *notification) {
                                                      NSDictionary *userInfo = notification.userInfo;
                                                      NGNTaskList *commonTaskList =
                                                        [[NGNTaskService sharedInstance] entityById:999];
                                                      userInfo = @{@"taskList": commonTaskList};
                                                      [[NSNotificationCenter defaultCenter]
                                                       postNotificationName:NGNNotificationNameTaskListChange
                                                       object:nil
                                                       userInfo:userInfo];
                                                      [self.tableView reloadData];
                                                  }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:NGNNotificationNameGlobalModelChange
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *notification) {
                                                      [self.tableView reloadData];
                                                  }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:NGNNotificationNameTaskListChange
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *notification) {
                                                      [self.tableView reloadData];
                                                  }];
    
    [self.tableView setEditing:NO animated:YES];
}

#pragma mark - section handling

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"Active";
    }
    return @"Completed";
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return [[NGNTaskService sharedInstance] allActiveTasks].count;
    }
    return [[NGNTaskService sharedInstance] allCompletedTasks].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *taskCell = [tableView dequeueReusableCellWithIdentifier:NGNControllerTaskCellIdentifier
                                                                forIndexPath:indexPath];
    NGNTask *currentTask;
    if (indexPath.section == 0) {
        currentTask = [[NGNTaskService sharedInstance] allActiveTasks][indexPath.row];
    } else {
        currentTask = [[NGNTaskService sharedInstance] allCompletedTasks][indexPath.row];
    }
    
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
    NGNTask *currentTask;
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        if (indexPath.section == 0) {
            currentTask = [[NGNTaskService sharedInstance] allActiveTasks][indexPath.row];
        } else {
            currentTask = [[NGNTaskService sharedInstance] allCompletedTasks][indexPath.row];
        }
        [[NGNTaskService sharedInstance] removeTask:currentTask];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:NGNNotificationNameGlobalModelChange
                                                        object:nil
                                                      userInfo:nil];
}

// Override to insert some additional functionality to cell when you swipe left
-(NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //edit row action (done - complete task)
    UITableViewRowAction *editAction =
    [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal
                                       title:@"Done"
                                     handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        NGNTask *currentTask;
        if (indexPath.section == 0) {
            currentTask = [[NGNTaskService sharedInstance] allActiveTasks][indexPath.row];
        } else {
            currentTask = [[NGNTaskService sharedInstance] allCompletedTasks][indexPath.row];
        }
        currentTask.finishedAt = [NSDate date];
        currentTask.completed = YES;
        [self.tableView reloadData];
        //notify everyone that task was changed
        NSDictionary *userInfo = @{@"task": currentTask};
        [[NSNotificationCenter defaultCenter] postNotificationName:NGNNotificationNameTaskChange
                                                            object:nil
                                                          userInfo:userInfo];
    }];
    editAction.backgroundColor = [UIColor grayColor];
    
    //delete row action
    UITableViewRowAction *deleteAction =
    [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"Delete"
                                     handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
                                         [self tableView:self.tableView commitEditingStyle:UITableViewCellEditingStyleDelete forRowAtIndexPath:indexPath];
                                     }];
    deleteAction.backgroundColor = [UIColor redColor];

    return @[deleteAction,editAction];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NGNTaskList *commonTaskList = [[NGNTaskService sharedInstance] entityById:999];
    if ([segue.identifier isEqualToString:NGNControllerSegueShowTaskDetail]) {
        NGNTaskDetailsViewController *taskDetailsViewController = segue.destinationViewController;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        NSArray *currentTaskList;
        if (indexPath.section == 0) {
            currentTaskList = [[NGNTaskService sharedInstance] allActiveTasks];
        } else {
            currentTaskList = [[NGNTaskService sharedInstance] allCompletedTasks];
        }
        NGNTask *task = currentTaskList[indexPath.row];
        taskDetailsViewController.entringTask = task;
        taskDetailsViewController.entringTaskList = commonTaskList;
    }
    if ([segue.identifier isEqualToString:NGNControllerSegueShowAddTask]) {
        NGNEditTaskViewController *editTaskViewController = segue.destinationViewController;
        editTaskViewController.navigationItem.title = @"Add task";
        editTaskViewController.entringTaskList = commonTaskList;
    }
}

#pragma mark - additional handling methods

- (IBAction)editBarButtonTapped:(UIBarButtonItem *)sender {
    UIBarButtonItem *doneBarButton =
    [[UIBarButtonItem alloc] initWithTitle:NGNControllerDoneButtonTitle
                                     style:UIBarButtonItemStylePlain
                                    target:self
                                    action:@selector(doneBarButtonTapped:)];
    self.navigationItem.leftBarButtonItem = doneBarButton;
    [self.tableView setEditing:YES];
    doneBarButton = nil;
}

- (IBAction)doneBarButtonTapped:(UIBarButtonItem *)sender {
    UIBarButtonItem *editBarButton =
    [[UIBarButtonItem alloc] initWithTitle:NGNControllerEditButtonTitle
                                     style:UIBarButtonItemStylePlain
                                    target:self
                                    action:@selector(editBarButtonTapped:)];
    self.navigationItem.leftBarButtonItem = editBarButton;
    [self.tableView setEditing:NO];
    editBarButton = nil;
}

#pragma mark - gestures handling

-(void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer {
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
        [self doneBarButtonTapped:nil];
    } else {
        [self editBarButtonTapped:nil];
    }
}

@end
