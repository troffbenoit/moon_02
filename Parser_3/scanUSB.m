//
//  scanUSB.m
//  Parser_3
//
//  Created by Stanley Benoit on 5/13/24.
//

#import <Foundation/Foundation.h>
#import "scanUSB.h"
#import "Parser_3.h"


@implementation scanUSB : NSObject

/*
 Scans for external USB drives connected to the system.
 This method retrieves a list of external USB drives connected
 to the system and allows the user to select one for further
 processing. It then calls the listFilesInDirectory method to
 list the files in the selected USB drive.
 */
- (void)scanExternalUSBDrives {
    FileScanner *fs;
    fs = [[FileScanner alloc] init];
    NSError *error;
    NSArray *paths = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:@"/Volumes" error:&error];
    if (error) {
        NSLog(@"Error: %@", [error localizedDescription]);
        // Handle the error appropriately, such as exiting the application or returning an error code
    } else {
        // Filter out '.DS_Store' file from the list of paths
        _usbDrives = [paths filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF != %@", @".DS_Store"]];
        
        if (_usbDrives == nil) {
            // Memory allocation error occurred during filtering
            NSLog(@"Memory allocation error while filtering paths.");
            // Handle the error appropriately
        } else {
            // Proceed with further processing using the filtered array
        }
    }
    
    // Display the list of USB drives
    printf("Found USB drives:\n");
    for (int i = 0; i < _usbDrives.count; i++) {
        printf("%d. %s\n", i + 1, [_usbDrives[i] UTF8String]);
    }
    
    // Prompt user for selection
    int selection;
    printf("Select a USB drive (1-%lu) or enter 0 to skip: ", (unsigned long)_usbDrives.count);
    scanf("%d", &selection);
    
    // Handle user selection
    if (selection > 0 && selection <= _usbDrives.count) {
        // Get the selected drive's directory path
        NSString *selectedDrive = _usbDrives[selection - 1];
        NSString *directoryPath = [NSString stringWithFormat:@"/Volumes/%@", selectedDrive];
        
        // List files in the selected drive's directory
        [fs listFilesInDirectory:directoryPath];
    } else if (selection == 0) {
        // User chooses to skip scanning USB drives
        printf("Skipping USB drive scanning.\n");
    } else {
        // Invalid selection
        printf("Invalid selection.\n");
    }
}
@end

