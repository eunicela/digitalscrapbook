import Foundation
import UIKit

enum ImageStorage {
    static func save(_ image: UIImage) throws -> String {
        let directory = try imagesDirectory()
        let filename = "\(UUID().uuidString).jpg"

        guard let data = image.jpegData(compressionQuality: 0.86) else {
            throw ImageStorageError.couldNotEncode
        }

        try data.write(to: directory.appending(path: filename), options: [.atomic])
        return filename
    }

    static func image(named filename: String) -> UIImage? {
        guard !filename.isEmpty else {
            return nil
        }

        return UIImage(contentsOfFile: url(for: filename).path)
    }

    private static func url(for filename: String) -> URL {
        URL.documentsDirectory.appending(path: "CardImages").appending(path: filename)
    }

    private static func imagesDirectory() throws -> URL {
        let directory = URL.documentsDirectory.appending(path: "CardImages")
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        return directory
    }
}

enum ImageStorageError: Error {
    case couldNotEncode
}
