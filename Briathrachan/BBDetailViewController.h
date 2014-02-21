//
//  TBDetailViewController.h
//  Briathrachan
//
//  Created by Tobias Bayer on 20.02.14.
//  Copyright (c) 2014 Tobias Bayer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BBDetailViewController : UIViewController

@property (strong, nonatomic) id detailItem;

@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@end
