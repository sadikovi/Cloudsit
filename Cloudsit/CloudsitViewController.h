//
//  CloudsitViewController.h
//  Cloudsit
//
//  Created by Ivan Sadikov on 7/06/14.
//  Copyright (c) 2014 Ivan Sadikov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "CloudsitManager.h"
#import "SettingsManager.h"
#import "DateManager.h"
#import "NoResultView.h"

@interface CloudsitViewController : UIViewController
<CloudsitManagerDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UITableViewDataSource, UITableViewDelegate>

@end
