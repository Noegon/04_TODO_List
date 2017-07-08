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
#import "NGNManagedTask+CoreDataProperties.h"
#import "NGNManagedTaskList+CoreDataProperties.h"
#import "NGNTaskService.h"
#import "NGNConstants.h"
#import "NGNLocalizationConstants.h"
#import "AppDelegate.h"

@interface NGNEditTaskViewController ()

@property (strong, nonatomic) IBOutlet UITextField *taskNameInsertTextField;
@property (strong, nonatomic) IBOutlet UITextView *notesInsertTextView;
@property (strong, nonatomic) IBOutlet UITableViewCell *dateTableCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *priorityTableCell;
@property (strong, nonatomic) IBOutlet UISwitch *remaindDaySwither;

@property (assign, nonatomic) NSInteger currentTaskPriority;

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
        [NSString stringWithFormat:@"%@%lld", NGNNotificationRequestIDTaskTime, self.entringTask.entityId];
    [[UNUserNotificationCenter currentNotificationCenter]
     removeDeliveredNotificationsWithIdentifiers:@[notificationID]];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NGNNotificationNameLocalNotificationListChanged
                                                        object:nil
                                                      userInfo:nil];
    
    // taskNameInsertTextField configured
    [self.taskNameInsertTextField becomeFirstResponder];
    
    // navigation bar title is set
    if (![self.navigationItem.title isEqualToString:
          NSLocalizedString(NGNLocalizationKeyControllerAddTaskNavigationItemTitle, nil)]) {
        self.navigationItem.title = NSLocalizedString(NGNLocalizationKeyControllerEditTaskNavigationItemTitle, nil);
    }
    
    // save bar button is set and configured
    UIBarButtonItem *saveBarButton =
        [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(NGNLocalizationKeyControllerSaveButtonTitle, nil)
                                         style:UIBarButtonItemStylePlain
                                        target:self
                                        action:@selector(saveBarButtonTapped:)];
    if (!self.taskNameInsertTextField.text) {
        saveBarButton.enabled = NO;
    }
    self.navigationItem.rightBarButtonItem = saveBarButton;
    saveBarButton = nil;
    
    if (!self.entringTask) {
        self.taskNameInsertTextField.text = NSLocalizedString(NGNLocalizationKeyControllerNoneTitle, nil);
        self.dateTableCell.textLabel.text = [NSDate ngn_formattedStringFromDate:[NSDate date]];
        self.notesInsertTextView.text = @"";
        self.priorityTableCell.detailTextLabel.text = [self stringfiedPriority:NGNNonePriority];
        self.remaindDaySwither.on = NO;
        self.currentTaskPriority = NGNNonePriority;
    } else {
        self.taskNameInsertTextField.text = self.entringTask.name;
        self.dateTableCell.textLabel.text = [NSDate ngn_formattedStringFromDate:self.entringTask.startedAt];
        self.notesInsertTextView.text = self.entringTask.notes;
        self.priorityTableCell.detailTextLabel.text = [self stringfiedPriority:self.entringTask.priority];
        self.remaindDaySwither.on = self.entringTask.shouldRemindOnDay;
        self.currentTaskPriority = self.entringTask.priority;
    }
    
    [[NSNotificationCenter defaultCenter]
     addObserverForName:NGNNotificationNameTaskChange
     object:nil
     queue:[NSOperationQueue mainQueue]
     usingBlock:^(NSNotification *notification) {
         NSDictionary *userInfo = notification.userInfo;
         NGNManagedTask *task = userInfo[@"task"];
         self.dateTableCell.textLabel.text =
            [NSDate ngn_formattedStringFromDate:task.startedAt];
         self.priorityTableCell.detailTextLabel.text = [NSString stringWithFormat:@"%lld", task.priority];
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
    
    NSManagedObjectContext *managedContext = [NGNTaskService sharedInstance].managedObjectContext;
    
    NSString *notificationName;
    
    if (!self.entringTask) {
        self.entringTask =
            [NSEntityDescription insertNewObjectForEntityForName:@"NGNManagedTask"
                                          inManagedObjectContext:managedContext];
        self.entringTask.entityId = foo4random();
    }
    
    self.entringTask.name = self.taskNameInsertTextField.text;
    self.entringTask.startedAt = [NSDate ngn_dateFromString:self.dateTableCell.textLabel.text];
    self.entringTask.notes = self.notesInsertTextView.text;
    self.entringTask.shouldRemindOnDay = self.remaindDaySwither.on;
    self.entringTask.priority = self.currentTaskPriority;
    
    if ([self.navigationItem.title containsString:
         NSLocalizedString(NGNLocalizationKeyControllerAddTaskNavigationItemTitle, nil)]) {
        notificationName = NGNNotificationNameTaskAdd;
        [self.entringTaskList addEntityCollectionObject:self.entringTask];
    } else {
        notificationName = NGNNotificationNameTaskChange;
        [self.entringTask updateEntity];
    }
    [[NGNTaskService sharedInstance] saveCollection];
    
    //notifications
    NSDictionary *userInfo = @{@"task": self.entringTask,
                               @"taskList": self.entringTaskList};
    [[NSNotificationCenter defaultCenter] postNotificationName:notificationName
                                                        object:nil
                                                      userInfo:userInfo];
    
    //local notifications
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"10.0")) {
        NSString *notificationID =
            [NSString stringWithFormat:@"%@%lld", NGNNotificationRequestIDTaskTime, self.entringTask.entityId];
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
    UIAlertController *alertViewController =
        [UIAlertController alertControllerWithTitle:
         NSLocalizedString(NGNLocalizationKeyControllerSelectPriorityTitle, nil)
                                            message:nil
                                     preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:
                                   NSLocalizedString(NGNLocalizationKeyControllerCancelButtonTitle, nil)
                                                           style:UIAlertActionStyleCancel handler:nil];
    [alertViewController addAction:cancelAction];
    
    UIAlertAction *nonePriorityAction =
        [UIAlertAction actionWithTitle:NSLocalizedString(NGNLocalizationKeyControllerPriorityNoneTitle, nil)
                                 style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * _Nonnull action) {
                                   self.currentTaskPriority = NGNNonePriority;
                                   self.priorityTableCell.detailTextLabel.text =
                                    [self stringfiedPriority:NGNNonePriority];
                               }];
    [alertViewController addAction:nonePriorityAction];
    
    UIAlertAction *lowPriorityAction =
        [UIAlertAction actionWithTitle:NSLocalizedString(NGNLocalizationKeyControllerPriorityLowTitle, nil)
                                 style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * _Nonnull action) {
                                   self.currentTaskPriority = NGNLowPriority;
                                   self.priorityTableCell.detailTextLabel.text =
                                    [self stringfiedPriority:NGNLowPriority];
                               }];
    [alertViewController addAction:lowPriorityAction];
    
    UIAlertAction *mediumPriorityAction =
        [UIAlertAction actionWithTitle:NSLocalizedString(NGNLocalizationKeyControllerPriorityMediumTitle, nil)
                                 style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * _Nonnull action) {
                                   self.currentTaskPriority = NGNMediumPriority;
                                   self.priorityTableCell.detailTextLabel.text =
                                    [self stringfiedPriority:NGNMediumPriority];
                               }];
    [alertViewController addAction:mediumPriorityAction];
    
    UIAlertAction *highPriorityAction =
        [UIAlertAction actionWithTitle:NSLocalizedString(NGNLocalizationKeyControllerPriorityHighTitle, nil)
                                 style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * _Nonnull action) {
                                   self.currentTaskPriority = NGNHighPriority;
                                   self.priorityTableCell.detailTextLabel.text =
                                    [self stringfiedPriority:NGNHighPriority];
                               }];
    [alertViewController addAction:highPriorityAction];
    
