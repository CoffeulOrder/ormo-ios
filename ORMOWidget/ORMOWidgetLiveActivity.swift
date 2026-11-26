//
//  ORMOWidgetLiveActivity.swift
//  ORMOWidget
//
//  Figma "4.5.2 잠금 화면 · 실시간 현황"(295:4851) 4개 상태(주문 확인 중·만드는 중·픽업 대기·
//  픽업 완료)와 "Live Activity · Dynamic Island"(302:4776, Compact·Minimal·Expanded)를 그대로
//  옮겼다. 색은 메인 앱 DesignSystem을 가져올 수 없어(다른 타겟) 직접 값으로 적었다.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct ORMOWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: OrderActivityAttributes.self) { context in
            OrderActivityCardView(attributes: context.attributes, state: context.state)
                .activitySystemActionForegroundColor(.white)
        } dynamicIsland: { context in
            DynamicIsland {
                // Figma 1469:42919 실측: 로고·상태 라벨이 카메라(센서 하우징) 옆 맨 윗줄을
                // 포함해서 디자인돼 있다 — 전부 .bottom에만 넣으면 그 줄이 시스템이 카메라를
                // 위해 비워두는 공간 아래로 밀려나 카메라 자리가 빈칸처럼 보인다. .leading·
                // .trailing에 나눠 넣어야 카메라 양옆 맨 위 줄에 자리 잡는다(Apple 표준
                // Dynamic Island Expanded 레이아웃).
                DynamicIslandExpandedRegion(.leading) {
                    Image("OrmoLogoOnDark")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 37, height: 16)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text(OrderActivityDynamicIslandExpandedView.headerLabel(for: context.state.phase))
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(OrderActivityDynamicIslandExpandedView.blue300)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    OrderActivityDynamicIslandExpandedView(attributes: context.attributes, state: context.state)
                }
            } compactLeading: {
                Image("OrmoLogoOnDark")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 13)
            } compactTrailing: {
                Text("\(context.attributes.pickupNumber)")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(OrderActivityDynamicIslandExpandedView.blue300)
            } minimal: {
                Text("\(context.attributes.pickupNumber)")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(OrderActivityDynamicIslandExpandedView.blue300)
            }
        }
    }
}

// Figma "Live Activity · Lock Screen"(295:4851) 실측: 번호를 담는 별도 사각 타일이 없다 —
// 제목 글자 맨 앞 "27번"이 brand 색으로 끼어들고, 오른쪽에 본문 Live Order Bar와 같은 일러스트
// (주문 확인 중=프린터, 만드는 중=컵+커피 표면+물방울, 픽업 대기·완료=컵)가 들어간다.
struct OrderActivityCardView: View {
    let attributes: OrderActivityAttributes
    let state: OrderActivityAttributes.ContentState

