//
//  NGNInboxViewController.m
//  TODOList
//
//  Created by Alex on 01.06.17.
//  Copyright © 2017 Alex. All rights reserved.
//

#import "NGNInboxViewController.h"
#import "NGNTaskDetailsViewController.h"
#import "NSDate+NGNDateToStringConverter.h"
#import "NGNEditTaskViewController.h"
#import "NGNTask.h"
#import "NGNTaskList.h"
#import "NGNTaskService.h"
#import "NGNConstants.h"

@interface NGNInboxViewController () <UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate>

@property (strong, nonatomic) NGNTaskList *taskList;
@property (strong, nonatomic) UISegmentedControl *segmentedControl;

- (IBAction)editBarButtonTapped:(UIBarButtonItem *)sender;
- (IBAction)doneBarButtonTapped:(UIBarButtonItem *)sender;
- (void)segmentedControlSelectionChange;

@end

@implementation NGNInboxViewController

-(instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        _taskList = [[NGNTaskList alloc]initWithId:999 name:@"Common task list"];
        [[NGNTaskService sharedInstance]addEntity:self.taskList];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    srand((unsigned int)time(NULL));

    [[NSNotificationCenter defaultCenter] addObserverForName:NGNNotificationNameTaskChange
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *notification) {
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
    
    [[NSNotificationCenter defaultCenter] addObserverForName:NGNNotificationNameTaskAdd
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *notification) {
                                                      [self.tableView reloadData];
                                                  }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:NGNNotificationNameTaskListAdd
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *notification) {
                                                      [self.tableView reloadData];
                                                  }];
    
    [self.tableView setEditing:NO animated:YES];
    
    //adding segment control into table header
    self.segmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"Date", @"Group"]];
    [self.segmentedControl setWidth:(self.view.bounds.size.width-20)/2 forSegmentAtIndex:0];
    [self.segmentedControl setWidth:(self.view.bounds.size.width-20)/2 forSegmentAtIndex:1];
    [self.segmentedControl setSelectedSegmentIndex:1];
    UIView *tableHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 60)];
    [tableHeader setBackgroundColor:[UIColor whiteColor]];
    self.tableView.tableHeaderView = tableHeader;
    [self.tableView.tableHeaderView addSubview:self.segmentedControl];
    [self.segmentedControl setCenter:CGPointMake((self.view.bounds.size.width)/2, 60/2)];
    
    [self.segmentedControl addTarget:self
                              action:@selector(segmentedControlSelectionChange)
                    forControlEvents:UIControlEventValueChanged];
    
    [self segmentedControlSelectionChange];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.segmentedControl.selectedSegmentIndex == 0) {
        NSArray *datesArray = [[NGNTaskService sharedInstance] allActiveTasksGroupedByStartDate];
        return [datesArray count];
    }
    return [[NGNTaskService sharedInstance] entityCollection].count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.segmentedControl.selectedSegmentIndex == 0) {
        NSArray *datesArray = [[NGNTaskService sharedInstance] allActiveTasksGroupedByStartDate];
        return [datesArray[section] count];
    }
    NGNTaskList *currentTaskList = [NGNTaskService sharedInstance].entityCollection[section];
    return [currentTaskList activeTasksList].count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *taskCell = [tableView dequeueReusableCellWithIdentifier:NGNControllerTaskCellIdentifier
                                                                forIndexPath:indexPath];
    NGNTask *currentTask;
    if (self.segmentedControl.selectedSegmentIndex == 0) {
        NSArray *taskArray = [[NGNTaskService sharedInstance] allActiveTasksGroupedByStartDate][indexPath.section];
        currentTask = taskArray[indexPath.row];
    } else {
        NGNTaskList *currentTaskList = [NGNTaskService sharedInstance].entityCollection[indexPath.section];
        currentTask = [currentTaskList activeTasksList][indexPath.row];
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
    NGNTaskList *currentTaskList = [NGNTaskService sharedInstance].entityCollection[indexPath.section];
    NGNTask *currentTask;
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        if (self.segmentedControl.selectedSegmentIndex == 0) {
            NSMutableArray *currentTaskArray =
                [[NGNTaskService sharedInstance] allActiveTasksGroupedByStartDate][indexPath.section];
            currentTask = currentTaskArray[indexPath.row];
            [[NGNTaskService sharedInstance] removeTask:currentTask];
        } else {
            currentTask = currentTaskList.entityCollection[indexPath.row];
            [currentTaskList removeEntity:currentTask];
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        NSInteger newTaskId = (rand() % INT_MAX);
        currentTask = [[NGNTask alloc] initWithId:newTaskId name:@"None"];
        [currentTaskList pushEntity:currentTask];
        [tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:NGNNotificationNameGlobalModelChange
                                                        object:nil
                                                      userInfo:nil];
    [self.tableView reloadData];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)aTableView
           editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

// Override to insert some additional functionality to cell when you swipe left
-(NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //edit row action (done - complete task)
    UITableViewRowAction *editAction =
        [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal
                                           title:@"Done"
                                         handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        NGNTask *currentTask;
        if (self.segmentedControl.selectedSegmentIndex == 0) {
            NSMutableArray *currentTaskArray =
                [[NGNTaskService sharedInstance] allActiveTasksGroupedByStartDate][indexPath.section];
            currentTask = currentTaskArray[indexPath.row];
        } else {
            NGNTaskList *currentTaskList = [NGNTaskService sharedInstance].entityCollection[indexPath.section];
            currentTask = [currentTaskList activeTasksList][indexPath.row];
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
    
    //insert row action
    UITableViewRowAction *insertAction =
        [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"Insert"
                                     handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
        [self tableView:self.tableView commitEditingStyle:UITableViewCellEditingStyleInsert forRowAtIndexPath:indexPath];
    }];
    insertAction.backgroundColor = [UIColor greenColor];
    
    if (self.segmentedControl.selectedSegmentIndex == 0) {
        return @[deleteAction,editAction];
    }
    return @[deleteAction,editAction, insertAction];
}


// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath
                                                  toIndexPath:(NSIndexPath *)toIndexPath {
    if (self.segmentedControl.selectedSegmentIndex == 0) {
        NSMutableArray *currentTaskArray = [[NGNTaskService sharedInstance] allActiveTasksGroupedByStartDate][fromIndexPath.section];
        NSMutableArray *destinationTaskArray = [[NGNTaskService sharedInstance] allActiveTasksGroupedByStartDate][toIndexPath.section];
        if ([currentTaskArray isEqual:destinationTaskArray]) {
            [currentTaskArray exchangeObjectAtIndex:fromIndexPath.row withObjectAtIndex:toIndexPath.row];
        } else {
            NGNTask *fromTask = currentTaskArray[fromIndexPath.row];
            NGNTask *toTask = destinationTaskArray[toIndexPath.row];
            fromTask.startedAt = toTask.startedAt;
            [destinationTaskArray insertObject:fromTask atIndex:toIndexPath.row];
            [currentTaskArray removeObject:fromTask];
        }
    } else {
        NGNTaskList *currentTaskList = [NGNTaskService sharedInstance].entityCollection[fromIndexPath.section];
        NGNTaskList *destinationTaskList = [NGNTaskService sharedInstance].entityCollection[toIndexPath.section];
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

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (self.segmentedControl.selectedSegmentIndex == 0) {
        NSArray *taskListsArray = [[NGNTaskService sharedInstance] allActiveTasksGroupedByStartDate][section];
        NGNTask *currentTask;
        if ([taskListsArray count]) {
            currentTask = [taskListsArray firstObject];
        }
        return [NSDate ngn_formattedStringFromDate:currentTask.startedAt];
    }
    NGNTaskList *list = [NGNTaskService sharedInstance].entityCollection[section];
    return list.name;
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NGNTaskDetailsViewController *taskDetailsViewController = segue.destinationViewController;
    if ([segue.identifier isEqualToString:NGNControllerSegueShowTaskDetail]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        NGNTask *task;
        NGNTaskList *currentTaskList;
        if (self.segmentedControl.selectedSegmentIndex == 0) {
            NSArray *taskListsArray = [[NGNTaskService sharedInstance] allActiveTasksGroupedByStartDate][indexPath.section];
            task = taskListsArray[indexPath.row];
            currentTaskList = [[NGNTaskService sharedInstance] taskListByTaskId:task.entityId];
        } else {
            currentTaskList = [NGNTaskService sharedInstance].entityCollection[indexPath.section];
            task = [currentTaskList activeTasksList][indexPath.row];
        }
        taskDetailsViewController.entringTask = task;
        taskDetailsViewController.entringTaskList = currentTaskList;
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

- (void)segmentedControlSelectionChange {
    if (self.segmentedControl.selectedSegmentIndex == 0) {
        [[[NGNTaskService sharedInstance] allActiveTasksGroupedByStartDate] sortUsingComparator:
         ^(NSMutableArray *list1, NSMutableArray *list2) {
             if ([list1 count] && [list2 count]) {
                 NGNTask *firstTask = [list1 firstObject];
                 NGNTask *secondTask = [list2 firstObject];
                 return [firstTask.startedAt compare: secondTask.startedAt];
             }
             return NSOrderedSame;
         }];

    } else if (self.segmentedControl.selectedSegmentIndex == 1) {
        [[NGNTaskService sharedInstance] sortEntityCollectionUsingComparator:
         ^(NGNTaskList *list1, NGNTaskList *list2) {
             return [list1.name compare:list2.name];
         }];
    }
    [self.tableView reloadData];
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
