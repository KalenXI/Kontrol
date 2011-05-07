//
//  BoxeeServerParser.m
//  Boxee Remote
//
//  Created by Kevin Vinck on 27/03/2011.
//  Copyright 2011 None. All rights reserved.
//

#import "BoxeeServerParser.h"

static NSSet *interestingKeys;

@implementation BoxeeServerParser

@synthesize cmd,application,version,name,response,httpAuthRequired,httpPort,signature;

+ (void)initialize
{
    if (!interestingKeys) {
        interestingKeys = [[NSSet alloc] initWithObjects:@"cmd", @"application", @"name", @"response", @"httpPort", @"httpAuthRequired", nil];
    }
}

- (void)dealloc
{
    [cmd release];
    [application release];
    [version release];
    [name release];
    [response release];
    [httpPort release];
    [signature release];
    [super dealloc];
}

- (BOOL)parseData:(NSData *)d
{
    // Create a parser
    validServer = NO;
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:d];
    [parser setDelegate:self];
    
    // Do the parse
    [parser parse];
    
    [parser release];
    
    //NSLog(@"items = %@", items);
    return validServer;
}



#pragma mark Delegate calls

- (void)parser:(NSXMLParser *)parser
didStartElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName
    attributes:(NSDictionary *)attributeDict
{
    //NSLog(@"starting Element: %@", elementName);
    
    // Is it the start of a new item?
    if ([elementName isEqual:@"BDP1"]) {
        validServer = YES;
        //NSLog(@"Attributes: %@",attributeDict);
        
        self.cmd = [attributeDict valueForKey:@"cmd"];
        self.application = [attributeDict valueForKey:@"application"];
        self.version = [attributeDict valueForKey:@"version"];
        self.name = [attributeDict valueForKey:@"name"];
        self.response = [attributeDict valueForKey:@"response"];
        self.httpPort = [attributeDict valueForKey:@"httpPort"];
        self.signature = [attributeDict valueForKey:@"signature"];
        return;
    }
}

- (void)parser:(NSXMLParser *)parser
 didEndElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName
{
    //NSLog(@"ending Element: %@", elementName);
    
    /*// Is the current item complete?
    if ([elementName isEqual:@"Item"]) {
        [items addObject:boxeeServerInProgress];
        
        // Clear the current item
        [boxeeServerInProgress release];
        boxeeServerInProgress = nil;
        return;
    }
    
    // Is the current key complete?
    if ([elementName isEqual:keyInProgress]) {
        if ([elementName isEqual:@"DetailPageURL"]) {
            //[boxeeServerInProgress setDetailPage:textInProgress];
        } else {
            //[boxeeServerInProgress setTitle:textInProgress];
            
        }
        // Clear the text and key
        [textInProgress release];
        textInProgress = nil;
        [keyInProgress release];
        keyInProgress = nil;
    }*/
}

// This method can get called multiple times for the
// text in a single element
- (void)parser:(NSXMLParser *)parser
foundCharacters:(NSString *)string
{
    [textInProgress appendString:string];
}
@end
