//
//  NGNTaskDetailsViewController.m
//  TODOList
//
//  Created by Alex on 04.06.17.
//  Copyright © 2017 Alex. All rights reserved.
//

#import "NGNTaskDetailsViewController.h"
#import "NGNEditViewController.h"
#import "NGNDateFormatHelper.h"
#import "NGNTask.h"
#import "NGNConstants.h"

@interface NGNTaskDetailsViewController () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UILabel *taskIdLabel;
@property (strong, nonatomic) IBOutlet UILabel *taskNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *startDateLabel;
@property (strong, nonatomic) IBOutlet UILabel *finishDateLabel;
@property (strong, nonatomic) IBOutlet UILabel *notesLabel;
@property (strong, nonatomic) IBOutlet UIButton *doneButton;

- (IBAction)doneButtonTapped:(UIButton *)sender;
- (IBAction)editBarButtonTapped:(UIBarButtonItem *)sender;


@end

@implementation NGNTaskDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.entringTask) {
        [self renewInformation];
    }
    
    [[NSNotificationCenter defaultCenter]
     addObserverForName:NGNNotificationNameTaskChange
     object:nil
     queue:[NSOperationQueue mainQueue]
     usingBlock:^(NSNotification *notification) {
         NSDictionary *userInfo = notification.userInfo;
         NGNTask *task = userInfo[@"task"];
         if ([task isEqual:self.entringTask]) {
             self.entringTask = task;
             [self renewInformation];
         }
     }];
}

- (IBAction)doneButtonTapped:(UIButton *)sender {
    self.finishDateLabel.text = [NGNDateFormatHelper formattedStringFromDate:[NSDate date]];
    self.entringTask.finishedAt = [NSDate date];
    self.entringTask.completed = YES;
    NSDictionary *userInfo = @{@"task": self.entringTask};
    [[NSNotificationCenter defaultCenter] postNotificationName:NGNNotificationNameTaskChange
                                                        object:nil
                                                      userInfo:userInfo];
    self.entringTask.completed = YES;
    self.doneButton.enabled = NO;
    self.navigationItem.rightBarButtonItem.enabled = NO;
}

- (IBAction)editBarButtonTapped:(UIBarButtonItem *)sender {
    NGNEditViewController *editViewController = [[NGNEditViewController alloc] init];
    editViewController.entringTask = self.entringTask;
    [self showViewController:editViewController sender:sender];
}

- (void)renewInformation {
    self.taskIdLabel.text = self.entringTask.taskId;
    self.taskNameLabel.text = self.entringTask.name;
    self.startDateLabel.text = [NGNDateFormatHelper formattedStringFromDate:self.entringTask.startedAt];
    self.notesLabel.text = self.entringTask.notes;
    if (self.entringTask.isCompleted) {
        self.finishDateLabel.text = [NGNDateFormatHelper formattedStringFromDate:self.entringTask.finishedAt];
        self.doneButton.enabled = NO;
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//#warning Incomplete implementation, return the number of sections
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//#warning Incomplete implementation, return the number of rows
    return 6;
}

/*
 - (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
 UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
 
 // Configure the cell...
 
 return cell;
 }
 */

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

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
