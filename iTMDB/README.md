# iTMDb

iTMDb is an Objective-C Cocoa wrapper (framework) for [TMDb.org](http://tmdb.org/) originally by Christian Rasmussen, 2010–2011. The support for version 3 of TMDB API has been entirely realized by Alessio Moiso, 2012-2013.

This software is dual-licensed (pick either one you want): **MIT License** or **New BSD License**. See the `LICENSE` file.

iTMDb is developed for **Mac OS X** 10.6 Snow Leopard, 10.7 Lion and 10.8 Mountain Lion, but it should work fine with **iOS** 4, 5 and 6 (though not tested — and the Cocoa framework will have to be replaced with Cocoa Touch). You need Xcode 4.2 to build the project.

Please remember to read the TMDb API [Terms of Use](http://api.themoviedb.org/2.1/terms-of-use) *(even though they refer to version 2.1, they are still valid for version 3)*.

You can safely submit your apps using iTMDb to the App Store (it's been approved for use with [Collection](http://collectionapp.com/) (version 2.1) and [InerziaStudios](http://www.inerziasoft.eu/en/software/inerziastudios/) (version 3)).

## Documentation

The framework was built to be as easy and intuitive to use, so looking at the header files should give you an idea of how it is structured. Please see the test application (available in the Xcode project) for code samples.

## How to use

You can check out the included test project (`iTMDbTest`) within the Xcode workspace for an example of how to use the framework. All iTMDb classes are prefixed with `TMDB`, and the main class, from which most common operations can be made, just called `TMDB`, is known as the "context".

1. Add the framework to your project like any other framework (use Google if you don't know how to do this).

2. Add the following line to the header (or source) files where you will be using iTMDb:

	``` objective-c
	 #import <iTMDb/iTMDb.h>
	```

3. You create an instance of iTMDb like this. Replace ``api_key`` with your own API key, provided by [TMDb](http://api.themoviedb.org/). iTMDb performs fetch requests asynchronously, so setting a delegate is required. The delegate will receive notifications when the loading is done. The object should follow the TMDBDelegate protocol.

	``` objective-c
	TMDB *tmdb = [[TMDB alloc] initWithAPIKey:@"api_key" delegate:self];
	```

4. Look up a movie (while knowing it's id).

	``` objective-c
	[tmdb movieWithID:22538];
	```
	
5. Look up movies (while knowing it's name).

	``` objective-c
	[tmdb movieWithName:@"MovieName"];
	```

6. An API request is made. Once information has been downloaded, the context object (`tmdb`) will receive a notification. The fetched properties are available through the returned object, which is sent to the context delegate (`tmdb.delegate`) with the following method:

	``` objective-c
	-[tmdb:(TMDB *)context didFinishLoadingMovie:(TMDBMovie *)movie]
	```

	Set the movie's title to a text field:

	``` objective-c
	-[movieTitleTextField setStringValue:movie.title];
	```

## Version 3 changes

iTMDB was originally developed to support TMDB API version 2.1. This repository contains an upgraded version that completely support version 3 (for further information, see the [TMDB API Documentation](http://docs.themoviedb.apiary.io/)).

Specifically, some new classes have been added and the framework now supports many more functions.

* *TMDBMovieCollection*: when looking up for a movie name, this version of iTMDB, returns an instance of class **TMDBMovieCollection**. This is an array that lists all the corresponding movies that contain the name that have been searched. You cannot use its element directly, as long as they do not contain all the information (they are instances of **TMDBPromisedMovie**): to get the real movie, you must initialize another request, using the ID of the promised movie to create an instance of **TMDBMovie**. There's also a convenience method that does this for you:

	``` objective-c
	-[promisedMovie movie];
	```

* *TMDBKeyword*: each instance of **TMDBMovie** contains a property called "keywords". This is an array of **TMDBKeyword** objects. You can get their readable-name using the *name* property.

* *TMDBGenre*: each instance of **TMDBMovie** contains a property called "genres" *(that is a replacement for the old property "categories")*. This is an array of **TMDBGenre** objects. You can get their readable-name using the *name* property.

* *TMDBCountry*: each instance of **TMDBMovie** contains a property called "countries". This is an array of **TMDBCountry** objects. You can get their readable-name using the *name* property; this object also offers the country ISO code.

* *TMDBImage*: an instance of **TMDBMovie** offers a *posters* and a *backdrops* property. Due to core changes to the TMDB API, they only contain NSDictionary objects. To get the original image, you should use the NSDictionary to initialize a new instance of **TMDBImage**. This object is responsible to make a [configuration](http://docs.themoviedb.apiary.io/#configuration) request to the TMBD server and then to return the already-allocated NSImage to its delegate.

	``` objective-c
	-[TMDBImage imageWithDictionary:(NSDictionary*)image context:(TMDB*)aContext delegate:(id<TMDBImageDelegate>)del];
	```
	
	Using the method above, the TMDBImage will make a configuration request to the TMDB server *(if necessary; this will be done only the first time you try to load an image for each context)* and return the **NSImage** object to the delegate.


## Other stuff

### What's missing

iTMDb does not yet cover the entire TMDb API, but movie search and lookup works. The things that you can do in this version are completely compatible with version 3 of the TMDB API, but stuff like Authentication, Collections *(the TMDBMovieCollection has nothing to do with real movies collection)*, People, Company, Genres and Keywords lookup are not implemented.

### Third-party code

iTMDb includes the following third-party code:

 * [SBJson](https://github.com/stig/json-framework) (New BSD License) - If on OS X Lion or iOS 5 then [NSJSONSerialization](http://developer.apple.com/library/mac/#documentation/Foundation/Reference/NSJSONSerialization_Class/Reference/Reference.html) is used instead.