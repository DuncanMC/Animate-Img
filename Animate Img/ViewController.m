//
//  ViewController.m
//  testing
//
//  Created by Duncan Champney on 1/8/14.
//  Copyright (c) 2014 WareTo. All rights reserved.
//

#import "ViewController.h"


//Constants used to find the images that are animated.
#define first_index 1
#define last_index 5
#define image_count (last_index - first_index +1)
#define imageNameFormat @"The Chin %d"
#define  delay_fudge 0.912557

@implementation ViewController


//-----------------------------------------------------------------------------------------------------------

- (void) animateImagesInLoop;
{
  frameIndex = 0;
  animateButton.enabled = NO;
  
  animationStartTimeInterval = [NSDate timeIntervalSinceReferenceDate];
  [self animateImagesWithDuration: duration
                          reverse: reverseAnimation
                        crossfade: crossfade
              withCompletionBlock:
   ^{
     repeatCount--;
     if (repeatCount >= 0)
       [self animateImagesInLoop];
     else
     {
       NSTimeInterval elapsedTime = [NSDate timeIntervalSinceReferenceDate] - animationStartTimeInterval;
       NSLog(@"Animation took %.2f seconds. crossfade = %d", elapsedTime, crossfade);
       
       if (!reverseAnimation)
         //If we are not reversing the animation, pause before resetting everything back
         //to the starting state.
         dispatch_after(dispatch_time(DISPATCH_TIME_NOW,
                                      1.0 *  delay_fudge * NSEC_PER_SEC),
                        dispatch_get_main_queue(),
                        ^{
                          
                          imageView1.alpha = 1.0;
                          imageView2.alpha = 1.0;
                          imageView1.image = images[0];
                          imageView2.image = images[1];
                          animateButton.enabled = YES;
                        }
                        );
       
       else
         animateButton.enabled = YES;
     }
   }];
}

//-----------------------------------------------------------------------------------------------------------
/*
 This method does frame-based animation of an array of images.
 It uses 2 image views, stacked on top of each other. At the beginning of the animation the top view contains
 the first frame. 
 
 The second image view contains the next frame. The first animation step is to fade the top image view, 
 revealing the second image frame underneath.
 
 In the second animation step, this method installs the 3rd animation frame in the (currently invisible)
 top image view, then fades that iamge view back to fully opaque.
 
 The animation code installs the next frame's image in the currently invisible image view, then either
 fades or reveals the top image view.
 
 if doCrossfade == NO, the same logic is executed, but the alpha changes are not animated.
 */

