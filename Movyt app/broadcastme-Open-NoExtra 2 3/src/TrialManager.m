//
//  TrialManager.m
//  iOSRTSP
//
//  Created by Mihai on 10/22/13.
//  Copyright (c) 2013 Agilio. All rights reserved.
//

#define kLibraryIsTrial NO// YES if library is for trial; NO otherwise
#define kTrialExpirationHour 1     // 1 to 12 AM
#define kTrialExpirationDay 20      // 1 to 31 (depending on the month)
#define kTrialExpirationMonth 11    // 1 to 12
#define kTrialExpirationYear 2014   // 2013 to infinity and beyond

@interface TrialManager : NSObject

+ (BOOL)checkTrial;

@end

@implementation TrialManager

+ (BOOL)checkTrial
{
    if (kLibraryIsTrial) {
        
        NSCalendar *gregorian = [[[NSCalendar alloc]
                                  initWithCalendarIdentifier:NSGregorianCalendar] autorelease];
        
        NSDateComponents *dateComponents = [gregorian components:(NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit | NSHourCalendarUnit | NSTimeZoneCalendarUnit)
                                               fromDate: [NSDate date]];
        [dateComponents setCalendar: gregorian];
        [dateComponents setHour: kTrialExpirationHour];
        [dateComponents setDay: kTrialExpirationDay];
        [dateComponents setMonth: kTrialExpirationMonth];
        [dateComponents setYear: kTrialExpirationYear];
        
        NSDate *expirationDate = [dateComponents date];
        
        if ([expirationDate timeIntervalSince1970] < [[NSDate date] timeIntervalSince1970]) {
            return NO;
        }
        else {
            return YES;
        }
    }
    else {
        return YES;
    }
    
}

@end

