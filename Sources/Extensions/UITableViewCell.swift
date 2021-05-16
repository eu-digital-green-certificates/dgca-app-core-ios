/*-
 * ---license-start
 * eu-digital-green-certificates / dgca-app-core-ios
 * ---
 * Copyright (C) 2021 T-Systems International GmbH and all other contributors
 * ---
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 * ---license-end
 */
//
//  UITableViewCell.swift
//  
//
//  Created by Yannick Spreen on 5/16/21.
//

#if os(iOS)
import UIKit

public extension UITableViewCell {
  func removeSectionSeparator() {
    for subview in subviews {
      if
        subview != contentView,
        abs(subview.frame.width - frame.width) <= 0.1,
        subview.frame.height < 2
      {
        subview.alpha = 0
      }
    }
  }
}

public class BorderLessSectionCell: UITableViewCell {
  public override func layoutSubviews() {
    super.layoutSubviews()
    removeSectionSeparator()
  }
}
#endif
