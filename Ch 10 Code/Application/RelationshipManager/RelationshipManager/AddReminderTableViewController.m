//
//  AddReminderTableViewController.m
//  RelationshipManager
//
//  Created by Nathan Jones on 4/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AddReminderTableViewController.h"
#import "Model.h"

#define kFieldTitleWidth 100

@interface AddReminderTableViewController () {
@private
    NSDate      *reminderDate;
    
    UITextField *reminderBodyField;
    UITextField *reminderDateField;
    UITextField *reminderActionField;
    
    UIDatePicker *reminderDatePicker;
    UIPickerView *reminderActionPicker;
}

- (void)cancel:(id)sender;
- (void)saveReminder:(id)sender;
- (void)datePickerChanged;

@end

@implementation AddReminderTableViewController

@synthesize contact = _contact;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        if (reminderDatePicker == nil) {
            reminderDatePicker = [[UIDatePicker alloc] init];
            reminderDatePicker.datePickerMode = UIDatePickerModeDateAndTime;
        
            // can't set reminders in the past
            reminderDatePicker.minimumDate = [NSDate date];
            reminderDatePicker.timeZone = [NSTimeZone systemTimeZone];
            [reminderDatePicker setDate:[NSDate date]];
            [reminderDatePicker addTarget:self 
                                   action:@selector(datePickerChanged) 
                         forControlEvents:UIControlEventValueChanged];
        }
        
        if (reminderActionPicker == nil) {
            reminderActionPicker = [[UIPickerView alloc] init];
            reminderActionPicker.delegate = self;
            reminderActionPicker.showsSelectionIndicator = YES;
        }
    }
    return self;
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"Add Reminder";
    
    // add a cancel button
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel 
                                                                                  target:self 
                                                                                  action:@selector(cancel:)];
    
    self.navigationItem.leftBarButtonItem = cancelButton;
    
    // add a save button
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave 
                                                                                target:self 
                                                                                action:@selector(saveReminder:)];
    
    self.navigationItem.rightBarButtonItem = saveButton;
}

#pragma mark - UI Response
- (void)cancel:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

- (void)saveReminder:(id)sender {
    [[Model sharedModel] scheduleContactFollowUpForContact:_contact
                                                    onDate:reminderDate
                                                  withBody:reminderBodyField.text
                                                 andAction:reminderActionField.text];

    // dismiss the add view
    [self dismissModalViewControllerAnimated:YES];
}

-(void)datePickerChanged {
    reminderDate = reminderDatePicker.date;
    
    // update the display
    reminderDateField.text = [NSString stringWithFormat:@"%@", [reminderDatePicker date]];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Both sections only have a single row, no need to determine section
    return 3;
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
                if (reminderBodyField == nil) {
                    reminderBodyField = [[UITextField alloc] initWithFrame:CGRectMake(kFieldTitleWidth,
                                                                                      2,
                                                                                      cell.contentView.frame.size.width - kFieldTitleWidth,
                                                                                      40)];
                    reminderBodyField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
                }
                
                cell.textLabel.text = @"Body";
                cell.accessoryView = reminderBodyField;
                
            } else if (indexPath.row == 1) {
                if (reminderDateField == nil) {
                    reminderDateField = [[UITextField alloc] initWithFrame:CGRectMake(kFieldTitleWidth,
                                                                                      2,
                                                                                      cell.contentView.frame.size.width - kFieldTitleWidth,
                                                                                      40)];
                    reminderDateField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
                    reminderDateField.inputView = reminderDatePicker;
                }
                
                cell.textLabel.text = @"Date";
                cell.accessoryView = reminderDateField;
                
            } else if (indexPath.row == 2) {
                if (reminderActionField == nil) {
                    reminderActionField = [[UITextField alloc] initWithFrame:CGRectMake(kFieldTitleWidth,
                                                                                        2,
                                                                                        cell.contentView.frame.size.width - kFieldTitleWidth,
                                                                                        40)];
                    reminderActionField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
                    reminderActionField.inputView = reminderActionPicker;
                }
                
                cell.textLabel.text = @"Action";
                cell.accessoryView = reminderActionField;
            }
            
            break;
            
        default:
            break;
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

#pragma mark - UIPickerViewDelegate

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
	return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return 2;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    return 300.0;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
    switch (row) {
        case 0:
            reminderActionField.text = @"Call";
            break;
        
        case 1:
            reminderActionField.text = @"Email";
            break;
            
        default:
            break;
    }

}

- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    switch (row) {
        case 0:
            return @"Call";
            break;
            
        case 1:
            return @"Email";
            break;
            
        default:
            break;
    }
    return @"";
}

@end
