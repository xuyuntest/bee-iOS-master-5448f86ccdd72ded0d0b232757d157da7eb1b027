import Foundation
import CryptoSwift

/// Save objects to file on disk
final public class DiskStorage {
    
    public let maxSize = 0
    public let fileManager: FileManager
    public let path: String
    
    var onRemove: ((String) -> Void)?
    
    public convenience init(_ name: String, fileManager: FileManager = FileManager.default) throws {
        let url = try fileManager.url(
            for: .cachesDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true)
        
        // path
        let path = url.appendingPathComponent(name, isDirectory: true).path
        
        self.init(fileManager: fileManager, path: path)
        
        try createDirectory()
    }
    
    public required init(fileManager: FileManager = FileManager.default, path: String) {
        self.fileManager = fileManager
        self.path = path
    }
    
    public func entry(forKey key: String) -> String? {
        let filePath = makeFilePath(for: key)
        if fileManager.fileExists(atPath: filePath) {
            return filePath
        }
        return nil
    }
    
    public func entry(forKey key: String) throws -> (Data, String) {
        let filePath = makeFilePath(for: key)
        let data = try Data(contentsOf: URL(fileURLWithPath: filePath))
        return (data, filePath)
    }
    
    public func setObject(_ data: Data, forKey key: String) throws {
        let filePath = makeFilePath(for: key)
        _ = fileManager.createFile(atPath: filePath, contents: data, attributes: nil)
    }
    
    public func removeObject(forKey key: String) throws {
        let filePath = makeFilePath(for: key)
        try fileManager.removeItem(atPath: filePath)
        onRemove?(filePath)
    }
    
    public func removeAll() throws {
        try fileManager.removeItem(atPath: path)
        try createDirectory()
    }
}

typealias ResourceObject = (url: Foundation.URL, resourceValues: URLResourceValues)

extension DiskStorage {
    /**
     Builds file name from the key.
     - Parameter key: Unique key to identify the object in the cache
     - Returns: A md5 string
     */
    func makeFileName(for key: String) -> String {
        let fileExtension = URL(fileURLWithPath: key).pathExtension
        let fileName = key.md5()
        
        switch fileExtension.isEmpty {
        case true:
            return fileName
        case false:
            return "\(fileName).\(fileExtension)"
        }
    }
    
    /**
     Builds file path from the key.
     - Parameter key: Unique key to identify the object in the cache
     - Returns: A string path based on key
     */
    func makeFilePath(for key: String) -> String {
        return "\(path)/\(makeFileName(for: key))"
    }
    
    /// Calculates total disk cache size.
    func totalSize() throws -> UInt64 {
        var size: UInt64 = 0
        let contents = try fileManager.contentsOfDirectory(atPath: path)
        for pathComponent in contents {
            let filePath = NSString(string: path).appendingPathComponent(pathComponent)
            let attributes = try fileManager.attributesOfItem(atPath: filePath)
            if let fileSize = attributes[.size] as? UInt64 {
                size += fileSize
            }
        }
        return size
    }
    
    func createDirectory() throws {
        guard !fileManager.fileExists(atPath: path) else {
            return
        }
        
        try fileManager.createDirectory(atPath: path, withIntermediateDirectories: true,
                                        attributes: nil)
    }
    
    /**
     Removes objects if storage size exceeds max size.
     - Parameter objects: Resource objects to remove
     - Parameter totalSize: Total size
     */
    func removeResourceObjects(_ objects: [ResourceObject], totalSize: UInt) throws {
        guard maxSize > 0 && totalSize > maxSize else {
            return
        }
        
        var totalSize = totalSize
        let targetSize = maxSize / 2
        
        let sortedFiles = objects.sorted {
            if let time1 = $0.resourceValues.contentModificationDate?.timeIntervalSinceReferenceDate,
                let time2 = $1.resourceValues.contentModificationDate?.timeIntervalSinceReferenceDate {
                return time1 > time2
            } else {
                return false
            }
        }
        
        for file in sortedFiles {
            try fileManager.removeItem(at: file.url)
            onRemove?(file.url.path)
            
            if let fileSize = file.resourceValues.totalFileAllocatedSize {
                totalSize -= UInt(fileSize)
            }
            
            if totalSize < targetSize {
                break
            }
        }
    }
}
