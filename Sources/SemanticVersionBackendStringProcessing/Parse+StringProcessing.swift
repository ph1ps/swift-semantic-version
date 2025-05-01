import SemanticVersionBackendCore

@available(iOS 16.0, macOS 13.0, macCatalyst 16.0, tvOS 16.0, watchOS 9.0, visionOS 1.0, *)
nonisolated(unsafe) let stringProcessingRegex = /^(?<major>0|[1-9]\d*)\.(?<minor>0|[1-9]\d*)\.(?<patch>0|[1-9]\d*)(?:-(?<prerelease>(?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*)(?:\.(?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*))*))?(?:\+(?<buildmetadata>[0-9a-zA-Z-]+(?:\.[0-9a-zA-Z-]+)*))?$/

@available(iOS 16.0, macOS 13.0, macCatalyst 16.0, tvOS 16.0, watchOS 9.0, visionOS 1.0, *)
public func parse(stringProcessing string: String) -> (UInt, UInt, UInt, [_Prerelease], String?)? {
  guard
    let match = try? stringProcessingRegex.firstMatch(in: string),
    let major = UInt(match.output.major),
    let minor = UInt(match.output.minor),
    let patch = UInt(match.output.patch)
  else { return nil }
  
  let prerelease = match.output.prerelease.map {
    $0.split(separator: ".").map {
      if let number = UInt($0) {
        return _Prerelease.numeric(number)
      } else {
        return .alphanumeric(String($0))
      }
    }
  }
  
  let build = match.output.buildmetadata.map { String($0) }
  return (major: major, minor: minor, patch: patch, prerelease: prerelease ?? [], build: build)
}
