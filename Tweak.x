#import <Foundation/Foundation.h>


%hook NSURL 
+ (instancetype)URLWithString:(NSString *)URLString {
	NSString *originalURLString = URLString;
	NSLog(@"[Retranslate] Original request URL: %@", URLString);

	// /translate_a/t?inputm=0&client=it&q=bonjour&hl=en&ie=UTF-8&oe=UTF-8&sl=en&tl=fr
	NSString *newURLString = [originalURLString stringByReplacingOccurrencesOfString :@"translate.google.com/translate_a/t?" withString:@"translate.google.com/translate_a/single?dt=t&dt=rmt&dt=bd&dt=rms&dt=qca&dt=ss&dt=md&dt=ld&dt=ex&dj=1&otf=2&"];

	//  /translate_a/hw?ime=handwriting&client=it&app=iostranslate&dbg=0&cs=1&oe=UTF-8&sl=en&tl=fr
	// https://inputtools.google.com/request?ime=handwriting&app=iostranslation&dbg=0&cs=1&oe=UTF-8
	newURLString = [newURLString stringByReplacingOccurrencesOfString :@"translate.google.com/translate_a/hw?" withString:@"inputtools.google.com/request?ime=handwriting&"];



	NSLog(@"[Retranslate] Modified request URL: %@", newURLString);

    return %orig(newURLString);
}
%end

%hook TextTranslator

- (id)parseTranslateAPIResponse:(id)response {
    NSError *jsonError = nil;
    id json = [NSJSONSerialization JSONObjectWithData:[response dataUsingEncoding:NSUTF8StringEncoding]
                                            options:0
                                              error:&jsonError];
    
    if (jsonError || !json) {
        NSLog(@"[Retranslate] JSON parsing error: %@", jsonError);
        return response;
    }

    if (![json isKindOfClass:[NSDictionary class]]) {
        return response;
    }

    NSArray *sentences = [json objectForKey:@"sentences"];
    if (![sentences isKindOfClass:[NSArray class]]) {
        return response;
    }

    NSMutableArray *processedSentences = [NSMutableArray array];
    NSMutableDictionary *lastTransSentence = nil;

    for (NSDictionary *sentence in sentences) {
        if (![sentence isKindOfClass:[NSDictionary class]]) {
            continue;
        }

        NSString *trans = [sentence objectForKey:@"trans"];
        NSString *srcTranslit = [sentence objectForKey:@"src_translit"];

        if (trans) {
            NSMutableDictionary *newSentence = [sentence mutableCopy];
            [processedSentences addObject:newSentence];
            lastTransSentence = newSentence;
        } else if (srcTranslit && lastTransSentence) {
            // If current sentence has no trans but has src_translit, 
            // copy src_translit to the last sentence that had trans
            [lastTransSentence setObject:srcTranslit forKey:@"src_translit"];
        }
    }

    NSMutableDictionary *modifiedJson = [json mutableCopy];
    [modifiedJson setObject:processedSentences forKey:@"sentences"];

    NSError *writeError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:modifiedJson 
                                                      options:NSJSONWritingPrettyPrinted 
                                                        error:&writeError];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData 
                                               encoding:NSUTF8StringEncoding];
    NSLog(@"[Retranslate] Modified response for parsing.");
    
    return %orig(jsonString);
}

%end

%ctor {
    NSLog(@"[Retranslate] Tweak loaded successfully");
}