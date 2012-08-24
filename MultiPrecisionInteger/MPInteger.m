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

-(MPInteger *) tensComplementOf {
    NSMutableString *ncomp = [NSMutableString string];
    for (int i = 0; i < [number count]; i++) {
        int comp = [[number objectAtIndex:i] intValue];
        comp = BASE - 1 - comp;
        [ncomp appendString:[NSString stringWithFormat:@"%d", comp]];
    }
    return [[[MPInteger alloc] initWithStringWithLeadingZeros:ncomp] add:[[MPInteger alloc] initWithString:@"1"]];
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

-(int) length {
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
            return [[number objectAtIndex:index] intValue];
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
        x = [x tensComplementOf];
        x = [x padToLength:[this length]];
        NSMutableString *reversed = [NSMutableString string];
        int carry = 0;
        for(int i = [this length] - 1; i >= 0; i--) {
            int sum = carry + [this digitAt:i] + [x digitAt:i];
            carry = sum / BASE;
            sum %= BASE;
            [reversed appendFormat:@"%d", sum];
        }
        NSMutableString *result = [NSMutableString string];
        for(int x = [reversed length] - 1; x >= 0; x--) {
            [result appendString:[reversed substringWithRange:NSMakeRange(x, 1)]];
        }
        if (carry == 0) { // Answer is negative
            MPInteger *comp = [[MPInteger alloc] initWithStringWithLeadingZeros:result];
            comp = [comp tensComplementOf];
            comp = [comp negate];
            return comp;
        } else {
            return [[MPInteger alloc] initWithString:result];
        }
    } 
}

-(MPInteger *) multiply:(MPInteger *)x {
    NSMutableString *resString;
    MPInteger *sumResult = [[MPInteger alloc] initWithString:@"0"];
    int carry, numZeroes = 0;
    for (int i = [x length] - 1; i >= 0; i--, numZeroes++) {
        resString = [NSMutableString string];
        carry = 0;
        
        for(int y = 0; y < numZeroes; y++) {
            [resString appendString:@"0"];
        }
        
        for (int j = [self length] - 1; j >= 0; j--) { //Building it backwards again
            carry =  carry + [x digitAt:i] * [self digitAt:j];
            [resString appendFormat:@"%d", carry % BASE];
            carry /= BASE;
        }
        [resString appendFormat:@"%d", carry];
        
        // Reverse the string and add it to the array of things to be summed
        int x = [resString length];
        NSMutableString *result = [NSMutableString string];
        while (x > 0) {
            x--;
            [result appendString:[resString substringWithRange:NSMakeRange(x, 1)]];
        }
        sumResult = [sumResult add:[[MPInteger alloc] initWithString:result]];
    }
    return sumResult;
}

-(MPInteger *) leftShift {
    NSMutableString *res = [NSMutableString string];
    for (int i = 1; i < [self length]; i++) {
        [res appendFormat:@"%d", [self digitAt:i]];
    }
    [res appendFormat:@"0"];
    return [[MPInteger alloc] initWithStringWithLeadingZeros:res];
}

-(MPInteger *) setDigit: (int) i to:(int) d {
    NSMutableString *desc = [NSMutableString stringWithString:[self description]];
    [desc replaceCharactersInRange:NSMakeRange(i, 1) withString:[NSString stringWithFormat:@"%d", d]];
    return [[MPInteger alloc] initWithStringWithLeadingZeros:desc];
}

-(BOOL) isZero {
    for (int i = 0; i < [number count]; i++) {
        if ([[number objectAtIndex:i] intValue] != 0) return NO;
    }
    return YES;
}

-(MPInteger *) appendDigit: (int) i {
    NSMutableString *res = [NSMutableString stringWithString:[self description]];
    [res appendFormat:@"%d", i];
    return [[MPInteger alloc] initWithString:res];
}

-(MPInteger *) divideBy:(MPInteger *)x {
    if ([x isZero]) return nil;
    MPInteger *remainder = [[MPInteger alloc] initWithString:@"0"];
    NSMutableString *quotient = [NSMutableString string];
    for (int i = 0; i < [self length]; i++) {
        int count = 0;
        remainder = [remainder appendDigit:[self digitAt:i]];
        while ([remainder compareWith:x] >= 0) {
            count++;
            remainder = [remainder subtract:x];            
        }
        [quotient appendFormat:@"%d", count];
    }
    return [[MPInteger alloc] initWithString:quotient];
}

-(MPInteger *) modulus:(MPInteger *)x {
    if ([x isZero]) return nil;
    MPInteger *remainder = [[MPInteger alloc] initWithString:@"0"];
    NSMutableString *quotient = [NSMutableString string];
    for (int i = 0; i < [self length]; i++) {
        int count = 0;
        remainder = [remainder appendDigit:[self digitAt:i]];
        while ([remainder compareWith:x] >= 0) {
            count++;
            remainder = [remainder subtract:x];            
        }
        [quotient appendFormat:@"%d", count];
    }
    return remainder;
}

-(int) compareWith:(MPInteger *)x {
    MPInteger *result = [self subtract:x];
    if ([result isZero]) {
        return 0;
    } else if(result.isPositive) {
        return 1;
    } else {
        return -1;
    }
}

-(BOOL) isLessThan:(MPInteger *)x {
    return [self compareWith:x] < 0;
}



@end
