//
//  RootTabView.swift
//  ORMO
//
//  Created by 성민 on 11/15/26.
//

import SwiftUI

struct RootTabView: View {
    var body: some View {
        // 하단 탭(주문내역·내정보 등)이 아직 설계되지 않아 임시로 메뉴 홈만 보여준다.
        HomeMenuView()
    }
}

#Preview {
    RootTabView()
}
