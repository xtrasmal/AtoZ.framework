

#define PROXY_DECLARE(__NAME__)\
	@interface __NAME__ : NSProxy @end
	

#define PROXY_DEFINE_BLOCK(__NAME__,__BACKING_CLASS__,__BACKING_BLOCK__) \
@implementation __NAME__ { __BACKING_CLASS__*backing; } \
- (id) init 	{ backing = (__BACKING_CLASS__*)__BACKING_BLOCK__(backing);  return self;	}\
- (NSMethodSignature*) methodSignatureForSelector:(SEL)sel 	{ return [backing methodSignatureForSelector:sel] ?: nil;	}\
- (void)forwardInvocation:(NSInvocation *)invocation 			{ [invocation invokeWithTarget: backing];							}\
- (BOOL)respondsToSelector:(SEL)aSelector 						{ return [backing respondsToSelector:aSelector]; 				}\
- (BOOL) conformsToProtocol:(Protocol *)p { return [@[@protocol(NSCopying),@protocol(NSObject)] containsObject:p]; 		}\
@end

#define PROXY_DEFINE(__NAME__,__BACKING_CLASS__) \
	PROXY_DEFINE_BLOCK(__NAME__,__BACKING_CLASS__,^(__BACKING_CLASS__*setter){ return setter = __BACKING_CLASS__.new; })

// Override some of NSProxy's implementations to forward them...
 


#define AZBindWDefVs(binder,binding,objectToBindTo,keyPath)   											\
	[binder bind:binding toObject:objectToBindTo withKeyPathUsingDefaults:keyPath]

#define AZBindButNil(binder,binding,objectToBindTo,keyPath,nilValuecase) 							\
	[binder bind:binding toObject:objectToBindTo withKeyPath:keyPath nilValue:nilValuecase]

#define AZBindTransf(binder,binding,objectToBindTo,keyPath,transformer)								\
	[binder bind:binding toObject:objectToBindTo withKeyPath:keyPath  transform:transformer]

#define AZBindNegate(binder,binding,objectToBindTo,keyPath)												\
	[binder bind:binding toObject:objectToBindTo withNegatedKeyPath:keyPath]

@interface NSObject (NibLoading)
+ (INST) loadFromNib;
@end
@interface NSObject (HidingAssocitively)
@property BOOL folded;
@end

@interface NSObject (GCD)
- (void)performOnMainThread:(void(^)(void))block wait:(BOOL)wait;
- (void)performAsynchronous:(void(^)(void))block;
- (void)performAfter:(NSTimeInterval)seconds block:(void(^)(void))block;
@end

@interface NSObject (ClassAssociatedReferences)
+ (void)		setValue:(id)value forKey:(NSS*)key;
+   (id) valueForKey:(NSS*)key;
@end

#define invokeSupersequent(...)  ([self getImplementationOf:_cmd after:impOfCallingMethod(self, _cmd)]) (self, _cmd, ##__VA_ARGS__)
IMP impOfCallingMethod(id lookupObject, SEL selector);
@interface NSObject (SupersequentImplementation)
// Lookup the next implementation of the given selector after the  default one. Returns nil if no alternate implementation is found.
- (IMP)getImplementationOf:(SEL)lookup after:(IMP)skip;
@end

/* AWEOME!!

	[@["methodOne", @"methodtwo"] each:^(id x) {
		[Foo addMethodForSelector:NSSelectorFromString(x) typed:"v@:" implementation:^(id self,SEL _cmd) {
			NSLog(@"Called -[%@ %@] with void return", [self class], NSStringFromSelector(_cmd));
		}];
		[foo performSelector:stringified];
	}];
	[@["returnWithInputOne:", @"returnWithInputTwo:"] eachWithIndex:^(id obj, NSUI idx){
		[Foo addMethodForSelector:stringified typed:"@@:" implementation:^id(id self, SEL _cmd) {
			return NSS.randomDicksonism;
		}];
		NSLog(@"%@", [foo performSelector:stringified]);
	}
	[Foo addMethodForSelector:@selector(idreturn) typed:"@@:" implementation:^ id (id self, SEL _cmd) {
		return [NSString stringWithFormat:@"Called -[%@ %@] with id return", [self class], NSStringFromSelector(_cmd)];
	}];
	NSLog(@"%@", [foo idreturn]);
}
*/

