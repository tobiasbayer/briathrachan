/*
 Copyright 2014 Tobias Bayer
 
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

#import <MessageUI/MFMailComposeViewController.h>
#import "BBInfoViewController.h"

@interface BBInfoViewController () <MFMailComposeViewControllerDelegate>

@end

@implementation BBInfoViewController

- (IBAction)openLink:(id)sender
{
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.smo.uhi.ac.uk/gaidhlig/faclair/bb"]];
}

- (IBAction)dismissInfo:(id)sender
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)sendFeedback:(id)sender
{
    MFMailComposeViewController *controller = [[MFMailComposeViewController alloc] init];
	controller.mailComposeDelegate = self;
	[controller setSubject:@"Briathrachan Feedback"];
	[controller setToRecipients:[NSArray arrayWithObject:@"iphonesoftware@tobias-bayer.de"]];
	[self presentViewController:controller animated:YES completion:nil];
}

#pragma mark - MFMailComposeViewControllerDelegate
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
	[self becomeFirstResponder];
	[self dismissViewControllerAnimated:YES completion:nil];
}

@end
