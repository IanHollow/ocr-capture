#if canImport(Testing)
  import Testing

  @testable import OCRCapture

  struct ConfigurationBoundaryTests {
    @Test(arguments: ["--timeout", "--minimum-text-height"], ["nan", "inf", "-inf", "1e309"])
    func rejectsNonfiniteNumbers(option: String, value: String) {
      #expect(throws: OCRCaptureError.self) {
        _ = try ConfigurationParser.parse(["capture", option, value])
      }
    }

    @Test(arguments: ["--max-pixels", "--max-input-bytes", "--candidates"])
    func rejectsIntegerOverflow(option: String) {
      #expect(throws: OCRCaptureError.self) {
        _ = try ConfigurationParser.parse(["capture", option, String(Int.max) + "0"])
      }
    }

    @Test
    func rejectsResourceLimits() {
      for (option, value) in [
        ("--max-pixels", "100000001"),
        ("--max-input-bytes", "268435457"),
        ("--timeout", "301"),
        ("--timeout", "0.01"),
      ] {
        #expect(throws: OCRCaptureError.self) {
          _ = try ConfigurationParser.parse(["capture", option, value])
        }
      }
    }

    @Test(arguments: [0, 1])
    func acceptsTextHeightBoundaries(value: Int) throws {
      let configuration = try ConfigurationParser.parse([
        "capture", "--minimum-text-height", String(value),
      ])
      #expect(configuration.minimumTextHeight == Float(value))
    }

    @Test(arguments: [1, 10])
    func acceptsCandidateBoundaries(value: Int) throws {
      let configuration = try ConfigurationParser.parse(["capture", "--candidates", String(value)])
      #expect(configuration.maximumCandidates == value)
    }
  }
#endif
