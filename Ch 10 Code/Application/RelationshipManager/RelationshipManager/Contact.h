//
//  Contact.h
//  RelationshipManager
//
//  Created by Nathan Jones on 4/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Note;

@interface Contact : NSManagedObject

@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSString * lastName;
@property (nonatomic, retain) NSString * company;
@property (nonatomic, retain) NSString * emailAddress;
@property (nonatomic, retain) NSString * phoneNumber;
@property (nonatomic, retain) NSSet *notes;
@end

@interface Contact (CoreDataGeneratedAccessors)

- (void)addNotesObject:(Note *)value;
- (void)removeNotesObject:(Note *)value;
- (void)addNotes:(NSSet *)values;
- (void)removeNotes:(NSSet *)values;
@end
