//
//  AddContactTableViewController.m
//  RelationshipManager
//
//  Created by Nathan Jones on 4/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AddContactTableViewController.h"
#import "Model.h"

#define kFieldTitleWidth 165

@interface AddContactTableViewController () {
@private
    UITextField *firstNameField;
    UITextField *lastNameField;
    UITextField *companyField;
    UITextField *emailAddressField;
    UITextField *phoneNumberField;
    UITextView  *noteField;
}

- (void)cancel:(id)sender;
- (void)saveContact:(id)sender;

@end

@implementation AddContactTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}



#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = @"Add Contact";
    
    // create our cancel button
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                  target:self 
                                                                                  action:@selector(cancel:)];
    
    self.navigationItem.leftBarButtonItem = cancelButton;
    
    // create our save button
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave 
                                                                               target:self 
                                                                               action:@selector(saveContact:)];
    
    self.navigationItem.rightBarButtonItem = saveButton;
}

#pragma mark - UI Response
- (void)cancel:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

- (void)saveContact:(id)sender {
    
    // save our contact    
    BOOL contactAdded = [[Model sharedModel] addContactWithFirstName:firstNameField.text
                                                            lastName:lastNameField.text
                                                             company:companyField.text
                                                        emailAddress:emailAddressField.text
                                                         phoneNumber:phoneNumberField.text
                                                             andNote:noteField.text];
    if (contactAdded == YES) {
        [self dismissModalViewControllerAnimated:YES];
    } else {
        [[[UIAlertView alloc] initWithTitle:@"Error"
                                    message:@"Unable to add contact. Confirm email address doesn't already exist."
                                   delegate:nil 
                          cancelButtonTitle:@"OK" 
                          otherButtonTitles:nil] show];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 3;
    } else if (section == 1) {
        return 2;
    }
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    // notes section
    if (indexPath.section == 2) {
        return 100;
    }
    
    // all other cells are standard height
    return 44;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 2) {
        return @"Notes";
    }
    return @"";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    switch (indexPath.section) {
        case 0:
            if (indexPath.row == 0) {
                if (firstNameField == nil) {
                    firstNameField = [[UITextField alloc] initWithFrame:CGRectMake(kFieldTitleWidth,
                                                                                   2,
                                                                                   cell.contentView.frame.size.width - kFieldTitleWidth,
                                                                                   40)];
                    firstNameField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
                }
                
                cell.textLabel.text = @"First Name";
                cell.accessoryView = firstNameField;
            } else if (indexPath.row == 1) {
                if (lastNameField == nil) {
                    lastNameField = [[UITextField alloc] initWithFrame:CGRectMake(kFieldTitleWidth,
                                                                                  2,
                                                                                  cell.contentView.frame.size.width - kFieldTitleWidth,
                                                                                  40)];
                    lastNameField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
                }
                
                cell.textLabel.text = @"Last Name";
                cell.accessoryView = lastNameField;
            } else {
                if (companyField == nil) {
                    companyField = [[UITextField alloc] initWithFrame:CGRectMake(kFieldTitleWidth,
                                                                                 2,
                                                                                 cell.contentView.frame.size.width - kFieldTitleWidth,
                                                                                 40)];
                    companyField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
                }
                
                cell.textLabel.text = @"Company";
                cell.accessoryView = companyField;
            }
            
            break;
        
        case 1:
            if (indexPath.row == 0) {
                if (phoneNumberField == nil) {
                    phoneNumberField = [[UITextField alloc] initWithFrame:CGRectMake(kFieldTitleWidth,
                                                                                     2,
                                                                                     cell.contentView.frame.size.width - 165,
                                                                                     40)];
                    phoneNumberField.keyboardType = UIKeyboardTypePhonePad;
                    phoneNumberField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
                }
                
                cell.textLabel.text = @"Phone Number";
                cell.accessoryView = phoneNumberField;
            } else {
                if (emailAddressField == nil) {
                    emailAddressField = [[UITextField alloc] initWithFrame:CGRectMake(kFieldTitleWidth,
                                                                                      2,
                                                                                      cell.contentView.frame.size.width - kFieldTitleWidth,
                                                                                      40)];
                    emailAddressField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
                }
                
                cell.textLabel.text = @"Email Address";
                cell.accessoryView = emailAddressField;
            }

        default:
            break;
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

@end
