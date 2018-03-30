//
//  ThemesViewControllerDelegate.h
//  TinkoffChat
//
//  Created by Олег Самойлов on 20/03/2018.
//  Copyright © 2018 Oleg Samoylov. All rights reserved.
//

@class ThemesViewController;

@protocol ThemesViewControllerDelegate<NSObject>

- (void)themesViewController:(ThemesViewController *)controller
              didSelectTheme:(UIColor *)selectedTheme;

@end
