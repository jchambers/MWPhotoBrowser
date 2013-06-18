//
//  MWBasicActionButtonDelegate.m
//  MWPhotoBrowser
//
//  Created by Jon Chambers on 6/18/13.
//
//

#import "MWBasicActionButtonDelegate.h"

#import <MessageUI/MessageUI.h>

@interface MWBasicActionButtonDelegate()<UIActionSheetDelegate, MFMailComposeViewControllerDelegate>

@property UIActionSheet *actionSheet;
@property MWPhotoBrowser *photoBrowser;

@end

@implementation MWBasicActionButtonDelegate

- (id)initWithPhotoBrowser:(MWPhotoBrowser *)photoBrowser;
{
    self = [super init];
    
    if (self) {
        [self setPhotoBrowser:photoBrowser];
        [self setActionSheet:nil];
    }
    
    return self;
}

- (UIBarButtonItem *)actionButton
{
    return [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(actionButtonPressed:)];
}

- (void)actionButtonPressed:(id)sender {
    if (self.actionSheet) {
        // Dismiss
        [self.actionSheet dismissWithClickedButtonIndex:self.actionSheet.cancelButtonIndex animated:YES];
    } else {
        id <MWPhoto> photo = [self.photoBrowser.delegate photoBrowser:self.photoBrowser photoAtIndex:self.photoBrowser.currentPageIndex];
        if ([self.photoBrowser.delegate numberOfPhotosInPhotoBrowser:self.photoBrowser] > 0 && [photo underlyingImage]) {
            
            // Keep controls hidden
            [self.photoBrowser setControlsHidden:NO animated:YES permanent:YES];
            
            // Sheet
            if ([MFMailComposeViewController canSendMail]) {
                self.actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self
                                                       cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:nil
                                                       otherButtonTitles:NSLocalizedString(@"Save", nil), NSLocalizedString(@"Copy", nil), NSLocalizedString(@"Email", nil), nil];
            } else {
                self.actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self
                                                       cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:nil
                                                       otherButtonTitles:NSLocalizedString(@"Save", nil), NSLocalizedString(@"Copy", nil), nil];
            }
            self.actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                [self.actionSheet showFromBarButtonItem:sender animated:YES];
            } else {
                [self.actionSheet showInView:self.photoBrowser.view];
            }
            
        }
    }
}

#pragma mark - Action Sheet Delegate

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (actionSheet == self.actionSheet) {
        // Actions
        self.actionSheet = nil;
        
        if (buttonIndex != actionSheet.cancelButtonIndex) {
            if (buttonIndex == actionSheet.firstOtherButtonIndex) {
                [self savePhoto]; return;
            } else if (buttonIndex == actionSheet.firstOtherButtonIndex + 1) {
                [self copyPhoto]; return;
            } else if (buttonIndex == actionSheet.firstOtherButtonIndex + 2) {
                [self emailPhoto]; return;
            }
        }
    }
    
    // [self hideControlsAfterDelay]; // Continue as normal...
}

#pragma mark - Actions

- (void)savePhoto {
    id <MWPhoto> photo = [self.photoBrowser.delegate photoBrowser:self.photoBrowser photoAtIndex:self.photoBrowser.currentPageIndex];
    if ([photo underlyingImage]) {
        [self.photoBrowser showProgressHUDWithMessage:[NSString stringWithFormat:@"%@\u2026" , NSLocalizedString(@"Saving", @"Displayed with ellipsis as 'Saving...' when an item is in the process of being saved")]];
        [self performSelector:@selector(actuallySavePhoto:) withObject:photo afterDelay:0];
    }
}

- (void)actuallySavePhoto:(id<MWPhoto>)photo {
    if ([photo underlyingImage]) {
        UIImageWriteToSavedPhotosAlbum([photo underlyingImage], self,
                                       @selector(image:didFinishSavingWithError:contextInfo:), nil);
    }
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    [self.photoBrowser showProgressHUDCompleteMessage: error ? NSLocalizedString(@"Failed", @"Informing the user a process has failed") : NSLocalizedString(@"Saved", @"Informing the user an item has been saved")];
    [self.photoBrowser hideControlsAfterDelay]; // Continue as normal...
}

- (void)copyPhoto {
    id <MWPhoto> photo = [self.photoBrowser.delegate photoBrowser:self.photoBrowser photoAtIndex:self.photoBrowser.currentPageIndex];
    if ([photo underlyingImage]) {
        [self.photoBrowser showProgressHUDWithMessage:[NSString stringWithFormat:@"%@\u2026" , NSLocalizedString(@"Copying", @"Displayed with ellipsis as 'Copying...' when an item is in the process of being copied")]];
        [self performSelector:@selector(actuallyCopyPhoto:) withObject:photo afterDelay:0];
    }
}

- (void)actuallyCopyPhoto:(id<MWPhoto>)photo {
    if ([photo underlyingImage]) {
        [[UIPasteboard generalPasteboard] setData:UIImagePNGRepresentation([photo underlyingImage])
                                forPasteboardType:@"public.png"];
        [self.photoBrowser showProgressHUDCompleteMessage:NSLocalizedString(@"Copied", @"Informing the user an item has finished copying")];
        [self.photoBrowser hideControlsAfterDelay]; // Continue as normal...
    }
}

- (void)emailPhoto {
    id <MWPhoto> photo = [self.photoBrowser.delegate photoBrowser:self.photoBrowser photoAtIndex:self.photoBrowser.currentPageIndex];
    if ([photo underlyingImage]) {
        [self.photoBrowser showProgressHUDWithMessage:[NSString stringWithFormat:@"%@\u2026" , NSLocalizedString(@"Preparing", @"Displayed with ellipsis as 'Preparing...' when an item is in the process of being prepared")]];
        [self performSelector:@selector(actuallyEmailPhoto:) withObject:photo afterDelay:0];
    }
}

- (void)actuallyEmailPhoto:(id<MWPhoto>)photo {
    if ([photo underlyingImage]) {
        MFMailComposeViewController *emailer = [[MFMailComposeViewController alloc] init];
        emailer.mailComposeDelegate = self;
        [emailer setSubject:NSLocalizedString(@"Photo", nil)];
        [emailer addAttachmentData:UIImagePNGRepresentation([photo underlyingImage]) mimeType:@"png" fileName:@"Photo.png"];
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            emailer.modalPresentationStyle = UIModalPresentationPageSheet;
        }
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_6_0
        [self.photoBrowser presentViewController:emailer animated:YES completion:nil];
#else
        [self.photoBrowser presentModalViewController:emailer animated:YES];
#endif
        [self.photoBrowser hideProgressHUD:NO];
    }
}

#pragma mark Mail Compose Delegate

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    if (result == MFMailComposeResultFailed) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Email", nil)
                                                        message:NSLocalizedString(@"Email failed to send. Please try again.", nil)
                                                       delegate:nil cancelButtonTitle:NSLocalizedString(@"Dismiss", nil) otherButtonTitles:nil];
		[alert show];
    }
    
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_6_0
    [self dismissViewControllerAnimated:YES completion:nil];
#else
	[self.photoBrowser dismissModalViewControllerAnimated:YES];
#endif
}

@end
