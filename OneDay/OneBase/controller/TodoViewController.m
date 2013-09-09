//
//  InputViewController.m
//  OneDay
//
//  Created by Yu Tianhang on 12-10-30.
//  Copyright (c) 2012年 Kimi Yu. All rights reserved.
//

#import "TodoViewController.h"
#import "TipViewController.h"
#import "DarkNavigationBarButton.h"

#import "DailyDoManager.h"
#import "KMModelManager.h"
#import "DailyDoBase.h"
#import "TodoData.h"
#import "AddonData.h"
#import "Smark.h"
#import "HintHelper.h"
#import "NSString+NSStringAdditions.h"

#define HelperWordButtonTagPrefix 10000

@interface TodoViewController () <UITextViewDelegate> {
    NSRange _selectRange;
    NSRange _removeTextRange;
    
    BOOL _needHandle;
}
@property (nonatomic) NSMutableArray *todos;
@property (nonatomic) NSString *removeText;
@property (nonatomic) NSString *appendText;
@property (nonatomic, weak) SMDetector *detector;
@property (nonatomic) HintHelper *hint;
@end

@implementation TodoViewController

- (NSString *)pageNameForTrack
{
    return [NSString stringWithFormat:@"TodoPage_%@", _dailyDo.addon.dailyDoName];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"todoPushToTipPage"]) {
        TipViewController *tController = segue.destinationViewController;
        tController.currentAddon = _dailyDo.addon;
        
        UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
        leftButton.frame = CGRectMake(5.f, 0, 44.f, 44.f);
        [leftButton setImage:[UIImage imageNamed:@"nav_back.png"] forState:UIControlStateNormal];
        UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
        [leftButton addTarget:tController action:@selector(cancel:) forControlEvents:UIControlEventTouchUpInside];
        tController.navigationItem.leftBarButtonItem = leftItem;
    }
}

- (void)reportKeyboardDidChangeFrame:(NSNotification *)notification
{
    CGFloat duration = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    CGRect keyboardFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    UIWindow *mainWindow = [[[UIApplication sharedApplication] windows] objectAtIndex:0];
    keyboardFrame = [mainWindow.rootViewController.view convertRect:keyboardFrame fromView:mainWindow];
    
    CGRect vFrame = self.view.frame;
    CGRect tFrame = _inputView.frame;
    tFrame.size.height = vFrame.size.height - keyboardFrame.size.height - SSHeight(_inputHelperBar);
    
    CGRect barFrame = _inputHelperBar.frame;
    barFrame.origin.y = CGRectGetMaxY(tFrame);
    
    [UIView animateWithDuration:duration animations:^{
        _inputView.frame = tFrame;
        _inputHelperBar.frame = barFrame;
    }];
}

#pragma mark - Viewliftcycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.detector = [SMDetector defaultDetector];
    self.hint = [[HintHelper alloc] initWithViewController:self dialogsPathPrefix:_dailyDo.addon.dailyDoName];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self updateInputHelperWords];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reportKeyboardDidChangeFrame:)
                                                 name:UIKeyboardWillChangeFrameNotification
                                               object:nil];
    
    [_dailyDo makeSnapshot];
    [self refreshText];
    
    if (![_hint show]) {
        [_inputView becomeFirstResponder];
    }
    else {
        [_hint setDidCloseTarget:self selector:@selector(handleHintClosed)];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
}

#pragma mark - private

- (void)handleHintClosed
{
    [_inputView becomeFirstResponder];
}

- (void)refreshText
{
    self.todos = [[_dailyDo todosSortedByIndex] mutableCopy];
    NSString *text = [_dailyDo todosTextWithLineNumber:YES];
    if ([text length] == 0 || [[text substringWithRange:NSMakeRange([text length] - 1, 1)] isEqualToString:SMSeparator]) {
        int index = [_todos count];
        TodoData *todo = [_dailyDo insertNewTodoAtIndex:index];
        todo.content = @"";
        [[KMModelManager sharedManager] saveContext:nil];
        
        [_todos addObject:todo];
        text = [NSString stringWithFormat:@"%@%d. ", text, index + 1];
        [self selectRangeMove:[todo lineNumberStringLength]];
    }
    
    _inputView.text = text;
    
    if ([_inputView.text length] <= 3) {
        NSString *tString = [[[DailyDoManager sharedManager] configurationsForDoName:_dailyDo.addon.dailyDoName] objectForKey:kConfigurationPlaceHolder];
        _inputView.placeholder = NSLocalizedString(tString, nil);
    }
    else {
        _inputView.placeholder = nil;
    }
        
    self.removeText = nil;
    self.appendText = nil;
}

