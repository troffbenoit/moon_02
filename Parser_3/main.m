//  main.m
//  Parser_3
//
//  Created by Stanley Benoit on 5/6/24.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#import "Parser_3.h"
#import "scanUSB.h"

@implementation FileScanner



- (void)displayMainMenu {
    int choice;
    printf("1. Scan for USB drives\n");
    printf("2. Scan Documents directory\n");
    printf("3. Enter custom directory path\n");
    printf("Enter your choice: ");
    scanf("%d", &choice);

    switch (choice) {
        case 1:
            [self scanExternalUSBDrives];
            break;
        case 2:
            [self scanDocumentsDirectory];
            break;
        case 3: {
            printf("Enter custom directory path: ");
            char customPath[256];
            scanf("%s", customPath);
            NSString *customDirectoryPath = [NSString stringWithUTF8String:customPath];
            [self setCustomDirectoryPath:customDirectoryPath]; // Set custom directory path

            if (![self validateDirectoryPath:customDirectoryPath]) {
                printf("Exiting...\n");
                exit(0); // Exit the program
            }

            [self scanCustomDirectory:customDirectoryPath]; // Scan custom directory
            break;
        }
        default:
            printf("Invalid choice.\n");
            break;
    }
}

- (BOOL)validateDirectoryPath:(NSString *)directoryPath {
    BOOL isDirectory;
    BOOL pathExists = [[NSFileManager defaultManager] fileExistsAtPath:directoryPath isDirectory:&isDirectory];
    if (pathExists && isDirectory) {
        return YES; // Valid directory path
    } else {
        printf("Invalid directory path. Please enter a valid directory path.\n");
        return NO; // Invalid directory path
    }
}


- (void)setCustomDirectoryPath:(NSString *)path {
    _customDirectoryPath = path;
}

- (void)scanCustomDirectory:(NSString *)directoryPath {
    [self listFilesInDirectory:directoryPath];
}

- (void)scanExternalUSBDrives{
    // Declare the pointer variable
    scanUSB *scanforUSBDrives;
    
    // Allocate memory for the object and initialize
    scanforUSBDrives = [[scanUSB alloc] init];
    
    // Check if object creation was successful
    if (scanforUSBDrives == nil) {
        NSLog(@"Object creation failed.");
    } else {
        NSLog(@"Object created successfully.");
        
        // Call a method on the object
        [scanforUSBDrives scanExternalUSBDrives];
        
        // Check object's properties if needed
        
        if (scanforUSBDrives->test != nil) {
            NSLog(@"Property initialized successfully.");
        } else {
            NSLog(@"Property initialization failed.");
        }
    }
}
/*

 Scans for external USB drives connected to the system.
 This method retrieves a list of external USB drives connected
 to the system and allows the user to select one for further
 processing. It then calls the listFilesInDirectory method to
 list the files in the selected USB drive.

- (void)scanExternalUSBDrives {
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
    
    
    NSError *error;
    
    // Get the paths of mounted volumes
    NSArray *paths = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:@"/Volumes" error:&error];
    
    // Handle any errors
    if (error) {
        printf("Error: %s\n", [[error localizedDescription] UTF8String]);
        return;
    }
    
    // Filter out the '.DS_Store' file from the list of paths
    _usbDrives = [paths filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF != %@", @".DS_Store"]];

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
        [self listFilesInDirectory:directoryPath];
    } else if (selection == 0) {
        // User chooses to skip scanning USB drives
        printf("Skipping USB drive scanning.\n");
    } else {
        // Invalid selection
        printf("Invalid selection.\n");
    }
}
*/
- (void)scanDocumentsDirectory {
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    [self listFilesInDirectory:documentsDirectory];
}

