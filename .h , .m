#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import "Send_PrintAppDelegate.h"

@interface DataBaseClass : NSObject {
  
	NSString *databaseName;
    NSString *databasePath;
    NSArray *documentPaths;
    NSString *documentsDir;
    Send_PrintAppDelegate *appDelegate;
    NSMutableArray *readBookmarkArray;

}
-(void) checkAndCreateDatabase;


-(void)InsertRecord:(NSString *)imgID addqality:(NSString *)quality andsize:(NSString *)size andborder:(NSString *)broder andmode:(NSString *)mode andmatte:(NSString *)matte;

-(void)readRecords ;

-(void)InsertImagesRecord:(NSString *)ordName addImages:(NSString *)imgsID andDate:(NSString *)date ;

-(void)readImagesRecord ;
-(void)readImages:(NSString *)orderName ;

-(void)InsertOrderName:(NSString *)ordName andDate:(NSString *)date ;

-(void)deleteOrder:(int)orderid ;

-(void)deleteOrderImages:(int)orderid ;

-(void)deleteSettingImage:(int)rid ;

-(void)chekingImages:(NSString *)imgID ;

-(void)chekingCartImages:(NSString *)imgID ;

-(void)chekingOrderName:(NSString *)ordName ;

-(BOOL)updateCartRecord:(int)cartid andQulity:(NSString *)qty andSize:(NSString *)size andBorder:(NSString *)border andMode:(NSString *)mode andMatte:(NSString *)matte ;


@end



.M



#import "DataBaseClass.h"


@implementation DataBaseClass


-(void) checkAndCreateDatabase
{  
  appDelegate = [[UIApplication sharedApplication] delegate];
    BOOL success;
    databaseName= @"Send2Pint.sqlite";
    documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    documentsDir = [documentPaths objectAtIndex:0];
    databasePath = [documentsDir stringByAppendingPathComponent:databaseName];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    success = [fileManager fileExistsAtPath:databasePath];
    if(success) return;
    NSString *databasePathFromApp = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:databaseName];
    [fileManager copyItemAtPath:databasePathFromApp toPath:databasePath error:nil];
    [fileManager release];
}

////////////////////////////// People Table ///////////////////////////////////////////////////////////////////

-(void)InsertRecord:(NSString *)imgID addqality:(NSString *)quality andsize:(NSString *)size andborder:(NSString *)broder andmode:(NSString *)mode andmatte:(NSString *)matte;

