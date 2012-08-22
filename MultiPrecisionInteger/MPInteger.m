//
//  MPInteger.m
//  MultiPrecisionInteger
//
//  Created by Matthew Bennett on 8/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MPInteger.h"

@implementation MPInteger

-(id) initWithString:(NSString *)x {
    if (self = [super init]) {
        NSScanner *scan;
        number = [[NSMutableArray alloc] initWithCapacity:[x length]];
        for (int i = 0; i < [x length]; i++) {
            int j;
            NSString *segment = [x substringWithRange:NSMakeRange(i, 1)];
            NSLog(@"%@", segment);
            scan = [[NSScanner alloc] initWithString:[x substringWithRange:NSMakeRange(i, 1)]];
            if ([scan scanInt:&j]) {
                printf("%d", j);
                NSNumber *ins = [[NSNumber alloc] initWithInt:j];
                [number addObject:ins];
            } else {
                return nil;
            }
        }
    }
    return self;
}

-(NSString *) description {
    NSMutableString *result = [[NSMutableString alloc] initWithString:@""];
    for (NSNumber *num in number) {
        [result appendString:[num stringValue]];
    }
    return [NSString stringWithString:result];Ç
}

-(MPInteger *) add:(MPInteger *)x {
    return nil;
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
}



@end
