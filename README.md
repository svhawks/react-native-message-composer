## 08/01/2017 - This project is no longer actively maintained. It will remain here so it can still be used but there will be no further updates or bug fixes. It likely needs a new major version for the recent changes in RN 0.40. If another user wants to consider taking ownership of the repo then please contact me

# react-native-message-composer

React Native module bridge to iOS MFMessageComposeViewController

**RN >= 0.40** Please use 1.0.0 of this library or higher

**RN < 0.40.0** Please use 0.1.0 of this library

## API

`composeMessageWithArgs(args, callback)`

This method launches a MFMessageComposeViewController and populates any values supplied from the args object.

###### Args

The args object is required and lets you prepopulate the MFMessageComposeViewController for the user. You can use the following parameters:

```
recipients - an array of strings
subject - string
messageText - string
attachments - an array of objects
presentAnimated - boolean (animate the appearance of the message composer - true by default)
dismissAnimated - boolean (animate the closing of the message composer - true by default)
```

attachments array:
```js
  [
    {
      url: 'http://...',               // required
      typeIdentifier: 'public.jpeg',   // required
      filename: 'pic.jpg',             // optional
     }
  ]
```

The url can be a web url to an image, video etc but be careful as by default http urls will not work without making changes to the info.plist in the native project. The url can also be a file path on the device, you could for example use https://facebook.github.io/react-native/docs/cameraroll.html to retrieve info on photos stored on the device.

For `typeIdentifier` see https://developer.apple.com/library/content/documentation/Miscellaneous/Reference/UTIRef/Articles/System-DeclaredUniformTypeIdentifiers.html

For further info on attachments view https://developer.apple.com/reference/messageui/mfmessagecomposeviewcontroller/1614069-addattachmentdata

The following shows an example args object

```js
{
	'recipients':[
		'0123456789', '059847362', '345123987'
	],
	'messageText':'Sample message text',
	'dismissAnimated': false
}
```

All the args parameters are optional. Simply omit any parameter not required from the args object. If you don't want to supply any initial data then set the args object to be empty (e.g. {}).

Messages will be sent as SMS or iMessage (depending on support of recipients phone), unless `subject` is supplied, in which case they will be sent as MMS or iMessage (depending on support of recipients phone, and user having turned on support for Subject on their iOS device).

###### Callback

The callback is required and will return one of four values, letting you know the message sending status. These are accessed via the following class constants:

```
var Composer = require('NativeModules').RNMessageComposer;

Composer.Sent - the user clicked send and the message has been sent (this does not guarantee delivery, merely that the message sent successfully)
Composer.Failed - the message failed to send for some reason
Composer.Cancelled - user closed the MFMessageComposeViewController by clicking the cancel button
Composer.NotSupported - device does not support sending messages
```

---

`messagingSupported(callback)`

This method returns a boolean value as a callback indicating whether or not the device supports messaging. This allows you to determine whether or not messaging will work before actually attempting to open a message, and whether you should show/hide certain UI components because of this.

## Getting Started

### Manual

1. From inside your project run `npm install react-native-message-composer --save`
2. In XCode, in the project navigator, right click `Libraries` ➜ `Add Files to [your project's name]`
3. Go to `node_modules` ➜ `react-native-message-composer` and add `RNMessageComposer.xcodeproj`
4. In XCode, in the project navigator, select your project. Add `libRNMessageComposer.a` to your project's `Build Phases` ➜ `Link Binary With Libraries`
5. Click `RNMessageComposer.xcodeproj` in the project navigator and go the `Build Settings` tab. Make sure 'All' is toggled on (instead of 'Basic'). Look for `Header Search Paths` and make sure it contains both `$(SRCROOT)/../react-native/React` and `$(SRCROOT)/../../React` - mark both as `recursive`.
6. Set up the project to run on your device (iOS simulator does not support sending messages)
7. Run your project (`Cmd+R`)

### rnpm (react-native link)

1. From inside your project run `npm install react-native-message-composer --save`
2. run `react-native link`

## Usage Example

```js
import React from 'react';
import Composer from 'react-native-message-composer';

// old way of accessing module is still supported too although no longer recommended
// import { NativeModules } from 'react-native';
// const Composer = NativeModules.RNMessageComposer;

Composer.messagingSupported(supported => {
	// do something like change the view based on whether or not messaging is supported
	// for example you could use this in componentWill/DidMount and show/hide components based on result
	// you could also use this to set state within app which would make showing/hiding components easier
});

// inside your code where you would like to send a message
Composer.composeMessageWithArgs(
	{
	    'messageText':'My sample message body text',
	    'subject':'My Sample Subject',
	    'recipients':['0987654321', '0123456789'],
		'presentAnimated': true,
		'dismissAnimated': false
   	},
	(result) => {
		switch(result) {
			case Composer.Sent:
				console.log('the message has been sent');
				break;
			case Composer.Cancelled:
				console.log('user cancelled sending the message');
				break;
			case Composer.Failed:
				console.log('failed to send the message');
				break;
			case Composer.NotSupported:
				console.log('this device does not support sending texts');
				break;
			default:
				console.log('something unexpected happened');
				break;
		}
	}
);
```

## TODO

- [x] Add support for message attachments
- [ ] Fix issue with a second MFMessageComposeViewController seeming to be present if rotate device whilst MFMessageComposeViewController is open
- [ ] Look at implementing MFMessageComposeViewControllerTextMessageAvailabilityDidChangeNotification to listen for changes to the MFMessageComposeViewController `canSendText` class method


## Credits

Thanks to [Kyle Mathews](https://github.com/KyleAMathews) for the idea.
