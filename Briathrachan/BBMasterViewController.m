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

#import "BBMasterViewController.h"
#import "BBWordDetailController.h"
#import "BBWordEntry.h"
#import "BBParser.h"

@interface BBMasterViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>

@property (nonatomic, strong) NSArray *index;
@property (nonatomic, strong) NSDictionary *entries;
@property (nonatomic, strong) NSMutableArray *tempEntries;
@property (nonatomic, strong) NSArray *copiedEntries;

@property (nonatomic, assign) BOOL maySelectRow;
@property (nonatomic, assign) BOOL isSearching;

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet UISearchBar *searchBar;

@end

@implementation BBMasterViewController

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
     _tableView.contentInset = UIEdgeInsetsMake(88, 0, 0, 0);
    [self buildIndex];
    [self parse];
}

- (void)viewDidAppear:(BOOL)animated {
    self.navigationController.navigationBarHidden = YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [_tableView indexPathForSelectedRow];
        BBWordEntry *word = nil;
        
        if(_isSearching) {
            word = [_copiedEntries objectAtIndex:indexPath.row];
        }
        else {
            NSString *indexString = [_index objectAtIndex:indexPath.section];
            NSArray *entryArray = [_entries objectForKey:indexString];
            word = [entryArray objectAtIndex:indexPath.row];
        }
        
        ((BBWordDetailController *)segue.destinationViewController).word = word;
    }
}

#pragma mark - File parsing
- (void)parse {
	@autoreleasepool {
        //TODO remove logs
		NSLog(@"Parsing...");
		
		BBParser *parser = [[BBParser alloc] init];
		_entries = [parser parse:[[NSBundle mainBundle] pathForResource:@"dictionary" ofType:@"txt"]];
		
		[self buildIndex];
        
		[_tableView reloadData];
		
		//[_spinner stopAnimating];
		//_tabBar.selectedItem = [_tabBar.items objectAtIndex:0];
		//_tabBar.userInteractionEnabled = YES;
		
		_tempEntries = [[NSMutableArray alloc] init];
		
		for(NSArray *array in [_entries allValues]) {
			[_tempEntries addObjectsFromArray:array];
		}
		
		NSLog(@"Finished parsing.");
        
	}
}

- (void)buildIndex {
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
	
	_index = [[NSArray alloc] initWithArray:tempArray];
}


#pragma mark - Table View
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	if(_isSearching) {
		return 1;
	}
    return [_index count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if(_isSearching) {
		return nil;
	}
	return [_index objectAtIndex:section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if(_isSearching) {
		return [_copiedEntries count];
	}
	else {
		NSString *key = [_index objectAtIndex:section];
		return [[_entries objectForKey:key] count];
	}
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:@"Cell"];
	
	BBWordEntry *entry = nil;
	if(_isSearching) {
		entry = [_copiedEntries objectAtIndex:indexPath.row];
	}
	else {
		NSString *key = [_index objectAtIndex:indexPath.section];
		entry = [[_entries objectForKey:key] objectAtIndex:indexPath.row];
	}
	
	cell.textLabel.text = entry.original;
	cell.detailTextLabel.text = entry.translation;
    
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	
    return cell;
}

#pragma mark - Searching

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
	NSString *searchText = _searchBar.text;
	
	NSPredicate *predicate;
	
	if(_searchBar.selectedScopeButtonIndex == 0) {
		predicate = [NSPredicate predicateWithFormat:@"originalForSearch BEGINSWITH[cd] %@ OR original BEGINSWITH[cd] %@", searchText, searchText];
	}
	else {
		predicate = [NSPredicate predicateWithFormat:@"translation MATCHES %@", [NSString stringWithFormat:@"(^|.* )%@.*", searchText]];
	}
    
	_copiedEntries = [_tempEntries filteredArrayUsingPredicate:predicate];
}

- (void)doneSearching {
	_searchBar.text = @"";
	[_searchBar resignFirstResponder];
	
	_maySelectRow = YES;
	_isSearching = NO;
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

#pragma mark - Search Bar

- (void)searchBarTextDidBeginEditing:(UISearchBar *)theSearchBar {
	_isSearching = YES;
	_maySelectRow = NO;
	self.tableView.scrollEnabled = NO;
	
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                              initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                              target:self action:@selector(doneSearching)];
	[self searchBar:theSearchBar textDidChange:theSearchBar.text];
}

- (void)searchBar:(UISearchBar *)theSearchBar textDidChange:(NSString *)searchText {
	if([searchText length] > 0) {
		_isSearching = YES;
		_maySelectRow = YES;
		self.tableView.scrollEnabled = YES;
		[self searchTableView];
	}
	else {
		_isSearching = NO;
		_maySelectRow = NO;
		self.tableView.scrollEnabled = NO;
	}
	
	[self.tableView reloadData];
}

- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope {
	[self searchTableView];
	[_tableView reloadData];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
	[self doneSearching];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)theSearchBar {
	[self searchTableView];
}

@end
