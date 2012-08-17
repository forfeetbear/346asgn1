//
//  MPInteger.m
//  MultiPrecisionInteger
//
//  Created by Matthew Bennett on 8/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MPInteger.h"

@implementation MPInteger

@synthesize isPositive;
@synthesize arrayRep;

-(id) initWithString:(NSString *)x {
    return nil;
}

-(id) initWithIntArray:(NSMutableArray *) arr isPositive:(BOOL) p{
    if (self = [super init]) {
        arrayRep = [[NSMutableArray alloc] initWithArray:arr copyItems:YES];
        self.isPositive = p;
    }    
    return self;
}

-(NSString *) description {
    return [arrayRep description];
}

-(MPInteger *) add:(MPInteger *)x {
    BOOL selfBigger = [self.arrayRep count] > [x.arrayRep count];
    int maxLength = selfBigger ? [self.arrayRep count] : [x.arrayRep count];
    int diff = ABS([self.arrayRep count] - [x.arrayRep count]);
    NSMutableArray *res = [[NSMutableArray alloc] initWithCapacity:maxLength];
    int carry = 0;
    for (int i = maxLength-1; i >=0; i--) {
        if (i < diff) {
            if(selfBigger) {
                int sum = [[self.arrayRep objectAtIndex:i] intValue] + carry;
                [res replaceObjectAtIndex:i withObject:[NSNumber numberWithInt:sum]];
                carry = 0;
            } else {                
                int sum = [[x.arrayRep objectAtIndex:i] intValue] + carry;
                [res replaceObjectAtIndex:i withObject:[NSNumber numberWithInt:sum]];                
                carry = 0;
            }            
        } else {
            int sum;
            if (selfBigger) {
                sum = [[self.arrayRep objectAtIndex:i] intValue] + [[x.arrayRep objectAtIndex:i-diff] intValue] + carry;
            } else {
                sum = [[self.arrayRep objectAtIndex:i-diff] intValue] + [[x.arrayRep objectAtIndex:i] intValue];
            }
            if (sum < 10) {
                [res replaceObjectAtIndex:i withObject:[NSNumber numberWithInt:sum]];
                carry = 0;
            } else {
                [res replaceObjectAtIndex:i withObject:[NSNumber numberWithInt:sum%10]];
                carry = 1;
            }
        }
        
    }
    return [[MPInteger alloc] initWithIntArray:res isPositive:YES];
}

-(MPInteger *) subtract:(MPInteger *)x {
    return nil;
}

-(MPInteger *) multiply:(MPInteger *)x {
    return nil;
}

-(MPInteger *) divideBy:(MPInteger *)x {
    return nil;
}

-(MPInteger *) modulus:(MPInteger *)x {
    return nil;
}

-(BOOL) isLessThan:(MPInteger *)x {
    MPInteger * res = [self subtract:x];
    return !res.isPositive;
}



@end
