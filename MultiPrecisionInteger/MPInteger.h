//
//  MPInteger.h
//  MultiPrecisionInteger
//
//  Created by Matthew Bennett on 8/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MPInteger : NSObject {
    NSMutableArray *number;
    BOOL isPositive;
}

// you will need these for me to test your code:
-(id) initWithString: (NSString *) x;
-(NSString *) description;

// your grade will be determined according to
// 20% for each of the following:
-(MPInteger *) add: (MPInteger *) x;
-(MPInteger *) subtract: (MPInteger *) x;
-(MPInteger *) multiply: (MPInteger *) x;
-(MPInteger *) divideBy: (MPInteger *) x;
-(MPInteger *) modulus: (MPInteger *) x;

// you will also need to implement this comparison
// to decode the secret message:
-(BOOL) isLessThan: (MPInteger *) x;
-(BOOL) isPositive;

@end