- (void)updateInputHelperWords
{
    NSArray *words = [[DailyDoManager sharedManager] inputHelperWordsForDoName:_dailyDo.addon.dailyDoName];
    
    CGRect tFrame = _inputHelperBar.frame;
    
    if ([words count] > 0) {
        tFrame.size.height = 40.f;
        _inputHelperBar.hidden = NO;
        
        NSMutableArray *mutItems = [NSMutableArray arrayWithCapacity:5];
        [mutItems addObject:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil]];
        [words enumerateObjectsUsingBlock:^(NSString *word, NSUInteger idx, BOOL *stop) {
            DarkNavigationBarButton *tButton = [DarkNavigationBarButton buttonWithType:UIButtonTypeCustom];
            [tButton addTarget:self action:@selector(helperWordButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
            tButton.tag = HelperWordButtonTagPrefix + idx;
            [tButton setTitle:word forState:UIControlStateNormal];
            tButton.titleLabel.font = [UIFont boldSystemFontOfSize:12.f];
            [tButton sizeToFit];
            setFrameWithWidth(tButton, SSWidth(tButton) + 20.f);
            
            UIBarButtonItem *tItem = [[UIBarButtonItem alloc] initWithCustomView:tButton];
            [mutItems addObject:tItem];
        }];
        
        _inputHelperBar.items = [mutItems copy];
    }
    else {
        tFrame.size.height = 0.f;
        _inputHelperBar.hidden = YES;
    }
    
    _inputHelperBar.frame = tFrame;
}

#pragma mark - Actions

- (void)helperWordButtonClicked:(id)sender
{
    DarkNavigationBarButton *tButton = (DarkNavigationBarButton *)sender;
    NSArray *words = [[DailyDoManager sharedManager] inputHelperWordsForDoName:_dailyDo.addon.dailyDoName];
    
    int idx = tButton.tag - HelperWordButtonTagPrefix;
    if (idx < [words count]) {
        NSString *word = [words objectAtIndex:idx];
        
        if ([self textView:_inputView shouldChangeTextInRange:_inputView.selectedRange replacementText:word]) {
            _inputView.text = [_inputView.text stringByAppendingString:word];
            [self textViewDidChange:_inputView];
        }
    }
}

- (IBAction)cancel:(id)sender
{
    [_dailyDo recoveryToSnapshot];
//    [self refreshText];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)save:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
    [_dailyDo removeBlankTodos];
    [_dailyDo detectTodos];
}

#pragma mark - TextView Methods

- (NSUInteger)indexForRange:(NSRange)range
{
    __block NSUInteger ret = 0;
    __block NSRange compareRange = NSMakeRange(0, 0);
    
    [_todos enumerateObjectsUsingBlock:^(TodoData *todo, NSUInteger idx, BOOL *stop) {
        int length = [todo.content length];
        length += [todo lineNumberStringLength];
        
        compareRange = NSMakeRange(NSMaxRange(compareRange), length);
        if (range.location >= compareRange.location && NSMaxRange(range) <= NSMaxRange(compareRange)) {
            ret = idx;
            *stop = YES;
        }
    }];
    
    if (NSMaxRange(range) > NSMaxRange(compareRange)) {
        return [_todos count];
    }
    else {
        return ret;
    }
}

// return YES if has separator in removeText
- (BOOL)textView:(UITextView *)textView removeTextInRange:(NSRange*)pRange replacementText:(NSString *)text
{
    BOOL ret = NO;
    NSRange range = *pRange;
    if (range.length > 0) {
        NSArray *removeContents = [_removeText componentsSeparatedByString:SMSeparator];
        
        NSRange breakRange = [_removeText rangeOfString:SMSeparator];
        ret = breakRange.location != NSNotFound;
        
        NSUInteger index = [self indexForRange:(breakRange.length > 0 ? NSMakeRange(range.location, NSMaxRange(breakRange)) : range)];
        
        NSMutableArray *removeTodos = [NSMutableArray arrayWithCapacity:[removeContents count]];
        [removeContents enumerateObjectsUsingBlock:^(NSString *content, NSUInteger offset, BOOL *stop){
            
            TodoData *tmpTodo = [_todos objectAtIndex:index + offset];
            
            NSUInteger lineNumber = [_detector lineNumberForString:content];
            if (lineNumber == NSNotFound) {
                if (offset == 0) {
                    if (range.location < [tmpTodo lineNumberStringLength] + [_dailyDo todoTextLengthFromIndex:0 beforeIndex:index autoNumber:YES]) {
                        // content must prefix by space
                        if ([content length] > 1) {
                            NSString *contentTrimSpace = [content substringFromIndex:1];
                            if ([removeContents count] > 1) {
                                contentTrimSpace = [NSString stringWithFormat:@"%@%@", contentTrimSpace, SMSeparator];
                            }
                            NSUInteger tmpLocation = range.location + 1 - [tmpTodo lineNumberStringLength] - [_dailyDo todoTextLengthFromIndex:0 beforeIndex:index autoNumber:YES];
                            tmpTodo.content = [tmpTodo.content stringByReplacingOccurrencesOfString:contentTrimSpace withString:@"" options:0 range:NSMakeRange(tmpLocation, [tmpTodo.content length] - tmpLocation)];
                            
                            *pRange = NSMakeRange(range.location + 1, range.length - 1);
                        }
                        
                        if (index > 0) {
                            TodoData *preTodo = [_todos objectAtIndex:index - 1];
                            preTodo.content = [NSString stringWithFormat:@"%@%@", [preTodo pureContent], tmpTodo.content];
                            [removeTodos addObject:tmpTodo];
                            
                            [self selectRangeMove:-[tmpTodo lineNumberStringLength]];
                        }
                        else {
                            [self selectRangeMove:1];
                        }
                    }
                    else {
                        NSUInteger tmpLocation = range.location - [tmpTodo lineNumberStringLength] - [_dailyDo todoTextLengthFromIndex:0 beforeIndex:index autoNumber:YES];
                        tmpTodo.content = [tmpTodo.content stringByReplacingOccurrencesOfString:content withString:@"" options:0 range:NSMakeRange(tmpLocation, [tmpTodo.content length] - tmpLocation)];
                    }
                }
                else {
                    SSLog(@"Edit todo content when offset is %d not 0", index);
                }
            }
            else {
                content = [content stringByTrimmingLineNumber];
                if (offset != [removeContents count] - 1) {
                    content = [NSString stringWithFormat:@"%@%@", content, SMSeparator];
                }
                
                if ([content length] == [tmpTodo.content length]) {
                    [removeTodos addObject:tmpTodo];
                }
                else {
                    tmpTodo.content = [tmpTodo.content stringByReplacingOccurrencesOfString:content withString:@"" options:0 range:NSMakeRange(0, [content length])];
                }
            }
        }];
        
        if ([removeTodos count] > 0) {
            [_dailyDo removeTodos:removeTodos];
        }
        [[KMModelManager sharedManager] saveContext:nil];
    }
    return ret;
}

- (void)textView:(UITextView *)textView appendText:(NSString *)appendText atLocation:(NSUInteger)location
{
    if ([appendText length] > 0) {
        
        NSUInteger index = [self indexForRange:NSMakeRange(location, 0)];
        NSArray *appendContents = [appendText componentsSeparatedByString:SMSeparator];
        
        [appendContents enumerateObjectsUsingBlock:^(NSString *content, NSUInteger offset, BOOL *stop){
            NSUInteger lineNumber = [_detector lineNumberForString:content];
            if (lineNumber != NSNotFound) {
                content = [content stringByTrimmingLineNumber];
                [self selectRangeMove:-[[NSString stringWithFormat:@"%d. ", lineNumber] length]];
            }
            
            if (offset == 0) {
                TodoData *tmpTodo = [_todos objectAtIndex:index];
                NSUInteger relativeLocation = location - [tmpTodo lineNumberStringLength] - [_dailyDo todoTextLengthFromIndex:0 beforeIndex:index autoNumber:YES];
                NSMutableString *tmpContent = [tmpTodo.content mutableCopy];
                if (!tmpContent) {
                    tmpContent = [NSMutableString stringWithCapacity:[content length]];
                }
                [tmpContent insertString:content atIndex:relativeLocation];
                
                // TODO: quick fix bug
                if (tmpTodo.managedObjectContext) {
                    tmpTodo.content = tmpContent;
                }
            }
            else {
                TodoData *preTodo = [_todos objectAtIndex:index + offset - 1];
                NSRange tmpSeparatorRange = [preTodo.content rangeOfString:SMSeparator];
                if (tmpSeparatorRange.location == NSNotFound) {
                    preTodo.content = [NSString stringWithFormat:@"%@%@", preTodo.content, SMSeparator];
                    [self selectRangeMove:1];
                }
                
                TodoData *insertTodo = [_dailyDo insertNewTodoAtIndex:index + offset];
                if (offset != [appendContents count] - 1) {
                    insertTodo.content = [NSString stringWithFormat:@"%@%@", content, SMSeparator];
                }
                else {
                    insertTodo.content = content;
                }
                [_todos addObject:insertTodo];
            }
        }];
        
        [[KMModelManager sharedManager] saveContext:nil];
    }
}

- (void)selectRangeMove:(NSInteger)length
{
    _selectRange = NSMakeRange(_selectRange.location + length, 0);
}

- (BOOL)convertToAvailableRange:(NSRange*)originalRange removeText:(NSString *)text
{
    if ([text isEqualToString:SMSeparator]) {   // remove a separator is unavailable
        return NO;
    }
    
    NSRange markedRange = [_inputView markedRange];
    if (markedRange.length > 0) {
        NSUInteger tmpLocation = markedRange.location == NSNotFound ? (*originalRange).location : markedRange.location;
        NSUInteger tmpLength = (*originalRange).length >= markedRange.length ? (*originalRange).length - markedRange.length : (*originalRange).length;
        *originalRange = NSMakeRange(tmpLocation, tmpLength);
        
        if (NSEqualRanges(NSIntersectionRange(*originalRange, markedRange), *originalRange)) {
            return YES;
        }
    }
    
    NSUInteger index = [self indexForRange:*originalRange];
    
    if (index >= [_todos count]) {
        return NO;
    }
    
    TodoData *tmpTodo = [_todos objectAtIndex:index];
    NSUInteger beforeIndexLength = [_dailyDo todoTextLengthFromIndex:0 beforeIndex:index autoNumber:YES];
    
    NSRange compareRange;
    if ((*originalRange).length > 0) {
        // line number without space is unavailable range when remove text
        compareRange = NSMakeRange(beforeIndexLength, [tmpTodo lineNumberStringLength] - 1);
    }
    else {
        // line number containing space is unavailable range when only append text
        compareRange = NSMakeRange(beforeIndexLength, [tmpTodo lineNumberStringLength]);
    }
    
    NSRange intersectionRange = NSIntersectionRange(*originalRange, compareRange);
    if (NSMaxRange(intersectionRange) > 0) {
        if ((*originalRange).length < compareRange.length) {
            return NO;
        }
        else {
            *originalRange = NSMakeRange((*originalRange).location + intersectionRange.length, (*originalRange).length - intersectionRange.length);
            return YES;
        }
    }
    else {
        return YES;
    }
}

#pragma mark - UITextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    BOOL available = [self convertToAvailableRange:&range removeText:[textView.text substringWithRange:range]];
    if (available) {
        _selectRange = NSMakeRange(range.location + [text length], 0);
        _removeTextRange = range;
        
        self.removeText = [textView.text substringWithRange:range];
        self.appendText = text;
    }
    return available;
}

