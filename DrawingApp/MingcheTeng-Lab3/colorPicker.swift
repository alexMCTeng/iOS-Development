//
//  colorPicker.swift
//  MingcheTeng-Lab3
//
//  Created by AlexTeng on 10/10/20.
//  Copyright © 2020 AlexTeng. All rights reserved.
//

import Foundation
struct FormattingControls: View {
    @State private var bgColor =
        Color(.sRGB, red: 0.98, green: 0.9, blue: 0.2)

    var body: some View {
        VStack {
            ColorPicker("Alignment Guides", selection: $bgColor)
        }
    }
}
