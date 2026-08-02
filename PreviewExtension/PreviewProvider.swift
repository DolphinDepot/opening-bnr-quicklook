import AppKit
import QuickLookUI
import UniformTypeIdentifiers

final class PreviewProvider: QLPreviewProvider, QLPreviewingController {
    func providePreview(for request: QLFilePreviewRequest) async throws -> QLPreviewReply {
        let data = try Data(contentsOf: request.fileURL, options: .mappedIfSafe)
        let bnr = try BNRFile(data: data)
        let html = try PreviewHTML.make(for: bnr)

        return QLPreviewReply(dataOfContentType: .html, contentSize: CGSize(width: 620, height: 640)) { reply in
            reply.stringEncoding = .utf8
            return Data(html.utf8)
        }
    }
}

private enum PreviewHTML {
    static func make(for bnr: BNRFile) throws -> String {
        let imageData = try pngData(pixels: bnr.rgbaPixels)
        let sections = bnr.metadata.map { item in
            """
            <h2>\(escape(item.language))</h2>
            <table>
              \(row("Short title", item.shortTitle))
              \(row("Short maker", item.shortMaker))
              \(row("Long title", item.longTitle))
              \(row("Long maker", item.longMaker))
              \(row("Description", item.description))
            </table>
            """
        }.joined()

        return """
        <!doctype html><meta charset="utf-8">
        <style>
          :root { color-scheme: light dark; }
          body { font: 13px -apple-system, sans-serif; margin: 28px; color: CanvasText; background: Canvas; }
          .banner { display: block; width: 384px; height: 128px; margin: 0 auto 24px; image-rendering: pixelated; }
          h1 { font-size: 20px; margin: 0 0 18px; } h2 { font-size: 14px; margin: 20px 0 6px; }
          table { width: 100%; border-collapse: collapse; table-layout: fixed; }
          th, td { padding: 7px 9px; border-bottom: 1px solid color-mix(in srgb, CanvasText 16%, transparent); vertical-align: top; }
          th { width: 110px; text-align: left; color: color-mix(in srgb, CanvasText 65%, transparent); font-weight: 500; }
          td { white-space: pre-wrap; overflow-wrap: anywhere; }
        </style>
        <img class="banner" src="data:image/png;base64,\(imageData.base64EncodedString())">
        <h1>\(escape(bnr.format)) metadata</h1>
        \(sections)
        """
    }

    private static func pngData(pixels: [UInt8]) throws -> Data {
        let bitmap = NSBitmapImageRep(
            bitmapDataPlanes: nil, pixelsWide: BNRFile.imageWidth, pixelsHigh: BNRFile.imageHeight,
            bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
            colorSpaceName: .deviceRGB, bytesPerRow: BNRFile.imageWidth * 4, bitsPerPixel: 32
        )!
        pixels.withUnsafeBytes { source in
            bitmap.bitmapData?.update(from: source.bindMemory(to: UInt8.self).baseAddress!, count: pixels.count)
        }
        guard let data = bitmap.representation(using: .png, properties: [:]) else { throw CocoaError(.fileWriteUnknown) }
        return data
    }

    private static func row(_ label: String, _ value: String) -> String {
        "<tr><th>\(escape(label))</th><td>\(escape(value))</td></tr>"
    }

    private static func escape(_ value: String) -> String {
        value.replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
            .replacingOccurrences(of: "\"", with: "&quot;")
    }
}