@interface 				 NSObject   (AddMethod)
+ (BOOL)   addMethodFromString :	(NSS*)s withArgs:(NSA*)a;  //NEEDSWORK NSMethodSignature
+ (BOOL)  addMethodForSelector : (SEL)selector typed:(const char*)types implementation:(id)blockPtr;
- (NSA*)  methodSignatureArray : (SEL)selector;
+ (NSA*)  methodSignatureArray : (SEL)selector;
- (NSA*) methodSignatureString : (SEL)selector;
+ (NSA*) methodSignatureString : (SEL)selector;
@end
#define PLCY objc_AssociationPolicy
@interface 						 NSObject   (AssociatedValues)
- (void)          setAssociatedValue : (id)val
										forKey : (NSS*)k; 	/* DEFAULTS TO OBJC_ASSOCIATION_RETAIN */
- (void)          setAssociatedValue : (id)val
									   forKey : (NSS*)k
										policy : (PLCY)p;
-   (id)       associatedValueForKey : (NSS*)k
									  orSetTo : (id)def
							         policy : (PLCY)p;
-   (id)       associatedValueForKey :	(NSS*)k
							        orSetTo : (id)def; 	/* DEFAULTS TO OBJC_ASSOCIATION_RETAIN_NONATOMIC */
-   (id)       associatedValueForKey :	(NSS*)k; 	/* or nil! */
- (void) removeAssociatedValueForKey :	(NSS*)k;
- (BOOL)    hasAssociatedValueForKey :	(NSS*)k;
- (void)   removeAllAssociatedValues ;
@end
//	- (void)registerObservation{	[observee addObserverForKeyPath:@"someValue" task:^(id obj, NSDictionary *change) {	NSLog(@"someValue changed: %@", change);  }]; }
//	-(void)observeKeyPath:(NSS*)keyPath;
//	@interface NSObject (AMBlockObservation)

@interface AZValueTransformer : NSValueTransformer
+ (instancetype)transformerWithBlock:(id (^)(id value))block;
@end

@interface NSObject (AtoZ)

@property (readonly) NSS * uuid; // Associated with custom getter
@property (strong) 	NSMA		* propertiesThatHaveBeenSet;

- (BOOL) valueWasSetForKey:(NSS*)key;


@property NSMA* undefinedKeys; /* USAGE: 	

	id scoop = @"poop";
	[scoop setValue:@2 forKey:@"farts"];
	LOG_EXPR( scoop[@"undefinedKeys"] ); 	-> ( farts ) 												*/

+ (instancetype) instanceWithProperties:(NSS*)firstKey,... NS_REQUIRES_NIL_TERMINATION;	/*  USAGE:	
	
	id whatever = [CAL instanceWithProperties:@"stupid", @(YES), @"sexy", @(NO), nil];  	*/

- (void) performBlockWithVarargsInArray:(void(^)(NSO*_self,NSA*varargs))block, ...NS_REQUIRES_NIL_TERMINATION; /*	USAGE:  	

	[NSS.randomBadWord performBlockWithVarargsInArray:^(NSO*_self,NSA*args){ 
					LOG_EXPR([args map:^(id o){ return [o withString:_self]; }]); 			}, @"Fuck my ", @"What a huge ", nil];
	-> ( "Fuck my shagger", "What a huge shagger" )	
*/


/*  USAGE: 	[@"Apple is "performBlockEachVararg:^(NSO*_self,id v){ LOG_EXPR([_self withString:v]); }, @"Whatever!", @"Sexy", @"fruitful", nil];
	-> Apple is Whatever!	-> Apple is Sexy	-> Apple is fruitful */
- (void) performBlockEachVararg:(void(^)(NSO*_self,id obj))block, ... NS_REQUIRES_NIL_TERMINATION;

- (void) bind:(NSA*)paths toObject:(id)o withKeyPaths:(NSA*)objKps;
- (void) bindToObject:(id)o withKeyPaths:(NSA*)objKps;
- (void)    b:(NSS*)b 		 tO:(id)o 			wKP:(NSS*)kp 		  o:(NSD*)opt;
/*
-(void)mouseDown:(NSEvent*)theEvent;	{
    NSColor* newColor = //mouse down changes the color somehow (view-driven change)
    self.color = newColor;
    [self propagateValue:newColor forBinding:@"color"];	} */
	 
-(void) propagateValue:(id)value forBinding:(NSString*)binding;

