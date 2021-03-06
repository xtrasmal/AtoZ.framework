
#import "AZLog.h"

#define __VSTR(x) (__bridge const void*)x

JREnumDefine ( LogEnv );

NSA* AZEnvVars (char** envp) { 					NSMA * vars = NSMA.new; char** env;
	for (env = envp; *env != 0; env++)	{      NSS * var, * raw;

		raw = [NSS stringWithCString:*env encoding:NSASCIIStringEncoding];
		objc_setAssociatedObject(	var = [raw substringBefore:@"="],	 	__VSTR(@"envVarValue"),
										 	[raw substringAfter:@"="],	OBJC_ASSOCIATION_RETAIN_NONATOMIC);
		[vars addObject:var];
	}
	return vars;
}
NSD* AZEnv (char** envp) {	return [AZEnvVars(envp) mapToDictionary:^id(id o) {
														return objc_getAssociatedObject(o, __VSTR(@"envVarValue"));		}];
}
void AZLogEnv(char** envp){ 	NSD* envD = AZEnv(envp);
	NSUI length = [envD.allKeys lengthOfLongestMemberString] + 2;
	LOGCOLORS( 	[NSA arrayWithArrays:[envD mapToArray:^NSArray *(id k, id v) { return @[[k paddedTo:length], v, zNL]; }]], 
					[NSC colorsInListNamed:@"flatui"], nil);
}
static NSA *gPal = nil;

static LogEnv logEnv = LogEnvUnknown;
@implementation AZLog


//- (BOOL) inTTY 			{   return [@(isatty(STDERR_FILENO))boolValue]; }
- (LogEnv) logEnv 		{

	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{	
		NSS* term = $UTF8orNIL(getenv("XCODE_COLORS"));
		if (term) logEnv = SameString(term,@"YES") ? LogEnvXcodeColor :
								 SameString(term,@"NO")  ? LogEnvXcodeNOColor : logEnv;
		else if (isatty(STDERR_FILENO))
			if ((term = $UTF8orNIL(getenv("TERM"))))
				logEnv = [term containsAllOf:@[@"color",@"256"]] ? LogEnvTTY256 :
							[term contains:@"color"] ? LogEnvTTYColor : LogEnvTTY;
	});	
//		of ([tty sharedInstance]) 		objc_msgSend([tty class],
//		NSSelectorFromString( isaColor256TTY ? @"initialize_colors_256" : @"initialize_colors_16"));
	// Xcode does NOT natively support colors in the Xcode debugging console.
	// You'll need to install the XcodeColors plugin to see colors in the Xcode console
//			NSS *xcode_colors = $UTF8(getenv("XcodeColors"));
//			isaXcodeColorTTY = xcode_colors && SameString(xcode_colors,@"YES");
//		}();
//		fprintf(stdout, "%sisaColorTTY\t=\t%s%s\t%sisaColor256TTY\t=\t%s%s\t%s\n", 
//		isaColorTTY ? "\033[38;5m" : "",  isaColorTTY ? "YES" : "NO", isaColorTTY ? "\033[0m" : "", 
//		isaColorTTY ? "\033[38;5m" : "",  isaColor256TTY ? "YES" : "NO", isaColorTTY ? "\033[0m" : "", 
//		$(@"%@isaXcodeColorTTY\t=\t%@%@",isaXcodeColorTTY ? XCODE_COLORS_ESCAPE @"fg244,100,80;" : zSPC, StringFromBOOL(isaXcodeColorTTY), isaXcodeColorTTY ? XCODE_COLORS_RESET : @"").UTF8String);
	return _logEnv = logEnv = logEnv == LogEnvUnknown ? LogEnvUnknown : logEnv;
}

#define LOG_CALLER_VERBOSE NO		// Rediculous logging of calling method
#define LOG_CALLER_INFO	YES		// Slighlty less annoying logging of calling method

- (NSA*) rgbColorValues:(id)color 				{
	__block float r, g, b;  __block NSC *x;									   //  printf("%s", $(@"%@",[color class]).UTF8String);

	if ([color ISKINDA:NSS.class]) x = [NSC colorWithName:color] ? : [NSC colorWithCSSRGB:color] ? : RED;

	ISA(color, NSC) ? ^{	 x = color;  x = x.isDark ? [x colorWithBrightnessOffset:2] : x;
		x = [x colorUsingColorSpace:NSColorSpace.genericRGBColorSpace];
		r = (x.redComponent * 255); g = (x.greenComponent * 255); b = (x.blueComponent * 255);					} ()

	: ISA(color, NSA) && [color count] == 3 ? ^{
		r = [color[0] integerValue]; g = [color[1] integerValue]; b = [color[2] integerValue];
	} () : nil;  return @[@(r), @(g), @(b)];
}
- (NSS*) colorizeString:(NSS*)string front:(id)front back:(id)back  {				//NSA *rgbs;
	if (front) [string setLogForeground:front];
	if (back)  [string  setLogBackground:back];
	return string;
}
- (NSS*) colorizeString:(NSS*)string withColor:(id)color 				{
	return [self colorizeString:string front:color back:nil];
}
/* Pass a variadic list of Colors, and Ovjects, in any order, TRMINATED BY NIL, abd it wiull use those colors to log those objects! */
//- (NSA*) COLORIZE:(id) colorsAndThings, ...  {