- (void) animateImagesWithDuration: (CGFloat) totalDuration
                           reverse: (BOOL) reverse
                         crossfade: (BOOL) doCrossfade
               withCompletionBlock: (void (^)(void)) completionBlock;
{
  
  NSUInteger frameCount = images.count-1;
  
  //If we're supposed to reverse, double the frame count
  //(minus 1 since we don't repeat the last frame
  if (reverse)
    frameCount += images.count-1;
  
  CGFloat frameDuration;
  
  frameDuration = duration/frameCount;
  
  
  UIImageView *imageViewArray[] = {imageView1, imageView2};
  
  if (frameIndex == 0)
  {
    //Start with both image views visible
    imageView1.alpha = 1.0;
    imageView2.alpha = 1.0;
  }
  
  
  //Install the current image in the currently visible image view.
  NSUInteger imageIndex = frameIndex;
  NSUInteger nextImageIndex = imageIndex + 1;
  
  //If we are reverseing, calculate image indexes that go backwards to the first one
  if (reverse && frameIndex >= images.count-1)
  {
    imageIndex = (images.count-1)*2 - frameIndex;
    nextImageIndex = imageIndex - 1;
  }
  
  //The image that's visible for the current frame.
  int currentImageViewindex = frameIndex %2;
  
  //install the next image frame in the "other" imageView.
  int newImageViewIndex = (frameIndex+1) %2;
  
  imageViewArray[currentImageViewindex].image = images[imageIndex];
  
  //Get the next image ready in the other image view.
  imageViewArray[newImageViewIndex].image = images[nextImageIndex];
  frameIndex++;
  
  if (doCrossfade)
  {
    [UIView animateWithDuration: frameDuration
                          delay: 0
                        options: UIViewAnimationOptionCurveLinear
                     animations:
                       ^{
                         //On even cycles, fade imageView1 to reveal imageView2
                         //On odd cycles, set imageView1's alpha to 1, since imageView1 contains the new image
                         imageView1.alpha = currentImageViewindex;
                       }
                     completion: (void (^)(BOOL finished))
                       ^{
                         //When the current animation step completes, trigger the method again.
                         if (frameIndex < frameCount)
                         {
                           [self animateImagesWithDuration: totalDuration
                                                   reverse: reverse
                                                 crossfade: doCrossfade
                                       withCompletionBlock: completionBlock];
                         }
                         else
                           if (completionBlock)
                             completionBlock();
                       }
     ];
  }
  else
  {
    //We're not supposed to crossfade, so just set the alpha and queue up the next step after a delay.
    CGFloat delay;
    
    //Wait to execute the first alpha change. (frameIndex will be 1 because we already incremented it above
    if (frameIndex == 1)
      delay = frameDuration;
    else delay = 0;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW,
                                 delay * delay_fudge * NSEC_PER_SEC),
                   dispatch_get_main_queue(),
                   ^{
                     imageView1.alpha = currentImageViewindex;
                     if (frameIndex < frameCount)
                     {
                       dispatch_after(dispatch_time(DISPATCH_TIME_NOW,
                                                    frameDuration *  delay_fudge * NSEC_PER_SEC),
                                      dispatch_get_main_queue(),
                                      ^{
                                        [self animateImagesWithDuration: totalDuration
                                                                reverse: reverse
                                                              crossfade: doCrossfade
                                                    withCompletionBlock: completionBlock];
                                      });
                     }
                     else
                     {
                       if (completionBlock)
                         completionBlock();
                     }
                   });
  }
}

//-----------------------------------------------------------------------------------------------------------

- (void) logImagesWithMessage: (NSString * ) message;
{
  NSUInteger i1Index = [images indexOfObjectIdenticalTo: imageView1.image];
  if (message.length)
    NSLog(@"%@", message);
  if (i1Index == NSNotFound)
    NSLog(@"imageView1 does not contain an image");
  else
    NSLog(@"imageView1 contains image %lu", (unsigned long)i1Index);
  
  NSUInteger i2Index = [images indexOfObjectIdenticalTo: imageView2.image];
  if (i2Index == NSNotFound)
    NSLog(@"imageView2 does not contain an image");
  else
    NSLog(@"imageView2 contains image %lu", (unsigned long)i2Index);
  
}
//-----------------------------------------------------------------------------------------------------------

- (void)viewWillAppear:(BOOL)animated
{
  durationField.text = [NSString stringWithFormat: @"%.2f", duration];
  crossfadeSwitch.on = crossfade;
  reverseAnimationSwitch.on = reverseAnimation;
}

//-----------------------------------------------------------------------------------------------------------

