//
//  NGNProjectsViewController.m
//  TODOList
//
//  Created by Alex on 02.06.17.
//  Copyright © 2017 Alex. All rights reserved.
//

#import "NGNProjectsViewController.h"
#import "NGNTaskListDetailsViewController.h"
#import "NSDate+NGNDateToStringConverter.h"
#import "NGNEditTaskViewController.h"
#import "NGNTask.h"
#import "NGNTaskList.h"
#import "NGNTaskService.h"
#import "NGNConstants.h"

static NSString *const NGNTaskListCellIdentifier = @"NGNTaskListCell";

@interface NGNProjectsViewController () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) NGNTaskList *taskList;

- (IBAction)editBarButtonTapped:(UIBarButtonItem *)sender;
- (IBAction)doneBarButtonTapped:(UIBarButtonItem *)sender;

@end

@implementation NGNProjectsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    srand((unsigned int)time(NULL));
    
    [[NSNotificationCenter defaultCenter] addObserverForName:NGNNotificationNameTaskListChange
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
    
    [[NSNotificationCenter defaultCenter] addObserverForName:NGNNotificationNameGlobalModelChange
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *notification) {
                                                      [self.tableView reloadData];
                                                  }];
    
    [self.tableView setEditing:NO animated:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    for (NGNTask *task in self.taskList.entityCollection) {
        if (![task.name length]) {
            [self.taskList removeEntity:task];
        }
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[NGNTaskService sharedInstance] entityCollection].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *taskCell = [tableView dequeueReusableCellWithIdentifier:NGNControllerTaskListCellIdentifier
                                                                forIndexPath:indexPath];
    NGNTaskList *currentTaskList = [NGNTaskService sharedInstance].entityCollection[indexPath.row];
    taskCell.textLabel.text = currentTaskList.name;
    taskCell.detailTextLabel.text = [NSString stringWithFormat:@"(%ld)", [currentTaskList entityCollection].count];
    return taskCell;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
                                            forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NGNTaskList *currentTaskList = [NGNTaskService sharedInstance].entityCollection[indexPath.row];
        [[NGNTaskService sharedInstance] removeEntity:currentTaskList];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        // notification to delete all information about deleted project
        [[NSNotificationCenter defaultCenter] postNotificationName:NGNNotificationNameGlobalModelChange
                                                            object:nil
                                                          userInfo:nil];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)aTableView
           editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:NGNControllerSegueShowAddProject]) {
    }
    if ([segue.identifier isEqualToString:NGNControllerSegueShowTaskListDetail]) {
        NGNTaskListDetailsViewController *taskListDetailsViewController = segue.destinationViewController;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        NGNTaskList *currentTaskList = [NGNTaskService sharedInstance].entityCollection[indexPath.row];
        taskListDetailsViewController.entringTaskList = currentTaskList;
    }
}

#pragma mark - additional handling methods

- (IBAction)editBarButtonTapped:(UIBarButtonItem *)sender {
    UIBarButtonItem *doneBarButton = [[UIBarButtonItem alloc] initWithTitle:NGNControllerDoneButtonTitle
                                                                      style:UIBarButtonItemStylePlain
                                                                     target:self
                                                                     action:@selector(doneBarButtonTapped:)];
    self.navigationItem.leftBarButtonItem = doneBarButton;
    [self.tableView setEditing:YES];
    doneBarButton = nil;
}

- (IBAction)doneBarButtonTapped:(UIBarButtonItem *)sender {
    UIBarButtonItem *editBarButton = [[UIBarButtonItem alloc] initWithTitle:NGNControllerEditButtonTitle
                                                                      style:UIBarButtonItemStylePlain
                                                                     target:self
                                                                     action:@selector(editBarButtonTapped:)];
    self.navigationItem.leftBarButtonItem = editBarButton;
    [self.tableView setEditing:NO];
    editBarButton = nil;
}

@end
