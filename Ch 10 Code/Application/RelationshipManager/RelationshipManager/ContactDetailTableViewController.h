//
//  ContactDetailTableViewController.h
//  RelationshipManager
//
//  Created by Nathan Jones on 4/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Contact.h"

@interface ContactDetailTableViewController : UITableViewController <UIActionSheetDelegate>

@property(nonatomic,strong) Contact *contact;
@property(nonatomic,assign) BOOL presentedModally;

@end