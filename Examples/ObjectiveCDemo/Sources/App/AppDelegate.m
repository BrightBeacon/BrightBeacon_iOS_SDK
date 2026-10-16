#import "AppDelegate.h"
#import "HomeController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)options {
    HomeController *home = [[HomeController alloc] initWithStyle:UITableViewStyleInsetGrouped];
    UINavigationController *navigation =
        [[UINavigationController alloc] initWithRootViewController:home];
    navigation.navigationBar.prefersLargeTitles = YES;

    self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    self.window.rootViewController = navigation;
    [self.window makeKeyAndVisible];
    return YES;
}

@end
