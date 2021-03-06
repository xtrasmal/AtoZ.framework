

#import <objc/runtime.h>
#import "extobjc_OSX/extobjc.h"
#import "AtoZUmbrella.h"
#import "AtoZCategories.h"


@protocol IBSingleton <NSObject>

@optional
- (void) setUp;
@concrete
+ (id) allocWithZone: (NSZone*)zone;
+ (instancetype)sharedInstance;
+ (id) alloc;
+ (id) _alloc;
- (id) init;
- (id) _init;
@end


@protocol AZPlistRepresentation <NSObject>
@concrete
@property (RONLY) NSD* plistRepresentation;
@end

@interface AZObject : NSObject <NSCoding, NSCopying, NSMutableCopying, AZPlistRepresentation>
@end

@interface AZArray : NSObject

+ (AZArray*)sharedArray;

- (void) addObject:(id)o;
- (NSUI) countOfObjects;
-   (id) objectInObjectsAtIndex:(NSUInteger)index;
@end


/*

@interface AZObject : NSObject <NSCoding,NSCopying,NSFastEnumeration>
@property (strong) id representedObject;
@property (copy) NSArray *keys;

// Shared instance is the object modified after each key change
//+ (AZObject*)sharedInstance;

//	After being notified of change to the shared instance,
//	call this to get last modified key of last modified instance
//+ (AZObject*)lastModifiedInstance;
//+ (NSString*)lastModifiedKey;
@property (nonatomic, retain) NSString *lastModifiedKey;
@property (nonatomic, retain) AZObject *lastModifiedInstance;
@property (nonatomic, retain) AZObject *sharedInstance;
@property (nonatomic, retain) NSString *uniqueID;
@end

@interface NSObject (NSCoding)

- (void) autoEncodeWithCoder: (NSCoder*)coder;
- (void) autoDecode:				(NSCoder*)coder;
//- (NSD*) properties;
- (NSD*) autoEncodedProperties;
@end
*/
