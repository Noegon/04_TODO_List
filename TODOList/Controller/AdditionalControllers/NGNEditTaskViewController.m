//
//  NGNEditTaskViewController.m
//  TODOList
//
//  Created by Alex on 11.06.17.
//  Copyright © 2017 Alex. All rights reserved.
//

#import "NGNEditTaskViewController.h"
#import "NGNDatePickingViewController.h"
#import "NGNPriorityViewController.h"
#import "NSDate+NGNDateToStringConverter.h"
#import "NGNConstants.h"
#import "NGNTask.h"
#import "NGNTaskList.h"

@interface NGNEditTaskViewController ()

@property (strong, nonatomic) IBOutlet UITextField *taskNameInsertTextField;
@property (strong, nonatomic) IBOutlet UITextView *notesInsertTextView;
@property (strong, nonatomic) IBOutlet UITableViewCell *dateTableCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *priorityTableCell;
@property (strong, nonatomic) IBOutlet UISwitch *remaindDaySwither;

- (IBAction)taskNameChanged:(UITextField *)sender;
- (IBAction)saveBarButtonTapped:(UIBarButtonItem *)sender;
- (IBAction)reminderSwitchChangeValue:(UISwitch *)sender;

#pragma mark - gestures handling
- (void)dismissKeyboard;

@end

@implementation NGNEditTaskViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    srand((unsigned int)time(NULL));
    
    // taskNameInsertTextField configured
    [self.taskNameInsertTextField becomeFirstResponder];
    
    // navigation bar title is set
    if (![self.navigationItem.title isEqualToString:@"Add task"]) {
        self.navigationItem.title = @"Edit task";
    }
    
    // save bar button is set and configured
    UIBarButtonItem *saveBarButton =
        [[UIBarButtonItem alloc] initWithTitle:NGNControllerSaveButtonTitle
                                         style:UIBarButtonItemStylePlain
                                        target:self
                                        action:@selector(saveBarButtonTapped:)];
    if (!self.taskNameInsertTextField.text) {
        saveBarButton.enabled = NO;
    }
    self.navigationItem.rightBarButtonItem = saveBarButton;
    saveBarButton = nil;
    
    if (!self.entringTask) {
        NSInteger newTaskId = (rand() % INT_MAX);
        self.entringTask = [[NGNTask alloc] initWithId:newTaskId name:@"None"];
    }
    
    NSString *stringfiedTaskDate = [NSDate ngn_formattedStringFromDate:self.entringTask.startedAt];
    self.taskNameInsertTextField.text = self.entringTask.name;
    self.dateTableCell.textLabel.text = stringfiedTaskDate;
    self.notesInsertTextView.text = self.entringTask.notes;
    self.priorityTableCell.detailTextLabel.text =
        !self.entringTask.priority ? @"None" :
        [NSString stringWithFormat:@"%ld", self.entringTask.priority];
    self.remaindDaySwither.on = self.entringTask.shouldRemindOnDay;
    
    [[NSNotificationCenter defaultCenter]
     addObserverForName:NGNNotificationNameTaskChange
     object:nil
     queue:[NSOperationQueue mainQueue]
     usingBlock:^(NSNotification *notification) {
         NSDictionary *userInfo = notification.userInfo;
         NGNTask *task = userInfo[@"task"];
         self.dateTableCell.textLabel.text =
            [NSDate ngn_formattedStringFromDate:task.startedAt];
         self.priorityTableCell.detailTextLabel.text = [NSString stringWithFormat:@"%ld", task.priority];
     }];
    
    // adding gesture recognizer to hide keyboard by tapping out of text fields
    UITapGestureRecognizer *tapOutOfTextFields = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(dismissKeyboard)];
    
    UITapGestureRecognizer *tapOnDateCell = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                    action:@selector(showDatePicker)];
    UITapGestureRecognizer *tapOnPriorityCell = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                        action:@selector(showPriorityPicker)];
    
    [self.view addGestureRecognizer:tapOutOfTextFields];
    [self.dateTableCell addGestureRecognizer:tapOnDateCell];
    [self.priorityTableCell addGestureRecognizer:tapOnPriorityCell];
}

- (IBAction)saveBarButtonTapped:(UIBarButtonItem *)sender {
    self.entringTask.name = self.taskNameInsertTextField.text;
    self.entringTask.startedAt = [NSDate ngn_dateFromString:self.dateTableCell.textLabel.text];
    self.entringTask.notes = self.notesInsertTextView.text;
    NSDictionary *userInfo = @{@"task": self.entringTask,
                               @"taskList": self.entringTaskList};
    NSString *notificationName;
    
    if ([self.navigationItem.title containsString:@"Add"]) {
        notificationName = NGNNotificationNameTaskAdd;
        [self.entringTaskList addEntity:self.entringTask];
    } else {
        notificationName = NGNNotificationNameTaskChange;
        [self.entringTaskList updateEntity:self.entringTask];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:notificationName
                                                        object:nil
                                                      userInfo:userInfo];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)taskNameChanged:(UITextField *)sender {
    self.navigationItem.rightBarButtonItem.enabled = [sender.text length] ? YES : NO;
}

- (IBAction)reminderSwitchChangeValue:(UISwitch *)sender {
    self.entringTask.shouldRemindOnDay = sender.isOn;
}

#pragma mark - gestures handling

- (void)dismissKeyboard {
    [self.taskNameInsertTextField resignFirstResponder];
    [self.notesInsertTextView resignFirstResponder];
}

- (void)showDatePicker {
    NGNDatePickingViewController *datePickingViewController = [[NGNDatePickingViewController alloc]init];
    datePickingViewController.entringTask = self.entringTask;
    [self showViewController:datePickingViewController sender:nil];
}

- (void)showPriorityPicker {
    [self performSegueWithIdentifier:NGNControllerSegueShowPrioritiesModal sender:nil];
}

 #pragma mark - Navigation
 
//  In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:NGNControllerSegueShowPrioritiesModal]) {
        NGNPriorityViewController *priorityViewController = [segue destinationViewController];
        //transparent background
        priorityViewController.providesPresentationContextTransitionStyle = YES;
        priorityViewController.definesPresentationContext = YES;
        [priorityViewController setModalPresentationStyle:UIModalPresentationOverFullScreen];
        
        priorityViewController.entringTask = self.entringTask;
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section != 1) {
        return 1;
    }
    return 2;
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
