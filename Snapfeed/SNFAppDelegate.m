//
//  SNFAppDelegate.m
//  Snapfeed
//
//  Created by Nino Vitale on 12/14/13.
//
//

#import "SNFAppDelegate.h"
#import "SNFFacebook.h"
#import "SNFOpenSessionViewController.h"
#import <Crashlytics/Crashlytics.h>

static NSString * const kCrashlyticsAPIKey = @"60c72262c2fc4df8067a6e7a2774efc31f783d0c";
static NSString * const kNewRelicAgentAppToken = @"AAc5f6b5e6a79b38d12f6ceb6cf348234670ad7545";

NSString *const FBSessionStateOpenedNotification = @"FBSessionStateOpenedNotification";

@implementation SNFAppDelegate

// Method for handling opening Facebook URLs
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
	return [FBSession.activeSession handleOpenURL:url];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // New Relic agent initialization
    //[NewRelicAgent startWithApplicationToken:kNewRelicAgentAppToken];
    
    // CocoaLumberjack logging initialization - logger and console
	[DDLog addLogger:[DDASLLogger sharedInstance]];
	[DDLog addLogger:[DDTTYLogger sharedInstance]];
	[[DDTTYLogger sharedInstance] setColorsEnabled:YES];
	[[DDTTYLogger sharedInstance] setForegroundColor:[UIColor flatRedColor] backgroundColor:nil forFlag:LOG_FLAG_ERROR];
	[[DDTTYLogger sharedInstance] setForegroundColor:[UIColor orangeColor] backgroundColor:nil forFlag:LOG_FLAG_WARN];
	[[DDTTYLogger sharedInstance] setForegroundColor:[UIColor flatGreenColor] backgroundColor:nil forFlag:LOG_FLAG_INFO];
	[[DDTTYLogger sharedInstance] setForegroundColor:[UIColor flatWhiteColor] backgroundColor:nil forFlag:LOG_FLAG_VERBOSE];
    
    // Crashlytics initialization
    [Crashlytics startWithAPIKey:kCrashlyticsAPIKey];
    
    // Register for opened session notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(openMainView:)
                                                 name:FBSessionStateOpenedNotification
                                               object:nil];
    
    // Initialize Facebook authentication check
    SNFFacebook *facebook = [SNFFacebook sharedInstance];
    if ([facebook activeSessionState] == FBSessionStateCreatedTokenLoaded) { // if a session was already active
        DDLogVerbose(@"%@: Session was already active, just opening session now", THIS_FILE);
        [facebook openSession];
    } else {
        DDLogVerbose(@"%@: No session exists, showing the login view", THIS_FILE);
        [self openLoginView];
    }
    
    return YES;
}

- (void)openLoginView {
    SNFOpenSessionViewController *openSession = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"OpenSession"];
    
    self.window.rootViewController = openSession;
    [self.window makeKeyAndVisible];
}

- (void)openMainView:(NSNotification *)notification {
    
    UITabBarController *mainView = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"MainTabBar"];
    
    self.window.rootViewController = mainView;
    [self.window makeKeyAndVisible];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [FBSession.activeSession handleDidBecomeActive];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    //[FBSession.activeSession close];
}

@end
