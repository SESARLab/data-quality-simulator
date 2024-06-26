import Foundation

@testable import DataBalanceSimulator

public class FileUtils {
    public static func createDirIfNotExist(atPath: String, withFM fileManager: FileManager) throws {
        var isDirectory: ObjCBool = false
        let doesFileExist = fileManager.fileExists(atPath: atPath, isDirectory: &isDirectory) 

        if !doesFileExist || (doesFileExist && !isDirectory.boolValue) {
            try fileManager.createDirectory(
                at: URL(fileURLWithPath: atPath, isDirectory: true), 
                withIntermediateDirectories: true
            )
        }
    }

    public static func rmDirIfExists(atPath: String, withFM fileManager: FileManager) throws {
        var isDirectory: ObjCBool = false
        let doesFileExist = fileManager.fileExists(atPath: atPath, isDirectory: &isDirectory) 

        if (doesFileExist && isDirectory.boolValue) {
            try fileManager.removeItem(at: URL(fileURLWithPath: atPath, isDirectory: true))
        }
    }

    public static func createConfigFile(
        withProps properties: [String: LosslessStringConvertible], 
        atPath: String, 
        withFM fileManager: FileManager
    ) {
        let jsonContent = try! JSONSerialization.data(
            withJSONObject: properties, options: []
        )

        fileManager.createFile(atPath: atPath, contents: jsonContent)
    }
}