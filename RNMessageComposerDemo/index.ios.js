/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 */
'use strict';

var React = require('react-native');
var {
  AppRegistry,
  StyleSheet,
  Text,
  TouchableOpacity,
  View,
} = React;

var Composer = require('NativeModules').RNMessageComposer;

var RNMessageComposerDemo = React.createClass({
  render: function() {
    return (
      <View style={styles.container}>
      <TouchableOpacity onPress={this.compose}>
        <Text style={styles.welcome}>
          Click to send a message
        </Text>
        </TouchableOpacity>
      </View>
    );
  },

  compose : function() {
    Composer.composeMessageWithArgs({
        'messageText':'My sample message body text',
        'subject':'My Sample Subject',
        'recipients':['987654321', '0123456789']
      },
      (result) => {
        switch(result) {
          case Composer.Sent:
            console.log('the message has been sent!');
            break;
          case Composer.Cancelled:
            console.log('user cancelled sending the message');
            break;
          case Composer.Failed:
            console.log('failed to send the message');
            break;
          case Composer.NotSupported:
            console.log('not supported to send sms');
            break;
          default:
            console.log('something unexpected happened');
            break;
        }
      }
    );
  }
});

var styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#F5FCFF',
  },
  welcome: {
    fontSize: 32,
    textAlign: 'center',
    margin: 10,
  },
});

AppRegistry.registerComponent('RNMessageComposerDemo', () => RNMessageComposerDemo);