    static let brand = Color(red: 0x29 / 255, green: 0x8d / 255, blue: 0xff / 255)
    private static let neutralWeak = Color.black.opacity(0.05)
    // "27번" 숫자는 밝은 배경(잠금 화면 카드)·어두운 배경(Dynamic Island) 어느 쪽에서도 Figma
    // 원본이 똑같이 이 brand 색 그대로를 쓴다(대비를 위해 밝게 바꾸지 않는다).
    static let textBrand = Color(red: 0x00 / 255, green: 0x6b / 255, blue: 0xdf / 255)
    private static let textPrimary = Color.black.opacity(0.8)
    private static let textSecondary = Color.black.opacity(0.7)
    private static let textTertiary = Color.black.opacity(0.58)

    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            header
            row
            stepsBar
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(backgroundColor)
    }

    private var header: some View {
        HStack {
            Image(state.phase == .waitingPickup ? "OrmoLogoOnDark" : "OrmoLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 37, height: 16)
            Spacer()
            Text(headerLabel)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(headerLabelColor)
        }
    }

    // VStack에 패딩만 주고 일러스트를 .overlay(.trailing)로 겹치던 이전 방식은, 제목·설명 글자
    // 상자의 실제 높이(긴 매장명이 한 줄 안에 다 안 들어가거나 기기별 글자 크기 설정에 따라
    // 달라짐)를 기준으로 가운데를 잡다 보니 실측 기기에서 일러스트가 아래로 처져 보였다
    // (실측 확인). HStack(alignment: .center)로 바꾸면 높이가 얼마든 둘이 항상 같은 줄 가운데에
    // 나란히 놓인다. 제목·설명도 한 줄로 고정해서 상자 높이가 기기마다 달라지지 않게 한다.
    private var row: some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                titleText
                    .lineLimit(1)
                Text(subtitle)
                    .font(.system(size: 14, weight: subtitleWeight))
                    .foregroundStyle(subtitleColor)
                    .lineLimit(1)
            }
            Spacer(minLength: 0)
            LiveOrderIllustrationView(phase: state.phase)
        }
    }

    private var titleText: Text {
        switch state.phase {
        case .confirming, .making:
            Text("\(attributes.pickupNumber)번")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(Self.textBrand)
                + Text(" \(Self.title(for: state.phase))")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(Self.textPrimary)
        case .waitingPickup:
            Text("\(attributes.pickupNumber)번 \(Self.title(for: state.phase))")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(.white)
        case .pickedUp:
            Text("\(attributes.pickupNumber)번 \(Self.title(for: state.phase))")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(Self.textPrimary)
        }
    }

    private var stepsBar: some View {
        VStack(spacing: 8) {
            HStack(spacing: 4) {
                segment(stepIndex: 0, corners: .leading)
                segment(stepIndex: 1, corners: .none)
                segment(stepIndex: 2, corners: .trailing)
            }
            .frame(height: 8)
            HStack(spacing: 8) {
                stepLabel("주문 확인", stepIndex: 0)
                stepLabel("만드는 중", stepIndex: 1)
                stepLabel("픽업 대기", stepIndex: 2)
            }
        }
    }

    private enum SegmentCorners { case leading, trailing, none }

    private func segment(stepIndex: Int, corners: SegmentCorners) -> some View {
        let shape = UnevenRoundedRectangle(
            topLeadingRadius: corners == .leading ? 999 : 0,
            bottomLeadingRadius: corners == .leading ? 999 : 0,
            bottomTrailingRadius: corners == .trailing ? 999 : 0,
            topTrailingRadius: corners == .trailing ? 999 : 0
        )
        return shape
            .fill(segmentColor(stepIndex))
            .frame(maxWidth: .infinity)
    }

    private func stepLabel(_ text: String, stepIndex: Int) -> some View {
        let isActive = stepIndex == OrderActivityCardView.stepIndex(for: state.phase)
        return Text(text)
            .font(.system(size: 12, weight: isActive ? .semibold : .medium))
            .foregroundStyle(labelColor(isActive: isActive))
            .frame(maxWidth: .infinity)
    }

    // Phase의 rawValue는 서버/직렬화용 문자열이라 단계 바의 "몇 번째 칸"에는 못 쓴다.
    static func stepIndex(for phase: OrderActivityAttributes.ContentState.Phase) -> Int {
        switch phase {
        case .confirming: 0
        case .making: 1
        case .waitingPickup, .pickedUp: 2
        }
    }

    static func title(for phase: OrderActivityAttributes.ContentState.Phase) -> String {
        switch phase {
        case .confirming: "주문 확인 중이에요"
        case .making: "음료를 만들고 있어요"
        case .waitingPickup: "음료가 준비되었어요"
        case .pickedUp: "음료를 받았어요"
        }
    }

    static func subtitle(attributes: OrderActivityAttributes, state: OrderActivityAttributes.ContentState) -> String {
        switch state.phase {
        case .confirming, .making:
            if let queueCount = state.queueCount {
                "\(attributes.storeName) · 내 앞에 \(queueCount)건"
            } else {
                attributes.storeName
            }
        case .waitingPickup:
            if let deadline = state.pickupDeadline {
                "\(timeFormatter.string(from: deadline))까지 받아 주세요"
            } else {
                "매장에서 받아 주세요"
            }
        case .pickedUp:
            "\(attributes.storeName) · 맛있게 드세요"
        }
    }

    private var subtitleWeight: Font.Weight {
        switch state.phase {
        case .confirming, .making: .regular
        case .waitingPickup, .pickedUp: .medium
        }
    }

    var subtitle: String { Self.subtitle(attributes: attributes, state: state) }

    private var headerLabel: String {
        switch state.phase {
        case .confirming: "주문 확인 중"
        case .making: "만드는 중"
        case .waitingPickup: "픽업 대기"
        case .pickedUp: "픽업 완료"
        }
    }

    private var backgroundColor: Color { state.phase == .waitingPickup ? Self.brand : .white }

    private var headerLabelColor: Color {
        switch state.phase {
        case .waitingPickup: .white
        case .pickedUp: Self.textTertiary
        default: Self.textBrand
        }
    }

    private var subtitleColor: Color { state.phase == .waitingPickup ? .white.opacity(0.85) : Self.textSecondary }

    func segmentColor(_ index: Int) -> Color {
        switch state.phase {
        case .confirming: index == 0 ? Self.brand : Self.neutralWeak
        case .making: index <= 1 ? Self.brand : Self.neutralWeak
        case .waitingPickup: .white
        case .pickedUp: Self.textTertiary
        }
    }

    func labelColor(isActive: Bool) -> Color {
        switch state.phase {
        case .waitingPickup: .white.opacity(isActive ? 1 : 0.7)
        case .pickedUp: Self.textTertiary
        default: isActive ? Self.textBrand : Self.textTertiary
        }
    }
}

