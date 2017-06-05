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
#import "NGNDateFormatHelper.h"
#import "NGNTask.h"
#import "NGNTaskService.h"
#import "NGNConstants.h"

static NSString *const NGNTaskCellIdentifier = @"NGNTaskCell";

@interface NGNInboxViewController () <UITableViewDataSource, UITableViewDelegate, NGNEditViewControllerDelegate>

@property (strong, nonatomic) NGNTaskService *taskService;

- (IBAction)addButtonTapped:(UIBarButtonItem *)sender;

@end

@implementation NGNInboxViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Tasks for testing application
    NGNTask *task1 = [NGNTask taskWithId:@"1" name:@"Make calculator 3.0"];
    NGNTask *task2 = [NGNTask taskWithId:@"2" name:@"Make TODO List 0.1"];
    NGNTask *task3 = [NGNTask taskWithId:@"3" name:@"Make somthing useful"];
    self.taskService = [[NGNTaskService alloc]init];
    [self.taskService addTask:task1];
    [self.taskService addTask:task2];
    [self.taskService addTask:task3];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//#warning Incomplete implementation, return the number of sections
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//#warning Incomplete implementation, return the number of rows
    return [self.taskService.taskList count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *taskCell = [tableView dequeueReusableCellWithIdentifier:NGNControllerTaskCellIdentifier
                                                                forIndexPath:indexPath];
    NGNTask *task = self.taskService.taskList[indexPath.row];
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
    NGNTaskDetailsViewController *controller = (NGNTaskDetailsViewController *)segue.destinationViewController;
    if ([controller isKindOfClass:[NGNTaskDetailsViewController class]]) {
        NGNTask *entringTask = [self.taskService taskByName:[(UITableViewCell *)sender textLabel].text];
        controller.entringTask = entringTask;
        entringTask = nil;
    }
    // Pass the selected object to the new view controller.
}


- (IBAction)addButtonTapped:(UIBarButtonItem *)sender {
    NGNEditViewController *editViewController = [[NGNEditViewController alloc] init];
//    [self.navigationController pushViewController:editViewController animated:YES];
    editViewController.delegate = self;
    [self showViewController:editViewController sender:sender];
    editViewController = nil;
}

#pragma mark - delegate methods
- (void)editViewController:(NGNEditViewController *)editViewController
              didSavedTask:(NGNTask *)task {
    [self.taskService updateTask:task];
    [self.tableView reloadData];
}

@end
