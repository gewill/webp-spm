import Foundation
import Cocoa
import WebP

// Helper to download images synchronously
func downloadSync(url: URL) -> Data? {
    let semaphore = DispatchSemaphore(value: 0)
    var resultData: Data? = nil
    let task = URLSession.shared.dataTask(with: url) { data, response, error in
        resultData = data
        semaphore.signal()
    }
    task.resume()
    _ = semaphore.wait(timeout: .distantFuture)
    return resultData
}

// Extract raw RGBA pixels from CGImage
func getRawRGBAPixels(from cgImage: CGImage) -> (pixels: Data, width: Int, height: Int)? {
    let width = cgImage.width
    let height = cgImage.height
    
    var rawData = Data(count: width * height * 4)
    rawData.withUnsafeMutableBytes { (buffer: UnsafeMutableRawBufferPointer) -> Void in
        guard let context = CGContext(
            data: buffer.baseAddress,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: width * 4,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Big.rawValue
        ) else {
            print("    [!] Failed to create CGContext for extraction")
            return
        }
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
    }
    return (rawData, width, height)
}

// Compress RGBA pixels to WebP
func compressToWebP(rgba: Data, width: Int, height: Int, quality: Float) -> Data? {
    var outputPointer: UnsafeMutablePointer<UInt8>? = nil
    let size = rgba.withUnsafeBytes { (rgbaBuffer: UnsafeRawBufferPointer) -> Int in
        guard let baseAddress = rgbaBuffer.baseAddress?.assumingMemoryBound(to: UInt8.self) else { return 0 }
        return WebPEncodeRGBA(baseAddress, Int32(width), Int32(height), Int32(width * 4), quality, &outputPointer)
    }
    
    guard size > 0, let pointer = outputPointer else { return nil }
    let webpData = Data(bytes: pointer, count: size)
    WebPFree(pointer)
    return webpData
}

// Decompress WebP data to RGBA pixels
func decompressWebP(webpData: Data) -> (rgba: Data, width: Int, height: Int)? {
    var width32: Int32 = 0
    var height32: Int32 = 0
    
    let decodedPointer = webpData.withUnsafeBytes { (webpBuffer: UnsafeRawBufferPointer) -> UnsafeMutablePointer<UInt8>? in
        guard let baseAddress = webpBuffer.baseAddress?.assumingMemoryBound(to: UInt8.self) else { return nil }
        return WebPDecodeRGBA(baseAddress, webpData.count, &width32, &height32)
    }
    
    guard let pointer = decodedPointer, width32 > 0, height32 > 0 else { return nil }
    
    let width = Int(width32)
    let height = Int(height32)
    let size = width * height * 4
    let rgbaData = Data(bytes: pointer, count: size)
    WebPFree(pointer)
    
    return (rgbaData, width, height)
}

// Save RGBA pixels back as a PNG file
func saveRGBAPixelsAsPNG(rgba: Data, width: Int, height: Int, to url: URL) -> Bool {
    guard let provider = CGDataProvider(data: rgba as CFData) else { return false }
    guard let cgImage = CGImage(
        width: width,
        height: height,
        bitsPerComponent: 8,
        bitsPerPixel: 32,
        bytesPerRow: width * 4,
        space: CGColorSpaceCreateDeviceRGB(),
        bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue),
        provider: provider,
        decode: nil,
        shouldInterpolate: false,
        intent: .defaultIntent
    ) else { return false }
    
    let rep = NSBitmapImageRep(cgImage: cgImage)
    guard let pngData = rep.representation(using: .png, properties: [:]) else { return false }
    
    do {
        try pngData.write(to: url)
        return true
    } catch {
        print("Failed to write PNG: \(error)")
        return false
    }
}

// Main execution
func main() {
    print("--------------------------------------------------")
    print("WebP Swift Package Manager Example")
    print("--------------------------------------------------")
    
    // 3 Copyright-free images (Unsplash source)
    let images = [
        (name: "beach", url: URL(string: "https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=400")!),
        (name: "dog", url: URL(string: "https://images.unsplash.com/photo-1543466835-00a7907e9de1?w=400")!),
        (name: "portrait", url: URL(string: "https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=400")!)
    ]
    
    let currentDir = FileManager.default.currentDirectoryPath
    let outputDir = "\(currentDir)/Outputs"
    try? FileManager.default.createDirectory(atPath: outputDir, withIntermediateDirectories: true, attributes: nil)
    print("Running in: \(currentDir)")
    print("Saving outputs to: \(outputDir)")
    
    for item in images {
        print("\n[*] Processing [\(item.name)] image...")
        
        // 1. Download image
        print("    Downloading image...")
        guard let rawData = downloadSync(url: item.url) else {
            print("    [!] Failed to download image")
            continue
        }
        
        // 2. Decode original image using Cocoa APIs
        guard let nsImage = NSImage(data: rawData),
              let cgImage = nsImage.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            print("    [!] Failed to parse image data using Cocoa")
            continue
        }
        
        // 3. Extract raw RGBA pixels
        guard let (pixels, width, height) = getRawRGBAPixels(from: cgImage) else {
            print("    [!] Failed to extract raw pixels")
            continue
        }
        print("    Image size: \(width)x\(height) pixels")
        print("    Original data size: \(rawData.count) bytes")
        
        // 4. Encode pixels to WebP (Quality 80)
        print("    Encoding to WebP (Quality 80)...")
        let quality: Float = 80.0
        guard let webpData = compressToWebP(rgba: pixels, width: width, height: height, quality: quality) else {
            print("    [!] Failed to encode WebP")
            continue
        }
        
        let webpSize = webpData.count
        let ratio = Double(webpSize) / Double(rawData.count) * 100
        print("    WebP compressed size: \(webpSize) bytes (Ratio: \(String(format: "%.2f", ratio))%)")
        
        // Save the WebP image to disk
        let webpURL = URL(fileURLWithPath: "\(outputDir)/\(item.name).webp")
        try? webpData.write(to: webpURL)
        print("    Saved WebP to: Outputs/\(webpURL.lastPathComponent)")
        
        // 5. Decode WebP back to RGBA pixels to verify roundtrip
        print("    Decoding WebP back to raw pixels...")
        guard let (decodedPixels, decodedWidth, decodedHeight) = decompressWebP(webpData: webpData) else {
            print("    [!] Failed to decode WebP")
            continue
        }
        
        // 6. Save decoded pixels as a new PNG to verify correctness
        let outputPNGURL = URL(fileURLWithPath: "\(outputDir)/\(item.name)_decoded.png")
        if saveRGBAPixelsAsPNG(rgba: decodedPixels, width: decodedWidth, height: decodedHeight, to: outputPNGURL) {
            print("    Verified! Saved decoded PNG to: Outputs/\(outputPNGURL.lastPathComponent)")
        } else {
            print("    [!] Failed to save verification PNG")
        }
    }
    
    print("\n--------------------------------------------------")
    print("WebP Example Finished Successfully!")
    print("--------------------------------------------------")
}

main()
