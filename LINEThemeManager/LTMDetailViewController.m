//
//  LTMDetailViewController.m
//  LineThemeManager
//
//  Created by Hiraku on 13/6/28.
//  Copyright (c) 2013年 Hiraku. All rights reserved.
//

#import "LTMDetailViewController.h"

@implementation LTMDetailViewController

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem
{
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        
        // Update the view.
        [self configureView];
    }
}

- (void)configureView
{
    // Update the user interface for the detail item.
    
    if (self.detailItem)
    {
        self.themeNameLabel.text = [[NSString alloc] initWithData:self.detailItem encoding:NSUTF8StringEncoding];
        themeName = self.themeNameLabel.text;
        //[self.detailItem description];
    }
    unsupportedTheme = NO;
    [preview setContentMode:UIViewContentModeScaleAspectFit];
    NSFileManager* fileManager = [NSFileManager defaultManager];
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)] && [[UIScreen mainScreen] scale] == 2.0)
    {
        if ([fileManager fileExistsAtPath:[NSString stringWithFormat:@"%@/%@/images/Preview.png",customThemePath,themeName]])
        {
            [preview setImage:[UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@/images/Preview.png",customThemePath,themeName]]];
        }
        else if([fileManager fileExistsAtPath:[NSString stringWithFormat:@"%@/%@/images/default_friend_mc01@2x.png",customThemePath,themeName]])
        {
            
            [preview setImage:[UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@/images/default_friend_mc01@2x.png",customThemePath,themeName]]];
        }
        else if([fileManager fileExistsAtPath:[NSString stringWithFormat:@"%@/%@/images/default_friend_mc01@2x.jpg",customThemePath,themeName]])
        {
            [preview setImage:[UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@/images/default_friend_mc01@2x.jpg",customThemePath,themeName]]];
        }
    }
    else
    {
        if ([fileManager fileExistsAtPath:[NSString stringWithFormat:@"%@/%@/images/Preview.png",customThemePath,themeName]])
        {
            [preview setImage:[UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@/images/Preview.png",customThemePath,themeName]]];
        }
        else if([fileManager fileExistsAtPath:[NSString stringWithFormat:@"%@/%@/images/default_friend_mc01.png",customThemePath,themeName]])
        {
            [preview setImage:[UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@/images/default_friend_mc01.png",customThemePath,themeName]]];
        }
        else if([fileManager fileExistsAtPath:[NSString stringWithFormat:@"%@/%@/images/default_friend_mc01.jpg",customThemePath,themeName]])
        {
            [preview setImage:[UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@/images/default_friend_mc01.jpg",customThemePath,themeName]]];
        }
        else
        {
            //themeName = NSLocalizedString(@"Unsupported Theme (For Retina Only)","");
            unsupportedTheme = YES;
            //[applyButton setEnabled:NO];
        }
    }
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationItem setTitle:NSLocalizedString(@"Preview", @"")];
	// Do any additional setup after loading the view, typically from a nib.
    LINEPath = [self getLINEPath];
    customThemePath = @"/var/mobile/Library/LINE Themes";
    officialThemePath = [NSString stringWithFormat:@"%@/Library/Application Support/Theme Packages/a0768339-c2d3-4189-9653-2909e9bb6f58/",LINEPath];
    
    // Load AD
    // Create a view of the standard size at the top of the screen.
    // Available AdSize constants are explained in GADAdSize.h.
    bannerView_ = [[GADBannerView alloc] initWithAdSize:kGADAdSizeBanner];
    bannerView_ = [[GADBannerView alloc]
                   initWithFrame:CGRectMake(0.0,480.0 - GAD_SIZE_320x50.height,GAD_SIZE_320x50.width,GAD_SIZE_320x50.height)];
    bannerView_.delegate = (id)self;
    CGRect navBarFrame = bannerView_.frame;
    navBarFrame.origin.y = self.view.frame.size.height - navBarFrame.size.height;
    bannerView_.frame = navBarFrame;
    [self.view addSubview:bannerView_];
    
    //[bannerView_ setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin];
    [bannerView_ setAutoresizingMask:(UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin)];
    
    // Specify the ad's "unit identifier." This is your AdMob Publisher ID.
    bannerView_.adUnitID = @"";
    // Let the runtime know which UIViewController to restore after taking
    // the user wherever the ad goes and add it to the view hierarchy.
    bannerView_.rootViewController = self;
    [self.view addSubview:bannerView_];
    // Initiate a generic request to load it with an ad.
    [bannerView_ loadRequest:[GADRequest request]];
    
    [self configureView];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)alertView:(UIAlertView *)alert clickedButtonAtIndex:(NSInteger)button
{
    switch (button)
    {
        case 1:
        {
            [NSThread detachNewThreadSelector: @selector(indicatorBegin) toTarget:self withObject:nil];
            
            system("killall LINE");
            
            NSFileManager *fileManager = [NSFileManager defaultManager];
            [[NSFileManager defaultManager] setDelegate:self];
            
            NSString* fileToMove = [NSString stringWithFormat:@"%@/%@",customThemePath,[[NSString alloc] initWithData:self.detailItem encoding:NSUTF8StringEncoding]];
            NSError *error = nil;
            
            if ([fileManager fileExistsAtPath:officialThemePath])
                [[NSFileManager defaultManager] removeItemAtPath:officialThemePath error:nil];
            
            if ([fileManager copyItemAtPath:fileToMove toPath:officialThemePath error:&error])
            {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Theme Applied","") message:[NSString stringWithFormat:NSLocalizedString(@"Theme %@ applied, please restart LINE now",""),themeName] delegate: self cancelButtonTitle:NSLocalizedString(@"OK","") otherButtonTitles:nil];
                [alertView show];
            }
            else
            {
                NSLog(@"%@",[error description]);
            }
            
            [loadingView removeFromSuperview];
        }
            break;
                
        case 0:
            break;
    }
}


-(IBAction)apply:(id)sender
{
    if (unsupportedTheme)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Unsupported Theme","") message:[NSString stringWithFormat:NSLocalizedString(@"Can't found non-@2x images in %@. If theme applied, it may cause errors. Do you want to continue?",""),themeName] delegate: self cancelButtonTitle:NSLocalizedString(@"Cancel" ,"")otherButtonTitles:NSLocalizedString(@"Continue" ,""),nil];
        [alertView show];
    }
    else
    {
        [NSThread detachNewThreadSelector: @selector(indicatorBegin) toTarget:self withObject:nil];
        
        system("killall LINE");
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        [[NSFileManager defaultManager] setDelegate:self];
        
        NSString* fileToMove = [NSString stringWithFormat:@"%@/%@",customThemePath,[[NSString alloc] initWithData:self.detailItem encoding:NSUTF8StringEncoding]];
        NSError *error = nil;
        
        if ([fileManager fileExistsAtPath:officialThemePath])
            [[NSFileManager defaultManager] removeItemAtPath:officialThemePath error:nil];
        
        if ([fileManager copyItemAtPath:fileToMove toPath:officialThemePath error:&error])
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Theme Applied","") message:[NSString stringWithFormat:NSLocalizedString(@"Theme %@ applied, please restart LINE now",""),themeName] delegate: self cancelButtonTitle:NSLocalizedString(@"OK","") otherButtonTitles:nil];
            [alertView show];
        }
        else
        {
            NSLog(@"%@",[error description]);
        }
        
        [loadingView removeFromSuperview];
    }
}

-(NSString *)getLINEPath
{
    NSString *LINE_Path;
    NSFileManager* fileManager = [NSFileManager defaultManager];
    for (NSString *path in [fileManager contentsOfDirectoryAtPath:@"/var/mobile/Applications" error:nil])
    {
        for (NSString *subpath in [fileManager contentsOfDirectoryAtPath:[NSString stringWithFormat:@"/var/mobile/Applications/%@", path] error:nil])
        {
            if ([subpath hasSuffix:@"LINE.app"])
            {
                LINE_Path = [NSString stringWithFormat:@"/var/mobile/Applications/%@", path];
                return LINE_Path;
            }
        }
    }
    return @"";
}

-(void)indicatorBegin
{
    loadingView = [[UIView alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2-125, self.view.frame.size.height/2-100, 250, 150)];
    [loadingView.layer setCornerRadius:15.0f];
    [loadingView setBackgroundColor:[UIColor blackColor]];
    [loadingView setAlpha:0.8];
    
    UILabel *loadingText = [[UILabel alloc] initWithFrame:CGRectMake(0, 75, 250, 75)];
    
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 250, 130)];
    spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    [spinner startAnimating];
    
    [loadingText setText:NSLocalizedString(@"Loading","")];
    [loadingText setFont:[UIFont systemFontOfSize:20]];
    [loadingText setTextAlignment:NSTextAlignmentCenter];
    [loadingText setTextColor:[UIColor whiteColor]];
    [loadingText setBackgroundColor:[UIColor clearColor]];
    
    [loadingView addSubview:spinner];
    [loadingView addSubview:loadingText];
    [self.view addSubview:loadingView];
}
@end