- (void)listFilesInDirectory:(NSString *)directoryPath {
    //NSError *error;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSDirectoryEnumerator *enumerator = [fileManager enumeratorAtURL:[NSURL fileURLWithPath:directoryPath]
                                          includingPropertiesForKeys:@[NSURLIsDirectoryKey]
                                                             options:NSDirectoryEnumerationSkipsHiddenFiles
                                                        errorHandler:^(NSURL *url, NSError *enumerationError) {
        printf("Error enumerating directory %s: %s\n", [[url path] UTF8String], [[enumerationError localizedDescription] UTF8String]);
        return YES; // Continue enumeration even if there's an error.
    }];
    
    NSMutableArray<NSURL *> *filteredFiles = [NSMutableArray array];
    NSUInteger fileCount = 0;
    for (NSURL *url in enumerator) {
        NSError *resourceError;
        NSNumber *isDirectory;
        [url getResourceValue:&isDirectory forKey:NSURLIsDirectoryKey error:&resourceError];
        if (resourceError) {
            printf("Error getting resource value for %s: %s\n", [[url path] UTF8String], [[resourceError localizedDescription] UTF8String]);
            continue;
        }
        if (![isDirectory boolValue]) {
            NSDictionary *fileAttributes = [fileManager attributesOfItemAtPath:[url path] error:&resourceError];
            if (resourceError) {
                printf("Error getting file attributes for %s: %s\n", [[url path] UTF8String], [[resourceError localizedDescription] UTF8String]);
                continue;
            }
            NSNumber *fileSize = [fileAttributes objectForKey:NSFileSize];
            if ([fileSize unsignedLongLongValue] == 0) {
                printf("Skipping file %s as it has size zero.\n", [[url lastPathComponent] UTF8String]);
                continue;
            }
            
            NSString *fileName = [url lastPathComponent];
            if ([fileName.pathExtension isEqualToString:@"txt"] || [fileName.pathExtension isEqualToString:@"log"] || [fileName.pathExtension isEqualToString:@"xml"]) {
                fileCount++;
                [filteredFiles addObject:url];
            }
        }
    }
    
    NSArray<NSURL *> *sortedFiles = [filteredFiles sortedArrayUsingComparator:^NSComparisonResult(NSURL *url1, NSURL *url2) {
        NSString *fileName1 = [url1 lastPathComponent];
        NSString *fileName2 = [url2 lastPathComponent];
        return [fileName1 compare:fileName2 options:NSCaseInsensitiveSearch];
    }];
    
    printf("Files found in %s:\n", [directoryPath UTF8String]);
    for (int i = 0; i < sortedFiles.count; i++) {
        printf("%d. %s\n", i + 1, [[sortedFiles[i] lastPathComponent] UTF8String]);
    }
    
    printf("Number of items in filteredFiles: %lu\n", (unsigned long)fileCount);
    
    int selection;
    printf("Select a file (1-%lu) or enter 0 to skip: ", (unsigned long)sortedFiles.count);
    scanf("%d", &selection);
    if (selection > 0 && selection <= sortedFiles.count) {
        NSURL *selectedURL = sortedFiles[selection - 1];
        [self searchKeywordInFile:selectedURL.path];
    } else if (selection == 0) {
        printf("Skipping file scanning.\n");
    } else {
        printf("Invalid selection.\n");
    }
}

/*
- (void)listFilesInDirectory:(NSString *)directoryPath {
    NSError *error;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSDirectoryEnumerator *enumerator = [fileManager enumeratorAtURL:[NSURL fileURLWithPath:directoryPath]
                                          includingPropertiesForKeys:@[NSURLIsDirectoryKey]
                                                             options:NSDirectoryEnumerationSkipsHiddenFiles
                                                        errorHandler:^(NSURL *url, NSError *enumerationError) {
        NSLog(@"Error enumerating directory %@: %@", [url path], [enumerationError localizedDescription]);
        return YES; // Continue enumeration even if there's an error.
    }];
    
    NSMutableArray<NSURL *> *filteredFiles = [NSMutableArray array];
    NSUInteger fileCount = 0;
    for (NSURL *url in enumerator) {
        NSError *resourceError;
        NSNumber *isDirectory;
        [url getResourceValue:&isDirectory forKey:NSURLIsDirectoryKey error:&resourceError];
        if (resourceError) {
            NSLog(@"Error getting resource value for %@: %@", [url path], [resourceError localizedDescription]);
            continue;
        }
        if (![isDirectory boolValue]) {
            NSDictionary *fileAttributes = [fileManager attributesOfItemAtPath:[url path] error:&resourceError];
            if (resourceError) {
                NSLog(@"Error getting file attributes for %@: %@", [url path], [resourceError localizedDescription]);
                continue;
            }
            NSNumber *fileSize = [fileAttributes objectForKey:NSFileSize];
            if ([fileSize unsignedLongLongValue] == 0) {
                NSLog(@"Skipping file %@ as it has size zero.", [url lastPathComponent]);
                continue;
            }
            
            NSString *fileName = [url lastPathComponent];
            if ([fileName.pathExtension isEqualToString:@"txt"] || [fileName.pathExtension isEqualToString:@"log"] || [fileName.pathExtension isEqualToString:@"csv"]) {
                fileCount++;
                [filteredFiles addObject:url];
            }
        }
    }
    
    NSArray<NSURL *> *sortedFiles = [filteredFiles sortedArrayUsingComparator:^NSComparisonResult(NSURL *url1, NSURL *url2) {
        NSString *fileName1 = [url1 lastPathComponent];
        NSString *fileName2 = [url2 lastPathComponent];
        return [fileName1 compare:fileName2 options:NSCaseInsensitiveSearch];
    }];
    
    printf("Files found in %s:\n", [directoryPath UTF8String]);
    for (int i = 0; i < sortedFiles.count; i++) {
        printf("%d. %s\n", i + 1, [[sortedFiles[i] lastPathComponent] UTF8String]);
    }
    
    printf("Number of items in filteredFiles: %lu\n", (unsigned long)fileCount);
    
    int selection;
    printf("Select a file (1-%lu) or enter 0 to skip: ", (unsigned long)sortedFiles.count);
    scanf("%d", &selection);
    if (selection > 0 && selection <= sortedFiles.count) {
        NSURL *selectedURL = sortedFiles[selection - 1];
        NSString *selectedFilePath = selectedURL.path;
        
        // Open the selected file in Notes
        [self openFileInNotes:selectedFilePath];
    } else if (selection == 0) {
        printf("Skipping file scanning.\n");
    } else {
        printf("Invalid selection.\n");
    }
}
*/


