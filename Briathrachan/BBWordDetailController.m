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

#import "BBWordDetailController.h"

@interface BBWordDetailController ()

@property (nonatomic, weak) IBOutlet UILabel *wordHeaderLabel;
@property (nonatomic, weak) IBOutlet UILabel *wordTranslationLabel;

@end

@implementation BBWordDetailController

- (void)viewWillAppear
{
    [self configureView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = NO;
    self.navigationItem.title = nil;
    
    UIButton *infoButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
    [infoButton addTarget:self action:@selector(showInfo:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:infoButton];

    [self configureView];
}

- (void)configureView
{
    if (_word) {
        _wordHeaderLabel.text = _word.original;
        _wordTranslationLabel.text = _word.translation;
    }
}

- (void)showInfo:(id)sender
{
    [self performSegueWithIdentifier:@"showInfo" sender:sender];
}

@end
