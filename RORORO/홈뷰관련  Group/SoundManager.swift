//
//  SoundManager.swift
//  RORORO
//
//  Created by 문현권 on 2/24/25.
//

import AVFoundation

class SoundManager {
    static let shared = SoundManager() // ✅ 싱글톤 패턴 사용 (어디서든 호출 가능)
    private var audioPlayer: AVAudioPlayer?

    // 🔥 사운드 재생 함수
    func playSound(_ fileName: String, fileType: String = "mp3") {
        if let soundURL = Bundle.main.url(forResource: fileName, withExtension: fileType) {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
                audioPlayer?.play()
            } catch {
                print("❌ 사운드 재생 실패: \(error.localizedDescription)")
            }
        } else {
            print("❌ 사운드 파일을 찾을 수 없습니다: \(fileName).\(fileType)")
        }
    }
}
