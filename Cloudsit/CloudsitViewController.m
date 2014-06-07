//
//  CloudsitViewController.m
//  Cloudsit
//
//  Created by Ivan Sadikov on 7/06/14.
//  Copyright (c) 2014 Ivan Sadikov. All rights reserved.
//

#import "CloudsitViewController.h"

@interface CloudsitViewController ()
@property (nonatomic, strong) CloudsitManager *manager;
@property (nonatomic, strong) NSDictionary *weatherData;
@property (weak, nonatomic) IBOutlet UILabel *cityLabel;
@end

@implementation CloudsitViewController

#define CloudsitUserDefaultsKey @"Cloudsit-sys-userdefaults-key-11021990"

- (void)loadFromUserDefaultsWithKey:(NSString *)key {
    self.weatherData = (NSDictionary *)[[NSUserDefaults standardUserDefaults] objectForKey:key];
    self.manager.currentLocation = (NSString *)[self.weatherData objectForKey:CloudsitManagerDataLocationKey];
}

- (void)updateUIWithSet:(BOOL)withSet {
    self.cityLabel.text = (NSString *)[self.weatherData objectForKey:CloudsitManagerDataLocationKey];
    
    if (withSet) {
        [self.view setNeedsDisplay];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.manager = [[CloudsitManager alloc] initWithRequestManager:YES];
    self.manager.delegate = self;
    self.weatherData = [NSDictionary dictionary];
    
    [self loadFromUserDefaultsWithKey:CloudsitUserDefaultsKey];
    
    [self updateUIWithSet:NO];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.manager.currentLocation = @"London";
    
    [self updateUIWithSet:YES];
}

- (IBAction)click:(UIButton *)sender {
    if (self.manager) {
        [self.manager refreshDataForLocation:self.manager.currentLocation];
    } else {
        NSLog(@"Manager is nil");
    }
}

#pragma mark - CloudsitManagerDelegate Methods

- (void)managerDidSendRequestWithURL:(CloudsitManager *)manager {
    // do something at the beggining of update
}

- (void)manager:(CloudsitManager *)manager didReceiveResult:(NSDictionary *)result {
    if (!self.weatherData) {
        self.weatherData = [NSDictionary dictionary];
    }
    
    self.weatherData = result;
    [[NSUserDefaults standardUserDefaults] setObject:result forKey:CloudsitUserDefaultsKey];
}

- (void)manager:(CloudsitManager *)manager didFailWithError:(NSError *)error {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                    message:[error description]
                                                   delegate:nil
                                          cancelButtonTitle:@"Ok, I got it"
                                          otherButtonTitles:nil, nil];
    [alert show];
}

@end
