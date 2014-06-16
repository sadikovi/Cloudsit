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
@property (nonatomic, strong) NSDictionary *currentLocation;
@property (nonatomic, strong) NSDate *lastUpdate;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) UITableView *weatherTable;
@property (nonatomic) BOOL animating;

@property (weak, nonatomic) IBOutlet UICollectionView *weekView;
@property (weak, nonatomic) IBOutlet UILabel *cityLabel;
@property (weak, nonatomic) IBOutlet UILabel *countryLabel;
@property (weak, nonatomic) IBOutlet UILabel *tempLabel;
@property (weak, nonatomic) IBOutlet UIImageView *weatherCodeLabel;
@property (weak, nonatomic) IBOutlet UILabel *minTempLabel;
@property (weak, nonatomic) IBOutlet UILabel *maxTempLabel;
@property (weak, nonatomic) IBOutlet UILabel *weatherDescLabel;
@property (weak, nonatomic) IBOutlet UIView *infoView;
@property (weak, nonatomic) IBOutlet UIView *buttonsView;
@property (weak, nonatomic) IBOutlet UIView *loadingView;
@property (weak, nonatomic) IBOutlet UIButton *updateButton;
@property (weak, nonatomic) IBOutlet UIButton *slideButton;


@end

@implementation CloudsitViewController

#define UpdateIntervalLimit     10
#define UpdateIntertval         10
#define offset                  50
#define WeatherTableCellHeight  80;


- (void)loadFromUserDefaults {
    self.lastUpdate = [SettingsManager defaultManager].lastUpdate;
    self.weatherData = [SettingsManager defaultManager].weatherData;
    [self invokeActiveLocationFromUserDefaults];
}

- (void)invokeActiveLocationFromUserDefaults {
    self.currentLocation = [SettingsManager defaultManager].activeLocation;
}

- (void)updateUIWithResult:(NSDictionary *)result usingSet:(BOOL)withSet {
    self.cityLabel.text = (NSString *)[result objectForKey:LOCATIONS_NAME_KEY];
    self.countryLabel.text = (NSString *)[result objectForKey:LOCATIONS_LOCATION_KEY];
    
    NSString *temperature = @"";
    NSString *lowTemperature = @"";
    NSString *highTemperature = @"";
    
    if ([SettingsManager defaultManager].isFahrenheit) {
        temperature = (NSString *)[[result objectForKey:CloudsitManagerDataCurrentConditionKey] objectForKey:@"tempF"];
        lowTemperature = [(NSString *)[[result objectForKey:CloudsitManagerDataCurrentConditionKey] objectForKey:@"minTempF"] stringByAppendingString:@"℉"];
        highTemperature = [(NSString *)[[result objectForKey:CloudsitManagerDataCurrentConditionKey] objectForKey:@"maxTempF"] stringByAppendingString:@"℉"];
    } else {
        temperature = (NSString *)[[result objectForKey:CloudsitManagerDataCurrentConditionKey] objectForKey:@"tempC"];
        lowTemperature = [(NSString *)[[result objectForKey:CloudsitManagerDataCurrentConditionKey] objectForKey:@"minTempC"] stringByAppendingString:@"℃"];
        highTemperature = [(NSString *)[[result objectForKey:CloudsitManagerDataCurrentConditionKey] objectForKey:@"maxTempC"] stringByAppendingString:@"℃"];
    }
    
    self.tempLabel.text = [NSString stringWithFormat:@"%@", temperature];
    self.minTempLabel.text = [NSString stringWithFormat:@"L: %@", lowTemperature];
    self.maxTempLabel.text = [NSString stringWithFormat:@"H: %@", highTemperature];
    // should be some code for image view
    //self.weatherCodeLabel.text = (NSString *)[[result objectForKey:CloudsitManagerDataCurrentConditionKey] objectForKey:@"weatherCode"];
    self.weatherDescLabel.text = (NSString *)[[result objectForKey:CloudsitManagerDataCurrentConditionKey] objectForKey:@"weatherDesc"];
    
    [self.weekView reloadData];
    [self.weatherTable reloadData];
    
    if (withSet) {
        [self.view setNeedsDisplay];
    }
}

- (void)refreshWeather {
    [NoResultView removeNoResultViewFromSuperview:self.infoView];
    if (!self.currentLocation) {
        self.loadingView.hidden = NO;
        self.weatherData = nil;
    }
    
    if (self.manager) {
        [self.manager refreshDataForLocation:[self.currentLocation objectForKey:LOCATIONS_SEARCH_LOC_KEY]];
        [self stopSpin];
        [self startSpin];
    }
}

- (void) spinWithOptions: (UIViewAnimationOptions) options {
    // this spin completes 360 degrees every 2 seconds
    [UIView animateWithDuration: 0.5f
                          delay: 0.0f
                        options: options
                     animations: ^{
                         self.updateButton.transform = CGAffineTransformRotate(self.updateButton.transform, M_PI / 2);
                     }
                     completion: ^(BOOL finished) {
                         if (finished) {
                             if (self.animating) {
                                 // if flag still set, keep spinning with constant speed
                                 [self spinWithOptions: UIViewAnimationOptionCurveLinear];
                             } else if (options != UIViewAnimationOptionCurveEaseOut) {
                                 // one last spin, with deceleration
                                 [self spinWithOptions: UIViewAnimationOptionCurveEaseOut];
                             }
                         }
                     }];
}

- (void)startSpin {
    if (!self.animating) {
        self.animating = YES;
        [self spinWithOptions: UIViewAnimationOptionCurveEaseIn];
    }
}

