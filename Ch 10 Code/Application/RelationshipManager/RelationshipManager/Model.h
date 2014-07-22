//
//  Model.h
//  RelationshipManager
//
//  Created by Nathan Jones on 4/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Contact.h"

@interface Model : NSObject

@property (readonly, strong, nonatomic) NSManagedObjectContext          *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel            *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator    *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL*)applicationDocumentsDirectory;

+ (Model*)sharedModel;

- (NSArray*)contacts;

- (NSArray*)notesForContact:(Contact*)contact;

- (Contact*)contactWithEmailAddress:(NSString*)emailAddress;

- (BOOL)addContactWithFirstName:(NSString*)firstName
                       lastName:(NSString*)lastName
                        company:(NSString*)company
                   emailAddress:(NSString*)emailAddress
                    phoneNumber:(NSString*)phoneNumber
                        andNote:(NSString*)note;

/* LOCAL NOTIFICATIONS */
- (void)scheduleNotificationWithFireDate:(NSDate*)fireDate
                                timeZone:(NSTimeZone*)timeZone
                          repeatInterval:(NSCalendarUnit)repeatInterval
                               alertBody:(NSString*)alertBody
                             alertAction:(NSString*)alertAction
                             launchImage:(NSString*)launchImage
                               soundName:(NSString*)soundName
                             badgeNumber:(NSInteger)badgeNumber
                             andUserInfo:(NSDictionary*)userInfo;

- (void)scheduleContactFollowUpForContact:(Contact*)contact
                                   onDate:(NSDate*)date
                                 withBody:(NSString*)body
                                andAction:(NSString*)action;

- (NSArray*)notificationsForContact:(Contact*)contact;

- (void)cancelNotificationsForContact:(Contact*)contact;

@end