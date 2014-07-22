//
//  ContactDetailTableViewController.m
//  RelationshipManager
//
//  Created by Nathan Jones on 4/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ContactDetailTableViewController.h"
#import "NotesTableViewController.h"
#import "AddReminderTableViewController.h"
#import "Model.h"

#define kFieldTitleWidth 165

@interface ContactDetailTableViewController() {
@private
    UITextField *firstNameField;
    UITextField *lastNameField;
    UITextField *companyField;
    UITextField *emailAddressField;
    UITextField *phoneNumberField;
    UITextView  *noteField;
    
    UILabel     *addReminderCellContent;
    UILabel     *cancelRemindersCellContent;
}

- (void)saveContact:(id)sender;
- (void)cancel:(id)sender;

@end

@implementation ContactDetailTableViewController

@synthesize contact = _contact;
@synthesize presentedModally = _presentedModally;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = [NSString stringWithFormat:@"%@ %@", _contact.firstName, _contact.lastName];
    
    // create our save Contact button
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave 
                                                                                target:self 
                                                                                action:@selector(saveContact:)];
    self.navigationItem.rightBarButtonItem = saveButton;

    // create our cancel button
    // this is only done modally b/c typically
    // there would be a back button
    if (_presentedModally == YES) {
        UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                      target:self 
                                                                                      action:@selector(cancel:)];
        self.navigationItem.leftBarButtonItem = cancelButton;
    }
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // reload the table view, primarily for notification counts
    [self.tableView reloadData];
}

#pragma mark - UI Response
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

- (void)cancel:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 5;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 3;
    } else if (section == 1) {
        return 2;
    }
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    CGRect cellFrame = CGRectMake(kFieldTitleWidth,
                              2,
                              cell.contentView.frame.size.width - kFieldTitleWidth,
                              40);
    
    switch (indexPath.section) {
        case 0:
            if (indexPath.row == 0) {
                if (firstNameField == nil) {
                    firstNameField = [[UITextField alloc] initWithFrame:cellFrame];
                    firstNameField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
                }
                
                firstNameField.text = _contact.firstName;
                cell.textLabel.text = @"First Name";
                cell.accessoryView = firstNameField;
            } else if (indexPath.row == 1) {
                if (lastNameField == nil) {
                    lastNameField = [[UITextField alloc] initWithFrame:cellFrame];
                    lastNameField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
                }
                
                lastNameField.text = _contact.lastName;
                cell.textLabel.text = @"Last Name";
                cell.accessoryView = lastNameField;
            } else {
                if (companyField == nil) {
                    companyField = [[UITextField alloc] initWithFrame:cellFrame];
                    companyField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
                }
                
                companyField.text = _contact.company;
                cell.textLabel.text = @"Company";
                cell.accessoryView = companyField;
            }
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            break;
            
        case 1:
            if (indexPath.row == 0) {
                if (phoneNumberField == nil) {
                    phoneNumberField = [[UITextField alloc] initWithFrame:cellFrame];
                    phoneNumberField.keyboardType = UIKeyboardTypePhonePad;
                    phoneNumberField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
                }
                
                phoneNumberField.text = _contact.phoneNumber;
                cell.textLabel.text = @"Phone Number";
                cell.accessoryView = phoneNumberField;
            } else {
                if (emailAddressField == nil) {
                    emailAddressField = [[UITextField alloc] initWithFrame:cellFrame];
                    emailAddressField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
                }
                
                emailAddressField.text = _contact.emailAddress;
                cell.textLabel.text = @"Email Address";
                cell.accessoryView = emailAddressField;
            }
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            break;
            
        case 2:
            cell.textLabel.text = @"Notes";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
            break;
            
        case 3: {
            if (addReminderCellContent == nil) {
                addReminderCellContent = [[UILabel alloc] initWithFrame:CGRectMake(0, 
                                                                                   0, 
                                                                                   300,
                                                                                   cell.contentView.frame.size.height)];
                addReminderCellContent.textAlignment = UITextAlignmentCenter;
                addReminderCellContent.font = [UIFont boldSystemFontOfSize:18];
                addReminderCellContent.textColor = [UIColor blueColor];
                addReminderCellContent.backgroundColor = [UIColor clearColor];
            
                [cell.contentView addSubview:addReminderCellContent];
            }
            addReminderCellContent.text = @"Add Reminder";
            
            
            break;
        }
        case 4: {
            NSArray *reminders = [[Model sharedModel] notificationsForContact:_contact];
            
            if (cancelRemindersCellContent == nil) {
                cancelRemindersCellContent = [[UILabel alloc] initWithFrame:CGRectMake(0, 
                                                                                       0, 
                                                                                       300,
                                                                                       cell.contentView.frame.size.height)];
                cancelRemindersCellContent.textAlignment = UITextAlignmentCenter;
                cancelRemindersCellContent.font = [UIFont boldSystemFontOfSize:18];
                cancelRemindersCellContent.textColor = [UIColor blueColor];
                cancelRemindersCellContent.backgroundColor = [UIColor clearColor];
                
                [cell.contentView addSubview:cancelRemindersCellContent];
            }
            
            cancelRemindersCellContent.text = [NSString stringWithFormat:@"Cancel Reminders (%i)", [reminders count]];
            
            break;
        }
        default:
            break;
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (indexPath.section) {
        
        // view contact notes
        case 2: {
            NotesTableViewController *notesVC = [[NotesTableViewController alloc] initWithStyle:UITableViewStylePlain];
            [self.navigationController pushViewController:notesVC animated:YES];
            break;
        }
        
        // add a reminder for current contact
        case 3: {
            AddReminderTableViewController *reminderVC = [[AddReminderTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
            reminderVC.contact = _contact;
            UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:reminderVC];
            [self presentModalViewController:nc animated:YES];
            break;
        }
        
        // cancel notifications for current contact
        case 4: {
            UIActionSheet *confirmCancel = [[UIActionSheet alloc] initWithTitle:@"Are you sure you want to cancel notifications?"
                                                                       delegate:self 
                                                              cancelButtonTitle:@"Cancel" 
                                                         destructiveButtonTitle:@"Cancel Notifications" 
                                                              otherButtonTitles:nil];
            [confirmCancel showInView:self.view];
            break;
        }
        default:
            
            break;
    }
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    // user elected to cancel notifications
    if (buttonIndex == 0) {
        [[Model sharedModel] cancelNotificationsForContact:_contact];
        [self.tableView reloadData];
    }
}
@end
