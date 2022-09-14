//
//  PhotoWidget.swift
//  AWSL
//
//  Created by FlyKite on 2022/9/13.
//

import WidgetKit
import SwiftUI

struct AWSLWidgetEntryView : View {
    var entry: RandomPhotoProvider.Entry

    var body: some View {
        if let image = entry.image {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
        } else {
            Image(systemName: "photo.on.rectangle.angled")
                .resizable()
                .scaledToFit()
                .frame(width: 64, height: 64)
                .foregroundColor(.pink)
        }
    }
}

@main
struct AWSLWidget: Widget {
    let kind: String = "AWSLWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: RandomPhotoProvider()) { entry in
            AWSLWidgetEntryView(entry: entry)
                .widgetURL(URL(string: "awsl://random?photo"))
        }
        .configurationDisplayName("看图")
        .description("随机展示一张图片")
        .supportedFamilies([.systemSmall, .systemLarge, .systemExtraLarge])
    }
}

struct AWSLWidget_Previews: PreviewProvider {
    static var previews: some View {
        AWSLWidgetEntryView(entry: PhotoEntry(date: Date(), photo: nil, image: nil))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
