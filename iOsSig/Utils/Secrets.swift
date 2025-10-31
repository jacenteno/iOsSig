import Foundation

struct Secrets {
    private static let obfuscatedPassword: [UInt8] = [0x23, 0x12, 0x05, 0x74, 0x67, 0x56]
    private static let key: [UInt8] = [0x1A, 0x2B, 0x3C, 0x4D, 0x5E, 0x6F]

    static func getMasterPassword() -> String {
        var deobfuscated: [UInt8] = []
        for i in 0..<obfuscatedPassword.count {
            deobfuscated.append(obfuscatedPassword[i] ^ key[i])
        }
        return String(bytes: deobfuscated, encoding: .utf8) ?? ""
    }
}
