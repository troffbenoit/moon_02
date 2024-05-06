//
//  Parser_3.h
//  Parser_3
//
//  Created by Stanley Benoit on 5/6/24.
//

#ifndef Parser_3_h
#define Parser_3_h

#import <Foundation/Foundation.h>

@interface FileScanner : NSObject {
    NSArray *_usbDrives; // Instance variable to store USB drives
    NSString *_customDirectoryPath; // Instance variable to store custom directory path
}

// Display the main menu
- (void)displayMainMenu;

// Validate a directory path
- (BOOL)validateDirectoryPath:(NSString *)directoryPath;

// Scan a custom directory
- (void)scanCustomDirectory:(NSString *)directoryPath;

// Set the custom directory path
- (void)setCustomDirectoryPath:(NSString *)path;

// Scan external USB drives
- (void)scanExternalUSBDrives;

// Scan the Documents directory
- (void)scanDocumentsDirectory;

// List files in a directory
- (void)listFilesInDirectory:(NSString *)directoryPath;

// Search for a keyword in a file
- (void)searchKeywordInFile:(NSString *)filePath;

// Restart the application
- (void)restartApplication;

// Handle post-save actions
- (void)handlePostSaveActions;

@end

#endif /* Parser_3_h */
