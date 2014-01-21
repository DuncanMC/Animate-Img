//
//  ViewController.h
//  testing
//
//  Created by Duncan Champney on 1/8/14.
//  Copyright (c) 2014 WareTo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController
{
  __weak IBOutlet UIImageView *imageView1;
  __weak IBOutlet UIImageView *imageView2;
  __weak IBOutlet UIButton *animateButton;

  __weak IBOutlet UIView *containerView;
  __weak IBOutlet NSLayoutConstraint *containerTopConstraint;
  __weak IBOutlet NSLayoutConstraint *containerBottomConstraint;
  __weak IBOutlet UITextField *durationField;
  __weak IBOutlet UISwitch *crossfadeSwitch;
  __weak IBOutlet UISwitch *reverseAnimationSwitch;
  
  

  
  UITextField *textFieldToEdit;
  id showKeyboardNotificaiton;
  id hideKeyboardNotificaiton;
  CGFloat keyboardSlideDuration;
  CGFloat keyboardShiftAmount;
  CGFloat duration;
  
  NSTimeInterval animationStartTimeInterval;
  
  BOOL crossfade;
  BOOL reverseAnimation;
  
  NSMutableArray *images;
  int frameIndex;
  int repeatCount;
  
}
- (IBAction)animateImages:(id)sender;
- (IBAction)handleCrossFadeSwitch:(UISwitch *)sender;
- (IBAction)handleReverseSwitch:(UISwitch *)sender;

@end
