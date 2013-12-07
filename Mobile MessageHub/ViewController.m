//
//  ViewController.m
//  Mobile MessageHub
//
//  Created by Ben Leiken on 11/6/13.
//  Copyright (c) 2013 BKL. All rights reserved.
//

#import "ViewController.h"
#import "MessageView.h"

#define INITIAL_PAGE_LOAD 3

@interface ViewController () <UITextFieldDelegate, NSURLConnectionDelegate, UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate>
@property (strong, nonatomic) IBOutlet UITextField *usernameField;
@property (strong, nonatomic) IBOutlet UITextField *messageField;
@property (strong, nonatomic) IBOutlet UIButton *submitButton;
@property (strong, nonatomic) IBOutlet UIButton *pagesViewButton;

@property (strong, nonatomic) IBOutlet UITableView *messagesTable;
@property (strong, nonatomic) IBOutlet UIButton *viewAll;
@property (strong, nonatomic) IBOutlet UIButton *hideAll;

@property (strong, nonatomic) NSArray * returnedMessages;
@property (strong, nonatomic) NSMutableArray * messages;

@property (assign ,nonatomic) int offset;
@property (assign, nonatomic) int total;

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIPageControl *pageControl;
@property (nonatomic, strong) NSCache *views;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
   
   self.usernameField.delegate = self;
   self.messageField.delegate = self;
   self.offset = 0;
   
   self.messages = [[NSMutableArray alloc] init];
   

   self.messagesTable.hidden = YES;
   self.pagesViewButton.hidden = YES;
   
   self.messagesTable.delegate = self;
   self.messagesTable.dataSource = self;
   
   self.hideAll.hidden = YES;
   
   UITableViewController *tableViewController = [[UITableViewController alloc] init];
   tableViewController.tableView = self.messagesTable;
   
   /*
   self.refresher = [[UIRefreshControl alloc] init];
   self.refresher.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to Refresh"];
   [self.refresher addTarget:self action:@selector(getMessages) forControlEvents:UIControlEventValueChanged];
   */
   
   //tableViewController.refreshControl = self.refresher;
	// Do any additional setup after loading the view, typically from a nib.
}

- (void) getCount
{
   NSURL *url = [NSURL URLWithString:@"http://0.0.0.0:3000/messages/length.json"];
   
   NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                          cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:20.0];
   
   
   [request setHTTPMethod:@"GET"];
   
   [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
   
   NSOperationQueue *queue = [[NSOperationQueue alloc] init];
   [NSURLConnection sendAsynchronousRequest:request
                                      queue:queue
                          completionHandler:^(NSURLResponse *response, NSData *responseData, NSError *error) {
                             if (error == nil) {
                                
                                NSString * jsonString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
                                
                                NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
                                NSDictionary * msg = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];
                                self.total = [[msg objectForKey:@"length"] intValue];
                             }
                             else {
                                UIAlertView *alert1 = [[UIAlertView alloc] initWithTitle: @"Failure" message: @"Something went terribly wrong..."delegate: nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                                
                                [alert1 performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:YES];
                             }
                          }];

}