//    NSDictionary *userInfo = @{@"task": self.entringTask,
//                               @"taskList": self.entringTaskList};
//    [[NSNotificationCenter defaultCenter] postNotificationName:NGNNotificationNameTaskChange
//                                                        object:nil
//                                                      userInfo:userInfo];
    [self presentViewController:alertViewController animated:YES completion:nil];
}

- (void)showDatePicker {
    [self performSegueWithIdentifier:NGNControllerSegueShowDatePicking sender:self.dateTableCell];
}

 #pragma mark - Navigation

- (IBAction)unwindToEditViewController:(UIStoryboardSegue *)unwindSegue {
    NGNDatePickingViewController *datePickingViewController = unwindSegue.sourceViewController;
    if ([unwindSegue.identifier isEqualToString:NGNControllerSegueUnwindToEditWithDone]) {
        
        self.dateTableCell.textLabel.text = [NSDate ngn_formattedStringFromDate:datePickingViewController.datePicker.date];
//        NSDictionary *userInfo = @{@"task": self.entringTask,
//                                   @"taskList": self.entringTaskList};
//        [[NSNotificationCenter defaultCenter] postNotificationName:NGNNotificationNameTaskChange
//                                                            object:nil
//                                                          userInfo:userInfo];
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
            result = NSLocalizedString(NGNLocalizationKeyControllerPriorityNoneTitle, nil);
            break;
        case NGNLowPriority:
            result = NSLocalizedString(NGNLocalizationKeyControllerPriorityLowTitle, nil);
            break;
        case NGNMediumPriority:
            result = NSLocalizedString(NGNLocalizationKeyControllerPriorityMediumTitle, nil);
            break;
        case NGNHighPriority:
            result = NSLocalizedString(NGNLocalizationKeyControllerPriorityHighTitle, nil);
            break;
    }
    return result;
}

@end
