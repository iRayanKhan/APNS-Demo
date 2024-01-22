# APNS Demo 


APNS Demo is a 100% Swift/SwiftUI client to test if push notifications work when re-signed.

## Features:
* Customize notification title and subtitle
* Recieve remote push notifications
* View notification token

## Installation
* Requires iOS 14.0+
* Download the pre-compiled .ipa from [Releases]()
* Sideload the app using any sideload tool using a certificate the supports notifications
* [TanaraSign](https://github.com/iRayanKhan/TanaraSign) is a recommeneded sideload tool

## Building the project:
* To build the project you will need Xcode 15.0+
* Using the app installed via Xcode results in a sanbox notification environment which results a bad token, and defeats the use case of this project.
* Archive the app ```Product > Archive > Release Testing```
* Sideload the app using any sideload tool using a certificate the supports notifications
* [TanaraSign](https://github.com/iRayanKhan/TanaraSign) is a recommeneded sideload tool

## Manual testing:
> To test the notifications remotely you will need the app installed
* Obtain your notification token ```Long press the token to copy```
* Send a **POST** request to: ```https://api.wholelotta.red/push/send```
* Include the following as raw/json in the body:
```
{
    "title": "Notification Title",
    "subTitle": "Notification Subtitle",
    "deviceToken": "DeviceToken"
}
```

### Responses: 
#### 200 - OK:
```
{"message": "Notification sent successfully."}
```

#### 500 - Error:
```
{"error": "The operation couldn’t be completed. (APNSwift.APNSwiftError.ResponseError error 0.)"}
```
> The most common cause of this issue is using the app built straight from Xcode instead of exporting the .ipa 