{
	
		[self checkAndCreateDatabase];
	
	sqlite3 *database;
	
	if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK) 
	{
		sqlite3_stmt *add_statement=nil;
		
		if(add_statement == nil) 
		{
			const char *sql = "insert into printdata(photo, quality, size ,border, mode, matte) Values( ?, ?, ?, ?, ?, ?)";
			if(sqlite3_prepare_v2(database, sql, -1, &add_statement, NULL) != SQLITE_OK)
				NSAssert1(0, @"Error while creating add statement. '%s'", sqlite3_errmsg(database));
		}
		sqlite3_bind_text(add_statement, 1, [imgID UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(add_statement, 2, [quality UTF8String], -1, SQLITE_TRANSIENT);
		sqlite3_bind_text(add_statement, 3, [size UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(add_statement, 4, [broder UTF8String], -1, SQLITE_TRANSIENT);
		sqlite3_bind_text(add_statement, 5, [mode UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(add_statement, 6, [matte UTF8String], -1, SQLITE_TRANSIENT);
		
		
		if (SQLITE_DONE != sqlite3_step(add_statement)) 
		{
			
			
		}
				
		sqlite3_reset(add_statement);
		
		sqlite3_finalize(add_statement);
	}
}


-(void)readRecords
{
	
    NSLog(@"it is working for reading records ");
    
	sqlite3 *database;
	
	[self checkAndCreateDatabase];
	
	[appDelegate.dataArray removeAllObjects];
	
    sqlite3_stmt *readStatment = nil;
	
    // Open the database. The database was prepared outside the application.
    if (sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK)
	{
        if(readStatment == nil)
        {
            const char *sql = "Select * from printdata";
            //const char *sql = "Select * from bookmark";
            if(sqlite3_prepare_v2(database, sql, -1, &readStatment, NULL) != SQLITE_OK)
                NSAssert1(0, @"Error while creating detail view statement. '%s'", sqlite3_errmsg(database));
        }
        
		
		while (sqlite3_step(readStatment) == SQLITE_ROW) 
		{
			
			NSMutableDictionary *dicContacts=[[NSMutableDictionary alloc]init];
			
			[dicContacts setValue:[NSString stringWithFormat:@"%d", sqlite3_column_int(readStatment, 0)] forKey:@"nid"];
			
            
             [dicContacts setValue:[NSString stringWithUTF8String:(char *)sqlite3_column_text(readStatment, 1)] forKey:@"photo"];
            
            [dicContacts setValue:[NSString stringWithUTF8String:(char *)sqlite3_column_text(readStatment, 2)] forKey:@"quality"];
			
			[dicContacts setValue:[NSString stringWithUTF8String:(char *)sqlite3_column_text(readStatment, 3)] forKey:@"size"];
           
            [dicContacts setValue:[NSString stringWithUTF8String:(char *)sqlite3_column_text(readStatment, 4)] forKey:@"broder"];
			
			[dicContacts setValue:[NSString stringWithUTF8String:(char *)sqlite3_column_text(readStatment, 5)] forKey:@"mode"];
			
			[dicContacts setValue:[NSString stringWithUTF8String:(char *)sqlite3_column_text(readStatment, 6)] forKey:@"matte"];
            
           
			
			[[appDelegate dataArray] addObject:dicContacts];
			
			[dicContacts release];
			
		}
		        sqlite3_finalize(readStatment);
	}
	
    sqlite3_close(database);
	
    
   	
}

//////////////////////// previous page ///////////////////////////

-(void)InsertOrderName:(NSString *)ordName andDate:(NSString *)date 
{
    
    [self checkAndCreateDatabase];
	
	sqlite3 *database;
	
	if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK) 
	{
		sqlite3_stmt *add_statement=nil;
		
		if(add_statement == nil) 
		{
			const char *sql = "insert into ordertable (ordername,date) Values( ?, ?)";
			if(sqlite3_prepare_v2(database, sql, -1, &add_statement, NULL) != SQLITE_OK)
				NSAssert1(0, @"Error while creating add statement. '%s'", sqlite3_errmsg(database));
		}
		
        
        sqlite3_bind_text(add_statement, 1, [ordName UTF8String], -1, SQLITE_TRANSIENT);
      
        
		sqlite3_bind_text(add_statement, 2, [date UTF8String], -1, SQLITE_TRANSIENT);
        
		
		if (SQLITE_DONE != sqlite3_step(add_statement)) 
		{
			
			
		}
        
		sqlite3_reset(add_statement);
		
		sqlite3_finalize(add_statement);
	}

}


-(void)InsertImagesRecord:(NSString *)ordName addImages:(NSString *)imgsID andDate:(NSString *)date 
{
	
    [self checkAndCreateDatabase];
	
	sqlite3 *database;
	
	if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK) 
	{
		sqlite3_stmt *add_statement=nil;
		
		if(add_statement == nil) 
		{
			const char *sql = "insert into previousorder(ordername, images ,date) Values( ?, ?, ?)";
			if(sqlite3_prepare_v2(database, sql, -1, &add_statement, NULL) != SQLITE_OK)
				NSAssert1(0, @"Error while creating add statement. '%s'", sqlite3_errmsg(database));
		}
		
          
        sqlite3_bind_text(add_statement, 1, [ordName UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(add_statement, 2, [imgsID UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(add_statement, 3, [date UTF8String], -1, SQLITE_TRANSIENT);
       		
		
		if (SQLITE_DONE != sqlite3_step(add_statement)) 
		{
			
			
		}
        
		sqlite3_reset(add_statement);
		
		sqlite3_finalize(add_statement);
	}
}

-(void)readImagesRecord
{
	
	sqlite3 *database;
	
	[self checkAndCreateDatabase];
	
	[appDelegate.orderNamesArray removeAllObjects];
	
    sqlite3_stmt *readStatment = nil;
	
    // Open the database. The database was prepared outside the application.
    if (sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK)
	{
        if(readStatment == nil)
        {
            const char *sql = "Select * from ordertable";
            //const char *sql = "Select * from bookmark";
            if(sqlite3_prepare_v2(database, sql, -1, &readStatment, NULL) != SQLITE_OK)
                NSAssert1(0, @"Error while creating detail view statement. '%s'", sqlite3_errmsg(database));
        }
        
		while (sqlite3_step(readStatment) == SQLITE_ROW) 
		{
			
			NSMutableDictionary *dicContacts=[[NSMutableDictionary alloc]init];
            
            
			[dicContacts setValue:[NSString stringWithUTF8String:(char *)sqlite3_column_text(readStatment, 0)] forKey:@"orderid"];

			
			[dicContacts setValue:[NSString stringWithUTF8String:(char *)sqlite3_column_text(readStatment, 1)] forKey:@"ordername"];

            [dicContacts setValue:[NSString stringWithUTF8String:(char *)sqlite3_column_text(readStatment, 2)] forKey:@"date"];
			
			            
			
			[[appDelegate orderNamesArray] addObject:dicContacts];
			
			[dicContacts release];
			
		}
        sqlite3_finalize(readStatment);
	}
	
    sqlite3_close(database);
	
}

-(void)readImages:(NSString *)orderName
{
   
    sqlite3 *database;
	
	[self checkAndCreateDatabase];
	
	[appDelegate.preImagesArray removeAllObjects];
	
    sqlite3_stmt *readStatment = nil;
	
    // Open the database. The database was prepared outside the application.
    if (sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK)
	{
        if(readStatment == nil)
        {
           const char *sql = "SELECT * FROM previousorder  where ordername like ?"; 
            //const char *sql = "Select * from bookmark";
            if(sqlite3_prepare_v2(database, sql, -1, &readStatment, NULL) != SQLITE_OK)
                NSAssert1(0, @"Error while creating detail view statement. '%s'", sqlite3_errmsg(database));
        }
        
	                           
        NSString *srarchitem = [NSString stringWithFormat:@"%%%@%%", orderName];
                
        sqlite3_bind_text(readStatment, 1, [srarchitem UTF8String], [srarchitem length], SQLITE_STATIC); 
        
        
		while (sqlite3_step(readStatment) == SQLITE_ROW) 
		{
			
			NSMutableDictionary *dicContacts=[[NSMutableDictionary alloc]init];
            
            [dicContacts setValue:[NSString stringWithUTF8String:(char *)sqlite3_column_text(readStatment, 0)] forKey:@"orderid"];

			
			[dicContacts setValue:[NSString stringWithUTF8String:(char *)sqlite3_column_text(readStatment, 1)] forKey:@"ordername"];
            
            [dicContacts setValue:[NSString stringWithUTF8String:(char *)sqlite3_column_text(readStatment, 2)] forKey:@"imgs"];
            
            [dicContacts setValue:[NSString stringWithUTF8String:(char *)sqlite3_column_text(readStatment, 3)] forKey:@"date"];
			
            [[appDelegate preImagesArray] addObject:dicContacts];
			
			[dicContacts release];
			
		}
        sqlite3_finalize(readStatment);
	}
	
    sqlite3_close(database);
	
}
-(void)deleteOrder:(int)orderid
{
    sqlite3 *database;
    [self checkAndCreateDatabase];
	
    if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK)
    {
        sqlite3_stmt *delete_statement=nil;     //first assign to nil
		
        if(delete_statement == nil)
        {
            const char *sql = "delete from ordertable where orderid = ?";        //u can give the condition also
            if(sqlite3_prepare_v2(database, sql, -1, &delete_statement, NULL) != SQLITE_OK)
                NSAssert1(0, @"Error while creating delete statement. '%s'", sqlite3_errmsg(database));
        }
		
        sqlite3_bind_int(delete_statement, 1, orderid);
		
        if (SQLITE_DONE != sqlite3_step(delete_statement))
        {
			NSLog(@"Error Delete");
        }
		
        sqlite3_reset(delete_statement);
        sqlite3_finalize(delete_statement);
    }
    
}

-(void)deleteOrderImages:(int)orderid
{
   
    sqlite3 *database;
    [self checkAndCreateDatabase];
	
    if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK)
    {
        sqlite3_stmt *delete_statement=nil;     //first assign to nil
		
        if(delete_statement == nil)
        {
            const char *sql = "delete from previousorder where orderid = ?";        //u can give the condition also
            if(sqlite3_prepare_v2(database, sql, -1, &delete_statement, NULL) != SQLITE_OK)
                NSAssert1(0, @"Error while creating delete statement. '%s'", sqlite3_errmsg(database));
        }
		
        sqlite3_bind_int(delete_statement, 1, orderid);
        
        
		
        if (SQLITE_DONE != sqlite3_step(delete_statement))
        {
			NSLog(@"Error Delete");
        }
		
        sqlite3_reset(delete_statement);
        sqlite3_finalize(delete_statement);
    }
    
}

-(void)deleteSettingImage:(int)rid
{
    
   
    
    sqlite3 *database;
    [self checkAndCreateDatabase];
	
    if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK)
    {
        sqlite3_stmt *delete_statement=nil;     //first assign to nil
		
        if(delete_statement == nil)
        {
            const char *sql = "delete from printdata where id = ?";        //u can give the condition also
            if(sqlite3_prepare_v2(database, sql, -1, &delete_statement, NULL) != SQLITE_OK)
                NSAssert1(0, @"Error while creating delete statement. '%s'", sqlite3_errmsg(database));
        }
		
        sqlite3_bind_int(delete_statement, 1, rid);
		
        if (SQLITE_DONE != sqlite3_step(delete_statement))
        {
			NSLog(@"Error Delete");
        }
		
        sqlite3_reset(delete_statement);
        sqlite3_finalize(delete_statement);
    }
    
}
-(void)chekingImages:(NSString *)imgID
{
    
    sqlite3 *database;
	
	[self checkAndCreateDatabase];
	
	[appDelegate.checkingArray removeAllObjects];
	
    sqlite3_stmt *readStatment = nil;
	
    if (sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK)
	{
        if(readStatment == nil)
        {
            const char *sql = "SELECT * FROM previousorder  where images like ?"; 
            //const char *sql = "Select * from bookmark";
            if(sqlite3_prepare_v2(database, sql, -1, &readStatment, NULL) != SQLITE_OK)
                NSAssert1(0, @"Error while creating detail view statement. '%s'", sqlite3_errmsg(database));
        }
        
        
        NSString *srarchitem = [NSString stringWithFormat:@"%%%@%%", imgID];
        
        sqlite3_bind_text(readStatment, 1, [srarchitem UTF8String], [srarchitem length], SQLITE_STATIC); 
        
        
		while (sqlite3_step(readStatment) == SQLITE_ROW) 
		{
			
			NSMutableDictionary *dicContacts=[[NSMutableDictionary alloc]init];
            
                       
            [dicContacts setValue:[NSString stringWithUTF8String:(char *)sqlite3_column_text(readStatment, 2)] forKey:@"imgs"];
            
           
			[[appDelegate checkingArray] addObject:dicContacts];
			
			[dicContacts release];
			
		}
        sqlite3_finalize(readStatment);
	}
	
       
    sqlite3_close(database);
    
    if ([appDelegate.checkingArray count] == 0) 
    { 
        NSLog(@"it is if block ");
        
        [self chekingCartImages:imgID];     
    }
    else    
    {
       
    }

}


-(void)chekingCartImages:(NSString *)imgID
{

     NSLog(@"chekingCartImages ");
    
    sqlite3 *database;
	
	[self checkAndCreateDatabase];
	
	[appDelegate.checkingArray removeAllObjects];
	
    sqlite3_stmt *readStatment = nil;
	
    if (sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK)
	{
        if(readStatment == nil)
        {
            const char *sql = "SELECT * FROM printdata  where photo like ?"; 
            //const char *sql = "Select * from bookmark";
            if(sqlite3_prepare_v2(database, sql, -1, &readStatment, NULL) != SQLITE_OK)
                NSAssert1(0, @"Error while creating detail view statement. '%s'", sqlite3_errmsg(database));
        }
        
        
        NSString *srarchitem = [NSString stringWithFormat:@"%%%@%%", imgID];
        
        sqlite3_bind_text(readStatment, 1, [srarchitem UTF8String], [srarchitem length], SQLITE_STATIC); 
        
        
		while (sqlite3_step(readStatment) == SQLITE_ROW) 
		{
			
			NSMutableDictionary *dicContacts=[[NSMutableDictionary alloc]init];
            
            
            [dicContacts setValue:[NSString stringWithUTF8String:(char *)sqlite3_column_text(readStatment, 2)] forKey:@"imgs"];
            
            
			[[appDelegate checkingArray] addObject:dicContacts];
			
			[dicContacts release];
			
		}
        sqlite3_finalize(readStatment);
	}
	
    
    sqlite3_close(database);
    
    if ([appDelegate.checkingArray count] == 0) 
    {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        [fileManager removeItemAtPath:imgID  error:NULL];   
    }
    else    
    {
        
    }
    
}


-(void)chekingOrderName:(NSString *)ordName
{
    
    sqlite3 *database;
	
	[self checkAndCreateDatabase];
	
	[appDelegate.checkingArray removeAllObjects];
	
    sqlite3_stmt *readStatment = nil;
	
    if (sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK)
	{
        if(readStatment == nil)
        {
            const char *sql = "SELECT * FROM ordertable  where ordername like ?"; 
            //const char *sql = "Select * from bookmark";
            if(sqlite3_prepare_v2(database, sql, -1, &readStatment, NULL) != SQLITE_OK)
                NSAssert1(0, @"Error while creating detail view statement. '%s'", sqlite3_errmsg(database));
        }
        
        
        NSString *srarchitem = [NSString stringWithFormat:@"%%%@%%", ordName];
        
        sqlite3_bind_text(readStatment, 1, [srarchitem UTF8String], [srarchitem length], SQLITE_STATIC); 
        
        
		while (sqlite3_step(readStatment) == SQLITE_ROW) 
		{
			
			NSMutableDictionary *dicContacts=[[NSMutableDictionary alloc]init];
            
            
            [dicContacts setValue:[NSString stringWithUTF8String:(char *)sqlite3_column_text(readStatment, 2)] forKey:@"imgs"];
            
            
			[[appDelegate checkingArray] addObject:dicContacts];
			
			[dicContacts release];
			
		}
        sqlite3_finalize(readStatment);
	}
	
    
    sqlite3_close(database);
    
    if ([appDelegate.checkingArray count] == 0) 
    {
        appDelegate.ordercondition = 1 ; 
    }
    else    
    {
        
    }
    
}


-(BOOL)updateCartRecord:(int)cartid andQulity:(NSString *)qty andSize:(NSString *)size andBorder:(NSString *)border andMode:(NSString *)mode andMatte:(NSString *)matte 
{
  	[self checkAndCreateDatabase];
 	sqlite3 *database;
    
    
    NSLog(@"update is working");
   	
	if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK) 
	{
		sqlite3_stmt *update_statement=nil;
        
		
		if(update_statement == nil) 
		{
			const char *sql = "UPDATE printdata SET quality = ?,size = ?,border = ? ,mode = ?,matte = ?  where id = ?";
            
            
            if(sqlite3_prepare_v2(database, sql, -1, &update_statement, NULL) != SQLITE_OK)
            {
                NSAssert1(0, @"Error while creating Updating statement. '%s'", sqlite3_errmsg(database));
            }
		}
       
        sqlite3_bind_text(update_statement, 1, [qty UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(update_statement, 2, [size UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(update_statement, 3, [border UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(update_statement, 4, [mode UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(update_statement, 5, [matte UTF8String], -1, SQLITE_TRANSIENT);
        
        sqlite3_bind_int(update_statement, 6, cartid);
        
        if (SQLITE_DONE != sqlite3_step(update_statement)) 
		{
			
            return 0;
		}
		else {
            [self readRecords];
            return 1;
		}
        
		
		sqlite3_reset(update_statement);
		
		sqlite3_finalize(update_statement);
	}
    
	
    return 1;
}







@end