// Calls -[NSObject bind:binding toObject:object withKeyPath:keyPath options:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSContinuouslyUpdatesValueBindingOption, nil]]
- (void)bind:(NSString*)binding toObject:(id)object withKeyPathUsingDefaults:(NSS*)keyPath;
// Calls -[NSO bind:b toObject:o withKeyPath:kp options:@{ NSContinuouslyUpdatesValueBindingOption: @(YES), NSNullPlaceholderBindingOption: nilValue}];
- (void)bind:(NSString *)binding toObject:(id)object withKeyPath:(NSString *)keyPath nilValue:(id)nilValue;
// Same as `-[NSObject bind:toObject:withKeyPath:] but also transforms values using the given transform block.
- (void)bind:(NSS*)binding toObject:(id)o withKeyPath:(NSS*)kp transform:(id (^)(id value))transformBlock;
// Same as `-[NSObject bind:toObject:withKeyPath:] but the value is transformed by negating it.
- (void)bind:(NSS*)binding toObject:(id)o withNegatedKeyPath:(NSS*)keyPath;



-(id) filterKeyPath:(NSS*)kp recursively:(id(^)(id))mayReturnOtherObjectOrNil;

- (void)performBlock:(void (^)())block;
//- (void)performBlock:(void (^)())block afterDelay:(NSTimeInterval)delay;

- (NSS*) xmlRepresentation;
- (BOOL) saveAs:(NSS*)file;
// adapted from the CocoaDev MethodSwizzling page

//+ (BOOL) exchangeInstanceMethod:(SEL)sel1 withMethod:(SEL)sel2;
//+ (BOOL) exchangeClassMethod:(SEL)sel1 withMethod:(SEL)sel2;

- (NSURL*)urlified;

//-(void) propagateValue:(id)value forBinding:(NSString*)binding;

-(void) 	DDLogError;
-(void) 	DDLogWarn;
-(void) 	DDLogInfo	;
-(void) 	DDLogVerbose;

- (void) bindArrayKeyPath:(NSS*)array toController:(NSArrayController*)controller;

- (id) performString:(NSS*)string;
- (id) performString:(NSS*)string withObject:(id) obj;

//- (id)performSelectorARC:(SEL)selector withObject:(id)obj;
//- (id)performSelectorARC:(SEL)selector withObject:(id)one withObject:(id)two;

//- (NSS*) instanceMethods;
//- (NSA*) instanceMethodArray;
- (NSA*) instanceMethodNames;
//+ (NSA*) instanceMethods;
- (NSS*) instanceMethodsInColumns;

/*
	block1 one = ^id(void){ id a= @"a"; return a;};
	block1 oneA = ^id(void){ id b= @"a"; return b;};
	block2 two = ^id(id amber) { return amber;   };
	
	LOG_EXPR([oneA isKindOfBlock:one]); = YES
	LOG_EXPR([oneA isKindOfBlock:two]); = NO
*/
- (NSS*) blockDescription;
- (BOOL) isKindOfBlock:(id)anotherBlock;
- (NSMethodSignature*) blockSignature;

/* USAGE:
-(void)mouseDown:(NSEvent*)theEvent {
	NSColor* newColor = //mouse down changes the color somehow (view-driven change)
	self.color = newColor;
	[self propagateValue:newColor forBinding:@"color"];  } */
//-(void) propagateValue:(id)value forBinding:(NSString*)binding;
//- (NSA*) settableKeys;
//- (NSA*) keysWorthReading;
//-(void) setWithDictionary:(NSD*)dic;

/*
[WSLObjectSwitch switchOn:<id object> defaultBlock:^{ NSLog (@"Dee Fault"); }
					cases:	@"sausage", ^{ NSLog (@"Hello, sweetie."); },
							@"test",	^{ NSLog (@"A test"); }, nil];
*/

-(BOOL) isKindOfAnyClass:(NSA*)classes;
typedef void (^caseBlock)();
+(void)switchOn:(id<NSObject>)obj cases:casesList, ...;
+(void)switchOn:(id<NSObject>)obj
   defaultBlock:(caseBlock)defaultBlock
		  cases:casesList, ...;


	// To add array style subscripting:
- (void)setObject:(id)obj atIndexedSubscript:(NSUInteger)idx; // setter
- (id)objectAtIndexedSubscript:(NSUInteger)idx;			   // getter

	// To add dictionary style subscripting
