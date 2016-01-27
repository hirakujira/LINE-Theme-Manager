//
//  LTMMasterViewController.h
//  LineThemeManager
//
//  Created by Hiraku on 13/6/28.
//  Copyright (c) 2013年 Hiraku. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "GADBannerView.h"

@interface LTMMasterViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
{
    NSString* LINEPath;
    NSString* customThemePath;
    NSString* officialThemePath;
    NSString* recoveryPath;
    
    NSMutableArray *themeList;
    NSMutableArray *_objects;
    NSString* language;
    UIView *loadingView;
    
    UIView *addThemeView;
    
    IBOutlet UITableView* themeListTable;
    IBOutlet UIToolbar* toolBar;
    // Declare one as an instance variable
    GADBannerView *bannerView_;
}
-(NSString *)getLINEPath;
-(void)recovery:(id)sender;
-(void)help:(id)sender;
@end
