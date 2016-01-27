//
//  LTMDetailViewController.h
//  LineThemeManager
//
//  Created by Hiraku on 13/6/28.
//  Copyright (c) 2013年 Hiraku. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "GADBannerView.h"

@interface LTMDetailViewController : UIViewController
{
    NSString* LINEPath;
    NSString* customThemePath;
    NSString* officialThemePath;
    NSString* themeName;
    BOOL unsupportedTheme;
    IBOutlet UIButton* applyButton;
    
    IBOutlet UIImageView* preview;
    // Declare one as an instance variable
    GADBannerView *bannerView_;
    UIView *loadingView;
}
@property (strong, nonatomic) id detailItem;
@property (weak, nonatomic) IBOutlet UILabel *themeNameLabel;
- (void)configureView;
- (IBAction)apply:(id)sender;
@end
