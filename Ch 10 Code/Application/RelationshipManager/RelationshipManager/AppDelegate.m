//
//  AppDelegate.m
//  RelationshipManager
//
//  Created by Nathan Jones on 4/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

//  This code uses a category created by Mungunth Kumar for
//  better alert view handling - https://github.com/MugunthKumar/UIKitCategoryAdditions

#import "AppDelegate.h"
#import "ContactsTableViewController.h"
#import "ContactDetailTableViewController.h"
#import "UIAlertView+MKBlockAdditions.h"
#import "Model.h"

#define kPushTokenTransmitted @"PushNotificationTokenTransmitted"

@interface AppDelegate () {
@private

}

@end

@implementation AppDelegate

@synthesize window = _window;
@synthesize navigationController = _navigationController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // determine if app launched from a local notification
    UILocalNotification *localNotification = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    if (localNotification != nil) {
        NSDictionary *userInfo = localNotification.userInfo;
        
        NSString *action = [userInfo objectForKey:@"action"];
        Contact *contact = [[Model sharedModel] contactWithEmailAddress:[userInfo objectForKey:@"emailAddress"]];
        
        // initiate a phone call
        if ([action isEqualToString:@"Call"]) {
            NSString *phone = [NSString stringWithFormat:@"tel:%@", contact.phoneNumber];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phone]];
            
        // start an email
        } else if ([action isEqualToString:@"Email"]) {
            NSString *email = [NSString stringWithFormat:@"mailto:%@", contact.emailAddress];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:email]];
            
        }
        
    }
    
    // determine if app launched from a push notification
    NSDictionary *pushNotification = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if (pushNotification != nil) {
        NSString *action = [[[pushNotification objectForKey:@"aps"] objectForKey:@"alert"] objectForKey:@"action-loc-key"];
        Contact *contact = [[Model sharedModel] contactWithEmailAddress:[pushNotification objectForKey:@"emailAddress"]];
        
        // initiate a phone call
        if ([action isEqualToString:@"Call"]) {
            NSString *phone = [NSString stringWithFormat:@"tel:%@", contact.phoneNumber];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phone]];
            
            // start an email
        } else if ([action isEqualToString:@"Email"]) {
            NSString *email = [NSString stringWithFormat:@"mailto:%@", contact.emailAddress];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:email]];
            
        }
    }
    
    // request permission to deliver remote notifications
    BOOL requested = [[NSUserDefaults standardUserDefaults]
                      boolForKey:kPushTokenTransmitted];
    if (requested != YES) {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert | 
                                                                               UIRemoteNotificationTypeBadge |                                                                   
                                                                               UIRemoteNotificationTypeSound)];
    }
    
    // reset the application badge to 0
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    ContactsTableViewController *contactsVC = [[ContactsTableViewController alloc] initWithStyle:UITableViewStylePlain];
    self.navigationController = [[UINavigationController alloc] initWithRootViewController:contactsVC];
    self.window.rootViewController = self.navigationController;
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Saves changes in the application's managed object context before the application terminates.
    [[Model sharedModel] saveContext];
}

#pragma mark - Local Notifications
- (void)application:(UIApplication*)application didReceiveLocalNotification:(UILocalNotification *)notification {
    
    // alert the user that a notification was received
    // because the user was in the application, we present
    // them with some additional information
    dispatch_async(dispatch_get_main_queue(), ^{
        NSDictionary *userInfo = notification.userInfo;
        
        NSString *action = [userInfo objectForKey:@"action"];
        Contact *contact = [[Model sharedModel] contactWithEmailAddress:[userInfo objectForKey:@"emailAddress"]];
        
        [UIAlertView alertViewWithTitle:@"Reminder"
                                message:notification.alertBody
                      cancelButtonTitle:@"Cancel" 
                      otherButtonTitles:[NSArray arrayWithObjects:@"View Contact", action, nil]
                              onDismiss:^(int buttonIndex)
                                 {  
                                     // display the contact details
                                     if (buttonIndex == 0) {
                                         
                                         ContactDetailTableViewController *contactVC = [[ContactDetailTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
                                         
                                         contactVC.contact = contact;
                                         contactVC.presentedModally = YES;
                                         
                                         UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:contactVC];
                                         [self.navigationController presentModalViewController:nc animated:YES];
                                         
                                     // initiate the selected action
                                     } else if (buttonIndex == 1) {
                                         // initiate a phone call
                                         if ([action isEqualToString:@"Call"]) {
                                             NSString *phone = [NSString stringWithFormat:@"tel:%@", contact.phoneNumber];
                                             [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phone]];
                                             
                                         // start an email
                                         } else if ([action isEqualToString:@"Email"]) {
                                             NSString *email = [NSString stringWithFormat:@"mailto:%@", contact.emailAddress];
                                             [[UIApplication sharedApplication] openURL:[NSURL URLWithString:email]];
                                             
                                         }
                                     }
                                 }
                               onCancel:^()
                                 {  
                                     // don't do anything for cancel
                                 }];
    });
    
    // reset the application badge to 0
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
}

