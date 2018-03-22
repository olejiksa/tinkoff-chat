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
    _model = [[Themes alloc]initWithTheme1:UIColor.lightGrayColor
                                    theme2:UIColor.darkGrayColor
                                    theme3:[UIColor colorWithRed:1.0 green:(244.0/255.0) blue:(100.0/255.0) alpha:1.0]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSData *colorData = [[NSUserDefaults standardUserDefaults] objectForKey:@"themeColor"];
    if (colorData != nil) {
        UIColor *color = [NSKeyedUnarchiver unarchiveObjectWithData:colorData];
        self.view.backgroundColor = color;
    }
}

- (void)dealloc {
    [_model release];
    
    _model = nil;
    _delegate = nil;
    
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
    
    if ([sender.currentTitle isEqualToString:@"Тема 1"])
        [_delegate themesViewController:self
                         didSelectTheme:self.model.theme1];
    else if ([sender.currentTitle isEqualToString:@"Тема 2"])
        [_delegate themesViewController:self
                         didSelectTheme:self.model.theme2];
    else if ([sender.currentTitle isEqualToString:@"Тема 3"])
        [_delegate themesViewController:self
                         didSelectTheme:self.model.theme3];
}

@end