- (void)setObject:(id)obj forKeyedSubscript:(id <NSCopying>)key; // setter
- (id)objectForKeyedSubscript:(id)key;						   // getter
- (void)performBlock:(void (^)(void))block afterDelay:(NSTimeInterval)delay;
- (void)fireBlockAfterDelay:(void (^)(void))block;


+ (NSMA*)newInstances:(NSUI)count;

//- existsOrElse:(id(^)(BOOL yesOrNO))block {
//
//}
//+(void)immediately:(void (^)())block
//{
//	[self begin];
//	[self setDisableActions:YES];
//	block();
//	[self commit];
//}
	// Finds all properties of an object, and prints each one out as part of a string describing the class.
//+ (NSString*)  autoDescribeWithClassType:	(Class) classType;

+ (NSString*)  autoDescribe;
- (NSString*)  autoDescribe;


- (void) setWindowPosition:	(AZWindowPosition) pos;
- (AZWindowPosition) windowPosition;

/*	Now every instance (of every class) has a dictionary, where you can store your custom attributes. With Key- Value Coding you can set a value like this:

//[myObject setValue: attributeValue forKeyPath: @"dictionary.attributeName"]

	And you can get the value like this:
//[myObject valueForKeyPath: @"dictionary.attributeName"]

	That even works great with the Interface Builder and User Defined Runtime Attributes.

	Key Path				   Type					 Value
	dictionary.attributeName   String(or other Type)	attributeValue
*/
- (NSMutableDictionary*) getDictionary;

//- (BOOL) debug;
@end

@interface NSObject (SubclassEnumeration)
+(NSA*) subclasses;
@end

@interface NSString (VARARGLOGGING)

- (NSS*)formatWithArguments:(NSA*)arr;
+ (NSS*)evaluatePseudoFormat:(NSS*)fmt withArguments:(NSA*)arr;
//- (void) log:(id) firstObject, ...;
@end

@interface NSObject (AG)

/* 
- (void)doSomethingWithFloat:(float)f;														// Example 1
	float value = 7.2661; 																		// Create a float
	float *height = &value; 																	// Create a _pointer_ to the float (a floater?)
	[self performSelector:@selector(doSomethingWithFloat:) withValue:height]; 	// Now pass the pointer to the float
	free(height); 																					// Don't forget to free the pointer!

- (int)addOne:(int)i;																			// Example 2
	int ten = 10; 																					// As above
	int *i = &ten;
	int *result = [self performSelector:@selector(addOne:) withValue:i]; 		// Returns a __pointer__ to the int
	NSLog(@"result is %d", *result); 														// Remember that it's a pointer, so keep the *!
 	free(result);

- (NSObject *)objectIfTrue:(BOOL)b;															// Example 3
	BOOL y = YES; 																					// Same as previously
 	BOOL *valid = &y;
 	void **p = [self performSelector:@selector(objectIfTrue:) withValue:valid];// Returns a pointer to an NSObject (standard Objective-C behaviour)
 	NSObject *obj = (__bridge NSObject *)*p;												// bridge the pointer to Objective-C
 	NSLog(@"object is %@", obj);
 	free(p);

- (NSS*)strWithView:(UIView *)v;														// Example 4
	UIView *view = [[UIView alloc] init];
 	void **p = [self performSelector:@selector(strWithView:) withValue:&view];
	NSString *str = (__bridge NSString *)*p;
	NSLog(@"string is %@", str);
	free(p);
*/

- (void*)performSelector:(SEL)selector withValue:(void *)value;
- (void*)performSelector:(SEL)selector withValue:(void *)value andValue:(void*)value2;


//	void **pp = [RED performSelector:@selector(colorWithSaturation:brightness:) withValues:oneP,twoP, nil];
//	NSLog(@"string is %@", (__bridge NSC*)*pp);
//	free(pp)
- (void*) performSelector:(SEL)aSelector withValues:(void *)context, ...;

+ (NSS*) stringFromType:(const char*)type;

//- (NSValue*) invoke:(SEL)selector withArgs:(NSA*)args;

/*
	NSView *vv = [NSV.alloc init];
 	[vv invokeSelector:@selector(setFrame:), AZVrect(AZRectFromDim(100))];
 	NSLog(@"%@",AZStringFromRect(vv.frame)); -> [x.0 y.0 [100 x 100]]
*/

