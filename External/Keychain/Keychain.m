//
// Keychain.h
//
// Based on code by Michael Mayo at http://overhrd.com/?p=208
//
// Created by Frank Kim on 1/3/11.
//

#import "Keychain.h"
#import <Security/Security.h>


@implementation Keychain

+ (void)saveString:(NSString *)inputString forKey:(NSString  *)account {
  NSParameterAssert(account);
  NSParameterAssert(inputString);

  NSMutableDictionary *query = [NSMutableDictionary dictionary];

  [query setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];
  [query setObject:account forKey:(__bridge id)kSecAttrAccount];
  [query setObject:(__bridge id)kSecAttrAccessibleWhenUnlocked
            forKey:(__bridge id)kSecAttrAccessible];

  OSStatus error = SecItemCopyMatching((__bridge CFDictionaryRef)query, NULL);

  NSData *inputData = [inputString dataUsingEncoding:NSUTF8StringEncoding];
  if (error == errSecSuccess) {
    // do update
    NSDictionary *attributesToUpdate =
        [NSDictionary dictionaryWithObject:inputData forKey:(__bridge id)kSecValueData];

    error = SecItemUpdate((__bridge CFDictionaryRef)query,
                          (__bridge CFDictionaryRef)attributesToUpdate);
    NSAssert1(error == errSecSuccess, @"SecItemUpdate failed: %ld", error);
  } else if (error == errSecItemNotFound) {
    // do add
    [query setObject:inputData forKey:(__bridge id)kSecValueData];

    error = SecItemAdd((__bridge CFDictionaryRef)query, NULL);
    NSAssert1(error == errSecSuccess, @"SecItemAdd failed: %ld", error);
  } else {
    NSAssert1(NO, @"SecItemCopyMatching failed: %ld", error);
  }
}

+ (NSString *)getStringForKey:(NSString *)account {
  NSParameterAssert(account);

  NSMutableDictionary *query = [NSMutableDictionary dictionary];

  [query setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];
  [query setObject:account forKey:(__bridge id)kSecAttrAccount];
  [query setObject:(id)kCFBooleanTrue forKey:(__bridge id)kSecReturnData];

  CFDataRef resultRef = nil;
  OSStatus error = SecItemCopyMatching((__bridge CFDictionaryRef)query,
                                        (CFTypeRef *)&resultRef);
  NSData* dataFromKeychain = (__bridge_transfer NSData*)resultRef;
  
  NSString *stringToReturn = nil;
  if (error == errSecSuccess)
      stringToReturn = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithData:dataFromKeychain encoding:NSUTF8StringEncoding]];
  return stringToReturn;
}

+ (void)deleteStringForKey:(NSString *)account {
  NSParameterAssert(account);

  NSMutableDictionary *query = [NSMutableDictionary dictionary];

  [query setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];
  [query setObject:account forKey:(__bridge id)kSecAttrAccount];

  OSStatus status = SecItemDelete((__bridge CFDictionaryRef)query);
  if (status != errSecSuccess)
    NSLog(@"SecItemDelete failed: %d", (int)status);
}

@end
