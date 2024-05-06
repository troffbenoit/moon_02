//
//  scanUSB.h
//  Parser_3
//
//  Created by Stanley Benoit on 5/13/24.
//

#ifndef scanUSB_h
#define scanUSB_h
@interface scanUSB : NSObject {
    NSArray *_usbDrives; // Instance variable to store USB drives
    NSString *_customDirectoryPath; // Instance variable to store custom directory path
    @public
    NSString *test;
}

- (void)scanExternalUSBDrives;
@end


#endif /* scanUSB_h */
