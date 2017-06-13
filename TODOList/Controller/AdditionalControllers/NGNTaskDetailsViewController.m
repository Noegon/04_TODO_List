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
#import "NGNTaskList.h"
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
         NGNTaskList *taskList = userInfo[@"taskList"];
         [taskList updateEntity:task];
         [self renewInformation];
     }];
}

- (IBAction)doneButtonTapped:(UIButton *)sender {
    self.finishDateLabel.text = [NSDate ngn_formattedStringFromDate:[NSDate date]];
    self.entringTask.finishedAt = [NSDate date];
    self.entringTask.completed = YES;
    NSDictionary *userInfo = @{@"task": self.entringTask,
                               @"taskList": self.entringTaskList};
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
        editTaskViewController.entringTaskList = self.entringTaskList;
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 7;
}

@end
