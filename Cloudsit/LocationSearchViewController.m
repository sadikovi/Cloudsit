//
//  LocationSearchViewController.m
//  Cloudsit
//
//  Created by Ivan Sadikov on 9/06/14.
//  Copyright (c) 2014 Ivan Sadikov. All rights reserved.
//

#import "LocationSearchViewController.h"

@interface LocationSearchViewController ()
/**
 * IBOutlets
 *
 */
@property (weak, nonatomic) IBOutlet UITableView *locationTable;

// data array for managing properties
@property (strong, nonatomic) NSMutableArray *data;

@property (strong, nonatomic) NSArray *searchPlaceResults;
@property (strong, nonatomic) BSPlaceManager *placeManager;

@end

@implementation LocationSearchViewController

// edit-done button parameters
#define EB_EDIT_TAG                 100
#define EB_EDIT_TITLE               @"Edit"
#define EB_DONE_TAG                 101
#define EB_DONE_TITLE               @"Done"
// table parameters
#define EB_TABLE_HEIGHT_FOR_ROW     70
#define EB_TABLE_HEIGHT_FOR_ROW_S   50
// animation duration
#define EB_SYSTEM_ANIMATION_DURATION  0.25

// reuseIdentifier for table
#define EB_REUSE_IDENTIFIER         @"tableLocationCell"
// loading indicator
#define EB_LOADING_INDICATOR        @"PLACES ARE LOADING"

#pragma mark - Private methods and helpers

/**
 * Method for changing bar button to enter and leave edit mode.
 *
 */
