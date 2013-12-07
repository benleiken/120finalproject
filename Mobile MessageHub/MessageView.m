//
//  MessageView.m
//  Mobile MessageHub
//
//  Created by Ben Leiken on 12/6/13.
//  Copyright (c) 2013 BKL. All rights reserved.
//

#import "MessageView.h"

@interface MessageView()

@property (nonatomic, strong) UILabel * authorLabel;
@property (nonatomic, strong) UILabel * contentLabel;


@end

@implementation MessageView

- (id)initWithFrame:(CGRect)frame andAuthor:(NSString *) author andContent:(NSString *) content
{
    self = [super initWithFrame:frame];
    if (self) {
       
       CGFloat x = [[UIScreen mainScreen] bounds].size.width;
       CGFloat y = [[UIScreen mainScreen] bounds].size.height;
       
       self.authorLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, x/2, 100)];
       self.contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, y/2, x/2, 200)];
       
       self.authorLabel.text = author;
       self.contentLabel.text = content;
       
       self.authorLabel.textColor = [UIColor blackColor];
       self.contentLabel.textColor = [UIColor blackColor];
       
       [self addSubview:self.authorLabel];
       [self addSubview:self.contentLabel];
       self.backgroundColor = [UIColor whiteColor];
       
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
