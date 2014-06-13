//
//  SettingsViewController.m
//  Cloudsit
//
//  Created by Ivan Sadikov on 9/06/14.
//  Copyright (c) 2014 Ivan Sadikov. All rights reserved.
//

#import "SettingsViewController.h"

@interface SettingsViewController ()
/**
 * IBOutlets
 *
 */
@property (weak, nonatomic) IBOutlet UITableView *locationTable;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *editButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *backButton;
@property (weak, nonatomic) IBOutlet UINavigationBar *bar;

// data array for managing properties
@property (strong, nonatomic) NSMutableArray *data;

@end

@implementation SettingsViewController

// edit-done button parameters
#define EB_EDIT_TAG                 100
#define EB_EDIT_TITLE               @"Edit"
#define EB_DONE_TAG                 101
#define EB_DONE_TITLE               @"Done"
// table parameters
#define EB_TABLE_HEIGHT_FOR_ROW     70
// animation duration
#define EB_SYSTEM_ANIMATION_DURATION  0.25


#pragma mark - Private methods and helpers

/**
 * Method for changing bar button to enter and leave edit mode.
 *
 */
- (void)button:(UIBarButtonItem *)sender didEnterEditMode:(BOOL)isEdited {
    if (!isEdited) {
        sender.tag = EB_EDIT_TAG;
        sender.title = EB_EDIT_TITLE;
    } else {
        sender.tag = EB_DONE_TAG;
        sender.title = EB_DONE_TITLE;
    }
}

/**
 * Hide search bar at the beginning of the loading.
 * This method is basically for using in selector to hide search bar when view is loaded and displayed.
 *
 */
- (void)hideSearchBarAtTheBeginning {
    [self table:self.locationTable moveSearchBarWithHidden:NO withAnimation:NO];
}

/**
 * Method for moving up/hiding SearchBar with animation.
 * For example, before displaying table, you can hide your search bar, so user cannot see it,
 * he will see it when scrolling down (like Notes app).
 * Works only when search bar is a part of yhe table (which usually is).
 *
 */
- (void)table:(UITableView *)table moveSearchBarWithHidden:(BOOL)isHidden withAnimation:(BOOL)animated {
    if (animated) {
        [UIView animateWithDuration:EB_SYSTEM_ANIMATION_DURATION
                         animations:^{
                             table.contentOffset = CGPointMake(0, self.searchDisplayController.searchBar.frame.size.height);
                         }
                         completion:^(BOOL finished) {
                             if (finished) {
                                 if (isHidden) {
                                     self.searchDisplayController.searchBar.hidden = YES;
                                 } else {
                                     self.searchDisplayController.searchBar.hidden = NO;
                                 }
                             }
                         }];
    } else {
        table.contentOffset = CGPointMake(0, self.searchDisplayController.searchBar.frame.size.height);
        if (isHidden) {
            self.searchDisplayController.searchBar.hidden = YES;
        } else {
            self.searchDisplayController.searchBar.hidden = NO;
        }
    }
}


#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // data for the first time
    // should be replaced after finishing all functional implementation
    //self.data = [NSMutableArray arrayWithObjects:@"London", @"Moscow", @"New York", @"Sydney", @"Auckland", @"Christchurch", @"Brisbone", nil];
    
    // setup table and bar button to not usual (not edit) mode
    [self button:self.editButton didEnterEditMode:NO];
    [self.locationTable setEditing:NO];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // hide search bar at the beginning, to show content only
    [self performSelector:@selector(hideSearchBarAtTheBeginning) withObject:nil afterDelay:0.0f];
}


#pragma mark - IBActions

- (IBAction)dismissControllerWithSender:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)toggleEditMode:(UIBarButtonItem *)sender {
    if (sender.tag == EB_EDIT_TAG) {
        // turn on the edit mode
        [self button:sender didEnterEditMode:YES];
        self.backButton.enabled = NO;
        
        // set table into edit mode and
        [self.locationTable setEditing:YES animated:YES];
        [self table:self.locationTable moveSearchBarWithHidden:YES withAnimation:YES];
    } else if (sender.tag == EB_DONE_TAG) {
        // turn off edit mode
        [self button:sender didEnterEditMode:NO];
        self.backButton.enabled = YES;
        
        // set table back to usual mode and return searchbar
        [self.locationTable setEditing:NO animated:YES];
        [self table:self.locationTable moveSearchBarWithHidden:NO withAnimation:YES];
    }
}


#pragma mark - UITableViewDataSource Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        // return 0 rows, as we will do auto place complete for the search
        return 0;
    } else {
        return [self.data count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // we do not use reuse cell, because it will have only up to 10 location, not a thousands of them.
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"tableWeatherCell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:14];
    cell.textLabel.text = [self.data objectAtIndex:indexPath.row];
    cell.showsReorderControl = YES;
    
    return cell;
}

#pragma mark - UITableViewDelegate Methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return EB_TABLE_HEIGHT_FOR_ROW;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.data removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    NSString *movingLocation = [self.data objectAtIndex:sourceIndexPath.row];
    [self.data removeObjectAtIndex:sourceIndexPath.row];
    [self.data insertObject:movingLocation atIndex:destinationIndexPath.row];
}

#pragma mark - SearchBar Methods [including helpers and protocol]

- (void)showOrHideToolbar:(BOOL)hidden {
    if (hidden) {
        self.bar.frame = CGRectOffset(self.bar.frame, 0, self.bar.frame.size.height);
        self.view.frame = CGRectInset(self.view.frame, 0, -self.bar.frame.size.height);
    } else {
        self.bar.frame = CGRectOffset(self.bar.frame, 0, -self.bar.frame.size.height);
        self.view.frame = CGRectInset(self.view.frame, 0, self.bar.frame.size.height);
    }
}


- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller {
    [UIView animateWithDuration:EB_SYSTEM_ANIMATION_DURATION
                     animations:^{
                         [self showOrHideToolbar:YES];
                     }
                     completion:^(BOOL finished) {
                         if (finished) {
                             self.bar.hidden = YES;
                         }
                     }];   
}

// method is called every time searchController is dismissed
- (void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller {
    self.bar.hidden = NO;
    [UIView animateWithDuration:EB_SYSTEM_ANIMATION_DURATION
                     animations:^{
                         [self showOrHideToolbar:NO];
                     }
                     completion:nil];
}

@end
