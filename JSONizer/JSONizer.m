//
//  JSONizer.m
//  JSONizer
//
//  Created by Craig Hughes on 3/17/14.
//  Copyright (c) 2014 The Cognitive Healthcare Company. All rights reserved.
//

#import "JSONizer.h"

#import <JavaScriptCore/JavaScriptCore.h>

@implementation JSONizer

// There is a bug in Apple's NSDate -> Javascript Date conversion where they are using the NSDate (seconds since 1970) instead of Javascript's (millis since 1970)
// So we need to multiply by 1000 to get it right.  And round, to match the behavior of the NSDateFormatter.
+ (NSDate *)fixDate:(NSDate *)orig
{
    return [NSDate dateWithTimeIntervalSince1970:round([orig timeIntervalSince1970]*1000)];
}

+ (NSDictionary *)fixDictionary:(NSDictionary *)orig
{
    // Allocate a new dictionary
    NSMutableDictionary *new = [NSMutableDictionary dictionaryWithCapacity:orig.count];
    [orig enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        new[key] = [self fixAllTheThings:obj];
    }];

    return new;
}

+ (NSArray *)fixArray:(NSArray *)orig
{
    NSMutableArray *new = [NSMutableArray arrayWithCapacity:orig.count];
    [orig enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        new[idx] = [self fixAllTheThings:obj];
    }];

    return new;
}

+ (id)fixAllTheThings:(id)obj
{
    if ( [obj isKindOfClass:[NSDate class]] )
    {
        return [self fixDate:obj];
    }

    if ( [obj isKindOfClass:[NSDictionary class]] )
    {
        return [self fixDictionary:obj];
    }

    if ( [obj isKindOfClass:[NSArray class]] )
    {
        return [self fixArray:obj];
    }

    return obj;
}

// Return YES if this object is a NSDate or recursively contains a NSDate
+ (BOOL)hasDate:(id)obj
{
    if( [obj isKindOfClass:[NSDate class]] )
    {
        return YES;
    }

    if( [obj isKindOfClass:[NSDictionary class]] )
    {
        __block BOOL found = NO;
        [obj enumerateKeysAndObjectsUsingBlock:^(id key, id recurse, BOOL *stop) {
            if( [self hasDate:recurse] )
            {
                found = YES;
                *stop = YES;
            }
        }];
        return found;
    }

    if( [obj isKindOfClass:[NSArray class]] )
    {
        __block BOOL found = NO;
        [obj enumerateObjectsUsingBlock:^(id recurse, NSUInteger idx, BOOL *stop) {
            if( [self hasDate:recurse] )
            {
                found = YES;
                *stop = YES;
            }
        }];
        return found;
    }

    return NO;
}

+ (id)fixAllDates:(id)obj
{
    if( [self hasDate:obj] )
    {
        return [self fixAllTheThings:obj];
    }

    return obj;
}

+ (NSString *) stringify:(id)object prettily:(BOOL)makePretty
{
    static JSContext *context = nil;
    static JSValue *stringify = nil;
    static BOOL needs_date_fixup = YES;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        context = [[JSContext alloc] initWithVirtualMachine:[[JSVirtualMachine alloc] init]];
        [context evaluateScript:@"var JSONizer_stringify = function(x,y) { return JSON.stringify(x, null, (y?\"\t\":null)); }"];
        stringify = context[@"JSONizer_stringify"];

        // Check if apple bug is present
        NSDateComponents *comps = [[NSDateComponents alloc] init];
        [comps setDay:1];
        [comps setMonth:1];
        [comps setYear:2010];
        context[@"testDate"] = [[NSCalendar currentCalendar] dateFromComponents:comps];
        JSValue *result = [context evaluateScript:@"testDate.getFullYear()"];
        needs_date_fixup = ([result toInt32] != 2010);
    });

    if(object != nil)
    {
        if( needs_date_fixup )
        {
            object = [self fixAllDates:object];
        }
        return [[stringify callWithArguments:@[object, makePretty?@YES:@NO]] toString];
    }
    return @"";
}

+ (NSString *) stringify:(id)object
{
    return [JSONizer stringify:object prettily:NO];
}

@end
