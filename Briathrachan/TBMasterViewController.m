//
//  TBMasterViewController.m
//  Briathrachan
//
//  Created by Tobias Bayer on 20.02.14.
//  Copyright (c) 2014 Tobias Bayer. All rights reserved.
//

#import "TBMasterViewController.h"
#import "TBDetailViewController.h"
#import "WordEntry.h"
#import "BBParser.h"

@interface TBMasterViewController ()

@property (nonatomic, strong) NSArray *index;
@property (nonatomic, assign) BOOL isSearching;
@property (nonatomic, strong) NSDictionary *entries;
@property (nonatomic, strong) NSMutableArray *tempEntries;

@end

@implementation TBMasterViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self buildIndex];
    [self parse];
}

- (void)parse {
	@autoreleasepool {
		NSLog(@"Parsing...");
		
		BBParser *parser = [[BBParser alloc] init];
		_entries = [parser parse:[[NSBundle mainBundle] pathForResource:@"bb-codes" ofType:@"txt"]];
		
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
	
	WordEntry *entry = nil;
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


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        
    }
}

@end