- (void)button:(UIButton *)sender didEnterEditMode:(BOOL)isEdited {
    if (!isEdited) {
        sender.tag = EB_EDIT_TAG;
        [sender setImage:[UIImage imageNamed:@"edit"] forState:UIControlStateNormal];
        //sender.title = EB_EDIT_TITLE;
    } else {
        sender.tag = EB_DONE_TAG;
        [sender setImage:[UIImage imageNamed:@"close-red"] forState:UIControlStateNormal];
        //sender.title = EB_DONE_TITLE;
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

- (void)storeSettingsInSettingsManager {
    [SettingsManager defaultManager].locations = self.data;
}

- (void)setupUIElements {
    //self.navigationController.navigationBar.tintColor = [UIColor darkGrayColor];
    self.navigationController.navigationBar.titleTextAttributes = @{
                                                                    UITextAttributeFont : [UIFont fontWithName:@"HelveticaNeue-Light" size:20],
                                                                    UITextAttributeTextColor : [UIColor blackColor],
                                                                    UITextAttributeTextShadowColor : [UIColor clearColor],
                                                                    UITextAttributeTextShadowOffset : [NSValue valueWithUIOffset:UIOffsetMake(0, 0)] };
    // back button
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setFrame:CGRectMake(0, 0, 30, 30)];
    [backButton setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [backButton setImage:[UIImage imageNamed:@"back-highlighted"] forState:UIControlStateHighlighted];
    [backButton addTarget:self action:@selector(hideLocationSettings:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *back = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem = back;
    
    // edit button
    UIButton *editButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [editButton setFrame:CGRectMake(0, 0, 30, 30)];
    [editButton setImage:[UIImage imageNamed:@"edit"] forState:UIControlStateNormal];
    [self button:editButton didEnterEditMode:NO];
    [editButton addTarget:self action:@selector(toggleEditMode:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *edit = [[UIBarButtonItem alloc] initWithCustomView:editButton];
    self.navigationItem.rightBarButtonItem = edit;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // setup UI elements
    [self setupUIElements];
    
    self.data = [[SettingsManager defaultManager].locations mutableCopy];
    if (!self.data) {
        self.data = [NSMutableArray array];
    }
    
    // setup table and bar button to not usual (not edit) mode
    [self.locationTable setEditing:NO];
    [self.locationTable registerClass:[UITableViewCell class] forCellReuseIdentifier:EB_REUSE_IDENTIFIER];
    
    // place manager
    self.placeManager = [[BSPlaceManager alloc] init];
    self.placeManager.delegate = self;
    self.searchPlaceResults = [NSArray array];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // hide search bar at the beginning, to show content only
    [self performSelector:@selector(hideSearchBarAtTheBeginning) withObject:nil afterDelay:0.0f];
}


#pragma mark - IBActions

- (IBAction)hideLocationSettings:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)toggleEditMode:(UIButton *)sender {
    if (sender.tag == EB_EDIT_TAG) {
        // turn on the edit mode
        [self button:sender didEnterEditMode:YES];
        //self.backButton.enabled = NO;
        
        // set table into edit mode and
        [self.locationTable setEditing:YES animated:YES];
        [self table:self.locationTable moveSearchBarWithHidden:YES withAnimation:YES];
    } else if (sender.tag == EB_DONE_TAG) {
        // turn off edit mode
        [self button:sender didEnterEditMode:NO];
        //self.backButton.enabled = YES;
        
        // set table back to usual mode and return searchbar
        [self.locationTable setEditing:NO animated:YES];
        [self table:self.locationTable moveSearchBarWithHidden:NO withAnimation:YES];
    }
}


#pragma mark - UITableViewDataSource Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return [self.searchPlaceResults count];
    } else {
        return [self.data count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:EB_REUSE_IDENTIFIER];
    
    //if (cell == nil) {
      UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:EB_REUSE_IDENTIFIER];
    //}
    
    cell.textLabel.font = [[SettingsManager defaultManager] systemFont];
    cell.detailTextLabel.font = [[SettingsManager defaultManager] systemFontDetail];
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        if ([self.searchPlaceResults count] > 0) {
            if ([[self.searchPlaceResults lastObject] isEqual:EB_LOADING_INDICATOR]) {
                UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
                [spinner startAnimating];
                spinner.center = cell.center;
                cell.textLabel.text = nil;
                cell.detailTextLabel.text = nil;
                [cell addSubview:spinner];
            } else {
                BSPlaceResult *place = (BSPlaceResult *)[self.searchPlaceResults objectAtIndex:indexPath.row];
                cell.textLabel.text = place.name;
                cell.detailTextLabel.text = place.location;
                UIImageView *addView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrow-up-left-gray"]];
                cell.accessoryView = addView;
                addView = nil;
            }
        }
    } else {
        cell.showsReorderControl = YES;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.text = (NSString *)[[self.data objectAtIndex:indexPath.row] objectForKey:LOCATIONS_NAME_KEY];
        cell.detailTextLabel.text = (NSString *)[[self.data objectAtIndex:indexPath.row] objectForKey:LOCATIONS_LOCATION_KEY];
        
        if ([SettingsManager isLocationActive:[self.data objectAtIndex:indexPath.row]]) {
            //cell.accessoryType = UITableViewCellAccessoryCheckmark;
            cell.imageView.image = [UIImage imageNamed:@"radio-selected-green"];
        } else {
            //cell.accessoryType = UITableViewCellAccessoryNone;
            cell.imageView.image = [UIImage imageNamed:@"radio-normal-green"];
        }

    }
    
    return cell;
}

#pragma mark - UITableViewDelegate Methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return EB_TABLE_HEIGHT_FOR_ROW_S;
    } else {
        return EB_TABLE_HEIGHT_FOR_ROW;
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.data removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self storeSettingsInSettingsManager];
    }
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.searchDisplayController.searchResultsTableView)
        return NO;
    else
        return YES;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    NSMutableDictionary *movingLocation = [self.data objectAtIndex:sourceIndexPath.row];
    [self.data removeObjectAtIndex:sourceIndexPath.row];
    [self.data insertObject:movingLocation atIndex:destinationIndexPath.row];
    [self storeSettingsInSettingsManager];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        BSPlaceResult *place = (BSPlaceResult *)[self.searchPlaceResults objectAtIndex:indexPath.row];
        NSMutableDictionary *location = [[SettingsManager locationWithName:place.name andLocation:place.location andDesc:place.description andSearch:place.searchLocation withActive:NO] mutableCopy];
        [self.data addObject:location];
        [self storeSettingsInSettingsManager];
        
        [self.searchDisplayController setActive:NO animated:YES];
    } else {
        for (NSIndexPath *path in [tableView indexPathsForVisibleRows]) {
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:path];
            if ([path isEqual:indexPath]) {
                //cell.accessoryType = UITableViewCellAccessoryCheckmark;
                cell.imageView.image = [UIImage imageNamed:@"radio-selected-green"];
                [SettingsManager location:(NSMutableDictionary *)[self.data objectAtIndex:path.row] setActive:YES];
            } else {
                //cell.accessoryType = UITableViewCellAccessoryNone;
                cell.imageView.image = [UIImage imageNamed:@"radio-normal-green"];
                [SettingsManager setLocationIsNotActive:(NSMutableDictionary *)[self.data objectAtIndex:path.row]];
            }
        }
    }

    return indexPath;
}

#pragma mark - SearchBar Methods [including helpers and protocol]

// method is called every time searchController is dismissed
- (void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller {
    // reload locations table after search is ended to see all new locations added
    [self.locationTable reloadData];
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    self.searchPlaceResults = [NSArray array];
    
    if ([self.placeManager connectionIsActive]) {
        [self.placeManager stopRequest];
    }
    
    if ([searchString length] > 0) {
        [self.placeManager searchPlace:searchString];
        [self.placeManager startRequest];
    }
    
    return YES;
}

#pragma mark - BSPlaceManagerDelegate Methods

- (void)placeManager:(BSPlaceManager *)manager processingRequest:(NSURLRequest *)request {
    self.searchPlaceResults = [NSArray arrayWithObjects:EB_LOADING_INDICATOR, nil];
}

- (void)placeManager:(BSPlaceManager *)manager didReceiveResult:(NSArray *)places {
    self.searchPlaceResults = [NSArray arrayWithArray:places];
    [self.searchDisplayController.searchResultsTableView reloadData];
}

- (void)placeManager:(BSPlaceManager *)manager didFailWithError:(NSError *)error {
    self.searchPlaceResults = [NSArray array];
    [self.searchDisplayController.searchResultsTableView reloadData];
}

@end
