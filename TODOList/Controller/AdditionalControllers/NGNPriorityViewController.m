//
//  NGNPriorityViewController.m
//  TODOList
//
//  Created by Alex on 11.06.17.
//  Copyright © 2017 Alex. All rights reserved.
//

#import "NGNPriorityViewController.h"
#import "NGNTask.h"
#import "NGNConstants.h"

@interface NGNPriorityViewController () <UITableViewDataSource, UITableViewDelegate>

- (IBAction)priorityButtonTapped:(UIButton *)sender;
- (IBAction)cancelButtonTapped:(UIButton *)sender;

@end

@implementation NGNPriorityViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    [self.tableView setRowHeight:30];
//    NSInteger numberOfSections = [self.tableView numberOfSections];
//    NSInteger rowsInSection = [self.tableView numberOfRowsInSection:0];
//    CGFloat totalRowHeight = rowsInSection * self.tableView.rowHeight * numberOfSections;
//    CGFloat topInset = MAX(0, CGRectGetHeight(self.tableView.bounds) - totalRowHeight);
//    self.tableView.contentInset = UIEdgeInsetsMake(topInset, 0, 0, 0);
    
    self.tableView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7f];
//        self.modalPresentationStyle = UIModalPresentationOverFullScreen;
//    self.modalPresentationStyle = UIModalPresentationCurrentContext;
//    self.modalPresentationStyle = UIModalPresentationFormSheet;

}

- (IBAction)priorityButtonTapped:(UIButton *)sender {
    self.entringTask.priority = [self.tableView.visibleCells
                                 indexOfObject:(UITableViewCell *)[sender superview].superview];
    NSDictionary *userInfo = @{@"task": self.entringTask};
    [[NSNotificationCenter defaultCenter] postNotificationName:NGNNotificationNameTaskChange
                                                        object:nil
                                                      userInfo:userInfo];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)cancelButtonTapped:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 6;
}

// - (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
// UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TestCell" forIndexPath:indexPath];
// 
// // Configure the cell...
// 
// return cell;
// }


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
