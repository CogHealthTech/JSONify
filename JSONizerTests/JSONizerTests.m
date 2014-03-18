//
//  JSONizerTests.m
//  JSONizerTests
//
//  Created by Craig Hughes on 3/17/14.
//  Copyright (c) 2014 The Cognitive Healthcare Company. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "JSONizer.h"

@interface JSONizerTests : XCTestCase

@end

@implementation JSONizerTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testNil
{
    NSString *basicNil = [JSONizer stringify:nil];
    XCTAssertEqualObjects(basicNil, @"", @"Nil did not stringify correctly");
}

- (void)testNull
{
    NSString *basicNull = [JSONizer stringify:[NSNull null]];
    XCTAssertEqualObjects(basicNull, @"null", @"Null did not stringify correctly");
}

- (void)testString
{
    NSString *basicString = [JSONizer stringify:@"Hello World!"];
    XCTAssertEqualObjects(basicString, @"\"Hello World!\"", @"String did not stringify correctly");
}

- (void)testNumber
{
    NSString *basicNumber = [JSONizer stringify:@1];
    XCTAssertEqualObjects(basicNumber, @"1", @"Number did not stringify correctly");
}

- (void)testDate
{
    NSDate *now = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"'\"'yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ'\"'"];
    [formatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];

    NSString *basicDate = [JSONizer stringify:now];
    NSLog(@"Date is: %@", basicDate);
    XCTAssertEqualObjects(basicDate, [formatter stringFromDate:now], @"Date did not match");
}

- (void)testKeyValue
{
    NSDictionary *dict = @{ @"key": @1 };
    NSString *basicKeyValue = [JSONizer stringify:dict];
    XCTAssertEqualObjects(basicKeyValue, @"{\"key\":1}", @"Object did not stringify correctly");
}

- (void)testArray
{
    NSString *basicArray = [JSONizer stringify:@[@1,@2,@3]];
    XCTAssertEqualObjects(basicArray, @"[1,2,3]", @"Array did not stringify correctly");
}

- (void)testKeyValueWithNull
{
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNull null], @"key", nil];
    NSString *basicKeyValue = [JSONizer stringify:dict];
    XCTAssertEqualObjects(basicKeyValue, @"{\"key\":null}", @"Object did not stringify correctly");
}

- (void)testObjectWithDateInIt
{
    NSDate *now = [NSDate date];
    NSDictionary *dict = @{ @"straight": now };
    NSArray *array = @[now, dict];

    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"'\"'yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ'\"'"];
    [formatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];

    NSString *nestedDates = [JSONizer stringify:array];
    NSString *expected = [NSString stringWithFormat:@"[%@,{\"straight\":%@}]", [formatter stringFromDate:now], [formatter stringFromDate:now]];

    XCTAssertEqualObjects(nestedDates, expected, @"Nested objects did not stringify dates correctly");
}

@end