// Figma "Live Activity · Dynamic Island"(302:4776) 개발 주석: "Expanded 안쪽은 Live Activity ·
// Lock Screen 컴포넌트를 그대로 넣고 색만 다크로 덮어써요." 아일랜드는 상태와 무관하게 항상
// 검정이라(잠금 화면의 "픽업 대기 = 브랜드 색 꽉 채움" 같은 반전 배경은 여기 없다), 레이아웃은
// 잠금 화면과 같고 글자·막대 색만 다크 팔레트(Blue 300·400, Grey 400·700)로 바꾼다.
struct OrderActivityDynamicIslandExpandedView: View {
    let attributes: OrderActivityAttributes
    let state: OrderActivityAttributes.ContentState

    static let blue300 = Color(red: 0x67 / 255, green: 0xaf / 255, blue: 0xfe / 255)
    private static let blue400 = Color(red: 0x45 / 255, green: 0x9c / 255, blue: 0xff / 255)
    private static let grey700 = Color(red: 0x4e / 255, green: 0x59 / 255, blue: 0x68 / 255)
    private static let grey400 = Color(red: 0xb0 / 255, green: 0xb8 / 255, blue: 0xc1 / 255)

    // 로고·상태 라벨은 ORMOWidgetLiveActivity의 DynamicIslandExpandedRegion(.leading/.trailing)으로
    // 옮겨서 카메라 양옆 맨 윗줄에 자리 잡는다(이 뷰는 그 아래 .bottom 영역 내용만 그린다).
    //
    // row-stepsBar 간격은 Figma 문서상 gap-12가 아니라 6을 써야 한다 — get_metadata로 받은
    // 절대좌표로 확인해보면, Figma의 "Row" 프레임 자체는 글자 높이(48)만큼만 차지하고 일러스트
    // (60)는 그 박스 밖으로(절대좌표 top=-6) 위아래 6px씩 넘쳐 그려진다. 반면 우리 HStack은
    // 일러스트가 제일 큰 자식이라 row 자체가 그 60을 그대로 차지해서 겹침이 없다. 거기다
    // 컵 그림은 일러스트 60×60 박스 안에서도 아래쪽에 1.64px 여백을 두고 떠 있다. 그래서
    // "컵 그림 아래쪽 ~ 단계 바"가 정확히 7.64px가 되려면, 우리 쪽 간격은 6(= 7.64 − 1.64)이어야
    // Figma가 가리키는 "컵과 바 사이 7.64px"와 실제로 같아진다(12를 그대로 쓰면 13.64가 된다).
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            row
            stepsBar
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 18)
    }

    // Lock Screen과 같은 이유로 overlay(.trailing) 대신 HStack으로 바꿨다 — 실측 기기에서
    // 일러스트가 아래로 처져 보이던 문제(글자 상자 높이 기준으로 가운데를 잡던 탓)를 없앤다.
    private var row: some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                titleText
                    .lineLimit(1)
                Text(subtitle)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(Self.grey400)
                    .lineLimit(1)
            }
            Spacer(minLength: 0)
            LiveOrderIllustrationView(phase: state.phase)
        }
    }

    private var titleText: Text {
        Text("\(attributes.pickupNumber)번")
            .font(.system(size: 18, weight: .semibold))
            .foregroundStyle(OrderActivityCardView.textBrand)
            + Text(" \(OrderActivityCardView.title(for: state.phase))")
            .font(.system(size: 18, weight: .semibold))
            .foregroundStyle(.white)
    }

    private var stepsBar: some View {
        VStack(spacing: 8) {
            HStack(spacing: 4) {
                segment(stepIndex: 0, corners: .leading)
                segment(stepIndex: 1, corners: .none)
                segment(stepIndex: 2, corners: .trailing)
            }
            .frame(height: 8)
            HStack(spacing: 8) {
                stepLabel("주문 확인", stepIndex: 0)
                stepLabel("만드는 중", stepIndex: 1)
                stepLabel("픽업 대기", stepIndex: 2)
            }
        }
    }

    private enum SegmentCorners { case leading, trailing, none }

    private func segment(stepIndex: Int, corners: SegmentCorners) -> some View {
        let shape = UnevenRoundedRectangle(
            topLeadingRadius: corners == .leading ? 999 : 0,
            bottomLeadingRadius: corners == .leading ? 999 : 0,
            bottomTrailingRadius: corners == .trailing ? 999 : 0,
            topTrailingRadius: corners == .trailing ? 999 : 0
        )
        return shape
            .fill(segmentColor(stepIndex))
            .frame(maxWidth: .infinity)
    }

    private func stepLabel(_ text: String, stepIndex: Int) -> some View {
        let isActive = stepIndex == OrderActivityCardView.stepIndex(for: state.phase)
        return Text(text)
            .font(.system(size: 12, weight: isActive ? .semibold : .medium))
            .foregroundStyle(isActive ? Self.blue300 : Self.grey400)
            .frame(maxWidth: .infinity)
    }

    static func headerLabel(for phase: OrderActivityAttributes.ContentState.Phase) -> String {
        switch phase {
        case .confirming: "주문 확인 중"
        case .making: "만드는 중"
        case .waitingPickup: "픽업 대기"
        case .pickedUp: "픽업 완료"
        }
    }

    private var subtitle: String { OrderActivityCardView.subtitle(attributes: attributes, state: state) }

    private func segmentColor(_ index: Int) -> Color {
        switch state.phase {
        case .confirming: index == 0 ? Self.blue400 : Self.grey700
        case .making: index <= 1 ? Self.blue400 : Self.grey700
        case .waitingPickup: index <= 2 ? Self.blue400 : Self.grey700
        case .pickedUp: Self.grey700
        }
    }
}