- (void)viewDidLoad
{
  
  crossfade = YES;
  reverseAnimation = YES;
  duration = 2;
  NSString *imageName;
  
  [super viewDidLoad];
  //-------------
  images = [NSMutableArray arrayWithCapacity: image_count];
  for (int index = 0; index < image_count; index++)
  {
    imageName = [NSString stringWithFormat: imageNameFormat, index+1];
    images[index] = [UIImage imageNamed: imageName];
  }
  imageView1.opaque = NO;
  
  //Set up a notification handler to shift the content view up to make room for the keyboard if the current text field
  //Will be covered by the keyboard.
  
  showKeyboardNotificaiton = [[NSNotificationCenter defaultCenter] addObserverForName: UIKeyboardWillShowNotification
                              
                                                                               object: nil
                                                                                queue: nil
                                                                           usingBlock: ^(NSNotification *note)
                              {
                                CGRect keyboardFrame;
                                NSDictionary* userInfo = note.userInfo;
                                keyboardSlideDuration = [[userInfo objectForKey: UIKeyboardAnimationDurationUserInfoKey] floatValue];
                                //-----------
                                 keyboardAnimationCurve = [userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue]<<16;
                                //-----------
                                keyboardFrame = [[userInfo objectForKey: UIKeyboardFrameBeginUserInfoKey] CGRectValue];
                                
                                UIInterfaceOrientation theStatusBarOrientation = [[UIApplication sharedApplication] statusBarOrientation];
                                
                                CGFloat keyboardHeight;
                                if UIInterfaceOrientationIsLandscape(theStatusBarOrientation)
                                  keyboardHeight = keyboardFrame.size.width;
                                else
                                  keyboardHeight = keyboardFrame.size.height;
                                
                                CGRect fieldFrame = textFieldToEdit.bounds;
                                fieldFrame = [self.view convertRect: fieldFrame fromView: textFieldToEdit];
                                CGRect contentFrame = self.view.frame;
                                CGFloat fieldBottom = fieldFrame.origin.y + fieldFrame.size.height;
                                
                                keyboardShiftAmount= 0;
                                if (contentFrame.size.height - fieldBottom <keyboardHeight)
                                {
                                  keyboardShiftAmount = keyboardHeight - (contentFrame.size.height - fieldBottom)+5;
                                  containerTopConstraint.constant -= keyboardShiftAmount;
                                  containerBottomConstraint.constant += keyboardShiftAmount;
                                  
                                  [UIView animateWithDuration: keyboardSlideDuration
                                                        delay: 0
                                                      options: keyboardAnimationCurve
                                                   animations:^{
                                                     //                                                     [viewToShift setNeedsUpdateConstraints];
                                                     [containerView layoutIfNeeded];
                                                   }
                                   completion: nil
                                   ];
                                 }
                              }
                              ];

  //Set up another notification handler to move the content view back down as the keyboard is dismissed.
  hideKeyboardNotificaiton = [[NSNotificationCenter defaultCenter] addObserverForName: UIKeyboardWillHideNotification
                                                                               object: nil
                                                                                queue: nil
                                                                           usingBlock: ^(NSNotification *note)
                              {
                                if (keyboardShiftAmount != 0)
                                  [UIView animateWithDuration: keyboardSlideDuration
                                                        delay: 0
                                                      options: keyboardAnimationCurve
                                                   animations:
                                   ^{
                                     containerBottomConstraint.constant -= keyboardShiftAmount;
                                     containerTopConstraint.constant += keyboardShiftAmount;
                                     [self.view setNeedsUpdateConstraints];
                                     [containerView layoutIfNeeded];
                                   }
                                                   completion: nil
                                   ];
                              }
                              ];

}


//-----------------------------------------------------------------------------------------------------------
#pragma mark -	IBAction methods
//-----------------------------------------------------------------------------------------------------------

- (IBAction)animateImages:(id)sender
{
  repeatCount = 0;
  [self animateImagesInLoop];
  
}

//-----------------------------------------------------------------------------------------------------------

- (IBAction)handleCrossFadeSwitch:(UISwitch *)sender;
{
  crossfade = sender.isOn;
}

//-----------------------------------------------------------------------------------------------------------

- (IBAction)handleReverseSwitch:(UISwitch *)sender
{
  reverseAnimation = sender.isOn;

}

//-----------------------------------------------------------------------------------------------------------
- (UIBarPosition)positionForBar:(id <UIBarPositioning>)bar {
  return UIBarPositionTopAttached;
}

//-----------------------------------------------------------------------------------------------------------
#pragma mark -	UITextFieldDelegate methods
//-----------------------------------------------------------------------------------------------------------

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
  textFieldToEdit = textField;
  return YES;
}

//-----------------------------------------------------------------------------------------------------------

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
  [textField resignFirstResponder];
  return TRUE;
}

//-----------------------------------------------------------------------------------------------------------

- (void)textFieldDidEndEditing:(UITextField *)textField
{
  CGFloat newValue = textField.text.floatValue;
  if (textField == durationField)
  {
    if (newValue > 0)
      duration = newValue;
    
    durationField.text= [NSString stringWithFormat: @"%.2f", duration];
  }
}

@end
