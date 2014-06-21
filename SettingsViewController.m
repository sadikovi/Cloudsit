//
//  SettingsViewController.m
//  Cloudsit
//
//  Created by Ivan Sadikov on 14/06/14.
//  Copyright (c) 2014 Ivan Sadikov. All rights reserved.
//

#import "SettingsViewController.h"

@interface SettingsViewController ()
@property (weak, nonatomic) IBOutlet UITableView *settingsTable;
@property (strong, nonatomic) NSArray *data;
@end

#define SE_REUSE_IDENTIFIER @"SE_REUSE_IDENTIFIER"

#define TAG                 @"tag"
    #define TAG_LOCATION        @"tag_location"
    #define TAG_TEMPERATURE     @"tag_temperature"
#define TITLE               @"title"
#define FOOTER              @"footer"
#define NUMBER_OF_ROWS      @"number_of_rows"


@implementation SettingsViewController

- (NSString *)titleForSectionUsingArray:(NSArray *)data atIndex:(NSInteger)index {
    return (NSString *)[[data objectAtIndex:index] objectForKey:TITLE];
}

- (IBAction)hideSettings:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (NSInteger)numberOfRowsForSectionUsingArray:(NSArray *)data atIndex:(NSInteger)index {
    return [[[data objectAtIndex:index] objectForKey:NUMBER_OF_ROWS] intValue];
}

- (NSString *)footerForSectionUsingArray:(NSArray *)data atIndex:(NSInteger)index {
    return (NSString *)[[data objectAtIndex:index] objectForKey:FOOTER];
}

- (NSString *)tagForSectionUsingArray:(NSArray *)data atIndex:(NSInteger)index {
    return (NSString *)[[data objectAtIndex:index] objectForKey:TAG];
}

- (IBAction)chooseTemperature:(UISwitch *)sender {
    [[SettingsManager defaultManager] setFahrenheitDegrees:sender.on];
}

- (void)setupUIElements {
    //self.navigationController.navigationBar.tintColor = [UIColor darkGrayColor];
    self.navigationController.navigationBar.titleTextAttributes = @{
                                                                    UITextAttributeFont : [UIFont fontWithName:@"HelveticaNeue-Light" size:20],
                                                                    UITextAttributeTextColor : [UIColor blackColor],
                                                                    UITextAttributeTextShadowColor : [UIColor clearColor],
                                                                    UITextAttributeTextShadowOffset : [NSValue valueWithUIOffset:UIOffsetMake(0, 0)] };
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setFrame:CGRectMake(0, 0, 30, 30)];
    [backButton setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [backButton setImage:[UIImage imageNamed:@"back-highlighted"] forState:UIControlStateHighlighted];
    [backButton addTarget:self action:@selector(hideSettings:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *back = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem = back;
}

- (void)log {
    NSLog(@"Tapped");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUIElements];
    [self.settingsTable registerClass:[UITableViewCell class] forCellReuseIdentifier:SE_REUSE_IDENTIFIER];
    
    // array wit titles for settings table
    self.data = [NSArray arrayWithObjects:
                 @{TITLE : @"Location", NUMBER_OF_ROWS : @"1", FOOTER : @"Choose location to view weather for.", TAG : TAG_LOCATION},
                 @{TITLE : @"Temperature", NUMBER_OF_ROWS : @"1", FOOTER : @"Choose to use Fahrenheit temperature scale.", TAG : TAG_TEMPERATURE},
                   nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [self.settingsTable reloadData];
    [super viewWillAppear:animated];
}

#pragma mark - UITableViewDataSource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [self titleForSectionUsingArray:self.data atIndex:section];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 30)];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectInset(view.frame, 10, 0)];
    label.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:20];
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = NSTextAlignmentLeft;
    label.text = [self tableView:tableView titleForHeaderInSection:section];
    [view addSubview:label];
    
    return view;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 30)];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectInset(view.frame, 10, 0)];
    label.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14];
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = [self tableView:tableView titleForFooterInSection:section];
    [view addSubview:label];
    
    return view;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    return [self footerForSectionUsingArray:self.data atIndex:section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self numberOfRowsForSectionUsingArray:self.data atIndex:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[self tagForSectionUsingArray:self.data atIndex:indexPath.section]];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:[self tagForSectionUsingArray:self.data atIndex:indexPath.section]];
    }
    
    cell.textLabel.font = [[SettingsManager defaultManager] systemFont];
    cell.detailTextLabel.font = [[SettingsManager defaultManager] systemFont];
    
    if ([[self tagForSectionUsingArray:self.data atIndex:indexPath.section] isEqualToString:TAG_LOCATION]) {
        cell.textLabel.text = @"Location";
        cell.detailTextLabel.text = [[SettingsManager defaultManager].activeLocation objectForKey:LOCATIONS_NAME_KEY];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    if ([[self tagForSectionUsingArray:self.data atIndex:indexPath.section] isEqualToString:TAG_TEMPERATURE]) {
        cell.textLabel.text = @"Use Fahrenheit";
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryView.frame = CGRectZero;
        UISwitch *temperatureSwitch = [[UISwitch alloc] initWithFrame:cell.accessoryView.frame];
        [temperatureSwitch setOn:[SettingsManager defaultManager].isFahrenheit];
        [temperatureSwitch addTarget:self action:@selector(chooseTemperature:) forControlEvents:UIControlEventValueChanged];
        temperatureSwitch.center = cell.accessoryView.center;
        cell.accessoryView = temperatureSwitch;
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate Methods

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([[self tagForSectionUsingArray:self.data atIndex:indexPath.section] isEqualToString:TAG_LOCATION]) {
        LocationSearchViewController *lsvc = [self.storyboard instantiateViewControllerWithIdentifier:@"LocationSearchVC"];
        [self.navigationController pushViewController:lsvc animated:YES];
    }
        
    return indexPath;
}



@end