- (NSValue*) invokeSelector:(SEL)selector, ...;

- (void) log;
- (void) logInColor:(NSC*)color;

//- (NSMethodSignature*) methodSignatureForSelector:(SEL)selector;
//- (void)forwardInvocation:(NSInvocation *)invocation;


/**	Additional performSelector signatures that support up to 7 arguments.	*/
- (id)performSelector:(SEL)selector withObject:(id)p1 withObject:(id)p2 withObject:(id)p3;
- (id)performSelector:(SEL)selector withObject:(id)p1 withObject:(id)p2 withObject:(id)p3
		   withObject:(id)p4;
- (id)performSelector:(SEL)selector withObject:(id)p1 withObject:(id)p2 withObject:(id)p3
		   withObject:(id)p4 withObject:(id)p5;
- (id)performSelector:(SEL)selector withObject:(id)p1 withObject:(id)p2 withObject:(id)p3
		   withObject:(id)p4 withObject:(id)p5 withObject:(id)p6;
- (id)performSelector:(SEL)selector withObject:(id)p1 withObject:(id)p2 withObject:(id)p3
		   withObject:(id)p4 withObject:(id)p5 withObject:(id)p6 withObject:(id)p7;


- (NSS*)segmentLabel;

- (id) responds:(NSS*)selStr do:(id)doBlock;

BOOL respondsTo(id obj, SEL selector);
BOOL respondsToString(id obj,NSS* string);

-(SEL) firstResponsiveSelFromStrings:(NSA*)selectors;
-(NSS*) firstResponsiveString:(NSA*)selectors;

- (BOOL) respondsToString:(NSS*)string;
- (id) respondsToStringThenDo: (NSS*)string withObject:(id)obj withObject:(id)objtwo;
- (id) respondsToStringThenDo: (NSS*)string withObject:(id)obj;
- (id) respondsToStringThenDo: (NSS*)string;

- (IBAction)increment:(id)sender;
- (IBAction)setFromSegmentLabel:(id)sender;
- (IBAction)performActionFromSegmentLabel:(id)sender;

- (IBAction)performActionFromLabel:(id)sender;

//- (BOOL) respondsToSelector:	(SEL) aSelector;

+ (NSDictionary*) classPropsFor:	(Class) klass;
//- (NSA*) methodDumpForClass:	(NSString*) Class;
+ (NSA*) classMethods;
- (NSS*) methods;

- (NSString*) stringFromClass;

- (void) setIntValue:	(NSInteger) i forKey:	(NSString*) key;
- (void) setIntValue:	(NSInteger) i forKeyPath:	(NSString*) keyPath;

- (void) setFloatValue:	(CGFloat) f forKey:	(NSString*) key;
- (void) setFloatValue:	(CGFloat) f forKeyPath:	(NSString*) keyPath;

- (BOOL) isEqualToAnyOf:	(id<NSFastEnumeration>) enumerable;

- (void) fire:	(NSString*) notificationName;
- (void) fire:	(NSString*) notificationName userInfo:	(NSDictionary*) userInfo;


- (id) observeName:	(NSString*) notificationName 
	  usingBlock:	(void (^) (NSNotification*) ) block;

- (void) observeObject:	(NSObject*) object
			 forName:	(NSString*) notificationName
			 calling:	(SEL) selector;

-(void)observeName:(NSS*) notificationName
		   calling:(SEL)selector;

- (void) stopObserving:	(NSObject*) object forName:	(NSString*) notificationName;

- (void) observeNotificationsUsingBlocks:(NSS*) firstNotificationName, ... NS_REQUIRES_NIL_TERMINATION;


// This awesome method was found at Stackoverflow From Rob Mayoff - http://stackoverflow.com/users/77567/rob-mayoff
// Initial Solution by Scott Thompson - http://stackoverflow.com/users/415303/scott-thompson http://stackoverflow.com/a/7933931/1320374

#define PerformSelectorWithoutLeakWarning(Stuff) do { \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"") \
Stuff; \
_Pragma("clang diagnostic pop") \
} while (0)

- (BOOL) canPerformSelector: (SEL)aSelector;
- (id) performSelectorSafely:(SEL)aSelector;
- (id) performSelectorWithoutWarnings:(SEL)aSelector;

