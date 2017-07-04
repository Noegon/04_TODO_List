//
//  NGNEditTaskViewController.m
//  TODOList
//
//  Created by Alex on 11.06.17.
//  Copyright © 2017 Alex. All rights reserved.
//

#import <UserNotifications/UserNotifications.h>

#import "NGNEditTaskViewController.h"
#import "NGNDatePickingViewController.h"
#import "NSDate+NGNDateToStringConverter.h"
#import "NGNConstants.h"
#import "NGNTask.h"
#import "NGNTaskList.h"
#import "NGNTaskService.h"

@interface NGNEditTaskViewController ()

@property (strong, nonatomic) IBOutlet UITextField *taskNameInsertTextField;
@property (strong, nonatomic) IBOutlet UITextView *notesInsertTextView;
@property (strong, nonatomic) IBOutlet UITableViewCell *dateTableCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *priorityTableCell;
@property (strong, nonatomic) IBOutlet UISwitch *remaindDaySwither;

- (IBAction)taskNameChanged:(UITextField *)sender;
- (IBAction)saveBarButtonTapped:(UIBarButtonItem *)sender;

#pragma mark - gestures handling
- (void)dismissKeyboard;

#pragma mark - additional handling methods
- (NSString *)stringfiedPriority:(NSInteger)priority;

@end

@implementation NGNEditTaskViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //removing notification if delivered
    NSString *notificationID =
        [NSString stringWithFormat:@"%@%ld", NGNNotificationRequestIDTaskTime, self.entringTask.entityId];
    [[UNUserNotificationCenter currentNotificationCenter]
     removeDeliveredNotificationsWithIdentifiers:@[notificationID]];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NGNNotificationNameLocalNotificationListChanged
                                                        object:nil
                                                      userInfo:nil];
    
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
        NSInteger newTaskId = foo4random();
        self.entringTask = [[NGNTask alloc] initWithId:newTaskId name:@"None"];
    }
    
    NSString *stringfiedTaskDate = [NSDate ngn_formattedStringFromDate:self.entringTask.startedAt];
    self.taskNameInsertTextField.text = self.entringTask.name;
    self.dateTableCell.textLabel.text = stringfiedTaskDate;
    self.notesInsertTextView.text = self.entringTask.notes;
    self.priorityTableCell.detailTextLabel.text = [self stringfiedPriority:self.entringTask.priority];
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
    
    UITapGestureRecognizer *tapOnPriorityCell = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                        action:@selector(showPriorityPicker)];
    
    UITapGestureRecognizer *tapOnDatePickingCell = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                        action:@selector(showDatePicker)];
    
    [self.view addGestureRecognizer:tapOutOfTextFields];
    [self.priorityTableCell addGestureRecognizer:tapOnPriorityCell];
    [self.dateTableCell addGestureRecognizer:tapOnDatePickingCell];
}

- (IBAction)saveBarButtonTapped:(UIBarButtonItem *)sender {
    self.entringTask.name = self.taskNameInsertTextField.text;
    self.entringTask.startedAt = [NSDate ngn_dateFromString:self.dateTableCell.textLabel.text];
    self.entringTask.notes = self.notesInsertTextView.text;
    self.entringTask.shouldRemindOnDay = self.remaindDaySwither.on;
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
    
    //notifications
    [[NSNotificationCenter defaultCenter] postNotificationName:notificationName
                                                        object:nil
                                                      userInfo:userInfo];
    
    //local notifications
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"10.0")) {
        NSString *notificationID =
            [NSString stringWithFormat:@"%@%ld", NGNNotificationRequestIDTaskTime, self.entringTask.entityId];
        if (self.entringTask.shouldRemindOnDay) {
            NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
            
            [calendar setTimeZone:[NSTimeZone localTimeZone]];
            
            NSDateComponents *components =
                [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour |
                                     NSCalendarUnitMinute | NSCalendarUnitSecond|NSCalendarUnitTimeZone
                            fromDate:[self.entringTask.startedAt dateByAddingTimeInterval:0]];
            
            UNMutableNotificationContent *objNotificationContent = [[UNMutableNotificationContent alloc] init];
            objNotificationContent.title = [NSString localizedUserNotificationStringForKey:@"Task is started!" arguments:nil];
            objNotificationContent.body = [NSString localizedUserNotificationStringForKey:self.entringTask.name
                                                                                arguments:nil];
            objNotificationContent.sound = [UNNotificationSound defaultSound];
            // update application icon badge number
            objNotificationContent.badge = @([[UIApplication sharedApplication] applicationIconBadgeNumber] + 1);
            objNotificationContent.userInfo = @{@"taskId": @(self.entringTask.entityId),
                                                @"taskListId": @(self.entringTaskList.entityId)};
            
            UNCalendarNotificationTrigger *trigger =
                [UNCalendarNotificationTrigger triggerWithDateMatchingComponents:components repeats:NO];
            
            
            UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:notificationID
                                                                                  content:objNotificationContent
                                                                                  trigger:trigger];
            UNUserNotificationCenter *userCenter = [UNUserNotificationCenter currentNotificationCenter];
            [userCenter addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
                if (!error) {
                    NSLog(@"Local Notification succeeded");
                }
                else {
                    NSLog(@"Local Notification failed");
                }
            }];
        } else {
            [[UNUserNotificationCenter currentNotificationCenter]
             removePendingNotificationRequestsWithIdentifiers:@[notificationID]];
        }
