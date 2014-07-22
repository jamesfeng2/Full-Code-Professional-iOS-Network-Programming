//
//  Note.h
//  RelationshipManager
//
//  Created by Nathan Jones on 4/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Contact;

@interface Note : NSManagedObject

@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSString * note;
@property (nonatomic, retain) Contact *noteFor;

@end
