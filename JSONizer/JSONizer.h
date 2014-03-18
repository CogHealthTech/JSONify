//
//  JSONizer.h
//  JSONizer
//
//  Created by Craig Hughes on 3/17/14.
//  Copyright (c) 2014 The Cognitive Healthcare Company. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JSONizer : NSObject

+ (NSString *) stringify:(id)object;
+ (NSString *) stringify:(id)object prettily:(BOOL)makePretty;

@end

@interface NSDictionary (JSONizer)
- (NSString *)toJSON;
- (NSString *)toPrettyJSON;
@end

@interface NSArray (JSONizer)
- (NSString *)toJSON;
- (NSString *)toPrettyJSON;
@end

@interface NSDate (JSONizer)
- (NSString *)toJSON;
- (NSString *)toPrettyJSON;
@end

@interface NSString (JSONizer)
- (NSString *)toJSON;
- (NSString *)toPrettyJSON;
@end

@interface NSNumber (JSONizer)
- (NSString *)toJSON;
- (NSString *)toPrettyJSON;
@end

@interface NSNull (JSONizer)
- (NSString *)toJSON;
- (NSString *)toPrettyJSON;
@end
