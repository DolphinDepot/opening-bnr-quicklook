import Foundation
import Testing
@testable import BNRKit

struct BNRFileTests {
    @Test func parsesBNR1MetadataAndRGB5A3Image() throws {
        var data = Data(repeating: 0, count: 0x1960)
        data.replaceSubrange(0..<4, with: Data("BNR1".utf8))
        data[0x20] = 0xFC
        data[0x21] = 0x00
        write("Short title", to: &data, at: 0x1820, length: 0x20)
        write("Maker", to: &data, at: 0x1840, length: 0x20)
        write("Long title", to: &data, at: 0x1860, length: 0x40)
        write("Long maker", to: &data, at: 0x18A0, length: 0x40)
        write("Description", to: &data, at: 0x18E0, length: 0x80)

        let bnr = try BNRFile(data: data)

        #expect(bnr.format == "BNR1")
        #expect(bnr.metadata == [BNRMetadata(
            language: "English", shortTitle: "Short title", shortMaker: "Maker",
            longTitle: "Long title", longMaker: "Long maker", description: "Description"
        )])
        #expect(Array(bnr.rgbaPixels.prefix(4)) == [255, 0, 0, 255])
        #expect(bnr.rgbaPixels.count == 96 * 32 * 4)
    }

    @Test func parsesSixBNR2Languages() throws {
        var data = Data(repeating: 0, count: 0x1FA0)
        data.replaceSubrange(0..<4, with: Data("BNR2".utf8))
        for index in 0..<6 {
            write("Title \(index)", to: &data, at: 0x1820 + index * 0x140, length: 0x20)
        }

        let bnr = try BNRFile(data: data)
        #expect(bnr.metadata.count == 6)
        #expect(bnr.metadata[5].language == "Dutch")
        #expect(bnr.metadata[5].shortTitle == "Title 5")
    }

    @Test func rejectsUnknownFiles() {
        #expect(throws: BNRParseError.invalidMagic) {
            try BNRFile(data: Data(repeating: 0, count: 0x1960))
        }
    }

    private func write(_ string: String, to data: inout Data, at offset: Int, length: Int) {
        let bytes = Data(string.utf8.prefix(length - 1))
        data.replaceSubrange(offset..<(offset + bytes.count), with: bytes)
    }
}