- (id) performSelectorWithoutWarnings:(SEL) aSelector withObject:(id)obj;
- (id) performSelectorWithoutWarnings:(SEL)aSelector withObject:(id)obj withObject:(id)obj2;
- (void) performSelector:	(SEL) aSelector afterDelay:	(NSTimeInterval) seconds;
- (void) addObserver:	(NSObject*) observer forKeyPath:	(NSString*) keyPath;
- (void) addObserver:	(NSObject*) observer 
	   forKeyPaths:	(id<NSFastEnumeration>) keyPaths;
- (void) removeObserver:	(NSObject*) observer 
		  forKeyPaths:	(id<NSFastEnumeration>) keyPaths;

- (void)az_willChangeValueForKeys:(NSA*)keys;//	(id<NSFastEnumeration>) keys;
- (void)az_didChangeValueForKeys:(NSA*)keys;//	(id<NSFastEnumeration>) keys;
- (void) triggerChangeForKeys:(NSA*)keys;

#pragma mark - PropertyArray
//- (NSDictionary*) dictionaryWithValuesForKeys;
//- (NSA*)  allKeys;

/** Example:
	MyObject *obj = [[MyObject alloc] init];
	obj.a = @"Hello A";  //setting some values to attrtypedef existing new;ibutes
	obj.b = @"Hello B";

	//dictionaryWithValuesForKeys requires keys in NSArray. You can now
	//construct such NSArray using `allKeys` from NSObject(PropertyArray) category
	NSDictionary *objDict = [obj dictionaryWithValuesForKeys: [obj allKeys]];

	//Resurrect MyObject from NSDictionary using setValuesForKeysWithDictionary
	MyObject *objResur = [[MyObject alloc] init];
	[objResur setValuesForKeysWithDictionary: objDict];
*/

#pragma mark - SetClass
- (void) setClass:	(Class) aClass;	// In your custom class
+ (instancetype) customClassWithProperties:(NSD*) properties;
- (instancetype) initWithProperties:		 (NSD*) properties;
- (instancetype) initWithDictionary:		 (NSD*) properties;
+ (instancetype) instanceWithDictionary:	 (NSD*) properties;
+ (instancetype) newFromDictionary:			 (NSD*) properties;

- (NSA*) objectKeys;
- (NSA*) primitiveKeys;

@end

/// USAGE:  [someDictionary mapPropertiesToObject: someObject];
@interface NSDictionary  (PropertyMap)

- (void) mapPropertiesToObject:	(id) instance;

@end

@interface NSObject (KVCExtensions)

- (void) setPropertiesWithDictionary:(NSD*)dictionary;
- (BOOL) canSetValueForKey:	   (NSString*) key;
- (BOOL) canSetValueForKeyPath: (NSString*) keyPath;

@end

@interface NSObject (ImageVsColor)

- (NSC*)colorValue;
- (NSIMG*)imageValue;

@end
/*
@interface NSObject (NoodlePerformWhenIdle)

- (void)performSelector:(SEL)aSelector withObject:(id)anArgument afterSystemIdleTime:(NSTimeInterval)delay;

- (void)performSelector:(SEL)aSelector withObject:(id)anArgument afterSystemIdleTime:(NSTimeInterval)delay withinTimeLimit:(NSTimeInterval)maxTime;

@end
*/


 // thanks Landon Fuller
#define VERIFIED_CLASS(className) ((className *) NSClassFromString(@"" # className))

@interface NSObject (SadunUtilities)

// Return all superclasses of object
- (NSA*) superclasses;

// Selector Utilities
- (NSInvocation *) invocationWithSelectorAndArguments: (SEL) selector,...;
- (BOOL) performSelector: (SEL) selector withReturnValueAndArguments: (void *) result, ...;
- (const char *) returnTypeForSelector:(SEL)selector;

// Request return value from performing selector
- (id) objectByPerformingSelectorWithArguments: (SEL) selector, ...;
- (id) objectByPerformingSelector:(SEL)selector withObject:(id) object1 withObject: (id) object2;
- (id) objectByPerformingSelector:(SEL)selector withObject:(id) object1;
- (id) objectByPerformingSelector:(SEL)selector;

