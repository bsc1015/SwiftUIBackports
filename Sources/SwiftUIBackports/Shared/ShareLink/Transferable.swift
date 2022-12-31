import SwiftUI

@available(iOS, deprecated: 16.0)
@available(macOS, deprecated: 13.0)
@available(watchOS, deprecated: 9.0)

/// TEMPORARY, DO NOT RELY ON THIS!
/// 
/// - Note: This **will be removed** in an upcoming release, regardless of semantic versioning
public protocol Shareable {
    var pathExtension: String { get }
    var itemProvider: NSItemProvider? { get }
}

internal struct ActivityItem<Data> where Data: RandomAccessCollection, Data.Element: Shareable {
    internal var data: Data
}

extension String: Shareable {
    public var pathExtension: String { "txt" }
    public var itemProvider: NSItemProvider? {
        do {
            let url = URL(fileURLWithPath: NSTemporaryDirectory())
                .appendingPathComponent("\(UUID().uuidString)")
                .appendingPathExtension(pathExtension)
            try write(to: url, atomically: true, encoding: .utf8)
            return .init(contentsOf: url)
        } catch {
            return nil
        }
    }
}

extension URL: Shareable {
    public var itemProvider: NSItemProvider? {
        .init(contentsOf: self)
    }
}

extension Image: Shareable {
    public var pathExtension: String { "jpg" }
    public var itemProvider: NSItemProvider? {
        do {
            let url = URL(fileURLWithPath: NSTemporaryDirectory())
                .appendingPathComponent("\(UUID().uuidString)")
                .appendingPathExtension(pathExtension)
            let renderer = ImageRenderer(content: self)
            #if os(macOS)
            var data: Data?
            if let cgImage = renderer.nsImage?.cgImage(forProposedRect: nil, context: nil, hints: nil) {
                let bitmapRep = NSBitmapImageRep(cgImage: cgImage)
                data = bitmapRep.representation(using: NSBitmapImageRep.FileType.jpeg, properties: [:])!
            }
            #else
            let data = renderer.uiImage?.jpegData(compressionQuality: 0.8)
            #endif
            try data?.write(to: url, options: .atomic)
            return .init(contentsOf: url)
        } catch {
            return nil
        }
    }
}

extension PlatformImage: Shareable {
    public var pathExtension: String { "jpg" }
    public var itemProvider: NSItemProvider? {
        do {
            let url = URL(fileURLWithPath: NSTemporaryDirectory())
                .appendingPathComponent("\(UUID().uuidString)")
                .appendingPathExtension(pathExtension)
            #if os(macOS)
            var data: Data?
            if let cgImage = cgImage(forProposedRect: nil, context: nil, hints: nil) {
                let bitmapRep = NSBitmapImageRep(cgImage: cgImage)
                data = bitmapRep.representation(using: NSBitmapImageRep.FileType.jpeg, properties: [:])!
            }
            #else
            let data = jpegData(compressionQuality: 0.8)
            #endif
            try data?.write(to: url, options: .atomic)
            return .init(contentsOf: url)
        } catch {
            return nil
        }
    }
}