- (void) endRefresh
{
   //[self.refresher endRefreshing];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)done:(id)sender {
   
   [self.usernameField resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
   [textField resignFirstResponder];
   return YES;
}
- (IBAction)submit:(id)sender {
   
   
   //Note: 17 is the app_id for ios on my messagehub
   NSArray *objects = [NSArray arrayWithObjects:self.usernameField.text, self.messageField.text, @"17" , nil];
   NSArray *keys = [NSArray arrayWithObjects:@"username", @"content", @"app_id", nil];
   NSDictionary *messageDict = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
   
   NSDictionary *jsonDict = [NSDictionary dictionaryWithObject:messageDict forKey:@"message"];
   
   NSData *jsonRequest = [NSJSONSerialization
                            dataWithJSONObject:jsonDict
                            options:NSJSONWritingPrettyPrinted
                            error:nil];
   
   
   NSURL *url = [NSURL URLWithString:@"http://0.0.0.0:3000/messages"];
   
   NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                          cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:20.0];
   NSData *requestData = jsonRequest;
   
   [request setHTTPMethod:@"POST"];

   [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
   [request setValue:[NSString stringWithFormat:@"%d", [requestData length]] forHTTPHeaderField:@"Content-Length"];
   [request setHTTPBody: requestData];
   
   NSOperationQueue *queue = [[NSOperationQueue alloc] init];
   [NSURLConnection sendAsynchronousRequest:request
                                      queue:queue
                          completionHandler:^(NSURLResponse *response, NSData *responseData, NSError *error) {
                             if (error == nil) {
                                UIAlertView *alert3 = [[UIAlertView alloc] initWithTitle: @"Success!" message: @"Message Submitted" delegate: nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                                
                                [alert3 performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:YES];
                                
                                self.total ++;

                             }
                             else {
                                UIAlertView *alert1 = [[UIAlertView alloc] initWithTitle: @"Failure" message: @"Something went terribly wrong..."delegate: nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                                                      
                                 [alert1 performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:YES];
                             }
                          }];
}

- (IBAction)pagesViewAction:(id)sender {
   CGRect bounds = [[UIScreen mainScreen] bounds];
   CGRect subviewFrame = CGRectMake(0, 0, bounds.size.width, bounds.size.height);
   self.scrollView = [[UIScrollView alloc] initWithFrame:subviewFrame];
   self.scrollView.backgroundColor = [UIColor whiteColor];
   self.scrollView.maximumZoomScale = 1.0;
   self.scrollView.minimumZoomScale = 1.0;
   self.scrollView.clipsToBounds = YES;
   self.scrollView.showsHorizontalScrollIndicator = NO;
   self.scrollView.scrollEnabled = YES;
   self.scrollView.pagingEnabled = YES;
   
   [self setupUI];
   
   [self.view addSubview:self.hideAll];

   
   
}

-(void)setupUI
{
   
   
   NSCache *views = [[NSCache alloc] init];
   for (NSUInteger i = 0; i < self.total; i++)
   {
      [views setObject:[NSNull null] forKey:@((int)i)];
   }
   self.views = views;
   
   
   self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.scrollView.frame) *self.total, CGRectGetHeight(self.scrollView.frame));
   self.scrollView.delegate = self;
   self.scrollView.backgroundColor = [UIColor whiteColor];
   
   self.pageControl = [[UIPageControl alloc] initWithFrame:self.scrollView.frame];
   self.pageControl.numberOfPages = self.total;
   self.pageControl.currentPage = 0;
   [self.view addSubview:self.pageControl];
   
   
   [self.view addSubview:self.scrollView];
   
   
   for(int i= self.pageControl.currentPage; i < self.pageControl.currentPage + INITIAL_PAGE_LOAD; i++){
      if(self.total > self.offset){
         [self getMessages];
      }
      if(self.pageControl.currentPage - i >= 0){
         [self loadScrollViewWithOffset:self.pageControl.currentPage - i];
      }
   }
   [self gotoOffset:NO];
   
}

- (void)loadScrollViewWithOffset:(NSUInteger)offset
{

   CGRect bounds = [[UIScreen mainScreen] bounds];
   CGFloat offsetTop = 0;
   
   // replace the placeholder if necessary
   
   NSDictionary * msg = self.messages[offset];

   
   MessageView *view = [self.views objectForKey:@((int)offset)];
   
   if ((NSNull *)view == [NSNull null])
   {
      view = [[MessageView alloc] initWithFrame:CGRectMake(0, offsetTop, bounds.size.width, bounds.size.height) andAuthor:[msg objectForKey:@"username"] andContent:[msg objectForKey:@"content"]];
      [self.views setObject:view forKey:@((int)offset)];
   }
   // add the controller's view to the scroll view
   if (view.superview == nil)
   {
      CGRect frame = self.scrollView.frame;
      frame.origin.x = CGRectGetWidth(frame) * offset;
      frame.origin.y = 0;
      view.frame = frame;
      
      [self.scrollView addSubview:view];
   }
}


// at the end of scroll animation, reset the boolean used when scrolls originate from the UIPageControl
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
   if(scrollView == self.scrollView){
      
   
      CGFloat pageWidth = CGRectGetWidth(self.scrollView.frame);
      NSUInteger offset= floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
      if(self.offset == offset && self.offset < self.total){
         self.pageControl.currentPage = offset;
         
         [self getMessages];
         
         //Nothing happens, we're still on the same page
         return;
      }
      NSUInteger numResponses = self.total;

      
      if(offset > 0){
         [self loadScrollViewWithOffset:offset - 1];
      }
      [self loadScrollViewWithOffset:offset];
      if(offset< numResponses - 1){
         [self loadScrollViewWithOffset:offset + 1];
      }
      if(offset < numResponses - 2){
         [self loadScrollViewWithOffset:offset + 2];
      }
   }
}

