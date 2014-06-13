//
//  SettingsViewController.h
//  Cloudsit
//
//  Created by Ivan Sadikov on 9/06/14.
//  Copyright (c) 2014 Ivan Sadikov. All rights reserved.
//

#import <UIKit/UIKit.h>


/**
 * Class for settings view
 * Basically it provides with location choosing and can be other things
 * 
 * Implements severl protocols: UITableViewDataSource, UITableViewDelegate
 * as well as UISearchBarDelegate and UISearchDisplayDelegate
 *
 */
@interface SettingsViewController : UIViewController
<UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UISearchDisplayDelegate>

@end
