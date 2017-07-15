//
//  NGNEditTaskListViewController.m
//  TODOList
//
//  Created by Alex on 12.06.17.
//  Copyright © 2017 Alex. All rights reserved.
//

#import "NGNAddProjectViewController.h"
#import "NSDate+NGNDateToStringConverter.h"
#import "NGNEditTaskViewController.h"
#import "NGNManagedTaskList+CoreDataProperties.h"
#import "NGNManagedTask+CoreDataProperties.h"
#import "NGNConstants.h"
#import "NGNTaskService.h"
#import "AppDelegate.h"

@interface NGNAddProjectViewController ()

@property (strong, nonatomic) NGNManagedTaskList *entringTaskList;
@property (strong, nonatomic) IBOutlet UITextField *projectNameTextField;

- (IBAction)saveBarButtonTapped:(UIBarButtonItem *)sender;
- (IBAction)projectNameValueChanged:(UITextField *)sender;

@end

@implementation NGNAddProjectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem.enabled = NO;
    [self.projectNameTextField becomeFirstResponder];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (IBAction)saveBarButtonTapped:(UIBarButtonItem *)sender {
    NSManagedObjectContext *managedContext = [NGNTaskService sharedInstance].managedObjectContext;
    self.entringTaskList =
        [NSEntityDescription insertNewObjectForEntityForName:@"NGNManagedTaskList"
                                      inManagedObjectContext:managedContext];
    
    self.entringTaskList.entityId = foo4random();
    self.entringTaskList.name = self.projectNameTextField.text;
    [[NGNTaskService sharedInstance] addEntity:self.entringTaskList];
    NSDictionary *userInfo = @{@"taskList": self.entringTaskList};
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NGNNotificationNameTaskListAdd
                                                        object:nil
                                                      userInfo:userInfo];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)projectNameValueChanged:(UITextField *)sender {
    self.navigationItem.rightBarButtonItem.enabled = [sender.text length] ? YES : NO;
}

@end