- (void) stopSpin {
    // set the flag to stop spinning after one last 90 degree increment
    self.animating = NO;
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
    self.weatherTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    //self.weatherTable.scrollEnabled = NO;
    
    [self shadowToView:self.infoView];
    [self.view insertSubview:self.weatherTable belowSubview:self.infoView];
    
    self.manager = [[CloudsitManager alloc] initWithRequestManager:YES];
    self.manager.delegate = self;
    self.weatherData = [NSDictionary dictionary];
    self.lastUpdate = [NSDate dateWithTimeIntervalSince1970:0];
    [self loadFromUserDefaults];
    
    [self updateUIWithResult:self.weatherData usingSet:NO];
    
    self.slideButton.tag = 0;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // first of all update UI
    [self updateUIWithResult:self.weatherData usingSet:YES];
    
    NSDate *now = [NSDate date];
    NSTimeInterval interval = [now timeIntervalSinceDate:self.lastUpdate];
    
    // if weather data is null we should insert spinner view
    self.loadingView.hidden = (self.weatherData)?YES:NO;
    
    NSString *location = (NSString *)[self.weatherData objectForKey:CloudsitManagerDataLocationKey];
    // invoke current location from user defaults
    [self invokeActiveLocationFromUserDefaults];
    
    if (self.currentLocation && ![[self.currentLocation objectForKey:LOCATIONS_SEARCH_LOC_KEY] isEqualToString:location]) {
        [self refreshWeather];
    } else {
        if (interval > UpdateIntervalLimit || !(interval >= 0)) {
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

- (IBAction)slide:(UIButton *)sender {
    // it is an initial state, view is down
    if (sender.tag == 0) {
        [self animateView:self.infoView forState:NO withBouncing:NO];
    } else {
        [self animateView:self.infoView forState:YES withBouncing:NO];
    }
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
                                                      self.slideButton.tag = isDown?0:1;
                                                  }
                                              }];
                             
                         }
                         
                         if (finished && !isBounce) {
                             self.slideButton.tag = isDown?0:1;
                         }
                     }];

}

#pragma mark - CloudsitManagerDelegate Methods

- (void)managerDidSendRequestWithURL:(CloudsitManager *)manager {
    // do something at the beginning of update
}

- (void)manager:(CloudsitManager *)manager didReceiveResult:(NSDictionary *)result {
    // stop animation
    [self stopSpin];
    self.weatherData = result;
    [SettingsManager defaultManager].weatherData = self.weatherData;
    self.lastUpdate = [NSDate date];
    [SettingsManager defaultManager].lastUpdate = self.lastUpdate;
    
    [NoResultView removeNoResultViewFromSuperview:self.infoView];
    self.loadingView.hidden = YES;
    [self updateUIWithResult:self.weatherData usingSet:YES];
    
    [self startTimer];
}

- (void)manager:(CloudsitManager *)manager didFailWithError:(NSError *)error {
    [self stopTimer];
    // stop animation
    [self stopSpin];
    
    BOOL isNotMsg = ![[error userInfo] objectForKey:@"msg"];
    NSString *message = isNotMsg?[error localizedDescription] : (NSString *)[[error userInfo] objectForKey:@"msg"];
    
    NoResultView *view = [[NoResultView alloc] initWithFrame:self.infoView.frame];
    [self.infoView insertSubview:view belowSubview:self.buttonsView];
    self.loadingView.hidden = YES;
    [self updateUIWithResult:nil usingSet:YES];
    
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
    
    NSString *tempMin = @"";
    NSString *tempMax = @"";
    if ([SettingsManager defaultManager].isFahrenheit) {
        tempMin = [currentDay objectForKey:@"minTempF"];
        tempMax = [currentDay objectForKey:@"maxTempF"];
    } else {
        tempMin = [currentDay objectForKey:@"minTempC"];
        tempMax = [currentDay objectForKey:@"maxTempC"];
    }
    
    weekdayTemp.text = [NSString stringWithFormat:@"%@/%@", tempMin, tempMax];
    weekdayTemp.textAlignment = NSTextAlignmentCenter;
    weekdayTemp.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:12];
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
    
    NSString *weekday = [[DateManager defaultManager] longWeekdayFromDate:(NSDate*)[currentDay objectForKey:@"date"]];
    
    NSString *tempMin = @"";
    NSString *tempMax = @"";
    if ([SettingsManager defaultManager].isFahrenheit) {
        tempMin = [[currentDay objectForKey:@"minTempF"] stringByAppendingString:@"℉"];
        tempMax = [[currentDay objectForKey:@"maxTempF"] stringByAppendingString:@"℉"];
    } else {
        tempMin = [[currentDay objectForKey:@"minTempC"] stringByAppendingString:@"℃"];
        tempMax = [[currentDay objectForKey:@"maxTempC"] stringByAppendingString:@"℃"];
    }
    
    NSString *condition = [currentDay objectForKey:@"weatherDesc"];
    
    NSString *day = [[DateManager defaultManager] stringFromDate:(NSDate *)[currentDay objectForKey:@"date"] usingMask:@"MMM dd"];
    //cell.textLabel.text = [NSString stringWithFormat:@"%@ %@: %@", weekday, day, condition];
    cell.textLabel.text = [NSString stringWithFormat:@"%@, %@: %@ / %@", weekday, day, tempMin, tempMax];
    cell.textLabel.font = [[SettingsManager defaultManager] systemFont];
    //cell.detailTextLabel.text = [NSString stringWithFormat:@"L: %@      H: %@", tempMin, tempMax];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", condition];
    cell.detailTextLabel.font = [[SettingsManager defaultManager] systemFontDetail];
    cell.imageView.image = [UIImage imageNamed:@"Default"];
    
    return cell;
}

#pragma mark - UITableViewDelegate Methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return WeatherTableCellHeight;
}


@end
