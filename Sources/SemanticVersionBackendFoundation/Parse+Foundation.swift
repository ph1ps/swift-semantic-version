import Foundation
import SemanticVersionBackendCore

let foundationRegex = try? NSRegularExpression(pattern: #"^(?<major>0|[1-9]\d*)\.(?<minor>0|[1-9]\d*)\.(?<patch>0|[1-9]\d*)(?:-(?<prerelease>(?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*)(?:\.(?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*))*))?(?:\+(?<buildmetadata>[0-9a-zA-Z-]+(?:\.[0-9a-zA-Z-]+)*))?$"#)

public func parse(foundation string: String) -> (UInt, UInt, UInt, [_Prerelease], String?)? {
  guard
    let foundationRegex,
    let match = foundationRegex.firstMatch(in: string, range: .init(string.startIndex..., in: string)),
    let majorRange = Range(match.range(at: 1), in: string),
    let minorRange = Range(match.range(at: 2), in: string),
    let patchRange = Range(match.range(at: 3), in: string),
    let major = UInt(string[majorRange]),
    let minor = UInt(string[minorRange]),
    let patch = UInt(string[patchRange])
  else { return nil }
  
  let prerelease = Range(match.range(at: 4), in: string).map {
    string[$0].split(separator: ".").map {
      if let number = UInt($0) {
        return _Prerelease.numeric(number)
      } else {
        return .alphanumeric(String($0))
      }
    }
  }
  
  let build = Range(match.range(at: 5), in: string).map { String(string[$0]) }
  return (major: major, minor: minor, patch: patch, prerelease: prerelease ?? [], build: build)
}
