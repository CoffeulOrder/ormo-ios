import SwiftUI

// 픽업 대기(받아 가세요) 상태에서 헤더 고리 뒤로 퍼지는 물결. 32 → 60pt로 커지며
// 35% → 0% 투명도로 사라지는 걸 1.2초 동안, 그 뒤 0.5초 쉬고 다시 — 받을 때까지 반복.
struct LiveOrderHaloView: View {
    var baseSize: CGFloat = 32
    var maxSize: CGFloat = 60

    @State private var isExpanded = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        Circle()
            .fill(Colors.fillBrand.opacity(isExpanded ? 0 : 0.35))
            .frame(width: isExpanded ? maxSize : baseSize, height: isExpanded ? maxSize : baseSize)
            .accessibilityHidden(true)
            .task {
                guard !reduceMotion else { return }
                while !Task.isCancelled {
                    withAnimation(.easeOut(duration: 1.2)) {
                        isExpanded = true
                    }
                    try? await Task.sleep(for: .seconds(1.7))
                    guard !Task.isCancelled else { return }
                    isExpanded = false
                    try? await Task.sleep(for: .seconds(0.05))
                }
            }
    }
}

#Preview {
    ZStack {
        LiveOrderHaloView()
        LiveOrderRingView(pickupNumber: 27, stage: .readyForPickup)
    }
    .padding(40)
}
