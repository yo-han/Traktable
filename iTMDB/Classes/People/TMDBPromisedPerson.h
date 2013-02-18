//
//  TMDBPerson.h
//  iTMDb
//
//  Created by Christian Rasmussen on 04/11/10.
//  Copyright 2010 Apoltix. All rights reserved.
//  Modified by Alessio Moiso on 16/01/13,
//  Copyright 2013 MrAsterisco. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class TMDBMovie;

/**
 * A `TMDBPerson` object contains information about a person associated with a `TMDBMovie` object.
 *
 * This class does not interact with the TMDb API itself and thus instances are immutable model objects.
 */
@interface TMDBPromisedPerson : NSObject {
	NSUInteger _id;
	NSString *_name;
	NSString *_character;
	TMDBMovie *_movie;
	NSString *_job;
	NSURL *_url;
	NSInteger _order;
	NSInteger _castID;
	NSURL *_profileURL;
}

/** @name Batch Processsing */
/**
 * Returns an array of `TMDBPerson` objects with the information provided in the personsInfo array.
 *
 * @param movie The movie with which the persons should be associated.
 * @param personInfo An array of NSDictionary objects with information about the persons for which objects are to be created.
 * @return An array of `TMDBPerson` objects.
 */
+ (NSArray *)personsWithMovie:(TMDBMovie *)movie personsInfo:(NSArray *)personsInfo;

/** @name Creating an Instance */
/**
 * Returns a person object populated with the provided person information.
 *
 * @param movie The movie object with which the person should be associated.
 * @param personInfo A dictionary containing information about the person.
 * @return An immutable person object populated with the provided person information.
 */
- (id)initWithMovie:(TMDBMovie *)movie personInfo:(NSDictionary *)personInfo;

/** @name Basic Information */
/** The TMDb ID of the person. */
@property (nonatomic, assign, readonly) NSUInteger id;

/** The name of the person. */
@property (nonatomic, copy,   readonly) NSString *name;

/** The name of the character the person played in the movie. */
@property (nonatomic, copy,   readonly) NSString *character;

/** The movie in which the person played a character or was part of a crew. */
@property (nonatomic, strong, readonly) TMDBMovie *movie;

/** The job position of the person in this movie. */
@property (nonatomic, copy,   readonly) NSString *job;

/** The order in which the person should be listed in the Cast and Crew list for the movie. */
@property (nonatomic, assign, readonly) NSInteger order;

/** The */
@property (nonatomic, assign, readonly) NSInteger castID;

/** @name External Resources */
/** A URL to an official website of this person. */
@property (nonatomic, strong, readonly) NSURL *url;

/** A URL to the TMDb profile page of this person. */
@property (nonatomic, strong, readonly) NSURL *profileURL;

@end