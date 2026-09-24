import Foundation
import XCTest

@testable import OCRCapture

final class ConfigurationFuzzTests: XCTestCase {
  func testBoundedArgumentMutations() {
    let seeds: [[String]] = [
      ["capture", "--timeout", "0.1"],
      ["capture", "--minimum-text-height", "1"],
      ["capture", "--max-pixels", "100000000"],
      ["capture", "--max-input-bytes", "268435456"],
      ["capture", "--candidates", "10"],
      ["capture", "--destination", "clipboard,stdout"],
      ["image", "/tmp/input.png", "--backend", "document", "--render", "markdown"],
      ["stdin", "--language", "en-US", "--custom-word", "example"],
      ["capture", "--timeout", "nan"],
      ["capture", "--max-pixels", "999999999999999999999999"],
    ]
    var random = ArgumentMutationRandom(state: 0xEC4A_71A5_2026)

    for iteration in 0..<1_000 {
      var arguments = seeds[Int(random.next() % UInt64(seeds.count))]
      let position = Int(random.next() % UInt64(arguments.count))
      var bytes = Array(arguments[position].utf8)
      let offset = Int(random.next() % UInt64(bytes.count + 1))
      switch random.next() % 3 {
      case 0 where !bytes.isEmpty:
        bytes.remove(at: min(offset, bytes.count - 1))
      case 1 where bytes.count < 96:
        bytes.insert(UInt8(truncatingIfNeeded: random.next()), at: offset)
      default:
        if !bytes.isEmpty {
          bytes[min(offset, bytes.count - 1)] = UInt8(truncatingIfNeeded: random.next())
        }
      }
      guard let mutated = String(bytes: bytes, encoding: .utf8) else { continue }
      arguments[position] = mutated

      do {
        let result = try ConfigurationParser.parse(arguments)
        XCTAssertTrue(
          result.minimumTextHeight >= 0 && result.minimumTextHeight <= 1, "case \(iteration)"
        )
        XCTAssertTrue(result.maximumPixels >= 1 && result.maximumPixels <= 100_000_000)
        XCTAssertTrue(result.maximumInputBytes >= 1 && result.maximumInputBytes <= 268_435_456)
        XCTAssertTrue(result.timeout >= 0.1 && result.timeout <= 300)
        XCTAssertTrue(result.maximumCandidates >= 1 && result.maximumCandidates <= 10)
      } catch is OCRCaptureError {
        continue
      } catch {
        XCTFail("Unexpected error in case \(iteration): \(error)")
      }
    }
  }
}

private struct ArgumentMutationRandom {
  var state: UInt64

  mutating func next() -> UInt64 {
    state ^= state << 13
    state ^= state >> 7
    state ^= state << 17
    return state
  }
}
