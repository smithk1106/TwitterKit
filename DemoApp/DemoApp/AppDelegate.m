//
//  AppDelegate.m
//  DemoApp
//
//  Created by Steven Hepting on 4/5/17.
//  Copyright © 2017 Twitter. All rights reserved.
//

#import "AppDelegate.h"
#import <DCIntrospect_ARC/DCIntrospect.h>
#import <FLEX/FLEX.h>
#import <TwitterKit/TWTRKit.h>
//#import "DemoApp-Swift.h"

@interface AppDelegate ()
    
@end

@implementation AppDelegate

UITextView *txtMessage = nil;

- (void)addMessage:(NSString *)message prefix:(NSString *)prefix {
    if(prefix == nil) prefix = @"i";
    txtMessage.text = [NSString stringWithFormat:@"%@%@%@\n", txtMessage.text, prefix, message];
}

#pragma mark Share to Twitter
- (void)shareTwitter:(UIViewController *)vc shareInfo:(NSDictionary *)shareInfo
{
//    TWTRComposer *composer = [[TWTRComposer alloc] init];
//    [composer setText:shareModel.share_content];
////    //带图片方法
////    [composer setImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrl]]]];
////    [composer setURL:[NSURL URLWithString:shareUrl]];
//    [composer showFromViewController:vc completion:^(TWTRComposerResult result){
//        if(result == TWTRComposerResultCancelled) {
//            //分享失败
//        }else{
//            //分享成功
//            NSLog(@"Shared to Twitter successfully.");
//        }
//    }];

    //检查是否当前会话具有登录的用户
    if ([[Twitter sharedInstance].sessionStore hasLoggedInUsers]) {
        NSString *userID = [Twitter sharedInstance].sessionStore.session.userID;
        TWTRAPIClient *client = [[TWTRAPIClient alloc] initWithUserID:userID];

        // Create and send a Tweet
        NSString *msg = [shareInfo objectForKey:@"message"];
        [client sendTweetWithText:msg completion:^(TWTRTweet *_Nullable tweet, NSError *_Nullable error){
            if(tweet) {
                NSLog(@"Twitter OK: [%@]%@", tweet.tweetID, tweet.text);
                [self addMessage:[NSString stringWithFormat:@"Twitter OK: [%@]%@", tweet.tweetID, tweet.text] prefix:@"[i]"];
            } else {
                NSLog(@"Twitter Error: %@", [error localizedDescription]);
                [self addMessage:[NSString stringWithFormat:@"Twitter Error: %@", [error localizedDescription]] prefix:@"[E]"];
                // Logout error user
                //[[Twitter sharedInstance].sessionStore logOutUserID:userID];
            }
        }];
    }else{
        [[Twitter sharedInstance] logInWithCompletion:^(TWTRSession *session, NSError *error) {
            if (session) {
                NSLog(@"Twitter Login OK: %@(%@)", session.userID, session.userName);
                [self addMessage:[NSString stringWithFormat:@"Twitter OK: [%@]%@", session.userID, session.userName] prefix:@"[i]"];

                [self shareTwitter:vc shareInfo:shareInfo];
            } else {
                NSLog(@"Twitter Login Error: %@", [error localizedDescription]);
                [self addMessage:[NSString stringWithFormat:@"Twitter Error: %@", [error localizedDescription]] prefix:@"[E]"];
            }
        }];
    }
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
    NSString *twitterConsumerKey = [info objectForKey:@"TwitterConsumerKey"];
    NSString *twitterConsumerSecret = [info objectForKey:@"TwitterConsumerSecret"];

    [[Twitter sharedInstance] startWithConsumerKey:twitterConsumerKey consumerSecret:twitterConsumerSecret];

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = [[UIViewController alloc] init];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    // Get screen information
    CGFloat screenWidth = [[UIScreen mainScreen] bounds].size.width;
    CGFloat topMargin;
    if (@available(iOS 13.0, *)) {
        topMargin = self.window.windowScene.statusBarManager.statusBarFrame.size.height;
    } else {
        topMargin = application.statusBarFrame.size.height;
        //topMargin = [UIApplication sharedApplication].statusBarFrame.size.height;
    }
    topMargin += 5;
    
    // Show title
    UILabel *labInfo = [[UILabel alloc] initWithFrame:CGRectMake((screenWidth - screenWidth * 0.8)/2, topMargin, screenWidth * 0.8, 30)];
    labInfo.adjustsFontSizeToFitWidth = NO;
    labInfo.textAlignment = NSTextAlignmentCenter;
    labInfo.font = [UIFont boldSystemFontOfSize:32.0];
    labInfo.textColor = UIColor.redColor;
    labInfo.text = @"Twitter Kit";
    [self.window addSubview:labInfo];
    
    // Show message
    txtMessage = [[UITextView alloc] initWithFrame:CGRectMake((screenWidth - screenWidth * 0.8)/2, topMargin + labInfo.frame.size.height + 20, screenWidth * 0.8, 500)];
    txtMessage.text = [NSString stringWithFormat:@"ConsumerKey: %@", [Twitter sharedInstance].authConfig.consumerKey];
    [self.window addSubview:txtMessage];
    
    // Share text message
    NSDictionary *shareInfo = @{
        @"message": @"Twitter Kit Test! #TwitterKit"
    };
    [self shareTwitter:self.window.rootViewController shareInfo:shareInfo];

#if TARGET_IPHONE_SIMULATOR
    [[DCIntrospect sharedIntrospector] start];
#endif

    return YES;
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString *, id> *)options
{
    return [[Twitter sharedInstance] application:app openURL:url options:options];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
