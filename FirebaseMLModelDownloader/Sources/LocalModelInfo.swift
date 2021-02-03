// Copyright 2021 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import Foundation
import FirebaseCore

/// Model info object with details about downloaded and locally available model.
// TODO: Can this be backed by user defaults property wrappers?
class LocalModelInfo {
  /// Model name.
  let name: String

  /// Hash of the model, as returned by server.
  let modelHash: String

  /// Size of the model, as returned by server.
  let size: Int

  init(name: String, modelHash: String, size: Int) {
    self.name = name
    self.modelHash = modelHash
    self.size = size
  }

  /// Convenience init to create local model info from remotely downloaded model info and a local model path.
  convenience init(from remoteModelInfo: RemoteModelInfo) {
    self.init(
      name: remoteModelInfo.name,
      modelHash: remoteModelInfo.modelHash,
      size: remoteModelInfo.size
    )
  }

  /// Convenience init to create local model info from stored info in user defaults.
  convenience init?(fromDefaults defaults: UserDefaults, name: String, appName: String) {
    let defaultsPrefix = LocalModelInfo.getUserDefaultsKeyPrefix(appName: appName, modelName: name)
    guard let modelHash = defaults.value(forKey: "\(defaultsPrefix).model-hash") as? String,
      let size = defaults.value(forKey: "\(defaultsPrefix).model-size") as? Int else {
      return nil
    }
    self.init(name: name, modelHash: modelHash, size: size)
  }
}

/// Extension to write local model info to user defaults.
extension LocalModelInfo: DownloaderUserDefaultsWriteable {
  /// Get user defaults key prefix.
  private static func getUserDefaultsKeyPrefix(appName: String, modelName: String) -> String {
    let bundleID = Bundle.main.bundleIdentifier ?? ""
    return "\(bundleID).\(appName).\(modelName)"
  }

  /// Write local model info to user defaults.
  func writeToDefaults(_ defaults: UserDefaults, appName: String) {
    let defaultsPrefix = LocalModelInfo.getUserDefaultsKeyPrefix(appName: appName, modelName: name)
    defaults.setValue(modelHash, forKey: "\(defaultsPrefix).model-hash")
    defaults.setValue(size, forKey: "\(defaultsPrefix).model-size")
  }

  func removeFromDefaults(_ defaults: UserDefaults, appName: String) {
    let defaultsPrefix = LocalModelInfo.getUserDefaultsKeyPrefix(appName: appName, modelName: name)
    defaults.removeObject(forKey: "\(defaultsPrefix).model-hash")
    defaults.removeObject(forKey: "\(defaultsPrefix).model-size")
  }
}

/// Named user defaults for FirebaseML.
extension UserDefaults {
  static var firebaseMLDefaults: UserDefaults {
    let suiteName = "com.google.firebase.ml"
    // TODO: reconsider force unwrapping
    let defaults = UserDefaults(suiteName: suiteName)!
    return defaults
  }
}