- (NSA*) colorizeAndReturn:(id) colorsAndThings, ... {

	__block NSMA *colors = NSMA.new;  __block NSMA *words  = NSMA.new;

	AZVA_Block sort   = ^(id thing) { [thing ISKINDA:NSC.class] ? 	[colors addObject:thing] 	: 	[words addObject:thing]; };
	AZVA_Block theBlk = ^(id thing) { [thing ISKINDA:NSA.class] ? [(NSA*)thing each:^(id obj) { sort(thing); }] : sort (thing); };

	azva_iterate_list(colorsAndThings, theBlk);   
	return [words nmap:^id (id o, NSUI i) { 
		NSS *n = $(@"%@", o); NSC *c  = [colors normal:i];  
		n.logForeground = c.isDark ? c.invertedColor : c;  return n;
	}];
}
/*NSA * COLORIZE		  ( id colorsAndThings, ... )*/							


-(void) logThese:(const char *)pretty things:(id)colorsAndThings, ... {

	__block NSMA *colors = NSMA.new;//[NSMA mutableArrayUsingWeakReferences];
	__block NSMA *words  = NSMA.new;//[NSMA mutableArrayUsingWeakReferences];
	AZVA_Block theBlk = ^(id it) {								//			AZVA_Block sort   = ^(id it) {
		objswitch(it)
		objkind(NSC) [colors addObject:it];
		objkind(NSS) [words  addObject:it];
		objkind(NSA) if ([(NSA*)it all:^BOOL(id obj) { return [obj ISKINDA:NSC.class];}])
									[colors addObjectsFromArray:it];
								 else [words addObject:[it debugDescription]];

//		[(NSA*)it each:^(id obj) {
//		   [obj ISKINDA:NSC.class] ? [colors addObject:[obj copy]] :
//		   [obj ISKINDA:NSS.class] ? [words  addObject:[obj copy]] : nil;
//			NSS* first = [obj firstResponsiveString:@[@"stringValue", @"name"]];
//			if (first) [words addObject:[obj vFK:first]];
//		}]:

		defaultcase if ([it respondsToString:@"debugDescription"]) [words addObject:[it vFK:@"debugDescription"]]; else  [it description];
		endswitch
//			NSS* first = [it firstResponsiveString:@[@"stringValue", @"name"]];
//				? [words addObject:[[ it stringValue]copy]] : nil;
	};
	azva_iterate_list(colorsAndThings, theBlk);
	//	NSLog(@"colors:%ld:%@ words:%ld:%@", colors.count, colors, words.count, words);
	//	NSA *colors, *words, *colorStringArray;  colorStringArray = colors1strings2(colorsAndThings); colors = colorStringArray[0]; words = colorStringArray[1];
	LogEnv e =  self.logEnv ;
	if (!colors.count) colors = @[RED,WHITE,BLUE].mutableCopy;
	if (!words.count) {  printf( "WARNING, NO WORDS TO PRINT: %s", pretty); return; }
	[words addObject:zNL];
	fprintf(stdout, "%s", //e != LogEnvXcodeColor ? [words componentsJoinedByString:@" "].UTF8String :

	 [[words reduce:LOG_CALLER_VERBOSE ? @"LOGCOLORS: ":@"" withBlock:^NSS*(NSS *sum,NSS *o) {
															if (![o isEqualToAnyOf:@[@" ",@"\n", @""]]) {
																NSC  *c = [colors advance];
																o.logForeground = c.isDark ? [c colorWithBrightnessMultiplier:2]: c;
																return [sum withString:o.colorLogString];
															}
															else return  [sum withString:o];
														}]UTF8String]);
}

void WEBLOG (id format, ...) {

	NSLogConsoleView* e = (NSLogConsoleView*)[NSLogConsole.sharedConsole webView];
//	[e logString: file:(char*)filename lineNumber:(int)lineNum];
	
}