#pragma mark - Remote Notifications
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {

    // hardcode the current user, this would typically
    // be a token or value retrieved after they logged
    // in to use the app
    NSString *userId = @"nate@emaildomain.com";
    NSString *token = [NSString stringWithFormat:@"%@", deviceToken];
    
    // clean the token
    token = [token stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    // handle the request off the main thread
    dispatch_async(dispatch_get_main_queue(), ^{

        // build the post body
        NSString *postBody = [NSString stringWithFormat:@"user=%@&token=%@", userId, token];
        
        // build the request
        NSString *endpoint = @"http://yourdomain.com/push/register.php";
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] 
                                        initWithURL:[NSURL URLWithString:endpoint]                                                       
                                        cachePolicy:NSURLRequestReloadIgnoringCacheData                           
                                        timeoutInterval:30.0];
        
        // configure the remaining request properties
        request.HTTPMethod = @"POST";
        request.HTTPBody = [postBody dataUsingEncoding:NSUTF8StringEncoding];
        [request setValue:@"application/x-www-form-urlencoded" 
       forHTTPHeaderField:@"Content-Type"];
        
        NSError *error = nil;
        NSHTTPURLResponse *response;
        
        // this method returns NSData, but in this case
        // we don't care about it
        [NSURLConnection sendSynchronousRequest:request
                              returningResponse:&response 
                                          error:&error];
        
        // verify we got a success
        if (response.statusCode == 200) {
            
            // save our local flag so that we don't
            // hit this logic each time the app is opened
            [[NSUserDefaults standardUserDefaults]
             setBool:YES forKey:kPushTokenTransmitted];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
        // alert the user if we didn't get a success
        } else {
            [[[UIAlertView alloc] initWithTitle:@"Error"
                                        message:@"Unable to "
                                       delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil] show];
        }
        
    });
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    // you could implement some analytics around how many people reject access...
    // you could also display an alert informing them that they won't receive alerts for x, y and z
}

- (void)application:(UIApplication*)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
    // alert the user that a notification was received
    // because the user was in the application, we present
    // them with some additional information / options
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSString *action = [[[userInfo objectForKey:@"aps"] objectForKey:@"alert"] objectForKey:@"action-loc-key"];
        Contact *contact = [[Model sharedModel] contactWithEmailAddress:[userInfo objectForKey:@"emailAddress"]];
        
        // get the reminder message
        NSString *message;
        message = [[[userInfo objectForKey:@"aps"] objectForKey:@"alert"] objectForKey:@"body"];
        if (message == nil) {
            // no message found at that path
            // that implies a simple notification structure
            message = [[userInfo objectForKey:@"aps"] objectForKey:@"alert"];
        }
        
        [UIAlertView alertViewWithTitle:@"Reminder"
                                message:message
                      cancelButtonTitle:@"Cancel" 
                      otherButtonTitles:[NSArray 
                                         arrayWithObjects:@"View Contact", 
                                         action, nil]
                              onDismiss:^(int buttonIndex)
                                 {  
                                     // display the contact details
                                     if (buttonIndex == 0) {
                                         
                                         ContactDetailTableViewController *contactVC = [[ContactDetailTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
                                         
                                         contactVC.contact = contact;
                                         contactVC.presentedModally = YES;
                                         
                                         UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:contactVC];
                                         
                                         [self.navigationController presentModalViewController:nc animated:YES];
                                         
                                         // initiate the selected action
                                     } else if (buttonIndex == 1) {
                                         
                                         // initiate a phone call
                                         if ([action isEqualToString:@"Call"]) {
                                             NSString *phone = [NSString stringWithFormat:@"tel:%@", contact.phoneNumber];
                                             
                                             [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phone]];
                                             
                                             // start an email
                                         } else if ([action isEqualToString:@"Email"]) {
                                             NSString *email = [NSString stringWithFormat:@"mailto:%@", contact.emailAddress];
                                             [[UIApplication sharedApplication] openURL:[NSURL URLWithString:email]];
                                             
                                         }
                                     }
                                 }                       
                               onCancel:^()
                                 {  
                                     // don't do anything for cancel
                                 }];
    });
    
    // reset the application badge to 0
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
}
@end