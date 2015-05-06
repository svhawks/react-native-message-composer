# react-native-message-composer

React Native module bridge to iOS MFMessageComposeViewController

## API

`composeMessageWithArgs(args, callback)` - launches a MFMessageComposeViewController and populates any values supplied from the args object.

Both the `args` object and `callback` function are required. The `args` object can be empty though ( e.g. { } ) if you don't want to populate the view with any initial data.

### Args

The args object lets you prepopulate the MFMessageComposeViewController for the user. You can use the following parameters:

```
recipients - an array of strings
subject - string
messageText - string
```

The following shows an example args object

```js
{
	'recipients':[
		'0123456789', '059847362', '345123987'
	],
	'subject':'Sample message subject',
	'messageText':'Sample message text'
}
```

All the args parameters are optional. Simply omit any parameter not required from the args object.

Messages will be sent as SMS or iMessage (depending on support of recipients phone), unless `subject` is supplied, in which case they will be sent as MMS or iMessage (depending on support of recipients phone).

### Callback

The callback will return one of four values, letting you know the message sending status. These are accessed via the following class constants:

```
var Composer = require('NativeModules').RNMessageComposer;

Composer.Sent - the user clicked send and the message has been sent (this does not guarantee delivery, merely that the message sent successfully)
Composer.Failed - the message failed to send for some reason
Composer.Cancelled - user closed the MFMessageComposeViewController by clicking the cancel button
Composer.NotSupported - device does not support sending messages
```

## Getting Started

1. From inside your project run `npm install react-native-message-composer --save`
2. In XCode, in the project navigator, right click `Libraries` ➜ `Add Files to [your project's name]`
3. Go to `node_modules` ➜ `react-native-message-composer` and add `RNMessageComposer.xcodeproj`
4. In XCode, in the project navigator, select your project. Add `libRNMessageComposer.a` to your project's `Build Phases` ➜ `Link Binary With Libraries`
5. Click `RNMessageComposer.xcodeproj` in the project navigator and go the `Build Settings` tab. Make sure 'All' is toggled on (instead of 'Basic'). Look for `Header Search Paths` and make sure it contains both `$(SRCROOT)/../react-native/React` and `$(SRCROOT)/../../React` - mark both as `recursive`.
6. Set up the project to run on your device (iOS simulator does not support sending messages)
7. Run your project (`Cmd+R`)

## Usage Example

```js
var React = require('react-native');
var Composer = require('NativeModules').RNMessageComposer;

// inside your code where you would like to send a message
Composer.composeMessageWithArgs(
	{
	    'messageText':'My sample message body text',
	    'subject':'My Sample Subject',
	    'recipients':['0987654321', '0123456789']
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

There is an example project supplied with the repo in the RNMessageComposerDemo folder. The sample app needs to be run on a device as the simulator does not support sending messages.

## TODO

- [ ] Add support for message attachments
- [ ] Fix issue with a second MFMessageComposeViewController seeming to be present if rotate device whilst MFMessageComposeViewController is open
- [ ] Look at implementing MFMessageComposeViewControllerTextMessageAvailabilityDidChangeNotification to listen for changes to the MFMessageComposeViewController `canSendText` class method


## Credits

Thanks to [Kyle Mathews](https://github.com/KyleAMathews) for the idea.