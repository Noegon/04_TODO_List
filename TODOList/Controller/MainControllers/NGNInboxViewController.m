//
//  NGNInboxViewController.m
//  TODOList
//
//  Created by Alex on 01.06.17.
//  Copyright © 2017 Alex. All rights reserved.
//

#import "NGNInboxViewController.h"
#import "NSDate+NGNDateToStringConverter.h"
#import "NGNEditTaskViewController.h"
#import "NGNTask.h"
#import "NGNTaskList.h"
#import "NGNTaskService.h"
#import "NGNConstants.h"

@interface NGNInboxViewController () <UITableViewDataSource,
                                      UITableViewDelegate,
                                      UIGestureRecognizerDelegate>

@property (strong, nonatomic) UISegmentedControl *segmentedControl;
@property (strong, nonatomic) NSMutableArray *dateSortedTaskListsArray;
@property (assign, nonatomic, getter=isAscendingSortDirection) BOOL ascendingSortDirection;

#pragma mark - additional handling methods

- (IBAction)sortDirectionBarButtonTapped:(UIBarButtonItem *)sender;
- (void)segmentedControlSelectionChange;
- (NGNTask *)actualTaskWithIndexPath:(NSIndexPath *)indexPath;
- (NGNTaskList *)actualTaskListWithIndexPath:(NSIndexPath *)indexPath;
- (void)refreshData;

@end

@implementation NGNInboxViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.taskChangeNotification =
    [[NSNotificationCenter defaultCenter] addObserverForName:NGNNotificationNameTaskChange
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification *notification) {
        [self refreshData];
    }];

    self.taskAddNotification =
    [[NSNotificationCenter defaultCenter] addObserverForName:NGNNotificationNameTaskAdd
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification *notification) {
        [self refreshData];
    }];
    
    self.taskListChangeNotification =
    [[NSNotificationCenter defaultCenter] addObserverForName:NGNNotificationNameTaskListChange
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification *notification) {
        [self refreshData];
    }];
    
    self.taskListAddNotification =
    [[NSNotificationCenter defaultCenter] addObserverForName:NGNNotificationNameTaskListAdd
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification *notification) {
        [self refreshData];
        
    }];
    
    self.globalModelChangeNotification =
    [[NSNotificationCenter defaultCenter] addObserverForName:NGNNotificationNameGlobalModelChange
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification *notification) {
        [self refreshData];
    }];
    
    [self.tableView setEditing:NO animated:YES];
    
    //adding segment control into table header
    self.segmentedControl = [[UISegmentedControl alloc] initWithItems:@[NGNControllerDateSegmentControlTitle,
                                                                        NGNControllerGroupSegmentControlTitle]];
    [self.segmentedControl setWidth:(self.view.bounds.size.width-20)/2 forSegmentAtIndex:0];
    [self.segmentedControl setWidth:(self.view.bounds.size.width-20)/2 forSegmentAtIndex:1];
    [self.segmentedControl setSelectedSegmentIndex:1];
    UIView *tableHeader =
        [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, NGNControllerTableHeaderHeight)];
    [tableHeader setBackgroundColor:[UIColor whiteColor]];
    self.tableView.tableHeaderView = tableHeader;
    [self.tableView.tableHeaderView addSubview:self.segmentedControl];
    [self.segmentedControl setCenter:CGPointMake((self.view.bounds.size.width)/2, NGNControllerTableHeaderHeight/2)];
    
    [self.segmentedControl addTarget:self
                              action:@selector(segmentedControlSelectionChange)
                    forControlEvents:UIControlEventValueChanged];
    self.dateSortedTaskListsArray = [[[NGNTaskService sharedInstance] allActiveTasksGroupedByStartDate] mutableCopy];
    self.ascendingSortDirection = YES;
    [self segmentedControlSelectionChange];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.segmentedControl.selectedSegmentIndex == 0) {
        NSArray *datesArray = self.dateSortedTaskListsArray;
        return [datesArray count];
    }
    return [[NGNTaskService sharedInstance] allActiveTaskLists].count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.segmentedControl.selectedSegmentIndex == 0) {
        NSArray *datesArray = self.dateSortedTaskListsArray;
        return [datesArray[section] count];
    }
    NGNTaskList *currentTaskList = [[NGNTaskService sharedInstance] allActiveTaskLists][section];
    return [currentTaskList activeTasksList].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *taskCell = [tableView dequeueReusableCellWithIdentifier:NGNControllerTaskCellIdentifier
                                                                forIndexPath:indexPath];
    NGNTask *currentTask = [self actualTaskWithIndexPath:indexPath];
    
    if (currentTask) {
        taskCell.textLabel.text = currentTask.name;
        UILongPressGestureRecognizer *longPressRecognizer = [[UILongPressGestureRecognizer alloc]
                                                             initWithTarget:self
                                                             action:@selector(handleLongPress:)];
        longPressRecognizer.delegate = self;
        longPressRecognizer.delaysTouchesBegan = YES;
        [taskCell setGestureRecognizers:@[longPressRecognizer]];
    }
    
    return taskCell;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
                                            forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        NGNTask *currentTask = [self actualTaskWithIndexPath:indexPath];
        [self performTaskDeleteConfirmationDialogueAtTableView:tableView
                                                   atIndexPath:indexPath
                                             withStoreableItem:currentTask];
    }
}


