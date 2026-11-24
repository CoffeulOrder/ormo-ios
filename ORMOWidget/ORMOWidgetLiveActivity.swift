//
//  ORMOWidgetLiveActivity.swift
//  ORMOWidget
//
//  Figma "4.5.2 잠금 화면 · 실시간 현황" 4개 상태(주문 확인 중·만드는 중·픽업 대기·픽업 완료)를
//  그대로 옮긴 Live Activity. 색은 메인 앱 DesignSystem을 가져올 수 없어(다른 타겟) 직접 값으로 적었다.
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

struct OrderActivityCardView: View {
    let attributes: OrderActivityAttributes
    let state: OrderActivityAttributes.ContentState

    private static let brand = Color(red: 0x29 / 255, green: 0x8d / 255, blue: 0xff / 255)
    private static let brandWeak = Color(red: 0x29 / 255, green: 0x8d / 255, blue: 0xff / 255).opacity(0.16)
    private static let textBrand = Color(red: 0x00 / 255, green: 0x6b / 255, blue: 0xdf / 255)
    private static let textPrimary = Color.black.opacity(0.8)
    private static let textSecondary = Color.black.opacity(0.7)
    private static let textTertiary = Color.black.opacity(0.58)
    private static let neutralWeak = Color.black.opacity(0.05)

    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            header
            HStack(spacing: 12) {
                pickupNumberTile
                VStack(alignment: .leading, spacing: 2) {
                    Text(Self.title(for: state.phase))
                        .font(.system(size: 18, weight: titleWeight))
                        .foregroundStyle(titleColor)
                    Text(subtitle)
                        .font(.system(size: 14, weight: subtitleWeight))
                        .foregroundStyle(subtitleColor)
                }
            }
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

    private var pickupNumberTile: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(tileBackground)
            .frame(width: 48, height: 48)
            .overlay(
                Text("\(attributes.pickupNumber)")
                    .font(.system(size: tileNumberSize, weight: .bold))
                    .foregroundStyle(tileTextColor)
            )
    }

    private var stepsBar: some View {
        VStack(spacing: 8) {
            HStack(spacing: 4) {
                ForEach(0..<3, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 4)
                        .fill(segmentColor(index))
                        .frame(height: 8)
                }
            }
            HStack(spacing: 8) {
                stepLabel("주문 확인", isActive: state.phase == .confirming)
                stepLabel("만드는 중", isActive: state.phase == .making)
                stepLabel("픽업 대기", isActive: state.phase == .waitingPickup)
            }
        }
    }

    private func stepLabel(_ text: String, isActive: Bool) -> some View {
        Text(text)
            .font(.system(size: 12, weight: isActive ? .semibold : .medium))
            .foregroundStyle(labelColor(isActive: isActive))
            .frame(maxWidth: .infinity)
    }

    static func title(for phase: OrderActivityAttributes.ContentState.Phase) -> String {
        switch phase {
        case .confirming: "주문 확인 중이에요"
        case .making: "음료를 만들고 있어요"
        case .waitingPickup: "음료가 준비되었어요"
        case .pickedUp: "음료를 받았어요"
        }
    }

    private var titleWeight: Font.Weight {
        switch state.phase {
        case .confirming, .making: .semibold
        case .waitingPickup, .pickedUp: .bold
        }
    }

    private var subtitleWeight: Font.Weight {
        switch state.phase {
        case .confirming, .making: .regular
        case .waitingPickup, .pickedUp: .medium
        }
    }

    private var tileNumberSize: CGFloat {
        switch state.phase {
        case .confirming, .making: 20
        case .waitingPickup, .pickedUp: 18
        }
    }

    private var subtitle: String {
        switch state.phase {
        case .confirming, .making:
            if let queueCount = state.queueCount {
                "\(attributes.storeName) · 내 앞에 \(queueCount)건"
            } else {
                attributes.storeName
            }
        case .waitingPickup:
            if let deadline = state.pickupDeadline {
                "\(Self.timeFormatter.string(from: deadline))까지 받아 주세요"
            } else {
                "매장에서 받아 주세요"
            }
        case .pickedUp:
            "\(attributes.storeName) · 맛있게 드세요"
        }
    }

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

    private var tileBackground: Color {
        switch state.phase {
        case .waitingPickup: .white
        case .pickedUp: Self.neutralWeak
        default: Self.brandWeak
        }
    }

    private var tileTextColor: Color {
        state.phase == .pickedUp ? Self.textTertiary : Self.textBrand
    }

    private var titleColor: Color { state.phase == .waitingPickup ? .white : Self.textPrimary }

    private var subtitleColor: Color { state.phase == .waitingPickup ? .white.opacity(0.85) : Self.textSecondary }

    private func segmentColor(_ index: Int) -> Color {
        switch state.phase {
        case .confirming: index == 0 ? Self.brand : Self.neutralWeak
        case .making: index <= 1 ? Self.brand : Self.neutralWeak
        case .waitingPickup: .white
        case .pickedUp: Self.textTertiary
        }
    }

    private func labelColor(isActive: Bool) -> Color {
        switch state.phase {
        case .waitingPickup: .white.opacity(isActive ? 1 : 0.7)
        case .pickedUp: Self.textTertiary
        default: isActive ? Self.textBrand : Self.textTertiary
        }
    }
}

