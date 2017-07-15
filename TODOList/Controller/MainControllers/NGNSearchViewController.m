//
//  NGNSearchViewController.m
//  TODOList
//
//  Created by Alex on 02.06.17.
//  Copyright © 2017 Alex. All rights reserved.
//

#import "NGNSearchViewController.h"
#import "NSDate+NGNDateToStringConverter.h"
#import "NGNEditTaskViewController.h"
#import "NGNManagedTaskList+CoreDataProperties.h"
#import "NGNManagedTask+CoreDataProperties.h"
#import "NGNTaskService.h"
#import "NGNConstants.h"
#import "NGNLocalizationConstants.h"

@interface NGNSearchViewController () <UITableViewDataSource,
                                       UITableViewDelegate,
                                       UISearchResultsUpdating,
                                       UISearchBarDelegate>

@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) UISearchController *searchController;

@property (strong, nonatomic) NSArray *currentlyUsingTasks;
@property (strong, nonatomic) NSArray *searchResultTasks;

@end

@implementation NGNSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchResultsUpdater = self;
    self.searchController.searchBar.delegate = self;
    self.searchController.dimsBackgroundDuringPresentation = NO;
    self.searchController.searchBar.scopeButtonTitles =
        @[NSLocalizedString(NGNLocalizationKeyControllerActiveTasksSearchBarScopeTitle, nil),
          NSLocalizedString(NGNLocalizationKeyControllerCompletedTasksSearchBarScopeTitle, nil)];
    [self.searchController.searchBar setBackgroundColor:[UIColor whiteColor]];
    self.searchController.searchBar.selectedScopeButtonIndex = 0;
    self.tableView.tableHeaderView = self.searchController.searchBar;
    self.definesPresentationContext = YES;
    
    [self.searchController.searchBar sizeToFit];
    
    self.currentlyUsingTasks = [[NGNTaskService sharedInstance] allTasks];
    
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.searchResultTasks.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *taskCell = [tableView dequeueReusableCellWithIdentifier:NGNControllerTaskCellIdentifier];
    NGNManagedTask *currentTask = self.searchResultTasks[indexPath.row];
    taskCell.textLabel.text = currentTask.name;
    
    return taskCell;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:NGNControllerSegueShowEditTask]) {
        NGNEditTaskViewController *editTaskViewController = segue.destinationViewController;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        NGNManagedTask *task = self.searchResultTasks[indexPath.row];;
        NGNManagedTaskList *currentTaskList = [[NGNTaskService sharedInstance] entityById:task.entityId];
        editTaskViewController.entringTask = task;
        editTaskViewController.entringTaskList = currentTaskList;
    }
}

#pragma mark - search control handling methods

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.name contains[cd] %@", searchController.searchBar.text];
    self.searchResultTasks = [self.currentlyUsingTasks filteredArrayUsingPredicate:predicate];
    
    [self.tableView reloadData];
}

# pragma mark - search control delegate handling methods

- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope {
    self.currentlyUsingTasks = (selectedScope == 0) ?
                                [[NGNTaskService sharedInstance] allActiveTasks] :
                                [[NGNTaskService sharedInstance] allCompletedTasks];
    [self updateSearchResultsForSearchController:self.searchController];
}

@end
