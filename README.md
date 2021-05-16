<h1 align="center">
    EU Digital Green Certificates App Core - iOS
</h1>

<p align="center">
    <a href="/../../commits/" title="Last Commit"><img src="https://img.shields.io/github/last-commit/eu-digital-green-certificates/dgca-app-core-ios?style=flat"></a>
    <a href="/../../issues" title="Open Issues"><img src="https://img.shields.io/github/issues/eu-digital-green-certificates/dgca-app-core-ios?style=flat"></a>
    <a href="./LICENSE" title="License"><img src="https://img.shields.io/badge/License-Apache%202.0-green.svg?style=flat"></a>
</p>

<p align="center">
  <a href="#about">About</a> •
  <a href="#development">Development</a> •
  <a href="#documentation">Documentation</a> •
  <a href="#support-and-feedback">Support</a> •
  <a href="#how-to-contribute">Contribute</a> •
  <a href="#contributors">Contributors</a> •
  <a href="#licensing">Licensing</a>
</p>

## About

This repository contains the source code of the Digital Green Certificates App Core for iOS.

The app core provides shared functionality for the [verifier](https://github.com/eu-digital-green-certificates/dgca-verifier-app-ios) and [wallet](https://github.com/eu-digital-green-certificates/dgca-wallet-app-ios) apps.

## Translators 💬

You can help the localization of this project by making contributions to the [/Localization folder](Localization/SwiftDGC).

## Development

### Prerequisites

- You need a Mac to run Xcode.
- Xcode 12.5+ is used for our builds. The OS requirement is macOS 11.0+.
- To install development apps on physical iPhones, you need an Apple Developer account.

### Build

Since this is just a requirement module, it is used as a dependency in both the verifier and wallet apps on iOS.
For that, Xcode builds the module from source in the target app. Because of that, building this module on its own is not supported.

## Testing 🧑‍🔬  

This project uses the [testdata repo](https://github.com/eu-digital-green-certificates/dgc-testdata) for automatic tests. You can run tests in two ways:

1. Either via `./test.sh`,
2. Or via the Xcode project `project-for-testing/project-for-testing.xcodeproj`.

The second option is good for debugging single test case failures. Run the test script (1.) once, so that the data repo is checked out. Then, open Xcode and run the tests. You can [add automatic test failure breakpoints](https://developer.apple.com/library/archive/documentation/DeveloperTools/Conceptual/testing_with_xcode/chapters/06-debugging_tests.html#:~:text=Test%20Failure%20Breakpoint,-In%20the%20breakpoint&text=This%20breakpoint%20stops%20the%20test,failure%20in%20the%20test%20code.) for easy debugging.

## Documentation  

- [ ] TODO: Link to documentation

## Support and feedback

The following channels are available for discussions, feedback, and support requests:

| Type                     | Channel                                                |
| ------------------------ | ------------------------------------------------------ |
| **Issues**    | <a href="/../../issues" title="Open Issues"><img src="https://img.shields.io/github/issues/eu-digital-green-certificates/dgca-app-core-ios?style=flat"></a>  |
| **Other requests**    | <a href="mailto:opensource@telekom.de" title="Email DGC Team"><img src="https://img.shields.io/badge/email-DGC%20team-green?logo=mail.ru&style=flat-square&logoColor=white"></a>   |

## How to contribute  

Contribution and feedback is encouraged and always welcome. For more information about how to contribute, the project structure, as well as additional contribution information, see our [Contribution Guidelines](./CONTRIBUTING.md). By participating in this project, you agree to abide by its [Code of Conduct](./CODE_OF_CONDUCT.md) at all times.

## Contributors  

Our commitment to open source means that we are enabling -in fact encouraging- all interested parties to contribute and become part of its developer community.

## Licensing

Copyright (C) 2021 T-Systems International GmbH and all other contributors

Licensed under the **Apache License, Version 2.0** (the "License"); you may not use this file except in compliance with the License.

You may obtain a copy of the License at https://www.apache.org/licenses/LICENSE-2.0.

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the [LICENSE](./LICENSE) for the specific language governing permissions and limitations under the License.
