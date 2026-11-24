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
                DynamicIslandExpandedRegion(.leading) {
                    Text("\(context.attributes.pickupNumber)")
                        .font(.system(size: 20, weight: .bold))
                }
                DynamicIslandExpandedRegion(.trailing) {
                    EmptyView()
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text(OrderActivityCardView.title(for: context.state.phase))
                        .font(.system(size: 15, weight: .semibold))
                }
            } compactLeading: {
                Text("\(context.attributes.pickupNumber)")
                    .font(.system(size: 13, weight: .bold))
            } compactTrailing: {
                Image(systemName: context.state.phase == .pickedUp ? "checkmark.circle.fill" : "cup.and.saucer.fill")
            } minimal: {
                Image(systemName: context.state.phase == .pickedUp ? "checkmark.circle.fill" : "cup.and.saucer.fill")
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
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(titleColor)
                    Text(subtitle)
                        .font(.system(size: 14, weight: .medium))
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
            Text("ORMO")
                .font(.system(size: 13, weight: .heavy))
                .foregroundStyle(headerLogoColor)
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
                    .font(.system(size: 20, weight: .bold))
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
        case .waitingPickup: "음료가 준비됐어요"
        case .pickedUp: "음료를 받았어요"
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

    private var headerLabel: String {
        switch state.phase {
        case .confirming: "주문 확인 중"
        case .making: "만드는 중"
        case .waitingPickup: "픽업 대기"
        case .pickedUp: "픽업 완료"
        }
    }

    private var backgroundColor: Color { state.phase == .waitingPickup ? Self.brand : .white }

    private var headerLogoColor: Color { state.phase == .waitingPickup ? .white : Self.textBrand }

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
        case .confirming: index == 0 ? Self.brand : Self.brandWeak
        case .making: index <= 1 ? Self.brand : Self.brandWeak
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
