import SwiftUI

struct VerificationCodeView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = VerificationCodeViewModel()
    @FocusState private var isCodeFieldFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            topNavigationBar
            sectionHeader
            codeBoxes
            Spacer(minLength: 0)
            mailNotReceivedLink
                .frame(maxWidth: .infinity)
                .padding(.bottom, Spacing.spacing16)
        }
        .background(
            hiddenCodeField
        )
        .background(Colors.backgroundDefault.ignoresSafeArea())
        .navigationBarHidden(true)
        .onAppear {
            isCodeFieldFocused = true
        }
        .onChange(of: viewModel.inputGeneration) {
            isCodeFieldFocused = true
        }
    }

    private var hiddenCodeField: some View {
        TextField(
            "",
            text: Binding(
                get: { viewModel.code },
                set: { viewModel.codeChanged(to: $0) }
            )
        )
        .keyboardType(.numberPad)
        .textContentType(.oneTimeCode)
        .focused($isCodeFieldFocused)
        .opacity(0)
        .frame(width: 1, height: 1)
        .allowsHitTesting(false)
        .id(viewModel.inputGeneration)
    }

    private var topNavigationBar: some View {
        HStack(spacing: 0) {
            Button(action: { dismiss() }) {
                Image(.arrowBackIos)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                    .frame(width: 40, height: 40)
            }
            .buttonStyle(.plain)

            Spacer()
        }
        .padding(.horizontal, Spacing.spacing8)
        .frame(height: 56)
        .background(Colors.backgroundDefault)
    }

    private var sectionHeader: some View {
        VStack(alignment: .leading, spacing: Spacing.spacing20) {
            Text("메일로 받은\n인증번호 6자리를 입력해주세요")
                .font(Typography.displayXsSemibold)
                .foregroundStyle(Colors.textPrimary)

            Text(viewModel.isExpired ? "시간이 지났어요" : "남은 시간 \(viewModel.remainingTimeText)")
                .font(Typography.bodyMdMedium)
                .foregroundStyle(Colors.textSecondary)
        }
        .padding(.horizontal, Spacing.spacing20)
        .padding(.vertical, 10) // Figma 원본값이 10px (spacing 토큰 중 일치 항목 없음)
    }

    private var codeBoxes: some View {
        VStack(alignment: .leading, spacing: 10) { // Figma 원본값이 10px (spacing 토큰 중 일치 항목 없음)
            codeBoxesRow

            if viewModel.isInvalid {
                errorFooter
            }
        }
        .padding(Spacing.spacing20)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var codeBoxesRow: some View {
        HStack(spacing: 7) {
            ForEach(0..<VerificationCodeViewModel.codeLength, id: \.self) { index in
                codeBox(at: index)
            }
        }
        .frame(maxWidth: .infinity)
        .keyframeAnimator(initialValue: CGFloat.zero, trigger: viewModel.shakeTrigger) { content, offset in
            content.offset(x: offset)
        } keyframes: { _ in
            KeyframeTrack {
                CubicKeyframe(-8, duration: 0.06)
                CubicKeyframe(7, duration: 0.06)
                CubicKeyframe(-5, duration: 0.06)
                CubicKeyframe(3, duration: 0.06)
                CubicKeyframe(0, duration: 0.06)
            }
        }
        .onTapGesture {
            isCodeFieldFocused = true
        }
    }

    private func codeBox(at index: Int) -> some View {
        let characters = Array(viewModel.code)
        let digit = index < characters.count ? String(characters[index]) : nil
        let isFocused = index == characters.count && !viewModel.isExpired

        let borderColor: Color = if isFocused {
            Colors.fillBrand
        } else if viewModel.isInvalid {
            Colors.borderDanger
        } else if digit == nil {
            Colors.borderDefault
        } else {
            Colors.fieldBorder
        }
        let lineWidth: CGFloat = isFocused || viewModel.isInvalid ? 2 : 1

        return Text(digit ?? "")
            .font(Typography.displaySmSemibold)
            .foregroundStyle(Colors.textPrimary)
            .frame(width: 50, height: 56)
            .background(digit == nil && !isFocused ? Colors.fillNeutralWeak : Colors.backgroundDefault)
            .clipShape(RoundedRectangle(cornerRadius: Radius.lg))
            .overlay(
                RoundedRectangle(cornerRadius: Radius.lg)
                    .stroke(borderColor, lineWidth: lineWidth)
            )
    }

    private var errorFooter: some View {
        HStack(spacing: Spacing.spacing4) {
            Image(.errorIcon)
                .resizable()
                .scaledToFit()
                .frame(width: 16, height: 16)

            Text("인증번호를 다시 확인해주세요")
                .font(Typography.bodySmRegular)
                .foregroundStyle(Colors.textDanger)
        }
    }

    private var mailNotReceivedLink: some View {
        let label: String
        let action: () -> Void
        if viewModel.isExpired {
            label = "다시 받기"
            action = viewModel.resendTapped
        } else if viewModel.isInvalid {
            label = "인증번호 다시 받기"
            action = viewModel.resendTapped
        } else {
            label = "메일이 안 오나요?"
            action = viewModel.mailNotReceivedTapped
        }

        return Button(action: action) {
            Text(label)
                .font(Typography.bodyMdRegular)
                .foregroundStyle(Colors.textBrand)
                .underline()
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    VerificationCodeView()
}
