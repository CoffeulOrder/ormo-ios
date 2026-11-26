import Foundation

// 서버의 요일별 영업시간(dayOfWeek: 1=월~7=일)을 화면이 쓰는 3분할(평일/토/일·공휴일) 문구와
// "다음 영업 시작" 안내 문구로 바꾼다. RemoteCafeRepository·RemoteMenuRepository가 공유한다.
struct BusinessHourDTO: Decodable {
    let dayOfWeek: Int
    // 쉬는 날(closed: true)은 openTime·closeTime 자체가 null로 온다.
    let openTime: String?
    let closeTime: String?
    let closed: Bool
}

enum StoreScheduleFormatting {
    // 영업 중 멈춤(PAUSED)은 서버가 다시 여는 시각을 따로 주지 않아(수동 토글이라 종료 시점을
    // 알 수 없음), 특정 시각 대신 이 문구를 쓴다.
    static let pausedResumeText = "곧"

    static func shortTime(_ rawTime: String) -> String {
        String(rawTime.prefix(5))
    }

    static func operatingHours(from businessHours: [BusinessHourDTO]) -> OperatingHours {
        func text(forDayOfWeek day: Int) -> String {
            guard let hour = businessHours.first(where: { $0.dayOfWeek == day }),
                  !hour.closed, let openTime = hour.openTime, let closeTime = hour.closeTime else { return "쉬어요" }
            return "\(shortTime(openTime))~\(shortTime(closeTime))"
        }
        return OperatingHours(weekdays: text(forDayOfWeek: 1), saturday: text(forDayOfWeek: 6), sundayAndHoliday: text(forDayOfWeek: 7))
    }

    // 오늘 영업이 끝났을 때(CLOSED), 다음으로 여는 날짜의 오픈 시각을 "내일 08:30"/"3일 뒤 08:30" 형태로.
    static func nextOpeningText(from businessHours: [BusinessHourDTO], now: Date = Date()) -> String {
        let calendarWeekday = Calendar.current.component(.weekday, from: now) // 1=일~7=토
        let todayDayOfWeek = calendarWeekday == 1 ? 7 : calendarWeekday - 1 // 1=월~7=일로 변환

        for offset in 1...7 {
            let candidateDay = ((todayDayOfWeek - 1 + offset) % 7) + 1
            guard let hour = businessHours.first(where: { $0.dayOfWeek == candidateDay }),
                  !hour.closed, let openTime = hour.openTime else { continue }
            let dayText = offset == 1 ? "내일" : "\(offset)일 뒤"
            return "\(dayText) \(shortTime(openTime))"
        }
        return "영업 정보를 확인해 주세요"
    }
}
