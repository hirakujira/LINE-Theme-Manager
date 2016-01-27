//
//  LTMasterViewController.m
//  LINE Themer
//
//  Created by Hiraku on 13/6/28.
//  Copyright (c) 2013年 Hiraku. All rights reserved.
//

#import "LTMMasterViewController.h"
#import "LTMDetailViewController.h"

@interface UIAlertView (Apple)
- (void) addTextFieldWithValue:(NSString *)value label:(NSString *)label;
- (id) buttons;
- (NSString *) context;
- (void) setContext:(NSString *)context;
- (void) setNumberOfRows:(int)rows;
- (void) setRunsModal:(BOOL)modal;
- (UITextField *) textField;
- (UITextField *) textFieldAtIndex:(NSUInteger)index;
- (void) _updateFrameForDisplay;
@end

@implementation LTMMasterViewController

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationItem setTitle:NSLocalizedString(@"Theme List", @"")];
    //self.navigationItem.leftBarButtonItem = self.editButtonItem;
    
    //UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addThemes:)];
    //self.navigationItem.rightBarButtonItem = addButton;
    
    UIBarButtonItem *recoveryButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Recovery", @"") style:UIBarButtonItemStylePlain target:self action:@selector(recovery:)];
    self.navigationItem.rightBarButtonItem = recoveryButton;
    
    UIBarButtonItem *helpButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Help", @"") style:UIBarButtonItemStylePlain target:self action:@selector(help:)];
    self.navigationItem.leftBarButtonItem = helpButton;
    
    language = [[NSLocale preferredLanguages] objectAtIndex:0];
    [themeListTable setFrame:CGRectMake(themeListTable.frame.origin.x, themeListTable.frame.origin.y,themeListTable.frame.size.width, themeListTable.frame.size.height-50)];
    [toolBar setFrame:CGRectMake(toolBar.frame.origin.x,toolBar.frame.origin.y-50,toolBar.frame.size.width, toolBar.frame.size.height)];
    
    // Load AD
    bannerView_ = [[GADBannerView alloc] initWithAdSize:kGADAdSizeBanner];
    bannerView_ = [[GADBannerView alloc] initWithFrame:CGRectMake(0.0,50.0 - GAD_SIZE_320x50.height, GAD_SIZE_320x50.width,GAD_SIZE_320x50.height)];
    bannerView_.delegate = (id)self;
    
    CGRect navBarFrame = bannerView_.frame;
    navBarFrame.origin.y = self.view.frame.size.height - navBarFrame.size.height;
    bannerView_.frame = navBarFrame;
    
    [bannerView_ setAutoresizingMask:(UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin)];
    
    // Specify the ad's "unit identifier." This is your AdMob Publisher ID.
    bannerView_.adUnitID = @"a151ce73faed62a";
    bannerView_.rootViewController = self;
    [bannerView_ loadRequest:[GADRequest request]];
    [self.view addSubview:bannerView_];
    
    
    LINEPath = [self getLINEPath];
    customThemePath = @"/User/Library/LINE Themes";
    officialThemePath = [NSString stringWithFormat:@"%@/Library/Application Support/Theme Packages/a0768339-c2d3-4189-9653-2909e9bb6f58/",LINEPath];
    recoveryPath = @"/User/Library/LINE Themes/Recovery";
    
    if (!themeList)
    {
        themeList = [[NSMutableArray alloc] init];
        NSArray *subFolders = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:customThemePath error:nil];
        
        for (NSString *themeFolder in subFolders)
        {
            NSFileManager *fileManager = [[NSFileManager alloc] init];
            if([fileManager fileExistsAtPath:[NSString stringWithFormat:@"%@/%@/theme.json",customThemePath,themeFolder]] && ![themeFolder isEqualToString:@"Recovery"])
            {
                NSData *data = [themeFolder dataUsingEncoding:NSUTF8StringEncoding];
                [themeList addObject:data];
            }
        }
    }
    
    if ([themeList count] == 0)
    {
        if([language hasPrefix:@"zh"])
        {
            UIImageView* helpView = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2-125, 30, 250, 150)];
            [helpView setContentMode:UIViewContentModeTop];
            [helpView setImage:[UIImage imageNamed:@"help_zh"]];
            [self.view addSubview:helpView];
        }
        else
        {
            UIImageView* helpView = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2-125, 30, 250, 150)];
            [helpView setContentMode:UIViewContentModeTop];
            [helpView setImage:[UIImage imageNamed:@"help"]];
            [self.view addSubview:helpView];
        }
    }
    
    if ([LINEPath isEqualToString:nil]||[LINEPath isEqualToString:@""])
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error","") message: NSLocalizedString(@"LINE is not installed","") delegate: self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }
    else
    {
        system("killall LINE");
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if (![fileManager fileExistsAtPath:customThemePath])
            [[NSFileManager defaultManager] createDirectoryAtPath:customThemePath withIntermediateDirectories:NO attributes:nil error:nil];
        
        if ([fileManager fileExistsAtPath:officialThemePath])
            [fileManager copyItemAtPath:officialThemePath toPath:recoveryPath error:nil];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)addThemes:(id)sender
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Enter Theme URL" message:nil delegate:self  cancelButtonTitle:@"Cancel" otherButtonTitles: @"Download", nil];
    
    [alert setContext:@"themes"];
    
    [alert setNumberOfRows:1];
    [alert addTextFieldWithValue:@"http://" label:@""];
    
    UITextField *traits = [alert textField];
    [traits setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [traits setAutocorrectionType:UITextAutocorrectionTypeNo];
    [traits setKeyboardType:UIKeyboardTypeURL];
    // XXX: UIReturnKeyDone
    [traits setReturnKeyType:UIReturnKeyNext];
    
    [alert show];
}

