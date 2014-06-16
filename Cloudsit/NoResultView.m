//
//  NoResultView.m
//  Cloudsit
//
//  Created by Ivan Sadikov on 13/06/14.
//  Copyright (c) 2014 Ivan Sadikov. All rights reserved.
//

#import "NoResultView.h"

@implementation NoResultView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        CGRect noResultsLabelFrame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height/10);
        self.backgroundColor = [UIColor darkGrayColor];
        UILabel *noResultsLabel = [[UILabel alloc] initWithFrame:noResultsLabelFrame];
        noResultsLabel.backgroundColor = [UIColor clearColor];
        noResultsLabel.textAlignment = NSTextAlignmentCenter;
        noResultsLabel.text = @"No Results :(";
        noResultsLabel.textColor = [UIColor whiteColor];
        noResultsLabel.center = self.center;
        
        [self addSubview:noResultsLabel];
        
        self.tag = NO_RESULTS_VIEW_TAG;
    }
    return self;
}

+ (void)removeNoResultViewFromSuperview:(UIView *)superview {
    for (UIView *view in [superview subviews]) {
        if (view.tag == NO_RESULTS_VIEW_TAG) {
            [view removeFromSuperview];
            break;
        }
    }
}

@end
