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

#import "InfoViewController.h"

@implementation InfoViewController

#pragma mark -
#pragma mark Lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
	UITapGestureRecognizer *singleTap = 
	[[UITapGestureRecognizer alloc]
	 initWithTarget:self action:@selector(openLink:)];	
	[singleTap setNumberOfTapsRequired:1]; 
	singleTap.cancelsTouchesInView = NO;
	[linkLabel addGestureRecognizer:singleTap];
	
	if([MFMailComposeViewController canSendMail]) {
		sendFeedbackButton.enabled = YES;
	}
	else {
		sendFeedbackButton.enabled = NO;
	}

}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:YES];
	[self.navigationController setNavigationBarHidden:NO animated:YES];
	versionLabel.text = [NSString stringWithFormat:@"Version %@", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]];
}

#pragma mark -
#pragma mark IBActions
- (IBAction)done:(id)sender {
	[self dismissModalViewControllerAnimated:YES];
}

- (IBAction)sendFeedback:(id)sender {
	MFMailComposeViewController *controller = [[MFMailComposeViewController alloc] init];
	controller.mailComposeDelegate = self;
	[controller setSubject:@"Briathrachan Feedback"];
	[controller setToRecipients:[NSArray arrayWithObject:@"iphonesoftware@tobias-bayer.de"]];
	[self presentModalViewController:controller animated:YES];
}

- (void)openLink:(id)sender {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.smo.uhi.ac.uk/gaidhlig/faclair/bb"]];
}

#pragma mark -
#pragma mark MFMailComposeViewControllerDelegate
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
	[self becomeFirstResponder];
	[self dismissModalViewControllerAnimated:YES];
}

@end
