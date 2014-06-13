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
@property (nonatomic, strong) NSString *currentLocation;
@property (nonatomic, strong) NSDate *lastUpdate;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) UITableView *weatherTable;

@property (weak, nonatomic) IBOutlet UICollectionView *weekView;
@property (weak, nonatomic) IBOutlet UILabel *cityLabel;
@property (weak, nonatomic) IBOutlet UILabel *tempLabel;
@property (weak, nonatomic) IBOutlet UILabel *weatherCodeLabel;
@property (weak, nonatomic) IBOutlet UILabel *minTempLabel;
@property (weak, nonatomic) IBOutlet UILabel *maxTempLabel;
@property (weak, nonatomic) IBOutlet UILabel *weatherDescLabel;
@property (weak, nonatomic) IBOutlet UIView *infoView;


@end

@implementation CloudsitViewController

#define CloudsitUserDefaultsKey @"Cloudsit-sys-userdefaults-key-11021990"
#define CloudsitUserDefaultsUpdateKey @"Cloudsit-sys-userdefaults-key-11021990_update"
#define CloudsitUserDefaultsLocationKey @"Cloudsit-sys-userdefaults-key-11021990_location"
#define UpdateIntervalLimit     10
#define UpdateIntertval         10
#define offset                  50
#define WeatherTableCellHeight  80;



- (void)loadFromUserDefaults {
    NSDate *lUpdate = (NSDate *)[[NSUserDefaults standardUserDefaults] objectForKey:CloudsitUserDefaultsUpdateKey];
    if (lUpdate) {
        self.lastUpdate = lUpdate;
    }
    
    self.weatherData = (NSDictionary *)[[NSUserDefaults standardUserDefaults] objectForKey:CloudsitUserDefaultsKey];
    [self invokeCurrentLocationFromUserDefaults];
}

- (void)invokeCurrentLocationFromUserDefaults {
    self.currentLocation = (NSString *)[[NSUserDefaults standardUserDefaults] objectForKey:CloudsitUserDefaultsLocationKey];
}

- (void)updateCurrentLocationAndUserDefaultsWithLocation:(NSString *)location {
    self.currentLocation = location;
    [[NSUserDefaults standardUserDefaults] setObject:location forKey:CloudsitUserDefaultsLocationKey];
}

- (void)updateUIWithResult:(NSDictionary *)result usingSet:(BOOL)withSet {
    self.cityLabel.text = (NSString *)[result objectForKey:CloudsitManagerDataLocationKey];
    
    NSString *temperature = (NSString *)[[result objectForKey:CloudsitManagerDataCurrentConditionKey] objectForKey:@"temp"];
    NSString *lowTemperature = (NSString *)[[result objectForKey:CloudsitManagerDataCurrentConditionKey] objectForKey:@"minTemp"];
    NSString *highTemperature = (NSString *)[[result objectForKey:CloudsitManagerDataCurrentConditionKey] objectForKey:@"maxTemp"];
    
    self.tempLabel.text = [NSString stringWithFormat:@"%@", temperature];
    self.minTempLabel.text = [NSString stringWithFormat:@"%@℃", lowTemperature];
    self.maxTempLabel.text = [NSString stringWithFormat:@"%@℃", highTemperature];
    self.weatherCodeLabel.text = (NSString *)[[result objectForKey:CloudsitManagerDataCurrentConditionKey] objectForKey:@"weatherCode"];
    self.weatherDescLabel.text = (NSString *)[[result objectForKey:CloudsitManagerDataCurrentConditionKey] objectForKey:@"weatherDesc"];
    
    [self.weekView reloadData];
    [self.weatherTable reloadData];
    
    if (withSet) {
        [self.view setNeedsDisplay];
    }
}

- (void)refreshWeather {
    if (self.manager) {
        [self.manager refreshDataForLocation:self.currentLocation];
    }
}

- (void)stopTimer {
    [self.timer invalidate];
    self.timer = nil;
}

- (void)startTimer {
    if (self.timer) {
        [self stopTimer];
    }
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:UpdateIntertval
                                                  target:self
                                                selector:@selector(refreshWeather)
                                                userInfo:nil
                                                 repeats:NO];
}

