//
//  CustomServerController.m
//  Kontrol
//
//  Created by Kevin Vinck on 5/17/11.
//  Copyright 2011 None. All rights reserved.
//

#import "CustomServerController.h"


@implementation CustomServerController

@synthesize delegate;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                            target:self 
                                                                                            action:@selector(buttonPressed:)] autorelease];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if (textField.tag == 0) {
        serverIP = [NSString stringWithFormat:@"%@%@",textField.text,string];
        NSLog(@"serverIP: %@",serverIP);
    } else if (textField.tag == 1) {
        serverPort = [NSString stringWithFormat:@"%@%@",textField.text,string];
        NSLog(@"serverport: %@",serverPort);
    }
    
    
    [serverIP retain];
    [serverPort retain];
    
    return YES;
}

-(void) buttonPressed:(id) sender {
    NSMutableArray *values;
    
    if (serverIP == nil) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Missing server IP." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    if (serverPort == nil) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Missing server port, setting to default (8800)." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        serverPort = @"8800";
    }
    
    values = [[NSMutableArray alloc] initWithObjects:serverIP,serverPort, nil];
    
    NSLog(@"serverIP: %@",serverIP);
    NSLog(@"serverport: %@",serverPort);
    [delegate doneButtonPressed:values];
    
    [values release];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField.tag == 0) {
        NSLog(@"Pressed next");
        [[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]].accessoryView becomeFirstResponder]; 
    }
    else if (textField.tag == 1) {
        [self buttonPressed:textField];
    }
    return YES;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *title = @"Server Details";
    return title;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *kCellIdentifier = @"Cell";
    
    
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault 
                                       reuseIdentifier:kCellIdentifier] autorelease];
        cell.accessoryType = UITableViewCellAccessoryNone;
        
        if ([indexPath section] == 0) {
            UITextField *playerTextField = [[UITextField alloc] initWithFrame:CGRectMake(110, 10, 185, 30)];
            playerTextField.adjustsFontSizeToFitWidth = YES;
            playerTextField.textColor = [UIColor blackColor];
            if ([indexPath row] == 0) {
                playerTextField.placeholder = @"127.0.0.1";
                playerTextField.tag = 0;
                playerTextField.keyboardType = UIKeyboardTypeDecimalPad;
                playerTextField.returnKeyType = UIReturnKeyNext;
                [playerTextField becomeFirstResponder];
            }
            else {
                playerTextField.placeholder = @"8080";
                playerTextField.tag = 1;
                playerTextField.keyboardType = UIKeyboardTypeNumberPad;
                playerTextField.returnKeyType = UIReturnKeyDone;
            }       
            playerTextField.backgroundColor = [UIColor whiteColor];
            playerTextField.autocorrectionType = UITextAutocorrectionTypeNo; // no auto correction support
            playerTextField.autocapitalizationType = UITextAutocapitalizationTypeNone; // no auto capitalization support
            playerTextField.textAlignment = UITextAlignmentLeft;
            playerTextField.delegate = self;
            
            playerTextField.clearButtonMode = UITextFieldViewModeNever; // no clear 'x' button to the right
            [playerTextField setEnabled: YES];
            playerTextField.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
            
            cell.accessoryView = playerTextField;
            
            [playerTextField release];
        }
    }
    if ([indexPath section] == 0) { // Email & Password Section
        if ([indexPath row] == 0) { // Email
            cell.textLabel.text = @"Server IP";
        }
        else {
            cell.textLabel.text = @"Server Port";
        }
    }
    else { // Login button section
        cell.textLabel.text = @"Log in";
    }
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
}

@end
