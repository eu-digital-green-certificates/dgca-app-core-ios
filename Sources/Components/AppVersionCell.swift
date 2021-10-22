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
//  AppVersionCell.swift
//  
//
//  Created by Yannick Spreen on 5/16/21.
//

#if os(iOS)
import UIKit

public class AppVersionCell: UITableViewCell {
  @IBOutlet weak var versionLabel: UILabel!

  public override func layoutSubviews() {
    super.layoutSubviews()

    let version = Bundle.main.releaseVersionNumber ?? "-"
    let build = Bundle.main.buildVersionNumber ?? "-"
    let format = l10n("app-version")
    versionLabel.text = String(format: format, version, build)
    removeSectionSeparator()
  }
}
#endif
