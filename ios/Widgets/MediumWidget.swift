//
//  MediumWidget.swift
//  WidgetsExtension
//
//  Created by Yerzhan Tulepov on 12.02.2022.
//

import SwiftUI
import WidgetKit

struct MediumWidget : View {
    var entry: Provider.Entry
    
    var body: some View {
        Text(entry.date, style: .date)
    }
}

struct Preview: PreviewProvider {
    static var previews: some View {
        MediumWidget(entry: Provider.previewEntry)
            .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}
