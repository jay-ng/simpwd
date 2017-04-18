//: Playground - noun: a place where people can play
/*
import UIKit
import CryptoSwift

var str = "Hello, playground"

let data = str.data(using: String.Encoding.utf8, allowLossyConversion: false)
let password: Array<UInt8> = Array("s33krit".utf8)
let salt: Array<UInt8> = Array("nacllcan".utf8)

try PKCS5.PBKDF2(password: password, salt: salt, iterations: 4096, variant: .sha256).calculate()

str.utf8


let key = Array("passwordpassword".utf8).md5() // -md md5
let iv  = Array("drowssapdrowssap".utf8)
let plaintext = Array("Nullam quis risus eget urna mollis ornare vel eu leo.".utf8)
let aes = try! AES(key: key, iv: iv, blockMode: .CBC, padding: PKCS7())
let cipher = try! aes.encrypt(plaintext)
let text = try! aes.decrypt(cipher)
String(bytes: text, encoding: String.Encoding.utf8)
 */