//
//  RNMessageComposer.m
//  RNMessageComposer
//
//  Created by Matthew Knight on 06/05/2015.
//  Copyright (c) 2015 Anarchic Knight. All rights reserved.
//

#import "RNMessageComposer.h"
#import <React/RCTConvert.h>
#import <MessageUI/MessageUI.h>

@interface RNMessageComposer() <MFMessageComposeViewControllerDelegate>

@end

@implementation RNMessageComposer
{
    NSMutableArray *composeViews;
    NSMutableArray *composeCallbacks;
    BOOL presentAnimated;
    BOOL dismissAnimated;
}

- (NSDictionary *)constantsToExport
{
    return @{
             @"Sent": @"sent",
             @"Cancelled": @"cancelled",
             @"Failed": @"failed",
             @"NotSupported": @"notsupported"
             };
}

+ (BOOL)requiresMainQueueSetup
{
  return NO;
}

- (instancetype)init
{
    if ((self = [super init]))
    {
        composeCallbacks = [[NSMutableArray alloc] init];
        composeViews = [[NSMutableArray alloc] init];
        presentAnimated = YES;
        dismissAnimated = YES;
    }
    return self;
}

RCT_EXPORT_MODULE()

RCT_EXPORT_METHOD(messagingSupported:(RCTResponseSenderBlock)callback)
{
    callback(@[[NSNumber numberWithBool:[MFMessageComposeViewController canSendText]]]);
}

RCT_EXPORT_METHOD(composeMessageWithArgs:(NSDictionary *)args callback:(RCTResponseSenderBlock)callback)
{
    dispatch_async(dispatch_get_main_queue(), ^{
        // check the device can actually send messages - return from method if not supported
        if(![MFMessageComposeViewController canSendText])
        {
            callback(@[@"notsupported"]);
            return;
        }

        MFMessageComposeViewController *mcvc = [[MFMessageComposeViewController alloc] init];
        mcvc.messageComposeDelegate = self;

        if(args[@"recipients"])
        {
            // check that recipients was passed as an NSArray
            if([args[@"recipients"] isKindOfClass:[NSArray class]])
            {
                NSArray *recipients = args[@"recipients"];
                if(recipients.count > 0)
                {
                    NSMutableArray *validRecipientTypes = [[NSMutableArray alloc] init];

                    // Check type of each item in NSArray and only use it if it was provided as an NSString.
                    // We could be more lenient here and just use RCTConvert on all values even if not
                    // provided as NSString originally. For now I prefer being more strict.
                    for(id recipient in recipients)
                    {
                        if([recipient isKindOfClass:[NSString class]])
                        {
                            [validRecipientTypes addObject:recipient];
                        }
                    }
                    if(validRecipientTypes.count != 0)
                    {
                        mcvc.recipients = validRecipientTypes;
                    }
                    else
                    {
                        RCTLog(@"You provided a recipients array but it did not contain any valid argument types");
                    }
                }
                else
                {
                    RCTLog(@"You provided a recipients array but it was empty. No values to add");
                }
            }
            else
            {
                RCTLog(@"recipients must be supplied as an array. Ignoring the values provided");
            }
        }

        // check to see if messages support subjects - if they do check if a subject has been supplied
        if([MFMessageComposeViewController canSendSubject])
        {
            if(args[@"subject"])
            {
                mcvc.subject = [RCTConvert NSString:args[@"subject"]];
            }
        }

        if(args[@"messageText"])
        {
            mcvc.body = [RCTConvert NSString:args[@"messageText"]];
        }

        if(args[@"presentAnimated"])
        {
            presentAnimated = [RCTConvert BOOL:args[@"presentAnimated"]];
        }

        if(args[@"dismissAnimated"])
        {
            dismissAnimated = [RCTConvert BOOL:args[@"dismissAnimated"]];
        }

        if([MFMessageComposeViewController canSendAttachments]) {
            if(args[@"attachments"])
            {
                if([args[@"attachments"] isKindOfClass:[NSArray class]])
                {
                    NSArray *attachments = args[@"attachments"];
                    for(id attachment in attachments)
                    {
                        if([attachment isKindOfClass:[NSDictionary class]])
                        {
                            if ([attachment objectForKey:@"url"] && [attachment objectForKey:@"typeIdentifier"])
                            {
                                NSURL *url = [NSURL URLWithString:[attachment objectForKey:@"url"]];
                                NSString *typeIdentifier = [attachment objectForKey:@"typeIdentifier"];
                                NSString *filename = [attachment objectForKey:@"filename"];

                                if (![mcvc addAttachmentData:[NSData dataWithContentsOfURL:url]
                                           typeIdentifier:typeIdentifier
                                                 filename:filename]) {
                                    NSLog(@"attachment failed to add: %@", attachment);
                                }
                            }
                        }
                    }
                }
            }
        }

        UIViewController *root = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
        while (root.presentedViewController) {
            root = root.presentedViewController;
        }
        [root presentViewController:mcvc animated:presentAnimated completion:nil];

        [composeViews addObject:mcvc];
        [composeCallbacks addObject:callback];
    });
}

#pragma mark - MFMessageComposeViewControllerDelegate

-(void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    NSUInteger index = [composeViews indexOfObject:controller];
    RCTAssert(index != NSNotFound, @"Dismissed view controller was not recognised");
    RCTResponseSenderBlock callback = composeCallbacks[index];

    switch (result) {
        case MessageComposeResultCancelled:
            callback(@[@"cancelled"]);
            break;
        case MessageComposeResultFailed:
            callback(@[@"failed"]);
            break;
        case MessageComposeResultSent:
            callback(@[@"sent"]);
            break;
        default:
            break;
    }

    UIViewController *vc = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
    while (vc.presentedViewController && vc != controller) {
      vc = vc.presentedViewController;
    }
    [vc dismissViewControllerAnimated:dismissAnimated completion:nil];

    [composeViews removeObjectAtIndex:index];
    [composeCallbacks removeObjectAtIndex:index];
}

@end
