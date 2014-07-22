//
//  ContactsTableViewController.m
//  RelationshipManager
//
//  Created by Nathan Jones on 4/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ContactsTableViewController.h"
#import "AddContactTableViewController.h"
#import "ContactDetailTableViewController.h"

#import "Model.h"
#import "Contact.h"

@interface ContactsTableViewController() {
@private
    NSArray *contacts;
}

- (void)addContact:(id)sender;

@end

@implementation ContactsTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        contacts = [[NSArray alloc] init];
    }
    return self;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = @"Contacts";
    contacts = [[Model sharedModel] contacts];
    
    // create our Add Contact button
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd 
                                                                               target:self 
                                                                               action:@selector(addContact:)];
    self.navigationItem.rightBarButtonItem = addButton;
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // refresh our data source and reload the table
    contacts = [[Model sharedModel] contacts];
    [self.tableView reloadData];
}

#pragma mark - UI Response
- (void)addContact:(id)sender {
    AddContactTableViewController *addVC = [[AddContactTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:addVC];
    [self presentModalViewController:nc animated:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [contacts count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    Contact *contact = [contacts objectAtIndex:indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@, %@", contact.lastName, contact.firstName];
    cell.detailTextLabel.text = contact.emailAddress;
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

    return cell;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    Contact *contact = [contacts objectAtIndex:indexPath.row];
    ContactDetailTableViewController *detailVC = [[ContactDetailTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
    detailVC.contact = contact;
    
    [self.navigationController pushViewController:detailVC animated:YES];
}

@end
