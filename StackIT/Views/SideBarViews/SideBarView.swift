//
//  SideBarView.swift
//  StackIT
//
//  Created by Jullian Mercier on 2020-08-06.
//

import SwiftUI

struct SideBarView: View {
    @EnvironmentObject var viewManager: ViewManager
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            AccountSectionView()
            TrendingSectionView()
            TagSectionView()
        }.padding(.top, 5)
    }
}

struct SideBarView_Previews: PreviewProvider {
    static var previews: some View {
        SideBarView()
    }
}
