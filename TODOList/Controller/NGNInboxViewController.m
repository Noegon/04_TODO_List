//
//  NGNInboxViewController.m
//  TODOList
//
//  Created by Alex on 01.06.17.
//  Copyright © 2017 Alex. All rights reserved.
//

#import "NGNInboxViewController.h"
#import "NGNEditViewController.h"
#import "NGNTaskDetailsViewController.h"
#import "NSDate+NGNDateToStringConverter.h"
#import "NGNTask.h"
#import "NGNTaskList.h"
#import "NGNTaskService.h"
#import "NGNConstants.h"

static NSString *const NGNTaskCellIdentifier = @"NGNTaskCell";

@interface NGNInboxViewController () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) NGNTaskList *taskList;

- (IBAction)addButtonTapped:(UIBarButtonItem *)sender;

@end

@implementation NGNInboxViewController

-(instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        _taskList = [[NGNTaskList alloc]initWithId:2 name:@"Common task list"];
        [[NGNTaskService sharedInstance]addEntity:self.taskList];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [[NSNotificationCenter defaultCenter] addObserverForName:NGNNotificationNameTaskChange
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *notification) {
        NSDictionary *userInfo = notification.userInfo;
        NGNTask *task = userInfo[@"task"];
        if ([self.taskList entityById:task.entityId]) {
            [self.taskList updateEntity:task];
                                                      }
        [[NGNTaskService sharedInstance]updateEntity:self.taskList];
        [self.tableView reloadData];
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    for (NGNTask *task in self.taskList.entityCollection) {
        if (![task.name length]) {
            [self.taskList removeEntity:task];
        }
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//#warning Incomplete implementation, return the number of sections
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//#warning Incomplete implementation, return the number of rows
    return [[[NGNTaskService sharedInstance]allActiveTasks] count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *taskCell = [tableView dequeueReusableCellWithIdentifier:NGNControllerTaskCellIdentifier
                                                                forIndexPath:indexPath];
//    NGNTask *task = self.taskService.taskList[indexPath.row];
    NGNTask *task = [[NGNTaskService sharedInstance]allActiveTasks][indexPath.row];
    taskCell.textLabel.text = task.name;
    return taskCell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NGNTaskDetailsViewController *taskDetailsViewController = (NGNTaskDetailsViewController *)segue.destinationViewController;
    if ([segue.identifier isEqualToString:NGNControllerSegueShowTaskDetail]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        NGNTask *task = [[NGNTaskService sharedInstance]allActiveTasks][indexPath.row];
        taskDetailsViewController.entringTask = task;
    }
}

- (IBAction)addButtonTapped:(UIBarButtonItem *)sender {
    NGNTask *task = [NGNTask taskWithId:0 name:nil];
    [self.taskList addEntity:task];
    NGNEditViewController *editViewController = [[NGNEditViewController alloc] init];
    editViewController.entringTask = task;
    [self showViewController:editViewController sender:sender];
}

@end
