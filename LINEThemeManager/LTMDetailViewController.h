//
//  LTMDetailViewController.h
//  LINEThemeManager
//
//  Created by Hiraku on 13/6/30.
//  Copyright (c) 2013年 Hiraku. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LTMDetailViewController : UIViewController

@property (strong, nonatomic) id detailItem;

@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@end
