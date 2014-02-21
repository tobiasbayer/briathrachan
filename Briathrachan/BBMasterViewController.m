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
#import "BBDetailViewController.h"
#import "BBWordEntry.h"
#import "BBParser.h"

@interface BBMasterViewController ()

@property (nonatomic, strong) NSArray *index;
@property (nonatomic, strong) NSDictionary *entries;
@property (nonatomic, strong) NSMutableArray *tempEntries;

@property (nonatomic, assign) BOOL isSearching;

@end

@implementation BBMasterViewController

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self buildIndex];
    [self parse];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        
    }
}

#pragma mark - File parsing
- (void)parse {
	@autoreleasepool {
		NSLog(@"Parsing...");
		
		BBParser *parser = [[BBParser alloc] init];
		_entries = [parser parse:[[NSBundle mainBundle] pathForResource:@"dictionary" ofType:@"txt"]];
		
		[self buildIndex];
        
		[self.tableView reloadData];
		
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
		//return [copyEntries count];
        return 1;
	}
	else {
		NSString *key = [_index objectAtIndex:section];
		return [[_entries objectForKey:key] count];
	}
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
	
	BBWordEntry *entry = nil;
	if(_isSearching) {
		//entry = [copyEntries objectAtIndex:indexPath.row];
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

- (NSArray *)_isSearching:(UITableView *)tableView {
	if(_isSearching)
		return nil;
	
	return _index;
}

@end