- (void)searchKeywordInFile:(NSString *)filePath {
    NSError *error;
    NSData *fileData = [NSData dataWithContentsOfFile:filePath options:NSDataReadingUncached error:&error];
    if (!fileData) {
        printf("Error: Unable to read file %s\n", [filePath UTF8String]);
        printf("Error: %s\n", [[error localizedDescription] UTF8String]);
        return;
    }
    
    NSString *fileContent;
    NSArray *encodings = @[@(NSUTF8StringEncoding), @(NSISOLatin1StringEncoding), @(NSASCIIStringEncoding), @(NSWindowsCP1251StringEncoding), @(NSWindowsCP1252StringEncoding), @(NSWindowsCP1253StringEncoding), @(NSWindowsCP1254StringEncoding),@(NSWindowsCP1250StringEncoding)];
    NSStringEncoding detectedEncoding = NSUTF8StringEncoding; // Default encoding
    for (NSNumber *encoding in encodings) {
        NSStringEncoding stringEncoding = [encoding unsignedIntegerValue];
        fileContent = [[NSString alloc] initWithData:fileData encoding:stringEncoding];
        if (fileContent) {
            detectedEncoding = stringEncoding;
            break; // Found a valid encoding
        }
    }
    
    NSString *encodingName = [NSString localizedNameOfStringEncoding:detectedEncoding];
    printf("Detected file encoding: %s\n", [encodingName UTF8String]);
    printf("for file: %s\n\n", [filePath UTF8String]);
    
    printf("1. Continue with detected encoding\n");
    printf("2. Start over\n");
    
    int choice;
    scanf("%d", &choice);
    
    if (choice == 1) {
        printf("Continuing with detected encoding.\n");
        
        //Open file in text editor
        //
        printf("Opening File in Text Editor.\n");
        NSURL *fileURL = [NSURL fileURLWithPath:filePath];
        BOOL success = [[NSWorkspace sharedWorkspace] openURL:fileURL];
        if (!success) {
           NSLog(@"Failed to open file.");
        }
        printf("Enter keyword to search for:\n");
        char keyword[100];
        scanf("%s", keyword);
        NSString *searchKeyword = [NSString stringWithCString:keyword encoding:NSUTF8StringEncoding];
        
        NSMutableArray *matchingLines = [NSMutableArray array];
        NSArray *lines = [fileContent componentsSeparatedByString:@"\n"];
        for (NSInteger i = 0; i < lines.count; i++) {
            NSString *line = lines[i];
            if ([line rangeOfString:searchKeyword options:NSCaseInsensitiveSearch].location != NSNotFound) {
                printf("Keyword found in file %s at line %ld: %s\n", [[filePath lastPathComponent] UTF8String], (long)(i + 1), [line UTF8String]);
                [matchingLines addObject:line];
            }
        }
        
        if (matchingLines.count > 0) {
            NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
            NSString *csvFileName = [NSString stringWithFormat:@"MatchingLines_%@.csv", searchKeyword];
            NSString *csvFilePath = [documentsDirectory stringByAppendingPathComponent:csvFileName];
            printf("Saving matching lines to CSV file: %s\n", [csvFilePath UTF8String]);
            
            NSMutableString *csvContent = [NSMutableString stringWithString:@"Matching Lines\n"];
            for (NSString *line in matchingLines) {
                [csvContent appendFormat:@"%@\n", line];
            }
            
            NSError *csvError;
            BOOL success = [csvContent writeToFile:csvFilePath atomically:YES encoding:NSUTF8StringEncoding error:&csvError];
            if (success) {
                printf("CSV file saved successfully.\n");
                [self handlePostSaveActions];
            } else {
                printf("Error saving CSV file: %s\n", [[csvError localizedDescription] UTF8String]);
                [self restartApplication];
            }
        } else {
            printf("No matching lines found.\n");
        }
    } else if (choice == 2) {
        [self restartApplication];
    } else {
        printf("Invalid choice. Exiting application...\n");
        exit(0);
    }
}

