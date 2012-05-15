/*
 Copyright 2010 Tobias Bayer
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

#import "RootViewController.h"
#import "WordEntry.h"
#import "BBParser.h"
#import "DetailViewController.h"
#import "InfoViewController.h"

@implementation RootViewController

@synthesize entries;
@synthesize tableView;
@synthesize index;

#pragma mark -
#pragma mark View lifecycle

- (void)buildIndex {
	//TODO build dynamically
	NSMutableArray *tempArray = [[NSMutableArray alloc] init];
	[tempArray addObject:@"A"];
	[tempArray addObject:@"B"];
	[tempArray addObject:@"C"];
	[tempArray addObject:@"D"];
	[tempArray addObject:@"E"];
	[tempArray addObject:@"F"];
	[tempArray addObject:@"G"];
	[tempArray addObject:@"H"];
	[tempArray addObject:@"I"];
	[tempArray addObject:@"L"];
	[tempArray addObject:@"M"];
	[tempArray addObject:@"N"];
	[tempArray addObject:@"O"];
	[tempArray addObject:@"P"];
	[tempArray addObject:@"R"];
	[tempArray addObject:@"S"];
	[tempArray addObject:@"T"];
	[tempArray addObject:@"U"];
	
	index = [[NSArray alloc] initWithArray:tempArray];
}

- (void)parse {
	@autoreleasepool {
		NSLog(@"Parsing...");
		
		BBParser *parser = [[BBParser alloc] init];
		entries = [parser parse:[[NSBundle mainBundle] pathForResource:@"bb-codes" ofType:@"txt"]];
		
		[self buildIndex];
			
		[self.tableView reloadData];
		
		[spinner stopAnimating];
		tabBar.selectedItem = [tabBar.items objectAtIndex:0];
		tabBar.userInteractionEnabled = YES;
		
		tempEntries = [[NSMutableArray alloc] init];
		
		for(NSArray *array in [entries allValues]) {
			[tempEntries addObjectsFromArray:array];
		}
		
		NSLog(@"Finished parsing.");
	
	}
}

- (void)viewDidLoad {
	[super viewDidLoad];
	[spinner startAnimating];
	
	[NSThread detachNewThreadSelector:@selector(parse) toTarget:self withObject:nil]; 

	isSearching = NO;
	maySelectRow = YES;
			
	self.navigationController.navigationBarHidden = YES;
	
	self.navigationItem.title = @"Back";
	
    [[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardWillShow:)
												 name:UIKeyboardWillShowNotification
											   object:nil];
	
    [[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardWillHide:)
												 name:UIKeyboardWillHideNotification
											   object:nil];
}

- (void)keyboardWillShow:(NSNotification *)notification {
    CGRect keyboardBounds;
    [[notification.userInfo valueForKey:UIKeyboardFrameBeginUserInfoKey] getValue:&keyboardBounds];
	
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    CGRect frame = self.tableView.frame;
	
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:0.3f];
	
    if (orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown) {
        frame.size.height -= keyboardBounds.size.height;
    }
    else {
        frame.size.height -= keyboardBounds.size.width;
	}

    self.tableView.frame = frame;
	
    [UIView commitAnimations];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    CGRect keyboardBounds;
    [[notification.userInfo valueForKey:UIKeyboardFrameBeginUserInfoKey] getValue: &keyboardBounds];
	
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    CGRect frame = self.tableView.frame;
	
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:0.3f];
	
    if (orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown) {
        frame.size.height += keyboardBounds.size.height;
    }
    else {
        frame.size.height += keyboardBounds.size.width;
	}
    
    self.tableView.frame = frame;
	
    [UIView commitAnimations];
}




- (IBAction)info:(id)sender {
	InfoViewController *infoViewController = [[InfoViewController alloc] initWithNibName:@"InfoViewController" bundle:nil];
	[self presentModalViewController:infoViewController animated:YES];
}

- (NSRange)searchInTranslation:(NSString *)translation searchFor:(NSString *)searchText {
	NSRange range = NSMakeRange(NSNotFound, 0);
	NSArray *words = [translation componentsSeparatedByString:@" "];
	for(NSString *string in words) {
		range = [string rangeOfString:searchText options:NSCaseInsensitiveSearch];
		if(range.location == 0) {
			break;
		}
	}
	
	return range;
}

- (void)searchTableView {
	NSString *searchText = searchBar.text;
	
	NSPredicate *predicate;
	
	if(searchBar.selectedScopeButtonIndex == 0) {
		predicate = [NSPredicate predicateWithFormat:@"originalForSearch BEGINSWITH[cd] %@ OR original BEGINSWITH[cd] %@", searchText, searchText];
	}
	else {
		predicate = [NSPredicate predicateWithFormat:@"translation MATCHES %@", [NSString stringWithFormat:@"(^|.* )%@.*", searchText]];
	}

	copyEntries = [tempEntries filteredArrayUsingPredicate:predicate];
}

- (void)doneSearching {
	searchBar.text = @"";
	[searchBar resignFirstResponder];
	
	maySelectRow = YES;
	isSearching = NO;
	self.navigationItem.rightBarButtonItem = nil;
	self.tableView.scrollEnabled = YES;
	
	[self.tableView reloadData];
}

- (void)scrollToTop:(id)sender {
	int reloadToRow = 0; 
	
	NSUInteger indexArr[] = {0,reloadToRow}; 
	
	if([self.tableView numberOfRowsInSection:0] > 0) {
		[self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathWithIndexes:indexArr length:2] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
	}
}



- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[self.navigationController setNavigationBarHidden:YES animated:YES];
}
 

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	for(UIGestureRecognizer *recognizer in self.navigationController.navigationBar.gestureRecognizers) {
		recognizer.enabled = YES;
	}
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	if(isSearching) {
		return 1;
	}
    return [index count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if(isSearching) {
		return nil;
	}
	return [index objectAtIndex:section]; 
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if(isSearching) {
		return [copyEntries count];
	}
	else {
		NSString *key = [index objectAtIndex:section];
		return [[entries objectForKey:key] count];
	}
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
	
	WordEntry *entry = nil;
	if(isSearching) {
		entry = [copyEntries objectAtIndex:indexPath.row];
	}
	else {
		NSString *key = [index objectAtIndex:indexPath.section];
		entry = [[entries objectForKey:key] objectAtIndex:indexPath.row];
	}
	
	
	cell.textLabel.text = entry.original;
	cell.detailTextLabel.text = entry.translation;
    
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	
    return cell;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {	
	if(isSearching)
		return nil;
	
	return index;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
	
	DetailViewController *detailViewController = [[DetailViewController alloc] initWithNibName:@"DetailViewController" bundle:nil];
	WordEntry *entry = nil;
	
	if(isSearching) {
		entry = [copyEntries objectAtIndex:indexPath.row];
	}
	else {
		NSString *indexString = [index objectAtIndex:indexPath.section];
		NSArray *entryArray = [entries objectForKey:indexString];
		entry = [entryArray objectAtIndex:indexPath.row];
	}
	
	detailViewController.entry = entry;
	
	[self.navigationController pushViewController:detailViewController animated:YES];
	
	for(UIGestureRecognizer *recognizer in self.navigationController.navigationBar.gestureRecognizers) {
		recognizer.enabled = NO;
	}
}

- (NSIndexPath *)tableView :(UITableView *)theTableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if(maySelectRow) {
		return indexPath;
	}
	else {
		return nil;
	}
}

#pragma mark -
#pragma mark UISearchBarDelegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)theSearchBar {

	isSearching = YES;
	maySelectRow = NO;
	self.tableView.scrollEnabled = NO;
	
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
											   initWithBarButtonSystemItem:UIBarButtonSystemItemDone
											   target:self action:@selector(doneSearching:)];
	[self searchBar:theSearchBar textDidChange:theSearchBar.text];	
}

- (void)searchBar:(UISearchBar *)theSearchBar textDidChange:(NSString *)searchText {
	if([searchText length] > 0) {
		isSearching = YES;
		maySelectRow = YES;
		self.tableView.scrollEnabled = YES;
		[self searchTableView];
	}
	else {
		isSearching = NO;
		maySelectRow = NO;
		self.tableView.scrollEnabled = NO;
	}
	
	[self.tableView reloadData];
}

- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope {
	[self searchTableView];
	[self.tableView reloadData];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
	[self doneSearching];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)theSearchBar {
	[self searchTableView];
}

@end