- (void)textViewDidChange:(UITextView *)textView
{
    if (KMEmptyString(_removeText) && KMEmptyString(_appendText)) {
        if ([textView.text length] == 0) {
            [self refreshText];
        }
        return;
    }
    
    NSRange markedRange = [textView markedRange];
    if (markedRange.length > 0 && KMEmptyString(_removeText)) {
        return;
    }
    else if (markedRange.length > 0 && [_removeText length] > 0) {
        if (NSIntersectionRange(markedRange, _removeTextRange).length > 0) {
            return;
        }
        else {
            // 全选内容后，输入中文会导致内容全部被删除，而没有默认的line number
            NSMutableString *tmpText = [textView.text mutableCopy];
            [tmpText deleteCharactersInRange:markedRange];
            textView.text = tmpText;
            
            self.appendText = @"";
        }
    }
    
    BOOL hasRemovedSeparator = [self textView:textView removeTextInRange:&_removeTextRange replacementText:_appendText];
    if ([_appendText isEqualToString:SMSeparator]) {
        if (!hasRemovedSeparator) {
            NSUInteger index = [self indexForRange:NSMakeRange(_removeTextRange.location, 0)];
            TodoData *tmpTodo = [_todos objectAtIndex:index];
            
            NSInteger tmpLocation = _removeTextRange.location - [tmpTodo lineNumberStringLength] - [_dailyDo todoTextLengthFromIndex:0 beforeIndex:index autoNumber:YES];
            if (tmpLocation >= 0) {
                TodoData *secondTodo = [_dailyDo separateTodoAtIndex:index fromContentCharacterIndex:tmpLocation];
                [self selectRangeMove:[secondTodo lineNumberStringLength]];
            }
        }
    }
    else {
        [self textView:textView appendText:_appendText atLocation:_removeTextRange.location];
    }
    
    [self refreshText];
    textView.selectedRange = _selectRange;
}

@end
