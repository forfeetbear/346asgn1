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
        NSScanner *scan;
        isPositive = ![[x substringWithRange:NSMakeRange(0, 1)] isEqualToString:@"-"];
        BOOL significant = NO;
        int size = isPositive ? [x length] : [x length] - 1;
        numberDat = [[NSMutableData alloc]initWithLength:size * sizeof(size)];
        int i = isPositive ? 0 : 1;
        int *num = [numberDat mutableBytes];
        count = 0;
        for (; i < [x length]; i++) {
            int j;
            scan = [[NSScanner alloc] initWithString:[x substringWithRange:NSMakeRange(i, 1)]];
            if ([scan scanInt:&j]) {
                if (j != 0) {
                    num[count++] = j;
                    significant = YES;
                } else if (j == 0 && significant) {
                    num[count++] = j;               
                }
            } else {
                return nil;
            }
        }
        if (count == 0) {
            num[count++] = 0;
        }
    }    
    return self;
}

-(id) initWithStringWithLeadingZeros:(NSString *)x {
    if (self = [super init]) {
        NSScanner *scan;  
        isPositive = ![[x substringWithRange:NSMakeRange(0, 1)] isEqualToString:@"-"];
        int size = isPositive ? [x length] : [x length] - 1;       
        numberDat = [[NSMutableData alloc]initWithLength:size * sizeof(size)];
        int i = isPositive ? 0 : 1;
        int *num = [numberDat mutableBytes];
        for (; i < [x length]; i++) {
            int j;
            scan = [[NSScanner alloc] initWithString:[x substringWithRange:NSMakeRange(i, 1)]];
            if ([scan scanInt:&j]) {            
                num[count++] = j;
            } else {
                return nil;
            }
        }
        if (count == 0) {
            num[count++] = 0;
        }
    }
    return self;
}

-(void) setIsPositive:(BOOL) val {
    isPositive = val;
}

-(MPInteger *) tensComplementOf {
    NSMutableString *acomp = [NSMutableString string];
    int *pcomp = [numberDat mutableBytes];
    for (int i = 0; i < count; i++) {
        int tcomp = pcomp[i];
        tcomp = BASE - 1 - tcomp;
        [acomp appendFormat:@"%d", tcomp];
    }
    //change to acomp
    return [[[MPInteger alloc] initWithStringWithLeadingZeros:acomp] add:[[MPInteger alloc] initWithString:@"1"]];
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
    return count;
}

-(NSString *) description {   
    NSMutableString *tresult = [[NSMutableString alloc] initWithString:@""];
    int *nums = [numberDat mutableBytes];
    if (!isPositive) {
        [tresult appendString:@"-"];
    }
    for (int i = 0; i < count; i++) {
        [tresult appendFormat:@"%d", nums[i]];
    }
    return tresult;
}

-(int) digitAt:(int) index {
    int *nums = [numberDat mutableBytes];
    if (index < count && index >= 0) {
            return nums[index];
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
            carry = sum / BASE;
            sum %= BASE;
            [revresult appendFormat:@"%d", sum];
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
        if ([self isZero] && [x isZero]) {
            return [[MPInteger alloc] initWithString:@"0"];
        }
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

-(BOOL) isZero {
    int *nums = [numberDat mutableBytes];
    for (int i = 0; i < count; i++) {
        if (nums[i] != 0) return NO;
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
    BOOL xWasPos = YES;
    if (![x isPositive]) {
        xWasPos = NO;
        x = [x negate];
    }
    MPInteger *remainder = [[MPInteger alloc] initWithString:@"0"];
    NSMutableString *quotient = [NSMutableString string];
    for (int i = 0; i < [self length]; i++) {
        int q = 0;
        remainder = [remainder appendDigit:[self digitAt:i]];
        while ([remainder compareWith:x] >= 0) {
            q++;
            remainder = [remainder subtract:x];            
        }
        [quotient appendFormat:@"%d", q];
    }
    MPInteger *answer = [[MPInteger alloc] initWithString:quotient];
    if ([self isPositive] != xWasPos) {
        if ([answer isZero]) {
            return [answer subtract:[[MPInteger alloc] initWithString:@"1"]];
        } else {
            return [answer negate];
        }
    }
    return [[MPInteger alloc] initWithString:quotient];
}

-(MPInteger *) modulus:(MPInteger *)x {
    if ([x isZero]) return nil;    
    BOOL xWasPos = YES;
    if (![x isPositive]) {
        xWasPos = NO;
        x = [x negate];
    }
    MPInteger *remainder = [[MPInteger alloc] initWithString:@"0"];
    NSMutableString *quotient = [NSMutableString string];
    for (int i = 0; i < [self length]; i++) {
        int q = 0;
        remainder = [remainder appendDigit:[self digitAt:i]];
        while ([remainder compareWith:x] >= 0) {
            q++;
            remainder = [remainder subtract:x];            
        }
        [quotient appendFormat:@"%d", q];
    }
    if (![self isPositive] == !xWasPos) {
        if (![self isPositive]) {
            return [remainder negate];
        } else {
            return remainder;
        }
    } else {
        remainder = [x subtract:remainder];
        if ([self isPositive]) {
            return [remainder negate];
        } else {
            return remainder;
        }        
    }
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
