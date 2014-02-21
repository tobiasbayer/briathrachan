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

#import "BBParser.h"
#import "WordEntry.h"

@implementation BBParser

- (NSString *)searchableString:(NSString *)string {
	NSString *result = [string stringByReplacingOccurrencesOfString:@"ò" withString:@"o"];
	result = [result stringByReplacingOccurrencesOfString:@"ó" withString:@"o"];
	result = [result stringByReplacingOccurrencesOfString:@"ì" withString:@"i"];
	result = [result stringByReplacingOccurrencesOfString:@"í" withString:@"i"];
	result = [result stringByReplacingOccurrencesOfString:@"á" withString:@"a"];
	result = [result stringByReplacingOccurrencesOfString:@"à" withString:@"a"];
	result = [result stringByReplacingOccurrencesOfString:@"é" withString:@"e"];
	result = [result stringByReplacingOccurrencesOfString:@"è" withString:@"e"];
	result = [result stringByReplacingOccurrencesOfString:@"ù" withString:@"u"];
	result = [result stringByReplacingOccurrencesOfString:@"ú" withString:@"u"];
	
	result = [result stringByReplacingOccurrencesOfString:@"Ò" withString:@"O"];
	result = [result stringByReplacingOccurrencesOfString:@"ó" withString:@"O"];
	result = [result stringByReplacingOccurrencesOfString:@"Ì" withString:@"I"];
	result = [result stringByReplacingOccurrencesOfString:@"Í" withString:@"I"];
	result = [result stringByReplacingOccurrencesOfString:@"À" withString:@"A"];
	result = [result stringByReplacingOccurrencesOfString:@"Á" withString:@"A"];
	result = [result stringByReplacingOccurrencesOfString:@"È" withString:@"E"];
	result = [result stringByReplacingOccurrencesOfString:@"É" withString:@"E"];
	result = [result stringByReplacingOccurrencesOfString:@"Ù" withString:@"U"];
	result = [result stringByReplacingOccurrencesOfString:@"Ú" withString:@"U"];
	
	return result;
}

- (NSDictionary *)parse:(NSString *)filename {
	NSString *filecontent = [NSString stringWithContentsOfFile:filename encoding:NSUTF8StringEncoding error:nil];
	NSLog(@"File length: %d", [filecontent length]);
	NSArray *lines = [filecontent componentsSeparatedByString:@"\n"];
	NSLog(@"Number of lines: %d", [lines count]);
	
	NSMutableDictionary *entryDict = [[NSMutableDictionary alloc] init];
		
	for(NSString *line in lines) {
		int originalStart = [line rangeOfString:@"["].location;
		int originalEnd = [line rangeOfString:@"]"].location;
		if(originalStart != NSNotFound) {
			NSString *original = [line substringWithRange:NSMakeRange(originalStart + 1, originalEnd - originalStart - 1)];
			int translationStart = originalEnd + 2;
			int translationEnd = [line length];
			NSString *translation = [line substringWithRange:NSMakeRange(translationStart, translationEnd - translationStart)];
			
			//TODO convert to string without accents
			NSString *key = [[[self searchableString:original] substringToIndex:1] uppercaseString];
			NSMutableArray *entryList = [entryDict objectForKey:key];
			if(entryList == nil) {
				entryList = [[NSMutableArray alloc] init];
				[entryDict setObject:entryList forKey:key];
			}
			
			WordEntry *entry = [[WordEntry alloc] init];
			entry.original = original;
			entry.translation = translation;
			entry.originalForSearch = [self searchableString:original];
			[entryList addObject:entry];
		}    
	}
	
	return entryDict;
}

@end
