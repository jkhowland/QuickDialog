//
// Copyright 2011 ESCOZ Inc  - http://escoz.com
//
// Licensed under the Apache License, Version 2.0 (the "License"); you may not use this
// file except in compliance with the License. You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software distributed under
// the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF
// ANY KIND, either express or implied. See the License for the specific language governing
// permissions and limitations under the License.
//

#import "QuickDialogDataSource.h"
#import "QSortingSection.h"
#import "QuickDialog.h"

@implementation QuickDialogDataSource

- (id <UITableViewDataSource>)initForTableView:(QuickDialogTableView *)tableView {
    self = [super init];
    if (self) {
        _tableView = tableView;
    }
    return self;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_tableView.root getVisibleSectionForIndex:section].visibleNumberOfElements;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    QSection *section = [_tableView.root getVisibleSectionForIndex:indexPath.section];
    QElement *element = [section getVisibleElementForIndex:indexPath.row];
    element.controller = _tableView.controller;
    UITableViewCell *cell = [element getCellForTableView:(QuickDialogTableView *) tableView controller:_tableView.controller];
    cell.accessibilityLabel = element.accessibilityLabel;
    cell.accessibilityIdentifier = element.accessibilityIdentifier;
    cell.userInteractionEnabled = element.enabled;
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [_tableView.root visibleNumberOfSections];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [_tableView.root getVisibleSectionForIndex:section].title;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    return [_tableView.root getVisibleSectionForIndex:section].footer;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return [[_tableView.root getVisibleSectionForIndex:indexPath.section] isKindOfClass:[QSortingSection class]];
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    QSortingSection *section = ((QSortingSection *) [_tableView.root getVisibleSectionForIndex: indexPath.section]);
    
    QElement *element;
    if (section.elements.count >= indexPath.row) {
        element = section.elements[indexPath.row];
    }
    
    if ([element.controller respondsToSelector:@selector(shouldDeleteElement:)]) {
        if (![(QuickDialogController *)element.controller shouldDeleteElement:element]) {
            return;
        };
    }
    
    if ([section removeElementForRow:indexPath.row]){
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    QSortingSection *section = ((QSortingSection *) [_tableView.root getVisibleSectionForIndex: sourceIndexPath.section]);
    [section moveElementFromRow:(NSUInteger) sourceIndexPath.row toRow:(NSUInteger) destinationIndexPath.row];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    QSection  *section = [_tableView.root getVisibleSectionForIndex: indexPath.section];
    if ([section isKindOfClass:[QSortingSection class]]){
        return ([(QSortingSection *) section canRemoveElementForRow:indexPath.row]);
    }
    return tableView.editing;
}

+ (CGFloat)heightForRowAtIndexPath:(NSIndexPath *)indexPath tableView:(QuickDialogTableView *)tableView {
    
    QSection *section = [tableView.root getVisibleSectionForIndex:indexPath.section];
    QElement *element = [section getVisibleElementForIndex:indexPath.row];
    
    if ([element isKindOfClass:[QRadioItemElement class]]) {
        element.controller = tableView.controller;
        
        UITableViewCell *cell = [element getCellForTableView:(QuickDialogTableView *) tableView controller:tableView.controller];
        
        UIFont *font = [UIFont systemFontOfSize:19];
        NSDictionary *attributes = @{NSFontAttributeName: font};
        CGRect boundingRect = [cell.textLabel.text boundingRectWithSize:CGSizeMake(300, CGFLOAT_MAX)
                                                                options:NSStringDrawingUsesLineFragmentOrigin
                                                             attributes:attributes
                                                                context:nil];
        
        
        return MAX(boundingRect.size.height + 22, 44);
        
    } else {
        return 44;
    }
    
}


@end
