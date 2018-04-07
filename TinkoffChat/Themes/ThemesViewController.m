//
//  ThemesViewController.m
//  TinkoffChat
//
//  Created by Олег Самойлов on 17/03/2018.
//  Copyright © 2018 Oleg Samoylov. All rights reserved.
//

#import "Themes.h"
#import "ThemesViewController.h"
#import "ThemesViewControllerDelegate.h"

@implementation ThemesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _model = [[Themes alloc]initWithTheme1:[UIColor colorWithRed:(121.0/255.0) green:(214.0/255.0) blue:(249.0/255.0) alpha:1.0]
                                    theme2:[UIColor colorWithRed:(184.0/255.0) green:(226.0/255.0) blue:(151.0/255.0) alpha:1.0]
                                    theme3:[UIColor colorWithRed:1.0 green:(244.0/255.0) blue:(100.0/255.0) alpha:1.0]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0), ^{
        NSData *colorData = [[NSUserDefaults standardUserDefaults] objectForKey:@"themeColor"];
        if (colorData != nil) {
            UIColor *color = [NSKeyedUnarchiver unarchiveObjectWithData:colorData];
            dispatch_async(dispatch_get_main_queue(), ^{
                self.view.backgroundColor = color;
            });
        }
    });
    
    NSData *colorData = [[NSUserDefaults standardUserDefaults] objectForKey:@"themeColor"];
    if (colorData != nil) {
        UIColor *color = [NSKeyedUnarchiver unarchiveObjectWithData:colorData];
        self.view.backgroundColor = color;
    }
}

- (void)dealloc {
    [_model release];
    
    [super dealloc];
}

- (Themes *)model {
    return _model;
}

- (void)setModel:(Themes *)model {
    if (_model != model) {
        [_model release];
        _model = [model retain];
    }
}

- (id<ThemesViewControllerDelegate>)delegate {
    return _delegate;
}

- (void)setDelegate:(id<ThemesViewControllerDelegate>)delegate {
    if (_delegate != delegate)
        _delegate = delegate;
}

- (IBAction)didCloseBarButtonItemTap {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)didThemeButtonTap:(UIButton *)sender {
    if (_delegate == nil)
        return;
    
    switch (sender.tag) {
        case 1:
            [_delegate themesViewController:self
                             didSelectTheme:self.model.theme1];
            break;
        case 2:
            [_delegate themesViewController:self
                             didSelectTheme:self.model.theme2];
            break;
        case 3:
            [_delegate themesViewController:self
                             didSelectTheme:self.model.theme3];
            break;
        default:
            break;
    }
}

@end