// Delay Utilities
- (void) performSelector: (SEL)select withCPointer:(void*)cPointer afterDelay:(NSTI)delay;
- (void) performSelector: (SEL)select withInt: 	(int)iVal  			 afterDelay:(NSTI) delay;
- (void) performSelector: (SEL)select withFloat:(CGF)fVal  		    afterDelay:(NSTI) delay;
- (void) performSelector: (SEL)select withBool: (BOOL)bVal         afterDelay:(NSTI) delay;
- (void) performSelector: (SEL)select 							          afterDelay:(NSTI) delay;
- (void) performSelector: (SEL)select withDelayAndArguments: (NSTI)delay,...;

// Return Values, allowing non-object returns
- (id) valueByPerformingSelector:(SEL)selector withObject:(id) object1 withObject: (id) object2;
- (id) valueByPerformingSelector:(SEL)selector withObject:(id) object1;
- (id) valueByPerformingSelector:(SEL)selector;

// Access to object essentials for run-time checks. Stored by class in dictionary.
@property (readonly) NSDictionary *selectors, *properties, *ivars, *protocols;

// Check for properties, ivar. Use respondsToSelector: and conformsToProtocol: as well
- (BOOL) hasProperty: (NSS*)propertyName;
- (BOOL) hasIvar: 	 (NSS*)ivarName;
+ (BOOL) classExists: (NSS*)className;
+   (id) instanceOfClassNamed:(NSS*)className;

// Attempt selector if possible
- (id) tryPerformSelector: (SEL) aSelector withObject: (id) object1 withObject: (id) object2;
- (id) tryPerformSelector: (SEL) aSelector withObject: (id) object1;
- (id) tryPerformSelector: (SEL) aSelector;

// Choose the first selector that the object responds to
- (SEL) chooseSelector: (SEL) aSelector, ...;
@end


//typedef void (^KVOFullBlock)(NSString *keyPath, id object, NSDictionary *change);
//@interface NSObject (NSObject_KVOBlock)
//- (id)addKVOBlockForKeyPath:(NSS*)inKeyPath options:(NSKeyValueObservingOptions)inOptions handler:(KVOFullBlock)inHandler;
//- (void)removeKVOBlockForToken:(id)inToken;
///// One shot blocks remove themselves after they've been fired once.
//- (id)addOneShotKVOBlockForKeyPath:(NSS*)inKeyPath options:(NSKeyValueObservingOptions)inOptions handler:(KVOFullBlock)inHandler;
//- (void)KVODump;
//@end

@interface AZBool : NSObject
@end


@interface 		     		 	  NSObject  (FOOCoding)

- (void) sV:(id)v fK:(id)k;  // setValue:forKey:
- (void) sV:(id)v fKP:(id)k; // setValue:forKeyPath:

-      (id)  		 initWithDictionary : (NSD*)dictionary;
-    (NSA*)        	     arrayForKey : (NSS*)key;
-    (NSA*)    	 		 arrayOfClass : (Class)objectClass forKey:(NSS*)key;
-    (NSA*)              arrayOfClass : (Class)objectClass;
-    (NSA*) arrayOfDictionariesForKey : (NSS*)key;
-    (NSA*)      arrayOfStringsForKey : (NSS*)key;

-    (BOOL)						boolForKey : (NSS*)key;

- (NSData*)			    		dataForKey : (NSS*)key;
- (NSDate*)				   	dateForKey : (NSS*)key;
-    (NSD*)  			dictionaryForKey : (NSS*)key;
-  (double)              doubleForKey : (NSS*)key;
-     (CGF) 				  floatForKey : (NSS*)key;
-     (NSI)             integerForKey : (NSS*)key;
-    (NSS*)              stringForKey : (NSS*)key;
-    (NSUI)     unsignedIntegerForKey : (NSS*)key;
-  (NSURL*)                 URLForKey : (NSS*)key;

- (id) mutableArrayValueForKeyOrKeyPath:(id)keyOrKeyPath;
- (id) valueForKeyOrKeyPath:(id)keyOrKeyPath transform:(THBinderTransformationBlock)tBlock;
- (id) valueForKeyOrKeyPath:(id)keyOrKeyPath;  //AZAddition
- (id) valueForKey:(NSS*)key assertingProtocol:(Protocol*)proto;  //AZAddition
- (id) valueForKey:(NSS*)key assertingClass:(Class)klass;
- (id) valueForKey:(NSS*)key assertingRespondsToSelector:(SEL)theSelector;
- (BOOL)contentsOfCollection:(id <NSFastEnumeration>)theCollection areKindOfClass:(Class)theClass;


@end