extension OrderActivityAttributes {
    fileprivate static var preview: OrderActivityAttributes {
        OrderActivityAttributes(pickupNumber: 27, storeName: "범석관 카페")
    }
}

extension OrderActivityAttributes.ContentState {
    fileprivate static var confirming: OrderActivityAttributes.ContentState {
        .init(phase: .confirming, queueCount: 3, pickupDeadline: nil)
    }

    fileprivate static var making: OrderActivityAttributes.ContentState {
        .init(phase: .making, queueCount: 2, pickupDeadline: nil)
    }

    fileprivate static var waitingPickup: OrderActivityAttributes.ContentState {
        .init(phase: .waitingPickup, queueCount: nil, pickupDeadline: Calendar.current.date(byAdding: .minute, value: 20, to: .now))
    }

    fileprivate static var pickedUp: OrderActivityAttributes.ContentState {
        .init(phase: .pickedUp, queueCount: nil, pickupDeadline: nil)
    }
}

#Preview("Notification", as: .content, using: OrderActivityAttributes.preview) {
    ORMOWidgetLiveActivity()
} contentStates: {
    OrderActivityAttributes.ContentState.confirming
    OrderActivityAttributes.ContentState.making
    OrderActivityAttributes.ContentState.waitingPickup
    OrderActivityAttributes.ContentState.pickedUp
}

#Preview("Dynamic Island Expanded", as: .dynamicIsland(.expanded), using: OrderActivityAttributes.preview) {
    ORMOWidgetLiveActivity()
} contentStates: {
    OrderActivityAttributes.ContentState.confirming
    OrderActivityAttributes.ContentState.making
    OrderActivityAttributes.ContentState.waitingPickup
    OrderActivityAttributes.ContentState.pickedUp
}

#Preview("Dynamic Island Compact", as: .dynamicIsland(.compact), using: OrderActivityAttributes.preview) {
    ORMOWidgetLiveActivity()
} contentStates: {
    OrderActivityAttributes.ContentState.making
}

#Preview("Dynamic Island Minimal", as: .dynamicIsland(.minimal), using: OrderActivityAttributes.preview) {
    ORMOWidgetLiveActivity()
} contentStates: {
    OrderActivityAttributes.ContentState.making
}