- (UITableViewCellEditingStyle)tableView:(UITableView *)aTableView
           editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

// Override to insert some additional functionality to cell when you swipe left
-(NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //done row action (done - complete task)
    UITableViewRowAction *doneAction =
        [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal
                                           title:NGNControllerDoneButtonTitle
                                         handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        NGNTask *currentTask = [self actualTaskWithIndexPath:indexPath];
        currentTask.finishedAt = [NSDate date];
        currentTask.completed = YES;
        [self.tableView reloadData];
        //notify everyone that task was changed
        NSDictionary *userInfo = @{@"task": currentTask};
        [[NSNotificationCenter defaultCenter] postNotificationName:NGNNotificationNameTaskChange
                                                            object:nil
                                                          userInfo:userInfo];
    }];
    doneAction.backgroundColor = [UIColor grayColor];
    
    //delete row action
    UITableViewRowAction *deleteAction =
        [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal
                                           title:NGNControllerDeleteButtonTitle
                                         handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
            [self tableView:self.tableView commitEditingStyle:UITableViewCellEditingStyleDelete
                                            forRowAtIndexPath:indexPath];
    }];
    deleteAction.backgroundColor = [UIColor redColor];

    return @[deleteAction, doneAction];
}


// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath
                                                  toIndexPath:(NSIndexPath *)toIndexPath {
    if (self.segmentedControl.selectedSegmentIndex == 0) {
        NSMutableArray *currentTaskArray = self.dateSortedTaskListsArray[fromIndexPath.section];
        NSMutableArray *destinationTaskArray = self.dateSortedTaskListsArray[toIndexPath.section];
        if ([currentTaskArray isEqual:destinationTaskArray]) {
            [currentTaskArray exchangeObjectAtIndex:fromIndexPath.row withObjectAtIndex:toIndexPath.row];
        } else {
            NGNTask *fromTask = currentTaskArray[fromIndexPath.row];
            NGNTask *toTask = (destinationTaskArray.count - 1 > toIndexPath.row) ?
            destinationTaskArray[toIndexPath.row] :
            destinationTaskArray[destinationTaskArray.count - 1];
            fromTask.startedAt = toTask.startedAt;
        }
    } else {
        NGNTaskList *currentTaskList = [self actualTaskListWithIndexPath:fromIndexPath];
        NGNTaskList *destinationTaskList = [self actualTaskListWithIndexPath:toIndexPath];
        if (currentTaskList == destinationTaskList) {
            [currentTaskList relocateEntityAtIndex:fromIndexPath.row withEntityAtIndex:toIndexPath.row];
        } else {
            [destinationTaskList insertEntity:currentTaskList.entityCollection[fromIndexPath.row]
                                      atIndex:toIndexPath.row];
            [currentTaskList removeEntity:currentTaskList.entityCollection[fromIndexPath.row]];
        }
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:NGNNotificationNameGlobalModelChange
                                                        object:nil
                                                      userInfo:nil];
}

// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
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
    if (self.segmentedControl.selectedSegmentIndex == 0) {
        NSArray *taskListsArray = self.dateSortedTaskListsArray[section];
        NGNTask *currentTask;
        if ([taskListsArray count] != 0) {
            currentTask = [taskListsArray firstObject];
        }
        text = [NSDate ngn_formattedStringFromDate:currentTask.startedAt withFormat:NGNControllerShowingDateFormat];
    } else {
        NGNTaskList *list = [[NGNTaskService sharedInstance] allActiveTaskLists][section];
        text = list.name;
    }
    label.text = text;
    
    [view addSubview:label];
    
    return view;
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:NGNControllerSegueShowEditTask]) {
        NGNEditTaskViewController *editTaskViewController = segue.destinationViewController;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        NGNTask *task = [self actualTaskWithIndexPath:indexPath];
        NGNTaskList *currentTaskList = [self actualTaskListWithIndexPath:indexPath];
        editTaskViewController.entringTask = task;
        editTaskViewController.entringTaskList = currentTaskList;
    }
    if ([segue.identifier isEqualToString:NGNControllerSegueShowAddTask]) {
        NGNEditTaskViewController *addTaskViewController = segue.destinationViewController;
        NSInteger addingTaskId = foo4random();
        NGNTask *addingTask = [[NGNTask alloc] initWithId:addingTaskId name:NGNControllerNoneTitle];
        NGNTaskList *commonTaskList = (NGNTaskList *)[[NGNTaskService sharedInstance] entityById:999];
        addTaskViewController.navigationItem.title = NGNControllerAddTaskNavigationItemTitle;
        addTaskViewController.entringTask = addingTask;
        addTaskViewController.entringTaskList = commonTaskList;
    }
}

#pragma mark - additional handling methods

- (IBAction)sortDirectionBarButtonTapped:(UIBarButtonItem *)sender {
    self.ascendingSortDirection = self.isAscendingSortDirection ? NO : YES;
    [self sortData];
    [self.tableView reloadData];
}

- (NGNTask *)actualTaskWithIndexPath:(NSIndexPath *)indexPath {
    NGNTask *actualTask;
    if (self.segmentedControl.selectedSegmentIndex == 0) {
        actualTask = self.dateSortedTaskListsArray[indexPath.section][indexPath.row];
    } else {
        NGNTaskList *currentTaskList = [[NGNTaskService sharedInstance] allActiveTaskLists][indexPath.section];
        actualTask = [currentTaskList activeTasksList][indexPath.row];
    }
    return actualTask;
}

- (NGNTaskList *)actualTaskListWithIndexPath:(NSIndexPath *)indexPath {
    NGNTaskList *actualTaskList;
    if (self.segmentedControl.selectedSegmentIndex == 0) {
        NGNTask *actualTask = self.dateSortedTaskListsArray[indexPath.section][indexPath.row];
        actualTaskList = (NGNTaskList *)[[NGNTaskService sharedInstance] entityById:actualTask.entityId];
    } else {
        actualTaskList = [[NGNTaskService sharedInstance] allActiveTaskLists][indexPath.section];
    }
    return actualTaskList;
}

- (void)segmentedControlSelectionChange {
    [self sortData];
    [self.tableView reloadData];
}

// method helps to reload data on controller with renewed data from model
- (void)refreshData {
    self.dateSortedTaskListsArray = [[[NGNTaskService sharedInstance] allActiveTasksGroupedByStartDate] mutableCopy];
    [self segmentedControlSelectionChange];
    [self.tableView reloadData];
}

- (void)sortData {
    if (self.segmentedControl.selectedSegmentIndex == 0) {
        [self.dateSortedTaskListsArray sortUsingComparator:
         ^(NSArray *list1, NSArray *list2) {
             if ((list1.count != 0) && (list2.count != 0)) {
                 NGNTask *firstTask = [list1 firstObject];
                 NGNTask *secondTask = [list2 firstObject];
                 NSInteger comparisonResult =
                    [NSDate ngn_compareDateWithoutTimePortion:firstTask.startedAt date:secondTask.startedAt];
                 comparisonResult = self.isAscendingSortDirection ? comparisonResult : comparisonResult * -1;
                 return comparisonResult;
             }
             return NSOrderedSame;
         }];
        
    } else if (self.segmentedControl.selectedSegmentIndex == 1) {
        [[NGNTaskService sharedInstance] sortEntityCollectionUsingComparator:
         ^(NGNTaskList *list1, NGNTaskList *list2) {
             NSInteger comparisonResult = [list1.name compare:list2.name];
             comparisonResult = self.isAscendingSortDirection ? comparisonResult : comparisonResult * -1;
             return comparisonResult;
         }];
    }
}

@end
