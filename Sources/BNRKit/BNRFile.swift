import Foundation

public struct BNRMetadata: Equatable, Sendable {
    public let language: String
    public let shortTitle: String
    public let shortMaker: String
    public let longTitle: String
    public let longMaker: String
    public let description: String
}

public struct BNRFile: Sendable {
    public static let imageWidth = 96
    public static let imageHeight = 32

    public let format: String
    public let rgbaPixels: [UInt8]
    public let metadata: [BNRMetadata]

    public init(data: Data) throws {
        guard data.count >= 0x1960 else { throw BNRParseError.fileTooShort }

        let magic = String(decoding: data.prefix(4), as: UTF8.self)
        let languages: [String]
        switch magic {
        case "BNR1": languages = ["English"]
        case "BNR2":
            guard data.count >= 0x1FA0 else { throw BNRParseError.fileTooShort }
            languages = ["English", "German", "French", "Spanish", "Italian", "Dutch"]
        default: throw BNRParseError.invalidMagic
        }

        format = magic
        rgbaPixels = Self.decodeImage(data[0x20..<0x1820])
        metadata = languages.enumerated().map { index, language in
            let offset = 0x1820 + index * 0x140
            return BNRMetadata(
                language: language,
                shortTitle: Self.decodeText(data[offset..<(offset + 0x20)]),
                shortMaker: Self.decodeText(data[(offset + 0x20)..<(offset + 0x40)]),
                longTitle: Self.decodeText(data[(offset + 0x40)..<(offset + 0x80)]),
                longMaker: Self.decodeText(data[(offset + 0x80)..<(offset + 0xC0)]),
                description: Self.decodeText(data[(offset + 0xC0)..<(offset + 0x140)])
            )
        }
    }

    private static func decodeText(_ bytes: Data.SubSequence) -> String {
        let content = Data(bytes.prefix { $0 != 0 })
        return String(data: content, encoding: .shiftJIS)
            ?? String(data: content, encoding: .utf8)
            ?? String(decoding: content, as: UTF8.self)
    }

    private static func decodeImage(_ bytes: Data.SubSequence) -> [UInt8] {
        let source = Array(bytes)
        var output = [UInt8](repeating: 0, count: imageWidth * imageHeight * 4)
        var sourceOffset = 0

        for tileY in stride(from: 0, to: imageHeight, by: 4) {
            for tileX in stride(from: 0, to: imageWidth, by: 4) {
                for y in 0..<4 {
                    for x in 0..<4 {
                        let pixel = UInt16(source[sourceOffset]) << 8 | UInt16(source[sourceOffset + 1])
                        sourceOffset += 2
                        let destination = ((tileY + y) * imageWidth + tileX + x) * 4

                        if pixel & 0x8000 != 0 {
                            output[destination] = expand5(UInt8((pixel >> 10) & 0x1F))
                            output[destination + 1] = expand5(UInt8((pixel >> 5) & 0x1F))
                            output[destination + 2] = expand5(UInt8(pixel & 0x1F))
                            output[destination + 3] = 255
                        } else {
                            output[destination] = expand4(UInt8((pixel >> 8) & 0x0F))
                            output[destination + 1] = expand4(UInt8((pixel >> 4) & 0x0F))
                            output[destination + 2] = expand4(UInt8(pixel & 0x0F))
                            let alpha = UInt8((pixel >> 12) & 0x07)
                            output[destination + 3] = (alpha << 5) | (alpha << 2) | (alpha >> 1)
                        }
                    }
                }
            }
        }
        return output
    }

    private static func expand5(_ value: UInt8) -> UInt8 { (value << 3) | (value >> 2) }
    private static func expand4(_ value: UInt8) -> UInt8 { (value << 4) | value }
}

public enum BNRParseError: Error, Equatable {
    case fileTooShort
    case invalidMagic
}
