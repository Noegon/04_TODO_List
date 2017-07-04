//
//  NGNTaskListDetailsViewController.m
//  TODOList
//
//  Created by Alex on 12.06.17.
//  Copyright © 2017 Alex. All rights reserved.
//

#import "NGNTaskListDetailsViewController.h"
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
    
    self.taskChangeNotification =
    [[NSNotificationCenter defaultCenter] addObserverForName:NGNNotificationNameTaskChange
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification *notification) {
        [self.tableView reloadData];
    }];
    
    self.taskAddNotification =
    [[NSNotificationCenter defaultCenter] addObserverForName:NGNNotificationNameTaskAdd
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification *notification) {
        [self.tableView reloadData];
        [[NSNotificationCenter defaultCenter] postNotificationName:NGNNotificationNameTaskListChange
                                                            object:nil
                                                          userInfo:@{@"taskList": self.entringTaskList}];
    }];
    
    [self.tableView setEditing:NO animated:YES];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    NGNTaskList *currentTaskList = [NGNTaskService sharedInstance].entityCollection[section];
    return [self.entringTaskList entityCollection].count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 22.;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70.;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *taskCell = [tableView dequeueReusableCellWithIdentifier:NGNControllerTaskCellIdentifier
                                                                forIndexPath:indexPath];
    NGNTask *currentTask = (NGNTask *)self.entringTaskList.entityCollection[indexPath.row];
    
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
        NGNTask *currentTask = (NGNTask *)self.entringTaskList.entityCollection[indexPath.row];
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

#pragma mark - section handling

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] init];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, CGRectGetWidth(self.view.frame), 22)];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor grayColor];
    label.text = [self entringTaskList].name;
    
    [view addSubview:label];
    
    return view;
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NGNEditTaskViewController *editTaskViewController = segue.destinationViewController;
    if ([segue.identifier isEqualToString:NGNControllerSegueShowEditTask]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        NGNTask *task = (NGNTask *)self.entringTaskList.entityCollection[indexPath.row];
        editTaskViewController.entringTask = task;
    }
    if ([segue.identifier isEqualToString:NGNControllerSegueShowAddTask]) {
        editTaskViewController.navigationItem.title = @"Add task";
    }
    editTaskViewController.entringTaskList = self.entringTaskList;
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