//        [[UNUserNotificationCenter currentNotificationCenter]
//            getPendingNotificationRequestsWithCompletionHandler:^(NSArray *requests){
//                for (UNNotificationRequest *request in requests) {
//                    NSNumber *tasklistId = request.content.userInfo[@"taskListId"];
//                    NGNTaskList *list = [[NGNTaskService sharedInstance] entityById: tasklistId.integerValue];
//                    NSNumber *taskId = request.content.userInfo[@"taskId"];
//                    NGNTask *task = [list entityById: taskId.integerValue];
//                    NSLog(@"%@", task);
//                }
//        }];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)taskNameChanged:(UITextField *)sender {
    self.navigationItem.rightBarButtonItem.enabled = [sender.text length] ? YES : NO;
}

#pragma mark - gestures handling

- (void)dismissKeyboard {
    [self.taskNameInsertTextField resignFirstResponder];
    [self.notesInsertTextView resignFirstResponder];
}

- (void)showPriorityPicker {
    UIAlertController *alertViewController = [UIAlertController alertControllerWithTitle:@"Select priority"
                                                                                 message:nil
                                                                          preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    [alertViewController addAction:cancelAction];
    
    UIAlertAction *nonePriorityAction = [UIAlertAction actionWithTitle:@"None"
                                                                 style:UIAlertActionStyleDefault
                                                               handler:^(UIAlertAction * _Nonnull action) {
        self.entringTask.priority = NGNNonePriority;
        self.priorityTableCell.detailTextLabel.text = [self stringfiedPriority:self.entringTask.priority];
    }];
    [alertViewController addAction:nonePriorityAction];
    
    UIAlertAction *lowPriorityAction = [UIAlertAction actionWithTitle:@"Low"
                                                                 style:UIAlertActionStyleDefault
                                                               handler:^(UIAlertAction * _Nonnull action) {
        self.entringTask.priority = NGNLowPriority;
        self.priorityTableCell.detailTextLabel.text = [self stringfiedPriority:self.entringTask.priority];
    }];
    [alertViewController addAction:lowPriorityAction];
    
    UIAlertAction *mediumPriorityAction = [UIAlertAction actionWithTitle:@"Medium"
                                                                style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * _Nonnull action) {
        self.entringTask.priority = NGNMediumPriority;
        self.priorityTableCell.detailTextLabel.text = [self stringfiedPriority:self.entringTask.priority];
    }];
    [alertViewController addAction:mediumPriorityAction];
    
    UIAlertAction *highPriorityAction = [UIAlertAction actionWithTitle:@"Highs"
                                                                   style:UIAlertActionStyleDefault
                                                                 handler:^(UIAlertAction * _Nonnull action) {
        self.entringTask.priority = NGNHighPriority;
        self.priorityTableCell.detailTextLabel.text = [self stringfiedPriority:self.entringTask.priority];
    }];
    [alertViewController addAction:highPriorityAction];
    
    NSDictionary *userInfo = @{@"task": self.entringTask,
                               @"taskList": self.entringTaskList};
    [[NSNotificationCenter defaultCenter] postNotificationName:NGNNotificationNameTaskChange
                                                        object:nil
                                                      userInfo:userInfo];
    [self presentViewController:alertViewController animated:YES completion:nil];
}

- (void)showDatePicker {
//    NGNDatePickingViewController *datePickingViewController = [[NGNDatePickingViewController alloc] init];
    [self performSegueWithIdentifier:NGNControllerSegueShowDatePicking sender:self.dateTableCell];
}

 #pragma mark - Navigation

- (IBAction)unwindToEditViewController:(UIStoryboardSegue *)unwindSegue {
    NGNDatePickingViewController *datePickingViewController = unwindSegue.sourceViewController;
    if ([unwindSegue.identifier isEqualToString:NGNControllerSegueUnwindToEditWithDone]) {
        
        self.entringTask.startedAt = datePickingViewController.datePicker.date;
        self.dateTableCell.textLabel.text = [NSDate ngn_formattedStringFromDate:datePickingViewController.datePicker.date];
        NSDictionary *userInfo = @{@"task": self.entringTask,
                                   @"taskList": self.entringTaskList};
        [[NSNotificationCenter defaultCenter] postNotificationName:NGNNotificationNameTaskChange
                                                            object:nil
                                                          userInfo:userInfo];
    }
    if ([unwindSegue.identifier isEqualToString:NGNControllerSegueUnwindToEditWithCancel]) {
        [datePickingViewController dismissViewControllerAnimated:YES completion:nil];
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

#pragma mark - additional handling methods
- (NSString *)stringfiedPriority:(NSInteger)priority {
    NSString *result;
    switch (priority) {
        case NGNNonePriority:
            result = @"None";
            break;
        case NGNLowPriority:
            result = @"Low";
            break;
        case NGNMediumPriority:
            result = @"Medium";
            break;
        case NGNHighPriority:
            result = @"High";
            break;
    }
    return result;
}

@end
