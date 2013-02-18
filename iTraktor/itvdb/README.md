# iTVDb (iOS wrapper for the TheTVDB XML API)

These Objective-C classes provide a wrapper around the [TVDB](http://thetvdb.com) XML API and can be used in iOS apps. These classes are Objective-C ARC (Automatic Reference Counting), so you'll need to enable ARC in XCode when setting up a new project. ARC is supported in iOS 4.0 and above, but you'll need to use the iOS 5.x SDK.

## Installation

iTVDb is available through [CocoaPods](http://cocoapods.org), so you can either add iTVDb as a pod or add it the old fashioned way. Both options are shown below:

### Using CocoaPods

Don't know what CocoaPods is? Well, it's the best way to manage library dependencies in Objective-C projects, so checkout their [website](http://cocoapods.org) to install CocoaPods and get started. Then continue with the following:

1. Add iTVDb to your Podfile:

    ```
    platform :ios
    pod "iTVDb"
    ```
2. Run `pod install`
3. Open your `ProjectName.xcworkspace` instead of `ProjectName.xcodeproj`
4. `#import "iTVDb/iTVDb.h"`

### Adding iTVDb the old fashioned way

1. Drag the `*.h` and `*.m` files from this repository into your project.
2. `#import "iTVDb.h"`

## Usage

To start using the iTVDb iOS wrapper classes you'll first need an API key from the TVDB website. An API key can be retrieved by [registering](http://thetvdb.com/?tab=apiregister) for one on the TVDB website. Once you have an API key, you'll need to initialize the TVDbClient by setting it as the following:

    [[TVDbClient sharedInstance] setApiKey: @"YOUR API KEY"];

Now that you've set your API key, you'll be able to start using the `TVDbShow` and `TVDbEpisode` classes.

### TVDbShow

As described above an API key is needed to use the iTVDb iOS wrapper in your iOS app, except for one call, which is `findByName:` on the `TVDbShow` class. This method can technically be called without one. The following will show you how to retrieve all the TV shows that match 'Game of Thrones':

    NSMutableArray *shows = [TVDbShow findByName:@"Game of Thrones"];

This will internally retrieve an XML file from the TVDB API, convert it to a NSDictionary and load it into a TVDbShow object, which in turn will be added to the NSMutableArray called `shows`. The data retrieved from this call is some basic information about the TV show.

If you want more detailed information, an API key is needed. Since the detailed information has to be retrieved by another API call. The NSMutableArray `shows` can contain multiple TVDbShow instances, but in this case it's a single object. The following properties can be accessed from the TVDbShow instance:

    show.showId           // 121361
    show.title            // Game of Thrones
    show.description      // Based on the fantasy novel series "A Song of Ice and Fire," Game of Thrones explores the story of an epic battle among seven kingdoms and two ruling families in the only game that matters - the Game of Thrones. All seek control of the Iron Throne, the possession of which ensures survival through the 40-year winter to come.
    show.imdbId           // tt0944947
    show.premiereDate     // 2011-04-17
    show.banner           // http://www.thetvdb.com/api/banners/graphical/121361-g19.jpg
    show.bannerThumbnail  // http://www.thetvdb.com/api/banners/_cache/graphical/121361-g19.jpg

To retrieve the detailed information of 'Game of Thrones', the `showId` from the previous API call is needed. Below is an example of retrieving such information.

    TVDbShow *show = [TVDbShow findById:[NSNumber numberWithInt:121361]];

The properties of `show` include all of the above and in addition to that, the following:

    show.status          // Continuing
    show.genre           // ["Action and Adventure", "Drama", "Fantasy"]
    show.actors          // ["Peter Dinklage", "Kit Harington", "Emilia Clarke", ...]
    show.airDay          // Sunday
    show.airTime         // 9:00 PM
    show.runtime         // 60
    show.network         // HBO
    show.contentRating   // TV-MA
    show.rating          // 9.4
    show.poster          // http://www.thetvdb.com/api/banners/posters/121361-13.jpg
    show.posterThumbnail // http://www.thetvdb.com/api/banners/_cache/posters/121361-13.jpg
    show.episodes        // [<TVDbEpisode instance>, <TVDbEpisode instance>, ...]

### TVDbEpisode

When you have an instance of the `TVDbShow` class, you're able to retrieve the belonging episodes by calling: `show.episodes`. But you're also able to retrieve an episode by using the `findById:` and `findByShowId:seasonNumber:episodeNumber:` class methods as described below:

    TVDbEpisode *episode = [TVDbEpisode findById:[NSNumber numberWithInt:4245779]];
    TVDbEpisode *episode = [TVDbEpisode findByShowId:[NSNumber numberWithInt:121361] seasonNumber:[NSNumber numberWithInt:2] episodeNumber:[NSNumber numberWithInt:9]];

The above class methods both return a `TVDbEpisode` instance. The properties which can be retrieved from `episode` (in both cases) are the following:

    episode.episodeId       // 4245779
    episode.title           // Valar Morghulis
    episode.description     // Tyrion awakens to a changed situation. King Joffrey doles out rewards to his subjects. As Theon stirs his men to action, Luwin offers some final advice. Brienne silences Jaime. Arya receives a gift from Jaqen. Dany goes to a strange place. Jon proves himself to Qhorin.
    episode.seasonNumber    // 2
    episode.episodeNumber   // 10
    episode.banner          // http://www.thetvdb.com/api/banners/episodes/121361/4245779.jpg
    episode.bannerThumbnail // http://www.thetvdb.com/api/banners/_cache/episodes/121361/4245779.jpg
    episode.writer          // ["David Benioff", "D.B. Weiss"]
    episode.director        // ["Alan Taylor"]
    episode.gueststars      // in this case it's empty, but when filled it's an array like `episode.writer`
    episode.imdbId          // tt2112510
    episode.premiereDate    // 2012-06-03
    episode.rating          // 8.5
    episode.showId          // 121361

### TVDbUpdater

When you've got a list of shows in your app, you might want to retrieve the shows with new episodes (or maybe just the episodes). The `TVDbUpdater` singleton can help you with that. The first time you have a list of shows (or episodes), you should save the timestamp of that moment in your app. Well, that's as easy as the following:

    [[TVDbUpdater sharedInstance] updateLastUpdatedAtTimestamp];

Once you've done that, you're set for the next update. Let's say you want to update the list of shows (or episodes) the next day. You'll be able to retrieve just the updated shows, episodes or both of them (from that moment on) with the following methods:

    NSDictionary *showUpdates = [[TVDbUpdater sharedInstance] showUpdates];
    NSDictionary *episodeUpdates = [[TVDbUpdater sharedInstance] episodeUpdates];
    NSDictionary *updates = [[TVDbUpdater sharedInstance] updates];

Just to clarify, all of these methods will retrieve data from the moment that was saved with the `updateLastUpdatedAtTimestamp` method until the very moment you call one of the update methods listed above.

## Credit where credit is due

iTVDb uses the [XML-to-NSDictionary](https://github.com/bcaccinolo/XML-to-NSDictionary) library by bcaccinolo to convert the retrieved XML into a NSDictionary.

## Contributing

You're very welcome to contribute to this project. To do so, follow these steps:

1. Fork this project
2. Clone your fork on your local machine
3. Create your feature branch with `git checkout -b my-new-feature`
4. Add a new feature, like perhaps TVDbActor, TVDbMirror or improve an existing feature
5. Commit your changes `git commit -am 'Added new feature'`
6. Push to your branch `git push origin my-new-feature`
7. Create a new Pull Request

## Copyright

Copyright 2012 Kevin Tuhumury. Released under the MIT License.