- (void)gotoOffset:(BOOL)animated
{
   NSInteger offset = self.pageControl.currentPage;
   
   // load the visible page and the page on either side of it (to avoid flashes when the user starts scrolling)
   if(offset >0){
      [self loadScrollViewWithOffset:offset - 1];
   }
   [self loadScrollViewWithOffset:offset];
   
   if(offset < self.total - 1){
      [self loadScrollViewWithOffset:offset + 1];
   }
   
   // update the scroll view to the appropriate page
   CGRect bounds = self.scrollView.bounds;
   bounds.origin.x = CGRectGetWidth(bounds) * offset;
   bounds.origin.y = 0;
   [self.scrollView scrollRectToVisible:bounds animated:animated];
}



- (void) getMessages
{
   if(self.total == 0)
   {
      [self getCount];
   }
   
   NSURL *url = [NSURL URLWithString:[NSString stringWithFormat: @"http://0.0.0.0:3000/messages/selection/%d.json", self.offset]];

   
   NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                          cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:20.0];
   

   [request setHTTPMethod:@"GET"];
   
   [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
   
   NSOperationQueue *queue = [[NSOperationQueue alloc] init];
   [NSURLConnection sendAsynchronousRequest:request
                                      queue:queue
                          completionHandler:^(NSURLResponse *response, NSData *responseData, NSError *error) {
                             if (error == nil) {
                                
                                 NSString * jsonString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
                                
                                NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
                                self.returnedMessages = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];
                                
                                NSMutableArray *array = [NSMutableArray arrayWithCapacity:[self.returnedMessages count]];
                                NSEnumerator *enumerator = [self.returnedMessages reverseObjectEnumerator];
                                for (id element in enumerator) {
                                   [array addObject:element];
                                }
                                
                                [self.messages addObjectsFromArray:array];
                              
                                self.offset = [self.messages count];
                                dispatch_async(dispatch_get_main_queue(), ^{
                                   [self.messagesTable reloadData];
                                });
                             }
                             else {
                                UIAlertView *alert1 = [[UIAlertView alloc] initWithTitle: @"Failure" message: @"Something went terribly wrong..."delegate: nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                                
                                [alert1 performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:YES];
                             }
                          }];

   
}


- (IBAction)show:(id)sender {
   self.messagesTable.hidden = NO;
   self.hideAll.hidden = NO;
   self.viewAll.hidden = YES;
   self.pagesViewButton.hidden = NO;
   

}


- (IBAction)hide:(id)sender {
   self.messagesTable.hidden =YES;
   self.hideAll.hidden = YES;
   self.viewAll.hidden = NO;
   self.pagesViewButton.hidden = YES;
   self.scrollView.hidden = YES;
   self.pageControl.hidden = YES;
}


#pragma TableViewDataSource


- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
   if (self.offset == 0) {
      return 1;
   }
   if([self.messages count] < self.total)
      return [self.messages count] +1;
   else
      return self.total;
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
   NSString* cellID = @"CellID";
   NSUInteger indexRow = [indexPath row];
   UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellID];
   
   
   if (cell == nil)
   {
      cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID];
   }
   
   if (indexPath.row < [self.messages count]) {
      NSDictionary * dict = self.messages[indexRow];
   
      cell.textLabel.text = [dict objectForKey:@"content"] ;
      cell.detailTextLabel.text = [dict objectForKey:@"username"];
      cell.textLabel.numberOfLines = 0;
      
      cell.tag = 2;
   }
   else{
      return [self loadingCell];
   }
   return cell;
}

#pragma mark UITableViewDelegate
- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
   return 50;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
   return NO;
}

- (UITableViewCell *)loadingCell {
   UITableViewCell *cell = [[UITableViewCell alloc]
                             initWithStyle:UITableViewCellStyleDefault
                             reuseIdentifier:nil];
   
   UIActivityIndicatorView *activityIndicator =
   [[UIActivityIndicatorView alloc]
    initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
   activityIndicator.center = cell.center;
   [cell addSubview:activityIndicator];
   
   [activityIndicator startAnimating];
   
   cell.tag = 0;
   
   return cell;
}

- (void)tableView:(UITableView *)tableView
  willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath {
   if (cell.tag == 0 && self.offset < self.total) {
      [self getMessages];
   }
   if(self.offset == 0 && cell.tag == 0)
   {
      [self getMessages];
   }
}

@end
