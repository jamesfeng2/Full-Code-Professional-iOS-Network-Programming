//
//  AddReminderTableViewController.h
//  RelationshipManager
//
//  Created by Nathan Jones on 4/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Contact.h"

@interface AddReminderTableViewController : UITableViewController <UIPickerViewDataSource, UIPickerViewDelegate>

@property(nonatomic,strong) Contact *contact;

@end