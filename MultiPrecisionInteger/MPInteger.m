//
//  MPInteger.m
//  MultiPrecisionInteger
//
//  Created by Matthew Bennett on 8/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MPInteger.h"

#define BASE 10

@implementation MPInteger

-(id) initWithString:(NSString *)x {
    if (self = [super init]) {
        isPositive = ![[x substringWithRange:NSMakeRange(0, 1)] isEqualToString:@"-"];
        BOOL significant = NO;
        NSScanner *scan;
        int size = isPositive ? [x length] : [x length] - 1;
        number = [[NSMutableArray alloc] initWithCapacity:size];
        int i = isPositive ? 0 : 1;
        for (; i < [x length]; i++) {
            int j;
            scan = [[NSScanner alloc] initWithString:[x substringWithRange:NSMakeRange(i, 1)]];
            if ([scan scanInt:&j]) {
                if (j != 0) {                    
                    NSNumber *ins = [[NSNumber alloc] initWithInt:j];
                    [number addObject:ins];
                    significant = YES;
                } else if (j == 0 && significant) {      
                    NSNumber *ins = [[NSNumber alloc] initWithInt:j];
                    [number addObject:ins];                    
                }
            } else {
                return nil;
            }
        }
        if ([number count] == 0) {
            [number addObject:[[NSNumber alloc] initWithInt:0]];
        }
    }    
    return self;
}

-(id) initWithStringWithLeadingZeros:(NSString *)x {
    if (self = [super init]) {        
        isPositive = ![[x substringWithRange:NSMakeRange(0, 1)] isEqualToString:@"-"];
        NSScanner *scan;
        int size = isPositive ? [x length] : [x length] - 1;
        number = [[NSMutableArray alloc] initWithCapacity:size];
        int i = isPositive ? 0 : 1;
        for (; i < [x length]; i++) {
            int j;
            scan = [[NSScanner alloc] initWithString:[x substringWithRange:NSMakeRange(i, 1)]];
            if ([scan scanInt:&j]) {                 
                    NSNumber *ins = [[NSNumber alloc] initWithInt:j];
                    [number addObject:ins];
            } else {
                return nil;
            }
        }
        if ([number count] == 0) {
            [number addObject:[[NSNumber alloc] initWithInt:0]];
        }
    }
    return self;
}

-(void) setIsPositive:(BOOL) val {
    isPositive = val;
}

-(MPInteger *) ninesComplementOf {
    NSMutableString *ncomp = [NSMutableString string];
    for (int i = 0; i < [number count]; i++) {
        int comp = [[number objectAtIndex:i] intValue];
        comp = BASE - 1 - comp;
        if (i == [number count] - 1) {
            comp += 1;
        }
        [ncomp appendString:[NSString stringWithFormat:@"%d", comp]];
    }
    return [[MPInteger alloc] initWithStringWithLeadingZeros:ncomp];
}

-(MPInteger *)negate {
    MPInteger *result = [[MPInteger alloc] initWithString:[self description]];
    [result setIsPositive:!isPositive];
    return result;
}

-(MPInteger *)padToLength:(int) i {
    if ([self length] < i) {
        int diff = i - [self length];
        NSMutableString *result = [[NSMutableString alloc] initWithString:@""];
        for (int i = 0; i < diff; i++) {
            [result appendString:@"0"];
        }
        [result appendString:[self description]]; 
        return [[MPInteger alloc] initWithStringWithLeadingZeros:result];
    }
    return self;
}

-(NSUInteger) length {
    return [number count];
}

-(NSString *) description {
    NSMutableString *result = [[NSMutableString alloc] initWithString:@""];
    if (!isPositive) {
        [result appendString:@"-"];
    }
    for (NSNumber *num in number) {
        [result appendString:[num stringValue]];
    }
    return [NSString stringWithString:result];
}

-(int) digitAt:(int) index {
    if (index < [self length] && index >= 0) {
        if (isPositive) {
            return [[number objectAtIndex:index] intValue];            
        } else {
            return -1 * [[number objectAtIndex:index] intValue];
        }
    }
    return -1;
}

-(BOOL) isPositive {
    return isPositive;
}



-(MPInteger *) add:(MPInteger *)x {
    // Do the appropriate case when numbers are negative
    if (!isPositive && !x.isPositive) {
        return [[[self negate] add:[x negate]] negate];
    } else if (isPositive && !x.isPositive) {
        return [self subtract:[x negate]];
    } else if (!isPositive && x.isPositive) {
        return [[self subtract:x] negate];
    } else {        
        // Make sure the two numbers are the same length
        MPInteger *this = [self padToLength:[x length]];
        x = [x padToLength:[self length]];
        int carry = 0;
        NSMutableString *revresult = [[NSMutableString alloc] initWithString:@""];
        
        // To make it a bit easier I will build the string up backwards and then reverse it
        for (int i = [this length] - 1; i >= 0; i--) {
            int sum = [this digitAt:i] + [x digitAt:i] + carry;
            NSNumber *digit = [[NSNumber alloc] initWithInt: sum % BASE];
            carry = sum / BASE;
            [revresult appendString:[digit stringValue]];
        }
        if (carry > 0) {
            [revresult appendString:[NSString stringWithFormat:@"%d", carry]];
        }
        
        // Now reverse the string so the numbers are in correct order
        int i = [revresult length];
        NSMutableString *result = [NSMutableString string];
        while (i > 0) {
            i--;
            [result appendString:[revresult substringWithRange:NSMakeRange(i, 1)]];
        }
        return [[MPInteger alloc] initWithString:result];
    }
}

-(MPInteger *) subtract:(MPInteger *)x {
    // Do the appropriate case when numbers are negative
    if (!isPositive && !x.isPositive) {
        return [[[self negate] subtract:[x negate]] negate];
    } else if (isPositive && !x.isPositive) {
        return [self add:[x negate]];
    } else if (!isPositive && x.isPositive) {
        return [[[self negate] add:x] negate];
    } else {
        // Make sure the two numbers are the same length
        MPInteger *this = [self padToLength:[x length]];
        x = [x padToLength:[self length]];
        // Find the complement of the subtrahend and then just add it ignoring the last carry
        x = [x ninesComplementOf];
        
        int carry = 0;
        NSMutableString *revresult = [[NSMutableString alloc] initWithString:@""];
        
        // To make it a bit easier I will build the string up backwards and then reverse it
        for (int i = [this length] - 1; i >= 0; i--) {
            int sum = [this digitAt:i] + [x digitAt:i] + carry;
            NSNumber *digit = [[NSNumber alloc] initWithInt: sum % BASE];
            carry = sum / BASE;
            [revresult appendString:[digit stringValue]];
        }
        // Now reverse the string so the numbers are in correct order
        int i = [revresult length];
        NSMutableString *result = [NSMutableString string];
        while (i > 0) {
            i--;
            [result appendString:[revresult substringWithRange:NSMakeRange(i, 1)]];
        }
        if (carry == 0) { //If the carry was zero then the result was negative so complement again
            MPInteger *intresult = [[MPInteger alloc] initWithString:result];
            intresult = [intresult ninesComplementOf];
            intresult.isPositive = NO;
            intresult = [[MPInteger alloc] initWithString:[intresult description]];
            return intresult;
        } else { //If the carry was not zero everything is fine
            return [[MPInteger alloc] initWithString:result];
        }
    }
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
}



@end