- (void)handlePostSaveActions {
    printf("1. Exit application\n");
    printf("2. Restart application\n");
    printf("Enter your choice: ");
    
    int restartChoice;
    scanf("%d", &restartChoice);
    if (restartChoice == 1) {
        printf("Exiting application...\n");
        exit(0);
    } else if (restartChoice == 2) {
        printf("Restarting application...\n");
        [self restartApplication];
    } else {
        printf("Invalid choice. Exiting application...\n");
        exit(0);
    }
}

- (void)restartApplication {
    printf("Restarting application...\n");
    //[self scanExternalUSBDrives];
    [self displayMainMenu];
    exit(0);
}

@end

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        FileScanner *scanner = [[FileScanner alloc] init];
        
        int choice;
        printf("1. Scan for USB drives\n");
        printf("2. Scan Documents directory\n");
        printf("3. Input custom directory path\n");
        printf("Enter your choice: ");
        scanf("%d", &choice);
        
        switch (choice) {
            case 1:
                [scanner scanExternalUSBDrives];
                break;
            case 2:
                [scanner scanDocumentsDirectory];
                break;
            case 3: {
                printf("Enter custom directory path: ");
                char customPath[256];
                scanf("%s", customPath);
                NSString *customDirectoryPath = [NSString stringWithUTF8String:customPath];
                [scanner setCustomDirectoryPath:customDirectoryPath]; // Set custom directory path
                if (![scanner validateDirectoryPath:customDirectoryPath]) {
                        printf("Exiting...\n");
                        return 0; // Exit the program
                    }
                [scanner scanCustomDirectory:customDirectoryPath]; // Scan custom directory
                break;
            }
            default:
                printf("Invalid choice.\n");
                return 1; // Exit with a non-zero status to indicate an error
        }
    }
    
    return 0; // Return 0 to indicate successful completion
}


/*
int main(int argc, const char * argv[]) {
    @autoreleasepool {
        FileScanner *scanner = [[FileScanner alloc] init];
       
        
        int choice;
        printf("1. Scan for USB drives\n");
        printf("2. Scan Documents directory\n");
        printf("3. Input custom directory path\n");
        printf("Enter your choice: ");
        scanf("%d", &choice);
        
        switch (choice) {
            case 1:
                [scanner scanExternalUSBDrives];
                break;
            case 2:
                [scanner scanDocumentsDirectory];
                break;
            case 3:
                printf("Enter custom directory path: ");
                char customPath[256];
                scanf("%s", customPath);
                
                if ([[NSFileManager defaultManager] fileExistsAtPath:customDirectoryPath]) {
                    [scanner listFilesInDirectory:customDirectoryPath];
                } else {
                    printf("Invalid directory path. Please try again.\n");
                }
                break;
            default:
                printf("Invalid choice.\n");
                break;
        }
    }
    return 0;
}
 */

/*
int main(int argc, const char * argv[]) {
    @autoreleasepool {
        FileScanner *scanner = [[FileScanner alloc] init];
        
        int choice;
        printf("1. Scan for USB drives\n");
        printf("2. Scan Documents directory\n");
        printf("Enter your choice: ");
        scanf("%d", &choice);
        
        switch (choice) {
            case 1:
                [scanner scanExternalUSBDrives];
                break;
            case 2:
                [scanner scanDocumentsDirectory];
                break;
            default:
                printf("Invalid choice.\n");
                break;
        }
    }
    return 0;
}
*/
