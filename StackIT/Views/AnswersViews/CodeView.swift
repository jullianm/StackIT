//
//  CodeView.swift
//  StackIT
//
//  Created by Jessy on 27/09/2020.
//

import SwiftUI

struct CodeView: View {
    let code: String

    var body: some View {
        VStack {
            HStack {

                Button("Copy") {
                    let pasteboard = NSPasteboard.general
                    pasteboard.declareTypes([NSPasteboard.PasteboardType.string], owner: nil)
                    pasteboard.setString(code, forType: NSPasteboard.PasteboardType.string)
                }//.padding(.all, 10)
                Spacer()
            }



            ScrollView(.horizontal, showsIndicators: true) {
                Text(code).fixedSize(horizontal: false, vertical: true).lineLimit(nil)
            }.padding(.all, 10).background(Color.stackITGray).cornerRadius(10.0)

        }
    }
}

struct CodeView_Previews: PreviewProvider {
    static var previews: some View {
        CodeView(code: "T = branch taken\nN = branch not taken\ndata[] = 0, 1, 2, 3, 4, ... 126, 127, 128, 129, 130, ... 250, 251, 252, ...\nbranch = N  N  N  N  N  ...   N    N    T    T    T  ...   T    T    T  ...\n\n= NNNNNNNNNNNN ... NNNNNNNTTTTTTTTT ... TTTTTTTTTT  (easy to predict))")
        CodeView(code: "//  Branch - Random\nseconds = 10.93293813\n\n//  Branch - Sorted\nseconds = 5.643797077\n\n//  Branchless - Random\nseconds = 3.113581453\n\n//  Branchless - Sorted\nseconds = 3.186068823")
        CodeView(code: "if (data[c] >= 128)\n   sum += data[c];)")
    }
}