-(void) logInColor:(id)colr file:(const char*)file line:(int)ln func:(const char*)fnc format:(id)fmt,...{

	if (!fmt || ![fmt ISKINDA:NSS.class]) return NSLog(@"you tried formatting with a %@, not a string!", NSStringFromClass([fmt class]));
// Get a reference to the arguments that follow the format parameter
//	__block NSMS *s = NSMS.new;
	va_list argList;
	va_start(argList, fmt);
// Perform format string argument substitution, reinstate %% escapes, then print
	NSString *s = [NSString.alloc initWithFormat:fmt arguments:argList];
	if (s && s.length)
//	s = [s stringByReplacingOccurrencesOfString:@"%%" withString:@"%%%%"];
//	if (s && s.length)
		printf("%s\n",[s stringByReplacingOccurrencesOfString:@"%%" withString:@"%%%%"].UTF8String);
//	[s release];
	va_end(argList);
/**
	azva_list_to_nsarray(fmt, FORMATTER)
	NSMS * formateed = [fmt mutableCopy];
	[FORMATTER each:^(id obj) {
		if (![formateed containsString:@"%"]) return;  NSRNG r = [formateed rangeOfString:@"%"]; r.length++; [formateed replaceCharactersInRange:r withString:obj]; 
	}];
	[((NSS*)formateed) setLogForeground:colr];
	fprintf(stdout,"%s",formateed.clr.UTF8String);
*//**	[self logNilTerminatedListOfColorsAndStrings:file things:[NSString stringWithFormat:fmt arguments:VA_A]]
   va_list argList;  va_start(argList,fmt);	NSS *path = nil, *fullPath = nil; __block NSS *lineNum = nil,*mess = nil,*func = nil,*output = nil; __block NSUI numberofspaces;

	fullPath = file ? $UTF8(file) : nil;
	if (fullPath) path = [[@"[" withString:[fullPath contains:@"/"] ? [fullPath lastPathComponent] : fullPath]withString:@"]"];
	/// : @"";
	mess 	= [NSS stringWithFormat:fmt arguments:argList];

		//:fl lineNumber:ln];setFakeStdin:$(@"%@%i%s%@",path, line, funcName, mess)];
	self.logEnv == LogEnvXcodeColor ? ^{

		path.logForeground 		= gPal [0];
		lineNum						= $( @":%i ", ln );
		lineNum.logForeground 	= gPal [1];
		numberofspaces		 		=      10;	//MIN(MAX((paddedString.length - concat.length), 2), 20);
		func  						= [$UTF8(fnc) truncateInMiddleToCharacters:30];
		func.logForeground 		= [gPal[2] darker];
		//	output = $(@"%@%@", path.colorLogString, lineNum.colorLogString);   //, [NSS spaces:numberofspaces]);
		NSC* messColor				= clr 	? : gPal [4];
		mess.logForeground      = messColor;
		mess 							= mess.colorLogString ?: mess;  //  actual log message

		output 						= [mess paddedTo:120];//withString:output];
		output 						= [output withString:func.colorLogString];
		//	[func containsAnyOf:@[@"///Color"]] ? @"" : func.colorLogString];	//	fflush(stdout);
		[NSTerminal printString:output];
///		fprintf(stderr, "%s\n", output.UTF8String);

	}() : [NSTerminal printString:mess]; 
	
//		[%@]:%i @"%s* / @"%@\n", / / * path, line, funcName,* / 
//										XCODE_COLORS_ESCAPE @"fg140,140,140;"   @":%i"  XCODE_COLORS_RESET
//										XCODE_COLORS_ESCAPE @"fg109,0,40;"  @" %s "		 XCODE_COLORS_RESET
//										XCODE_COLORS_ESCAPE @"%@" "%@"XCODE_COLORS_RESET @"\n",
//										path,
//										line, funcName,
//										colorString,
//										mess)
//	 toLog.UTF8String);//
	va_end(argList);
*/
} // ACTIVE NSLOG
@end
@implementation NSString (AtoZColorLog)
- (void)setLogForeground:(id)color {	//	printf("setting fg: %s", ((NSC*)color).nameOfColor.UTF8String);
    objc_setAssociatedObject(self,__VSTR(@"logFG"),[AZLOGSHARED rgbColorValues:color],OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (void)setLogBackground:(id)color {
    objc_setAssociatedObject(self,__VSTR(@"logBG"),[AZLOGSHARED rgbColorValues:color],OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (const char*) cchar {  return self.clr.UTF8String; }

- (NSS*) colorLogString {

	NSA *fgs = [self hasAssociatedValueForKey:@"logFG"] ? [self associatedValueForKey:@"logFG"] : nil;
   NSA *bgs = [self hasAssociatedValueForKey:@"logBG"] ? [self associatedValueForKey:@"logBG"] : nil;
	if (!fgs && !bgs) return self;
   NSS *colored = self.copy;
	if ((( fgs && fgs.count == 3) || (bgs && bgs.count ==3) ) && logEnv == LogEnvXcodeColor) {
		if (fgs && fgs.count ==3) {
			colored = $(XCODE_COLORS_ESCAPE @"fg%i,%i,%i;%@" XCODE_COLORS_RESET,
							[fgs[0] intValue], [fgs[1] intValue], [fgs[2] intValue], colored);
		}
		if (bgs && bgs.count ==3) {
			colored = colored ? : self;
			colored = $(XCODE_COLORS_ESCAPE @"bg%i,%i,%i;%@" XCODE_COLORS_RESET,
							[bgs[0] intValue], [bgs[1] intValue], [bgs[2] intValue], colored);
		}
		return colored;
	}
	if (logEnv == LogEnvTTYColor || logEnv == LogEnvTTY256){		static NSArray* cs, *bg;
		cs = cs ?: @[@31,@32,@33,@34,@35,@36,@37];
		bg = bg ?: @[@40,@41,@42];//,@43,@44,@45,@46,@47];
		return [NSString stringWithFormat:@"\033[%@;%@m%@\033[0m", [cs[arc4random() % 7 ]stringValue],
				  [bg[arc4random() % 3 ]stringValue], self];
	}
	else return self;
}
@end

//- (const char*) ttyClr {
//	BOOL inTTY =  [@(isatty(STDERR_FILENO))boolValue];
//	if (inTTY) return s;
//	NSArray* cs = @[@31,@32,@33,@34,@35,@36,@37];
//	NSArray* bg = @[@40];//,@41,@42,@43,@44,@45,@46,@47];
//	NSNumber* num = cs[arc4random() % 7 ];
//	NSNumber* nub = bg[arc4random() % 1 ];
//	NSString *let = [num stringValue];
//	NSString *blet = [nub stringValue];
//	return [NSString stringWithFormat:@"\033[%@;%@m%@\033[0m - %@", let,blet, s, num];
//}
// BLINKING	 "\033[38;5mWhatever\033[0m"


// Log levels: off, error, warn, info, verbose
//static const int ddLogLevel = LOG_LEVEL_VERBOSE;
//
//void _AZLog(const char *file, int lineNumber, const char *funcName, NSString *format,...) {
//	va_list arglist;
//
//	va_start (arglist, format);
//	if (![format hasSuffix: @"\n"]) {
//		format = [format stringByAppendingString: @"\n"];
//	}
//	NSString *body =  [[NSString alloc] initWithFormat: format arguments: arglist];
//	va_end (arglist);
//	const char *threadName = [[[NSThread currentThread] name] UTF8String];
//	NSString *fileName=[[NSString stringWithUTF8String:file] lastPathComponent];
//		//	if (threadName) {
//		//		fprintf(stderr,"%s/%s (%s:%d) %s",threadName,funcName,[fileName UTF8String],lineNumber,[body UTF8String]);
//		//	} else {
//		//		fprintf(stderr,"%p/%s (%s:%d) %s",[NSThread currentThread],funcName,[fileName UTF8String],lineNumber,[body UTF8String]);
//		//	}
//#ifdef PRINTMETHODS
//	fprintf(stderr,"%s:%d [%s] %s",[fileName UTF8String],lineNumber,funcName, [body UTF8String]);
//#else
//	fprintf(stderr,"line:%d %s",lineNumber, [body UTF8String]);
//#endif
//		//
//	[body release];
//}
//
//void _AZLog(const char *file, int lineNumber, const char *funcName, NSString *format,...);
//
//void QuietLog (const char *file, int lineNumber, const char *funcName, NSString *format, ...) {
//	if (format == nil) {
//		printf("nil\n");
//		return;
//	}
//		// Get a reference to the arguments that follow the format parameter
//	va_list argList;
//	va_start(argList, format);
//		// Perform format string argument substitution, reinstate %% escapes, then print
//	NSString *s = [[[NSString alloc] initWithFormat:format arguments:argList]stringByReplacingAllOccurancesOfString:@"fff" withString:@"%.1f"];
//		//for float the format specifier is %f and we can restrict it to print only two decimal place value by %.2f
//	printf("%s\n", [[s stringByReplacingOccurrencesOfString:@"%%" withString:@"%%%%"] UTF8String]);
//	[s release];
//	va_end(argList);
//}

//void QuietLog (NSString *format, ...) { if (format == nil) { printf("nil\n"); return; }
//	// Get a reference to the arguments that follow the format parameter
//	va_list argList;  va_start(argList, format);
//	// Perform format string argument substitution, reinstate %% escapes, then print
//	NSString *s = [[NSString alloc] initWithFormat:format arguments:argList];
//	printf("%s\n", [[s stringByReplacingOccurrencesOfString:@"%%" withString:@"%%%%"] UTF8String]);
//	[s release];
//	va_end(argList);
//}

// NSLog() writes out entirely too much stuff.  Most of the time I'm  not interested in the program name, process ID, and current time down to the subsecond level.
// This takes an NSString with printf-style format, and outputs it. regular old printf can't be used instead because it doesn't support the '%@' format option.

void QuietLog( NSString *fmt,...) {	va_list argList; va_start(argList, fmt);
	printf("%s",  [[NSS stringWithFormat:fmt arguments:argList]UTF8String]);
	va_end(argList);
} // QuietLog

#ifndef NDEBUG
#import <Foundation/Foundation.h>
#import <stdio.h>

extern void _NSSetLogCStringFunction(void (*)(const char *string, unsigned length, BOOL withSyslogBanner));
static void PrintNSLogMessage(const char *string, unsigned length, BOOL withSyslogBanner) {	puts(string);	}

static void HackNSLog(void) __attribute__((constructor));
static void HackNSLog(void) {	_NSSetLogCStringFunction(PrintNSLogMessage);	}

#endif

//void QuietLog (NSString *format, ...) {
//	va_list argList;	va_start (argList, format);
//	NSString *message = [[NSString alloc] initWithFormat:format arguments:argList];
//	fprintf (stderr, "*** %s ***\n", [message UTF8String]);	 va_end  (argList);
//} // QuietLog

//	NSUInteger fgCodeIndex;	NSString *fgCodeRaw;	char fgCode[24];	size_t fgCodeLen;	char resetCode[8];	size_t resetCodeLen;
//
//	if (fgs && isaColorTTY) {
//		NSC*fgColor = [NSC r:[fgs[0] floatValue] g:[fgs[1]floatValue] b:[fgs[2] floatValue] a:1];
//		// Map foreground color to closest available shell color
//		fgCodeRaw   = DDTTYLogger.codes_fg[fgCodeIndex];
//		NSString *escapeSeq = @"\033[";
//		NSUInteger len1 = [escapeSeq lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
//		NSUInteger len2 = [fgCodeRaw lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
//		[escapeSeq getCString:(fgCode)      maxLength:(len1+1) encoding:NSUTF8StringEncoding];
//		[fgCodeRaw getCString:(fgCode+len1) maxLength:(len2+1) encoding:NSUTF8StringEncoding];
//			
//			fgCodeLen = len1+len2;
//	}
//	NSS* save = [AZTEMPD withPath:@"whatever.txt"];
//	[@{@"color": colored } writeToFile:save atomically:YES];
//	printf("%s", save.UTF8String);
//    return colored ? : self;//@"Something went wrong";

//	else if (fgColor && isaXcodeColorTTY)
//	{
		// Convert foreground color to color code sequence
//		const char *escapeSeq = XCODE_COLORS_ESCAPE_SEQ;
//		int result = snprintf(fgCode, 24, "%sfg%u,%u,%u;", escapeSeq, fg_r, fg_g, fg_b);
//		fgCodeLen = MIN(result, (24-1));
//	}
//	else
//	{
//		// No foreground color or no color support
//		
//		fgCode[0] = '\0';
//		fgCodeLen = 0;
//	}



////void _AZColorLog		( id color, const char *filename, int line, const char *funcName, id format, ...) {
//
//	if (!gPal) gPal = NSC.randomPalette;
//   va_list argList;  va_start(argList,format);	__block NSS *lineNum,*path,*mess,*func,*output; __block NSUI numberofspaces;
//
//	path	= $(@"[%@]", $UTF8(filename).lastPathComponent);
//	mess 	= [NSS stringWithFormat:format arguments:argList];
//
//		//:fl lineNumber:ln];setFakeStdin:$(@"%@%i%s%@",path, line, funcName, mess)];
//	AZLogEnv() == LogEnvXcodeColor ? ^{
//
//		path.logForeground 		= gPal [0];
//		lineNum						= $( @":%i ", line );
//		lineNum.logForeground 	= gPal [1];
//		numberofspaces		 		=      10;	//MIN(MAX((paddedString.length - concat.length), 2), 20);
//		func  						= [$UTF8(funcName) truncateInMiddleToCharacters:30];
//		func.logForeground 		= [gPal[2] darker];
//		//	output = $(@"%@%@", path.colorLogString, lineNum.colorLogString);   //, [NSS spaces:numberofspaces]);
//		NSC* messColor				= color 	? : gPal [4];
//		mess.logForeground      = messColor;
//		mess 							= mess.colorLogString ?: mess;  //  actual log message
//
//		output 						= [mess paddedTo:120];//withString:output];
//		output 						= [output withString:func.colorLogString];
//		//	[func containsAnyOf:@[@"///Color"]] ? @"" : func.colorLogString];	//	fflush(stdout);
//		fprintf(stderr, "%s\n", output.UTF8String);
//
//	}() : ^{ fprintf(stderr, "%s", $(/*@"[%@]:%i @"%s*/ @"%@\n",/* path, line, funcName,*/ mess).UTF8String); return; }();
////										XCODE_COLORS_ESCAPE @"fg140,140,140;"   @":%i"  XCODE_COLORS_RESET
////										XCODE_COLORS_ESCAPE @"fg109,0,40;"  @" %s "		 XCODE_COLORS_RESET
////										XCODE_COLORS_ESCAPE @"%@" "%@"XCODE_COLORS_RESET @"\n",
////										path,
////										line, funcName,
////										colorString,
////										mess)
////	 toLog.UTF8String);//
//	va_end(argList);
//} // ACTIVE NSLOG
//

//typedef NSA*(^SeperateColorsThenStrings)(id colorsAndThings);
//AZVA_Block theBlk = ^(id thing) { [thing ISKINDA:NSC.class] ? [colors addObject:thing] : [words addObject:thing]; };
//
//SeperateColorsThenStrings colors1strings2 = ^(id colorsAndThings){
//
// __block NSMA *colors = NSMA.new;  __block NSMA *words  = NSMA.new;
//	azva_iterate_list(colorsAndThings, theBlk);
//	return @[Block_copy(colors), Block_copy(words)];
//};

//+(BOOL) inTTY 					{   return [@(isatty(STDERR_FILENO))boolValue]; }
//LogEnv AZLogEnv(void) 		{
//
//	if (inTTY()) return LogEnvTTY;
//	char *XcodeSaysColor	= getenv("XCODE_COLORS");
//	return XcodeSaysColor != NULL && SameChar(XcodeSaysColor,"YES") ? LogEnvXcodeColor :  LogEnvXcodeNOColor;
//}
//
//#define LOG_CALLER_VERBOSE NO		// Rediculous logging of calling method
//#define LOG_CALLER_INFO	YES		// Slighlty less annoying logging of calling method
//
//NSA * rgbColorValues			 	             (id color) 				{
//	__block float r, g, b;  __block NSC *x;									   //  printf("%s", $(@"%@",[color class]).UTF8String);
//
//	if ([color ISKINDA:NSS.class]) x = [NSC colorWithName:color] ? : [NSC colorWithCSSRGB:color] ? : RED;
//
//	ISA(color, NSC) ? ^{	 x = color;  x = x.isDark ? [x colorWithBrightnessOffset:2] : x;
//		x = [x colorUsingColorSpace:NSColorSpace.genericRGBColorSpace];
//		r = (x.redComponent * 255); g = (x.greenComponent * 255); b = (x.blueComponent * 255);					} ()
//
//	: ISA(color, NSA) && [color count] == 3 ? ^{
//		r = [color[0] integerValue]; g = [color[1] integerValue]; b = [color[2] integerValue];
//	} () : nil;  return @[@(r), @(g), @(b)];
//}
//NSS * colorizeStringWithColors (NSS *string, id front, id back)	{				//NSA *rgbs;
//	if (front) [string setLogForeground:front];
//	if (back)  [string  setLogBackground:back];
//	return string;
//}
//NSS * colorizeStringWithColor	 (NSS *string, id color) 				{
//	return colorizeStringWithColors(string, color, nil);
//}
//
///* Pass a variadic list of Colors, and Ovjects, in any order, TRMINATED BY NIL, abd it wiull use those colors to log those objects! */
//NSA * COLORIZE		  ( id colorsAndThings, ... )							{
//	__block NSMA *colors = NSMA.new;  __block NSMA *words  = NSMA.new;
//
//	AZVA_Block sort   = ^(id thing) { [thing ISKINDA:NSC.class] ? [colors addObject:thing] : [words addObject:thing]; };
//	AZVA_Block theBlk = ^(id thing) { if ([thing ISKINDA:NSA.class])  [(NSA*)thing each:^(id obj) {   sort(thing);		}];
//	else sort (thing);
//	};
//
//	azva_iterate_list(colorsAndThings, theBlk);   return [words nmap:^id (id o, NSUI i) { NSS *n = $(@"%@", o); NSC *c  = [colors normal:i];  n.logForeground = c.isDark ? c.invertedColor : c;  return n; }];
//}
//void logNilTerminatedListOfColorsAndStrings ( const char*pretty, id colorsAndThings,...) 	{
//
//	__block NSMA *colors = NSMA.new;  __block NSMA *words  = NSMA.new;
//	AZVA_Block theBlk = ^(id it) {								//			AZVA_Block sort   = ^(id it) {
//		[it ISKINDA:NSC.class] ? [colors addObject:[it copy]] :
//		[it ISKINDA:NSS.class] ? [words  addObject:[it copy ]] :
//		[it ISKINDA:NSA.class] ? [(NSA*)it each:^(id obj) {
//		   [obj ISKINDA:NSC.class] ? [colors addObject:[obj copy]] :
//		   [obj ISKINDA:NSS.class] ? [words  addObject:[obj copy]] :
//		   [obj respondsToString:@"stringValue"] ? [words addObject:[[obj stringValue]copy]] : nil;
//		}]:[ it respondsToString:@"stringValue"] ? [words addObject:[[ it stringValue]copy]] : nil;
//	};
//	azva_iterate_list(colorsAndThings, theBlk);
//	//	NSLog(@"colors:%ld:%@ words:%ld:%@", colors.count, colors, words.count, words);
//	//	NSA *colors, *words, *colorStringArray;  colorStringArray = colors1strings2(colorsAndThings); colors = colorStringArray[0]; words = colorStringArray[1];
//	LogEnv e =  AZLogEnv(); __block NSUI ctr = 0;
//	if (!colors.count) colors = @[WHITE].mutableCopy;
//	if (!words.count) {  printf( "WARNING, NO WORDS TO PRINT: %s", pretty); return; }
//	fprintf(stderr, "%s", //e != LogEnvXcodeColor ? [words componentsJoinedByString:@" "].UTF8String :
//
//	 [[words reduce:LOG_CALLER_VERBOSE ? @"LOGCOLORS: ":@"" withBlock:^NSS*(NSS *sum,NSS *o) {
//															NSC  *c 				= [colors normal:ctr];	ctr++;
//															o.logForeground 	= c.isDark ? [c colorWithBrightnessMultiplier:2]: c;
//															return [sum withString:o.colorLogString];
//														}]UTF8String]);
//}
//void WEBLOG (id format, ...) {
//
//	NSLogConsoleView* e = (NSLogConsoleView*)[NSLogConsole.sharedConsole webView];
//	[e logString: file:(char*)filename lineNumber:(int)lineNum];
//	
//}
//void _AZColorLog		( id color, const char *filename, int line, const char *funcName, id format, ...) {
//
//	if (!gPal) gPal = NSC.randomPalette;
//   va_list argList;  va_start(argList,format);	__block NSS *lineNum,*path,*mess,*func,*output; __block NSUI numberofspaces;
//
//	path	= $(@"[%@]", $UTF8(filename).lastPathComponent);
//	mess 	= [NSS stringWithFormat:format arguments:argList];
//
//		//:fl lineNumber:ln];setFakeStdin:$(@"%@%i%s%@",path, line, funcName, mess)];
//	AZLogEnv() == LogEnvXcodeColor ? ^{
//
//		path.logForeground 		= gPal [0];
//		lineNum						= $( @":%i ", line );
//		lineNum.logForeground 	= gPal [1];
//		numberofspaces		 		=      10;	//MIN(MAX((paddedString.length - concat.length), 2), 20);
//		func  						= [$UTF8(funcName) truncateInMiddleToCharacters:30];
//		func.logForeground 		= [gPal[2] darker];
//		//	output = $(@"%@%@", path.colorLogString, lineNum.colorLogString);   //, [NSS spaces:numberofspaces]);
//		NSC* messColor				= color 	? : gPal [4];
//		mess.logForeground      = messColor;
//		mess 							= mess.colorLogString ?: mess;  //  actual log message
//
//		output 						= [mess paddedTo:120];//withString:output];
//		output 						= [output withString:func.colorLogString];
//		//	[func containsAnyOf:@[@"///Color"]] ? @"" : func.colorLogString];	//	fflush(stdout);
//		fprintf(stderr, "%s\n", output.UTF8String);
//
//	}() : ^{ fprintf(stderr, "%s", $(/*@"[%@]:%i @"%s*/ @"%@\n",/* path, line, funcName,*/ mess).UTF8String); return; }();
////										XCODE_COLORS_ESCAPE @"fg140,140,140;"   @":%i"  XCODE_COLORS_RESET
////										XCODE_COLORS_ESCAPE @"fg109,0,40;"  @" %s "		 XCODE_COLORS_RESET
////										XCODE_COLORS_ESCAPE @"%@" "%@"XCODE_COLORS_RESET @"\n",
////										path,
////										line, funcName,
////										colorString,
////										mess)
////	 toLog.UTF8String);//
//	va_end(argList);
//} // ACTIVE NSLOG

/*
void _AZSimpleLog( const char *file, int lineNumber, const char *funcName, NSString *format, ... ) {
void LOGWARN(NSString *format,...) {
	va_list argList; va_start (argList, format);
	NSS* full = [NSS.alloc initWithFormat:format arguments:argList];
	NSLog(XCODE_COLORS_ESCAPE @"fg218,147,0;" "%@" XCODE_COLORS_RESET, full);
}
NSColor description
   void _AZSimpleLog( const char *file, int lineNumber, const char *funcName, NSString *format, ... ) {
		static NSA* colors;  colors = colors ?: NSC.randomPalette;
		static NSUI idx = 0;
		va_list   argList;
		va_start (argList, format);
		NSS *path   = [$UTF8(file) lastPathComponent];
		NSS *mess   = [NSString.alloc initWithFormat:format arguments:argList];
		NSS *toLog;
		char *xcode_colors = getenv(XCODE_COLORS);
		if (getenv(XCODE_COLORS) && (strcmp(xcode_colors, "YES") == 0))
		{
				//	NSS *justinfo = $(@"[%s]:%i",path.UTF8String, lineNumber);
				//	NSS *info   = [NSString stringWithFormat:@"word:%-11s rank:%u", [word UTF8String], rank];
				NSS *info   = $( XCODE_COLORS_ESCAPE @"fg82,82,82;" @" [%s]" XCODE_COLORS_RESET
														 XCODE_COLORS_ESCAPE @"fg140,140,140;" @":%i" XCODE_COLORS_RESET	, path.UTF8String, lineNumber);
				int max			 = 120;
				int cutTo			= 22;
				BOOL longer	 = mess.length > max;
				NSC *c = [colors normal:idx];
						c = c.isDark ? [c colorWithBrightnessMultiplier:1.5] : [c colorWithBrightnessMultiplier:.7];
				NSS *cs = $(@"%i,%i,%i",(int)(c.redComponent *255), (int)(c.greenComponent *255), (int)(c.blueComponent *255)); idx++;
				NSS* nextLine   = longer ? $(XCODE_COLORS_ESCAPE @"fg%@;" XCODE_COLORS_RESET @"\n\t%@\n", cs, [mess substringFromIndex:max - cutTo]) : @"\n";
				mess				= longer ? [mess substringToIndex:max - cutTo] : mess;
				int add = max - mess.length - cutTo;
				if (add > 0) {
						NSS *pad = [NSS.string stringByPaddingToLength:add withString:@" " startingAtIndex:0];
						info = [pad stringByAppendingString:info];
				}
				toLog   = $(XCODE_COLORS_ESCAPE @"fg%@;" @"%@" XCODE_COLORS_RESET @"%@%@", cs, mess, info, nextLine);
						// XcodeColors is installed and enabled!
				}
				else {
						NSS *info = $( XCODE_COLORS_ESCAPE @"fg82,82,82;" @"  [%s]" XCODE_COLORS_RESET
														  XCODE_COLORS_ESCAPE @"fg140,140,140;" @":%i" XCODE_COLORS_RESET	, path.UTF8String, lineNumber);
						toLog = $(@"%@ %s \n", info, mess.UTF8String);
		}

		fprintf ( stderr, "%s", toLog.UTF8String);//
		va_end  (argList);

		//	NSS *toLog  = $( XCODE_COLORS_RESET	@"%s" XCODE_COLORS_ESCAPE @"fg82,82,82;" @"%-70s[%s]" XCODE_COLORS_RESET
		//									XCODE_COLORS_ESCAPE @"fg140,140,140;" @":%i\n" XCODE_COLORS_RESET	,
		//									mess.UTF8String, "", path.UTF8String, lineNumber);

		//	NSLog(XCODE_COLORS_ESCAPE @"bg89,96,105;" @"Grey background" XCODE_COLORS_RESET);
		//	NSLog(XCODE_COLORS_ESCAPE @"fg0,0,255;"
		//			XCODE_COLORS_ESCAPE @"bg220,0,0;"
		//			@"Blue text on red background"
		//			XCODE_COLORS_RESET);

 */