// Figma "Live Activity · Dynamic Island" — Expanded. 아일랜드는 상태와 상관없이 항상 검정이고,
// 그 위에 잠금 화면 카드와 같은 구성(픽업 번호 타일 + 제목·설명 + 3단계 바)을 밝은 브랜드 색으로 얹는다.
struct OrderActivityDynamicIslandExpandedView: View {
    let attributes: OrderActivityAttributes
    let state: OrderActivityAttributes.ContentState

    static let blue300 = Color(red: 0x67 / 255, green: 0xaf / 255, blue: 0xfe / 255)
    private static let blue400 = Color(red: 0x45 / 255, green: 0x9c / 255, blue: 0xff / 255)
    private static let grey800 = Color(red: 0x33 / 255, green: 0x3d / 255, blue: 0x4b / 255)
    private static let grey700 = Color(red: 0x4e / 255, green: 0x59 / 255, blue: 0x68 / 255)
    private static let grey400 = Color(red: 0xb0 / 255, green: 0xb8 / 255, blue: 0xc1 / 255)

    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()

    var body: some View {
        // Dynamic Island Expanded는 높이 제한(84~160pt)이 빠듯해서, 잠금 화면 카드보다
        // 세로 여백·크기를 더 줄여야 단계 라벨까지 안 잘리고 다 보인다.
        VStack(alignment: .leading, spacing: 4) {
            header
            HStack(spacing: 10) {
                pickupNumberTile
                VStack(alignment: .leading, spacing: 1) {
                    Text(OrderActivityCardView.title(for: state.phase))
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(.white)
                    Text(subtitle)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundStyle(Self.grey400)
                }
            }
            stepsBar
        }
        .padding(.horizontal, 20)
        .padding(.top, 4)
        .padding(.bottom, 4)
    }

    private var header: some View {
        HStack {
            Image("OrmoLogoOnDark")
                .resizable()
                .scaledToFit()
                .frame(width: 37, height: 16)
            Spacer()
            Text(headerLabel)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(Self.blue300)
        }
    }

    private var pickupNumberTile: some View {
        RoundedRectangle(cornerRadius: 14)
            .fill(Self.grey800)
            .frame(width: 40, height: 40)
            .overlay(
                Text("\(attributes.pickupNumber)")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(Self.blue300)
            )
    }

    private var stepsBar: some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                ForEach(0..<3, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 3)
                        .fill(segmentColor(index))
                        .frame(height: 6)
                }
            }
            HStack(spacing: 8) {
                stepLabel("주문 확인", isActive: state.phase == .confirming)
                stepLabel("만드는 중", isActive: state.phase == .making)
                stepLabel("픽업 대기", isActive: state.phase == .waitingPickup)
            }
        }
    }

    private func stepLabel(_ text: String, isActive: Bool) -> some View {
        Text(text)
            .font(.system(size: 10, weight: isActive ? .semibold : .medium))
            .foregroundStyle(isActive ? Self.blue300 : Self.grey400)
            .frame(maxWidth: .infinity)
    }

    private var headerLabel: String {
        switch state.phase {
        case .confirming: "주문 확인 중"
        case .making: "만드는 중"
        case .waitingPickup: "픽업 대기"
        case .pickedUp: "픽업 완료"
        }
    }

    private var subtitle: String {
        switch state.phase {
        case .confirming, .making:
            if let queueCount = state.queueCount {
                "\(attributes.storeName) · 내 앞에 \(queueCount)건"
            } else {
                attributes.storeName
            }
        case .waitingPickup:
            if let deadline = state.pickupDeadline {
                "\(Self.timeFormatter.string(from: deadline))까지 받아주세요"
            } else {
                "매장에서 받아주세요"
            }
        case .pickedUp:
            "\(attributes.storeName) · 맛있게 드세요"
        }
    }

    private func segmentColor(_ index: Int) -> Color {
        switch state.phase {
        case .confirming: index == 0 ? Self.blue400 : Self.grey700
        case .making: index <= 1 ? Self.blue400 : Self.grey700
        case .waitingPickup: Self.blue400
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
