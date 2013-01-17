//
//  ImageTableViewCell.m
//  SparkiOS
//
//  Created by David Ragones on 1/5/13.
//
//  Copyright (c) 2013 Financial Business Systems, Inc. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import "ImageTableViewCell.h"

@implementation ImageTableViewCell

- (void)layoutSubviews {
    [super layoutSubviews];
    // reset frames so no shifting on image load
    self.imageView.frame = CGRectMake(1,1,40,40);
    self.textLabel.frame = CGRectMake(51,2,239,22);
    self.detailTextLabel.frame = CGRectMake(51,24,239,18);
}

@end
