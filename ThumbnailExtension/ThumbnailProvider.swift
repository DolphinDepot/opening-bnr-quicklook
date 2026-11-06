import CoreGraphics
import QuickLookThumbnailing

final class ThumbnailProvider: QLThumbnailProvider {
    override func provideThumbnail(for request: QLFileThumbnailRequest, _ handler: @escaping (QLThumbnailReply?, Error?) -> Void) {
        do {
            let data = try Data(contentsOf: request.fileURL, options: .mappedIfSafe)
            let bnr = try BNRFile(data: data)

            let maximum = request.maximumSize
            let scale = min(maximum.width / CGFloat(BNRFile.imageWidth), maximum.height / CGFloat(BNRFile.imageHeight))
            let size = CGSize(width: CGFloat(BNRFile.imageWidth) * scale, height: CGFloat(BNRFile.imageHeight) * scale)
            // Quick Look smooths the drawn image regardless of interpolation settings,
            // so upscale with nearest neighbour first to keep the pixel art sharp.
            let image = try Self.makeImage(from: bnr, factor: max(1, Int((scale * request.scale).rounded(.up))))

            handler(QLThumbnailReply(contextSize: size) { context in
                context.draw(image, in: CGRect(origin: .zero, size: size))
                return true
            }, nil)
        } catch {
            handler(nil, error)
        }
    }

    private static func makeImage(from bnr: BNRFile, factor: Int) throws -> CGImage {
        let width = BNRFile.imageWidth * factor
        let height = BNRFile.imageHeight * factor
        var pixels = [UInt8](repeating: 0, count: width * height * 4)
        for y in 0..<height {
            for x in 0..<width {
                let source = ((y / factor) * BNRFile.imageWidth + x / factor) * 4
                let destination = (y * width + x) * 4
                pixels[destination..<(destination + 4)] = bnr.rgbaPixels[source..<(source + 4)]
            }
        }

        guard
            let provider = CGDataProvider(data: Data(pixels) as CFData),
            let image = CGImage(
                width: width, height: height,
                bitsPerComponent: 8, bitsPerPixel: 32, bytesPerRow: width * 4,
                space: CGColorSpaceCreateDeviceRGB(),
                bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.last.rawValue),
                provider: provider, decode: nil, shouldInterpolate: false, intent: .defaultIntent
            )
        else { throw CocoaError(.fileReadCorruptFile) }
        return image
    }
}
