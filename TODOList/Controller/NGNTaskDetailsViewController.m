//
//  NGNTaskDetailsViewController.m
//  TODOList
//
//  Created by Alex on 04.06.17.
//  Copyright © 2017 Alex. All rights reserved.
//

#import "NGNTaskDetailsViewController.h"
#import "NSDate+NGNDateToStringConverter.h"
#import "NGNEditTaskViewController.h"
#import "NGNTask.h"
#import "NGNConstants.h"

@interface NGNTaskDetailsViewController () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UILabel *taskIdLabel;
@property (strong, nonatomic) IBOutlet UILabel *taskNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *startDateLabel;
@property (strong, nonatomic) IBOutlet UILabel *finishDateLabel;
@property (strong, nonatomic) IBOutlet UILabel *notesLabel;
@property (strong, nonatomic) IBOutlet UIButton *doneButton;
@property (strong, nonatomic) IBOutlet UILabel *priorityLabel;

- (IBAction)doneButtonTapped:(UIButton *)sender;


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
    self.finishDateLabel.text = [NSDate ngn_formattedStringFromDate:[NSDate date]];
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

- (void)renewInformation {
    self.taskIdLabel.text = [NSString stringWithFormat:@"%ld", self.entringTask.entityId];
    self.taskNameLabel.text = self.entringTask.name;
    self.startDateLabel.text = [NSDate ngn_formattedStringFromDate:self.entringTask.startedAt];
    self.notesLabel.text = self.entringTask.notes;
    self.priorityLabel.text = !self.entringTask.priority ?
                                                 @"None" :
                                                 [NSString stringWithFormat:@"%ld", self.entringTask.priority];
    if (self.entringTask.isCompleted) {
        self.finishDateLabel.text = [NSDate ngn_formattedStringFromDate:self.entringTask.finishedAt];
        self.doneButton.enabled = NO;
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:NGNControllerSegueShowEditTask]) {
        NGNEditTaskViewController *editTaskViewController = [segue destinationViewController];
        editTaskViewController.entringTask = self.entringTask;
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 7;
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

@end