- (void)alertView:(UIAlertView *)alert clickedButtonAtIndex:(NSInteger)button
{
    NSString *context = [alert context];
    if ([context isEqualToString:@"themes"])
    {
        switch (button)
        {
            case 1:
            {
                NSString *href = [[alert textField] text];
                if ([href hasSuffix:@".zip"])
                {
                    
                }
                else
                {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"URL Error" message:@"File type should be .zip" delegate:self  cancelButtonTitle:@"OK" otherButtonTitles: nil];
                    [alert show];
                }
            }
                break;
                
            case 0:
                break;
        }
    }
}
- (void)insertNewObject:(id)sender
{
    [themeList insertObject:[NSDate date] atIndex:0];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [themeListTable insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

//---------------------------------------------------------------------
#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return themeList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    if (cell == nil)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    if (indexPath.row >= 0)
    {
        cell.textLabel.text = [[NSString alloc] initWithData:[themeList objectAtIndex:indexPath.row] encoding:NSUTF8StringEncoding];
        
        NSFileManager* fileManager = [NSFileManager defaultManager];
        if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)] && [[UIScreen mainScreen] scale] == 2.0)
        {
            if ([fileManager fileExistsAtPath:[NSString stringWithFormat:@"%@/%@/images/passcode_code_2@2x.png",customThemePath,cell.textLabel.text]])
                [cell.imageView setImage:[UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@/images/passcode_code_2@2x.png",customThemePath,cell.textLabel.text]]];
            else if ([fileManager fileExistsAtPath:[NSString stringWithFormat:@"%@/%@/images/passcode_code_2@2x.jpg",customThemePath,cell.textLabel.text]])
                [cell.imageView setImage:[UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@/images/passcode_code_2@2x.jpg",customThemePath,cell.textLabel.text]]];
        }
        else
        {
            if ([fileManager fileExistsAtPath:[NSString stringWithFormat:@"%@/%@/images/passcode_code_2.png",customThemePath,cell.textLabel.text]])
                [cell.imageView setImage:[UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@/images/passcode_code_2.png",customThemePath,cell.textLabel.text]]];
            else if ([fileManager fileExistsAtPath:[NSString stringWithFormat:@"%@/%@/images/passcode_code_2.jpg",customThemePath,cell.textLabel.text]])
                [cell.imageView setImage:[UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@/images/passcode_code_2.jpg",customThemePath,cell.textLabel.text]]];
        }
    }
    else
        cell.textLabel.text = @"";
    
    //cell.textLabel.text = [themeList description];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        NSString* themeFolder = [[NSString alloc] initWithData:[themeList objectAtIndex:indexPath.row] encoding:NSUTF8StringEncoding];
        
        NSError *error;
        //NSLog(@"del %@",[NSString stringWithFormat:@"/User/Library/LINE Themes/%@",themeFolder]);
        [[NSFileManager defaultManager] removeItemAtPath:[NSString stringWithFormat:@"%@/%@",customThemePath,themeFolder] error:&error];
        NSLog(@"%@",[error description]);
        
        [themeList removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert)
    {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}

#pragma mark - Actions
//---------------------------------------------------------------------
-(void)recovery:(id)sender
{
    NSFileManager* fileManager = [NSFileManager defaultManager];
    [NSThread detachNewThreadSelector: @selector(indicatorBegin) toTarget:self withObject:nil];
    
    if ([fileManager fileExistsAtPath:officialThemePath])
        [[NSFileManager defaultManager] removeItemAtPath:officialThemePath error:nil];
    
    if ([fileManager fileExistsAtPath:recoveryPath])
    {
        if ([fileManager copyItemAtPath:recoveryPath toPath:officialThemePath error:nil])
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Recovery Theme","") message:NSLocalizedString(@"Backup theme applied, please restart LINE now.","") delegate: self cancelButtonTitle:NSLocalizedString(@"OK","") otherButtonTitles:nil];
            [alertView show];
        }
        
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Warnging","") message:NSLocalizedString(@"Backup of default theme not found, cannot recovery themes." ,"")delegate: self cancelButtonTitle:NSLocalizedString(@"OK","") otherButtonTitles:nil];
        [alertView show];
    }
    [loadingView removeFromSuperview];
    
}

-(void)help:(id)sender
{
    if ([language hasPrefix:@"zh"])
    {
        NSURL *url = [ [ NSURL alloc ] initWithString: @"http://cydia.hiraku.tw/info/LineThemeManager/index_zh.html" ];
        [[UIApplication sharedApplication] openURL:url];
    }
    else
    {
        NSURL *url = [ [ NSURL alloc ] initWithString: @"http://cydia.hiraku.tw/info/LineThemeManager/index.html" ];
        [[UIApplication sharedApplication] openURL:url];
    }
}

#pragma mark - Utilities
//---------------------------------------------------------------------
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    //透過標簽取得目標實體
    LTMDetailViewController *detailViewController = [[LTMDetailViewController alloc] initWithNibName:@"LTMDetailViewController" bundle:nil];
    
    //傳遞參數
    [detailViewController setDetailItem:[themeList objectAtIndex:indexPath.row]];
    
    //切換畫面
    [self.navigationController pushViewController:detailViewController animated:YES];
    [themeListTable selectRowAtIndexPath:[NSIndexPath indexPathForRow:-1 inSection:-1] animated:YES scrollPosition:0];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    [themeListTable setEditing:editing animated:animated];
    if (editing)
    {
        // you might disable other widgets here... (optional)
    }
    else
    {
        // re-enable disabled widgets (optional)
    }
}
/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */
@end
