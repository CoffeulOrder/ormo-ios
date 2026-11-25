import SwiftUI

struct MenuSearchView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: MenuSearchViewModel
    @FocusState private var isSearchFieldFocused: Bool

    init(allItems: [MenuItem], initialQuery: String = "") {
        let model = MenuSearchViewModel(allItems: allItems)
        model.query = initialQuery
        _viewModel = State(initialValue: model)
    }

    var body: some View {
        VStack(spacing: 0) {
            searchBar

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    if viewModel.query.isEmpty {
                        recentSearchSection
                    } else if !viewModel.results.isEmpty {
                        resultCountLabel
                        ForEach(Array(viewModel.results.enumerated()), id: \.element.id) { index, item in
                            if index > 0 {
                                thinDivider
                            }
                            resultRow(item)
                        }
                    } else {
                        noResultsView
                        popularMenuSection
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Colors.backgroundDefault.ignoresSafeArea())
        .navigationBarHidden(true)
        .onAppear { isSearchFieldFocused = true }
    }

    private var searchBar: some View {
        HStack(spacing: Spacing.spacing4) {
            Button(action: { dismiss() }) {
                Image(.arrowBackIos)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                    .padding(Spacing.spacing8)
            }
            .buttonStyle(.plain)

            HStack(spacing: Spacing.spacing8) {
                Image(.searchIcon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)

                TextField(
                    "",
                    text: $viewModel.query,
                    prompt: Text("메뉴 이름으로 검색해보세요").foregroundStyle(Colors.textTertiary)
                )
                .font(Typography.bodyMdRegular)
                .foregroundStyle(Colors.textPrimary)
                .focused($isSearchFieldFocused)
                .submitLabel(.search)
                .onSubmit { viewModel.submitSearch() }

                if !viewModel.query.isEmpty {
                    Button(action: { viewModel.query = "" }) {
                        Image(.closeIcon)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, Spacing.spacing16)
            .frame(height: 48)
            .frame(maxWidth: .infinity)
            .background(Colors.fillNeutralWeak)
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .padding(.leading, Spacing.spacing12)
        .padding(.trailing, Spacing.spacing20)
        .padding(.vertical, Spacing.spacing8)
        .background(Colors.backgroundDefault)
    }

    private var recentSearchSection: some View {
        Group {
            if !viewModel.recentSearches.isEmpty {
                Text("최근 검색")
                    .font(Typography.bodyLgSemibold)
                    .foregroundStyle(Colors.textPrimary)
                    .padding(.horizontal, Spacing.spacing20)
                    .padding(.vertical, Spacing.spacing12)

                ForEach(viewModel.recentSearches, id: \.self) { term in
                    recentSearchRow(term)
                }

                Color.clear.frame(height: Spacing.spacing16)
            }
        }
    }

    private func recentSearchRow(_ term: String) -> some View {
        HStack(spacing: Spacing.spacing8) {
            Button(action: { viewModel.recentSearchTapped(term) }) {
                Text(term)
                    .font(Typography.bodyMdMedium)
                    .foregroundStyle(Colors.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(.plain)

            Button(action: { viewModel.removeRecentSearch(term) }) {
                Image(.closeIcon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, Spacing.spacing20)
        .padding(.vertical, Spacing.spacing12)
    }

    private var resultCountLabel: some View {
        Text("메뉴 \(viewModel.results.count)개")
            .font(Typography.bodyMdMedium)
            .foregroundStyle(Colors.textSecondary)
            .padding(.horizontal, Spacing.spacing20)
            .padding(.top, Spacing.spacing16)
            .padding(.bottom, Spacing.spacing8)
    }

    private func resultRow(_ item: MenuItem) -> some View {
        Button(action: { viewModel.resultTapped(item) }) {
            VStack(alignment: .leading, spacing: Spacing.spacing4) {
                highlightedName(item.name, query: viewModel.query)
                    .font(Typography.bodyLgSemibold)

                Text("\(item.price.formatted())원")
                    .font(Typography.bodyMdSemibold)
                    .foregroundStyle(Colors.textPrimary)

                Text(item.description)
                    .font(Typography.bodySmRegular)
                    .foregroundStyle(Colors.textSecondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, Spacing.spacing20)
            .padding(.vertical, Spacing.spacing16)
        }
        .buttonStyle(.plain)
    }

    private func highlightedName(_ name: String, query: String) -> Text {
        guard !query.isEmpty, let range = name.range(of: query, options: .caseInsensitive) else {
            return Text(name).foregroundColor(Colors.textPrimary)
        }
        let prefix = String(name[name.startIndex..<range.lowerBound])
        let match = String(name[range])
        let suffix = String(name[range.upperBound...])
        return Text(prefix).foregroundColor(Colors.textPrimary)
            + Text(match).foregroundColor(Colors.textBrand)
            + Text(suffix).foregroundColor(Colors.textPrimary)
    }

    private var noResultsView: some View {
        ResultView(
            icon: .searchIcon,
            title: "'\(viewModel.query)'에 맞는 메뉴가 없어요",
            message: "다른 이름으로 검색해보세요"
        )
    }

    private var popularMenuSection: some View {
        Group {
            if !viewModel.popularItems.isEmpty {
                thickDivider

                Text("인기 메뉴")
                    .font(Typography.bodyLgSemibold)
                    .foregroundStyle(Colors.textPrimary)
                    .padding(.horizontal, Spacing.spacing20)
                    .padding(.top, Spacing.spacing12)

                ForEach(Array(viewModel.popularItems.enumerated()), id: \.element.id) { index, item in
                    if index > 0 {
                        thinDivider
                    }
                    popularMenuCard(item)
                }
            }
        }
    }

    private func popularMenuCard(_ item: MenuItem) -> some View {
        VStack(alignment: .leading, spacing: Spacing.spacing8) {
            Text(item.name)
                .font(Typography.bodyLgSemibold)
                .foregroundStyle(Colors.textPrimary)
            Text("\(item.price.formatted())원")
                .font(Typography.bodyMdSemibold)
                .foregroundStyle(Colors.textPrimary)
            Text(item.description)
                .font(Typography.bodySmRegular)
                .foregroundStyle(Colors.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(Spacing.spacing20)
    }

    private var thinDivider: some View {
        Rectangle()
            .fill(Colors.borderDefault)
            .frame(height: 1)
    }

    private var thickDivider: some View {
        Rectangle()
            .fill(Colors.backgroundLower)
            .frame(height: 12)
    }
}

#Preview {
    MenuSearchView(allItems: [
        MenuItem(id: "1", name: "아메리카노", price: 4000, description: "깔끔하고 산뜻한 기본 커피예요", badge: .popular, isSoldOut: false),
        MenuItem(id: "2", name: "카페라떼", price: 4500, description: "에스프레소에 부드러운 우유를 더했어요", badge: .popular, isSoldOut: false),
        MenuItem(id: "3", name: "바닐라라테", price: 5000, description: "달콤한 바닐라 시럽이 들어가요", badge: .popular, isSoldOut: false)
    ])
}
