import Foundation
import UIKit

enum ImageStorage {
    static func saveImageData(_ data: Data) throws -> String {
        let directory = try imagesDirectory()
        let filename = "\(UUID().uuidString).image"
        try data.write(to: directory.appending(path: filename), options: [.atomic])
        return filename
    }

    static func image(for filename: String) -> UIImage? {
        UIImage(contentsOfFile: url(for: filename).path)
    }

    static func url(for filename: String) -> URL {
        URL.documentsDirectory.appending(path: "ImportedImages").appending(path: filename)
    }

    private static func imagesDirectory() throws -> URL {
        let directory = URL.documentsDirectory.appending(path: "ImportedImages")
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        return directory
    }
}