- (void)shadowToView:(UIView *)view {
    [view.layer setShadowColor:[UIColor blackColor].CGColor];
    [view.layer setShadowOpacity:0.5];
    [view.layer setShadowRadius:5.0];
    [view.layer setShadowOffset:CGSizeMake(2.0, 2.0)];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.weekView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"weekdayCell"];
    
    CGRect tableFrame = CGRectMake(0, offset, self.view.frame.size.width, self.view.frame.size.height);
    self.weatherTable = [[UITableView alloc] initWithFrame:tableFrame style:UITableViewStylePlain];
    self.weatherTable.delegate = self;
    self.weatherTable.dataSource = self;
    //self.weatherTable.scrollEnabled = NO;
    
    self.manager = [[CloudsitManager alloc] initWithRequestManager:YES];
    self.manager.delegate = self;
    self.weatherData = [NSDictionary dictionary];
    self.lastUpdate = [NSDate dateWithTimeIntervalSince1970:0];
    
    [self loadFromUserDefaults];
    
    [self shadowToView:self.infoView];
    [self.view insertSubview:self.weatherTable belowSubview:self.infoView];
    
    [self updateUIWithResult:self.weatherData usingSet:NO];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSDate *now = [NSDate date];
    NSTimeInterval interval = [now timeIntervalSinceDate:self.lastUpdate];
    
    [self updateCurrentLocationAndUserDefaultsWithLocation:@"Christchurch, New Zealand"];
    
    NSString *location = (NSString *)[self.weatherData objectForKey:CloudsitManagerDataLocationKey];
    // invoke current location from user defaults
    [self invokeCurrentLocationFromUserDefaults];
    
    if (self.currentLocation && ![self.currentLocation isEqualToString:location]) {
        [self refreshWeather];
    } else {
        [self updateCurrentLocationAndUserDefaultsWithLocation:location];
        
        if (interval > UpdateIntervalLimit) {
            [self refreshWeather];
        } else {
            [self startTimer];
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self stopTimer];
}

- (IBAction)click:(UIButton *)sender {
    [self stopTimer];
    [self refreshWeather];
}

- (IBAction)handlePan:(UIPanGestureRecognizer *)recognizer {
    BOOL isDown;
    
    CGPoint translation = [recognizer translationInView:self.view];
    CGPoint velocity = [recognizer velocityInView:self.view];
    if (translation.y > 0) {
        recognizer.view.center = CGPointMake(recognizer.view.center.x, MIN(recognizer.view.center.y+translation.y, self.view.center.y-[UIApplication sharedApplication].statusBarFrame.size.height));
    } else {
        recognizer.view.center = CGPointMake(recognizer.view.center.x, MAX(recognizer.view.center.y+translation.y, -recognizer.view.frame.size.height/2 + offset));
    }
    
    if (velocity.y < 0) {
        isDown = NO;
    } else {
        isDown = YES;
    }
    
    [recognizer setTranslation:CGPointZero inView:self.view];
    
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        [self animateView:self.infoView forState:isDown withBouncing:NO];
    }
}

- (void)animateView:(UIView *)view forState:(BOOL)isDown withBouncing:(BOOL)isBounce {
    CGFloat bouncingOffset = 3;
    
    CGRect downFrame = CGRectMake(0, 0, view.frame.size.width, view.frame.size.height);
    CGRect upFrame = CGRectMake(0, -(view.frame.size.height-offset), view.frame.size.width, view.frame.size.height);
    CGRect downBouncingFrame = CGRectMake(0, -bouncingOffset, view.frame.size.width, view.frame.size.height);
    CGRect upBouncingFrame = CGRectMake(0, -(view.frame.size.height-offset)+bouncingOffset, view.frame.size.width, view.frame.size.height);
    
    [UIView animateWithDuration:0.4 delay:0 options:UIViewAnimationOptionCurveEaseIn
                     animations:^() {
                         if (isDown) {
                             view.frame = downFrame;
                         } else {
                             view.frame = upFrame;
                         }
                     }
                     completion:^(BOOL finished) {
                         if (finished && isBounce) {
                             [UIView animateWithDuration:0.1
                                              animations:^{
                                                  if (isDown) {
                                                      view.frame = downBouncingFrame;    
                                                  } else {
                                                      view.frame = upBouncingFrame;
                                                  }
                              
                                              }
                                              completion:^(BOOL finished) {
                                                  if (finished) {
                                                      [UIView animateWithDuration:0.1
                                                                       animations:^{
                                                                           if (isDown) {
                                                                               view.frame = downFrame;
                                                                           } else {
                                                                               view.frame = upFrame;
                                                                           }
                                                                       }];
                                                  }
                                              }];
                             
                         }
                     }];

}

