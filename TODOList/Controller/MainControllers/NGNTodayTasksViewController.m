//
//  NGNTodayTasksViewController.m
//  TODOList
//
//  Created by Alex on 02.06.17.
//  Copyright © 2017 Alex. All rights reserved.
//

#import "NGNTodayTasksViewController.h"
#import "NSDate+NGNDateToStringConverter.h"
#import "NGNEditTaskViewController.h"
#import "NGNTask.h"
#import "NGNTaskList.h"
#import "NGNTaskService.h"
#import "NGNConstants.h"

@interface NGNTodayTasksViewController () <UITableViewDataSource,
                                           UITableViewDelegate,
                                           UIGestureRecognizerDelegate>

@property (strong, nonatomic) id<NSObject> taskChangeNotification;
@property (strong, nonatomic) id<NSObject> taskAddNotification;
@property (strong, nonatomic) id<NSObject> taskListChangeNotification;
@property (strong, nonatomic) id<NSObject> globalModelChangeNotification;

- (IBAction)editBarButtonTapped:(UIBarButtonItem *)sender;
- (IBAction)doneBarButtonTapped:(UIBarButtonItem *)sender;

@end

@implementation NGNTodayTasksViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
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
        NGNTaskList *commonTaskList = [[NGNTaskService sharedInstance] entityById:999];
        NSDictionary *userInfo = @{@"taskList": commonTaskList};
        [[NSNotificationCenter defaultCenter] postNotificationName:NGNNotificationNameTaskListChange
                                                            object:nil
                                                          userInfo:userInfo];
        [self.tableView reloadData];
    }];
    
    self.globalModelChangeNotification =
    [[NSNotificationCenter defaultCenter] addObserverForName:NGNNotificationNameGlobalModelChange
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification *notification) {
        [self.tableView reloadData];
    }];
    
    self.taskListChangeNotification =
    [[NSNotificationCenter defaultCenter] addObserverForName:NGNNotificationNameTaskListChange
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification *notification) {
        [self.tableView reloadData];
    }];
    
    [self.tableView setEditing:NO animated:YES];
}

#pragma mark - section handling

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] init];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 0,
                                                               CGRectGetWidth(self.view.frame),
                                                               NGNControllerTableSectionHeaderHeight)];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor grayColor];
    
    NSString *text;
    if (section == 0) {
        text = NGNControllerActiveTasksSectionTitle;
    } else {
        text = NGNControllerCompletedTasksSectionTitle;
    }
    label.text = text;
    
    [view addSubview:label];
    
    return view;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self todayTasksListForSection:section].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *taskCell = [tableView dequeueReusableCellWithIdentifier:NGNControllerTaskCellIdentifier
                                                                forIndexPath:indexPath];
    
    NGNTask *currentTask = [self todayTasksListForSection:indexPath.section][indexPath.row];
    
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
    
    NGNTask *currentTask = [self todayTasksListForSection:indexPath.section][indexPath.row];
    [self performTaskDeleteConfirmationDialogueAtTableView:tableView
                                               atIndexPath:indexPath
                                         withStoreableItem:currentTask];
}

// Override to insert some additional functionality to cell when you swipe left
-(NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //edit row action (done - complete task)
    UITableViewRowAction *editAction =
    [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal
                                       title:NGNControllerDoneButtonTitle
                                     handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        NGNTask *currentTask = [self todayTasksListForSection:indexPath.section][indexPath.row];
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
    [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:NGNControllerDeleteButtonTitle
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
    NGNEditTaskViewController *editTaskViewController = segue.destinationViewController;
    if ([segue.identifier isEqualToString:NGNControllerSegueShowEditTask]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        NGNTask *task = [self todayTasksListForSection:indexPath.section][indexPath.row];
        editTaskViewController.entringTask = task;
    }
    if ([segue.identifier isEqualToString:NGNControllerSegueShowAddTask]) {
        editTaskViewController.navigationItem.title = NGNControllerAddTaskNavigationItemTitle;
    }
    editTaskViewController.entringTaskList = commonTaskList;
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

- (NSArray *)todayTasksListForSection:(NSInteger)section {
    NSMutableArray *todayTasks = [[NSMutableArray alloc] init];
    
    NSCalendar* calendar = [NSCalendar currentCalendar];
    if (section == 0) {
        for (NGNTask *task in [[NGNTaskService sharedInstance] allActiveTasks]) {
            if ([calendar isDateInToday:task.startedAt]) {
                [todayTasks addObject:task];
            }
        }
    } else {
        for (NGNTask *task in [[NGNTaskService sharedInstance] allCompletedTasks]) {
            if ([calendar isDateInToday:task.startedAt]) {
                [todayTasks addObject:task];
            }
        }
    }
    return [todayTasks copy];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:_taskAddNotification];
    [[NSNotificationCenter defaultCenter] removeObserver:_taskChangeNotification];
    [[NSNotificationCenter defaultCenter] removeObserver:_taskListChangeNotification];
    [[NSNotificationCenter defaultCenter] removeObserver:_globalModelChangeNotification];
}

@end
