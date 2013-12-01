# ImgurKit

__ImgurKit__ is an Objective-C library created to easily handle [Imgur](http://imgur.com) API requests within iOS and OS X apps, it is built on [AFNetworking](http://afnetworking.com/) and its [OAuth extension](https://github.com/AFNetworking/AFOAuth2Client). The project is at an early stage, I'm currently prototyping the classes so __don't use this library__ unless you want to test it.

## Todo

This todo list currently exists to list specific aspects of the library, not all the endpoints of the [Imgur API](http://api.imgur.com/) that should be handled.

### Whole project

* Must redefine the classes prefix, `Imgur` is to long, `JPIK` could be a better solution
* Rework indentation

### All models

* Must use the error parameter of the `JSONObjectWithData:options:error:` from the `NSJSONSerialization` class
* All asynchronous methods should return a ReactiveCocoa Signal, simplifying the way to manage the requests. This will also allow to ignore the callbacks and set them to `nil`.
* All asynchronous methods should return a unique `NSError` object containing the `AFHTTPRequestOperation` object and, if needed, the uploaded images. This allows to use the same callback signature with __and__ without using ReactiveCocoa.

### Album and Image models

* The non-basic classes should return non-basic images but this requires to make two request to Imgur, the user must be warned about this

### IKClient

* Enable anonymous navigation
* Add rate limits informations
* The various `sharedInstance...` class methods are confusing. Those should be removed and two clients must be created with a single `sharedClient` class method for each one. Each client will have a different base URL (one for the commercial endpoints, the other for the free ones). The client ID and secret will be set through a method which could be used only once.

### IKBasicAlbum

* Should the `deletehash` property be in read/write access?

### IKAlbum

* An album could be incomplete, this must be handled (see the [Album model](http://api.imgur.com/models/album))

### IKImage

* Add a progress callback for file uploads (impossible for URL uploads)

### Tests

* The `testAuthenticateUsingOAuthWithPIN` method must handle iOS
* Add a test for the `URLWithSize` method from the `IKBasicImage` class
* Add a library to provide promises, which will simplify the tests. Once the library is added, the `testAuthorizationURLAsync` test should be rewrite to use all the authentication types available.