#pragma mark - CloudsitManagerDelegate Methods

- (void)managerDidSendRequestWithURL:(CloudsitManager *)manager {
    // do something at the beginning of update
}

- (void)manager:(CloudsitManager *)manager didReceiveResult:(NSDictionary *)result {
    self.weatherData = result;
    [[NSUserDefaults standardUserDefaults] setObject:result forKey:CloudsitUserDefaultsKey];
    self.lastUpdate = [NSDate date];
    [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:CloudsitUserDefaultsUpdateKey];
    
    [self updateUIWithResult:self.weatherData usingSet:YES];
    [self startTimer];
}

- (void)manager:(CloudsitManager *)manager didFailWithError:(NSError *)error {
    [self stopTimer];
    
    BOOL isNotMsg = ![[error userInfo] objectForKey:@"msg"];
    NSString *message = isNotMsg?[error localizedDescription] : (NSString *)[[error userInfo] objectForKey:@"msg"];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:@"Ok, I got it"
                                          otherButtonTitles:nil, nil];
    [alert show];
}

#pragma mark - UICollectionView Methods

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [[self.weatherData objectForKey:CloudsitManagerDataWeatherKey] count];
}

- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *currentDay = [[self.weatherData objectForKey:CloudsitManagerDataWeatherKey] objectAtIndex:indexPath.row];
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"weekdayCell" forIndexPath:indexPath];
    // clean all cells from subviews, because of the reusability of these cells
    for (UIView *subview in [cell subviews]) {
        [subview removeFromSuperview];
    }
    
#define weekday_height 30
#define weekday_width  60
    UILabel *weekday = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, weekday_width, weekday_height)];
    weekday.textAlignment = NSTextAlignmentCenter;
    weekday.backgroundColor = [UIColor clearColor];
    weekday.text = [currentDay objectForKey:@"weekday"];
    weekday.center = CGPointMake(cell.frame.size.width/2, weekday_height/2);
    [cell addSubview:weekday];
    
    UILabel *weekdayTemp = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, weekday_width, weekday_height)];
    weekdayTemp.backgroundColor = [UIColor clearColor];
    weekdayTemp.center = CGPointMake(cell.frame.size.width/2, (cell.frame.size.height-weekday_height/2));
    NSString *tempMin = [currentDay objectForKey:@"minTemp"];
    NSString *tempMax = [currentDay objectForKey:@"maxTemp"];
    weekdayTemp.text = [NSString stringWithFormat:@"%@/%@", tempMin, tempMax];
    weekdayTemp.textAlignment = NSTextAlignmentCenter;
    weekdayTemp.font = [UIFont fontWithName:@"Helvetica" size:12];
    [cell addSubview:weekdayTemp];
    
    return cell;
}

#pragma mark – UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGSize retval = CGSizeMake(
                               self.weekView.frame.size.width/[[self.weatherData objectForKey:CloudsitManagerDataWeatherKey] count],
                               self.weekView.frame.size.height);
    
    return retval;
}

#pragma mark - UITableViewDataSource Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self.weatherData objectForKey:CloudsitManagerDataWeatherKey] count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"tableWeatherCell"];
    
    NSDictionary *currentDay = [[self.weatherData objectForKey:CloudsitManagerDataWeatherKey] objectAtIndex:indexPath.row];
    
    NSString *weekday = [currentDay objectForKey:@"weekday"];
    NSString *tempMin = [currentDay objectForKey:@"minTemp"];
    NSString *tempMax = [currentDay objectForKey:@"maxTemp"];
    NSString *condition = [currentDay objectForKey:@"weatherDesc"];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd/MM"];
    NSString *day = [dateFormatter stringFromDate:(NSDate *)[currentDay objectForKey:@"date"]];
    cell.textLabel.text = [NSString stringWithFormat:@"%@ [%@]: %@", weekday, day, condition];
    cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:14];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"L: %@℃      H: %@℃", tempMin, tempMax];
    cell.imageView.image = [UIImage imageNamed:@"Default"];
    
    return cell;
}

#pragma mark - UITableViewDelegate Methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return WeatherTableCellHeight;
}


@end
