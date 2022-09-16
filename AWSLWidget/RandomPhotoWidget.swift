//
//  RandomPhotoWidget.swift
//  AWSL
//
//  Created by FlyKite on 2022/9/13.
//

import WidgetKit
import SwiftUI

struct RandomPhotoWidgetEntryView : View {
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
struct RandomPhotoWidget: Widget {
    let kind: String = "AWSLWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: RandomPhotoProvider()) { entry in
            RandomPhotoWidgetEntryView(entry: entry)
                .widgetURL(URL(string: "awsl://random?photo"))
        }
        .configurationDisplayName("看图")
        .description("随机展示一张图片")
        .supportedFamilies([.systemSmall, .systemLarge, .systemExtraLarge])
    }
}

struct RandomPhotoWidget_Previews: PreviewProvider {
    static var previews: some View {
        RandomPhotoWidgetEntryView(entry: PhotoEntry(date: Date(), photo: nil, image: nil))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
