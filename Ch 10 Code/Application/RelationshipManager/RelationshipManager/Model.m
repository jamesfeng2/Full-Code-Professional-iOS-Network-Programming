//
//  Model.m
//  RelationshipManager
//
//  Created by Nathan Jones on 4/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Model.h"

@interface Model() {
@private
    //NSManagedObjectContext          *_managedObjectContext;
    //NSManagedObjectModel            *_managedObjectModel;
    //NSPersistentStoreCoordinator    *_persistentStoreCoordinator;
}

//- (NSPersistentStoreCoordinator *)persistentStoreCoordinator;

@end

@implementation Model

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

static Model *_instance = nil;

- (id)init {
    self = [super init];
    
    // initialize our core data context
    [self managedObjectContext];
    
    return self;
}

+ (Model *)sharedModel {
    if (_instance == nil) {
        _instance = [[self alloc] init];
    }
    
    return _instance;
}

- (NSArray*)contacts {
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Contact"];
    NSSortDescriptor *sortLast = [[NSSortDescriptor alloc] initWithKey:@"lastName" 
                                                             ascending:YES 
                                                              selector:@selector(localizedCaseInsensitiveCompare:)];
    
    NSSortDescriptor *sortFirst = [[NSSortDescriptor alloc] initWithKey:@"firstName"
                                                              ascending:YES 
                                                               selector:@selector(localizedCaseInsensitiveCompare:)];
    request.sortDescriptors = [NSArray arrayWithObjects:sortLast, sortFirst, nil];
    
    NSError *error = nil;
    NSArray *contacts = [_managedObjectContext executeFetchRequest:request
                                                             error:&error];
    
    return contacts;
}

- (NSArray*)notesForContact:(Contact*)contact {
    return nil;
}

- (Contact*)contactWithEmailAddress:(NSString*)emailAddress {
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Contact"];
    
    // add our search WHERE clause
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"emailAddress = %@", emailAddress];
    request.predicate = predicate;
    
    // add our sorting options, in theory this request will only ever have a single result
    NSSortDescriptor *sortEmail = [[NSSortDescriptor alloc] initWithKey:@"emailAddress" 
                                                              ascending:YES 
                                                               selector:@selector(localizedCaseInsensitiveCompare:)];
    request.sortDescriptors = [NSArray arrayWithObjects:sortEmail, nil];
    
    NSError *error = nil;
    NSArray *contacts = [_managedObjectContext executeFetchRequest:request
                                                             error:&error];
    
    // we count a nil and more than 1 as an error, return such
    if (!contacts || [contacts count] > 1) {
        return nil;
    }
    
    return [contacts lastObject];
}

- (BOOL)addContactWithFirstName:(NSString*)firstName
                       lastName:(NSString*)lastName
                        company:(NSString*)company
                   emailAddress:(NSString*)emailAddress
                    phoneNumber:(NSString*)phoneNumber
                        andNote:(NSString*)note {
    
    // validate a contact with this email address doesn't already exist
    Contact *uniqueCheck = [self contactWithEmailAddress:emailAddress];
    if (uniqueCheck) {
        return NO;
    }
    
    Contact *contact = [NSEntityDescription insertNewObjectForEntityForName:@"Contact" 
                                                     inManagedObjectContext:_managedObjectContext];

    contact.firstName = firstName;
    contact.lastName = lastName;
    contact.company = company;
    contact.emailAddress = emailAddress;
    contact.phoneNumber = phoneNumber;
    
    [self saveContext];
    
    return YES;
}

#pragma mark - Core Data
- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = _managedObjectContext;
    if (managedObjectContext != nil)
    {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error])
        {
            /*
             Error handling 
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();    // you would not want to include this in a shipped application
        } 
    }
}

#pragma mark - Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil)
    {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil)
    {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created from the application's model.
 */
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil)
    {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"RelationshipManager" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil)
    {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"RelationshipManager.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error])
    {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter: 
         [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

/**
 Returns the URL to the application's Documents directory.
 */
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

#pragma mark - Local Notifications
- (void)scheduleNotificationWithFireDate:(NSDate*)fireDate
                                timeZone:(NSTimeZone*)timeZone
                          repeatInterval:(NSCalendarUnit)repeatInterval
                               alertBody:(NSString*)alertBody
                             alertAction:(NSString*)alertAction
                             launchImage:(NSString*)launchImage
                               soundName:(NSString*)soundName
                             badgeNumber:(NSInteger)badgeNumber
                             andUserInfo:(NSDictionary*)userInfo {
    
    // create notification using parameter values
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.fireDate = fireDate;
    notification.timeZone = timeZone;
    notification.repeatInterval = repeatInterval;
    notification.alertBody = alertBody;
    notification.alertLaunchImage = launchImage;
    notification.soundName = soundName;
    notification.applicationIconBadgeNumber = badgeNumber;
    notification.userInfo = userInfo;
    
    // special handling for action
    // default hasAction is YES, so if we don't have one
    // set to no. this removes button / slider
    if (alertAction == nil) {
        notification.hasAction = NO;
    } else {
        notification.alertAction = alertAction;
    }
    
    // schedule notification asynchronously
    dispatch_async(dispatch_get_main_queue(), ^{
        [[UIApplication sharedApplication] 
         scheduleLocalNotification:notification];
    });
}

- (void)scheduleContactFollowUpForContact:(Contact*)contact
                                   onDate:(NSDate*)date
                                 withBody:(NSString*)body
                                andAction:(NSString*)action {
    
    // add action to user info to help user experience on launch
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                              contact.emailAddress, @"emailAddress",
                              contact.phoneNumber, @"phoneNumber",
                              @"contactProfile", @"type",
                              action, @"action", nil];
    
    [self scheduleNotificationWithFireDate:date
                                  timeZone:[NSTimeZone systemTimeZone]
                            repeatInterval:0                            // don't repeat
                                 alertBody:body
                               alertAction:action
                               launchImage:@""                          // contact default
                                 soundName:nil                          // no sounds
                               badgeNumber:1
                               andUserInfo:userInfo];
    
}

- (NSArray*)notificationsForContact:(Contact*)contact {
    NSMutableArray *contactNotifications = [[NSMutableArray alloc] init];
    
    // get ALL scheduled notifications and loop through them
    NSArray *scheduledNotifications = [[UIApplication sharedApplication] 
                                       scheduledLocalNotifications];
    
    for (UILocalNotification *notification in scheduledNotifications) {
        
        // if the email address in the notification user info matches 
        // the contacts email, add it to our output
        if ([[notification.userInfo objectForKey:@"emailAddress"] 
             isEqualToString:contact.emailAddress]) {
            
            [contactNotifications addObject:notification];
        }
    }
    
    return (NSArray*)contactNotifications;
}

- (void)cancelNotificationsForContact:(Contact*)contact {
    
    // retrieve all notifications for the specified 
    // contact and loop through them
    NSArray *notifications = [self notificationsForContact:contact];
    for (UILocalNotification *notification in notifications) {
        
        // cancel the notification
        [[UIApplication sharedApplication] 
         cancelLocalNotification:notification];
    }
}

@end