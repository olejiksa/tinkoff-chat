//
//  ThemesViewController.h
//  TinkoffChat
//
//  Created by Олег Самойлов on 17/03/2018.
//  Copyright © 2018 Oleg Samoylov. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Themes;
@protocol ThemesViewControllerDelegate;

@interface ThemesViewController : UIViewController {
    id<ThemesViewControllerDelegate> _delegate;
    Themes *_model;
}

- (void)dealloc;

@property (nonatomic, assign) id<ThemesViewControllerDelegate> delegate;
@property (nonatomic, retain) Themes *model;

- (IBAction)didCloseBarButtonItemTap;
- (IBAction)didThemeButtonTap:(UIButton *)sender;

@end
