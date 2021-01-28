//
//  task_Widget.swift
//  task Widget
//
//  Created by Ingvar on 27.01.2021.
//

import WidgetKit
import SwiftUI
import Intents

struct Provider: IntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: ConfigurationIntent())
    }
    
    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), configuration: configuration)
        completion(entry)
    }
    
    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []
        
        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate, configuration: configuration)
            entries.append(entry)
        }
        
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationIntent
}

struct task_WidgetEntryView : View {
    @Environment(\.widgetFamily) var family
    @Environment(\.colorScheme) var scheme
    @ObservedObject var batteryVM = BatteryViewModel()
    
    var entry: Provider.Entry
    
    var body: some View {
        ZStack {
            Image("background")
                .resizable()
                .aspectRatio(contentMode: .fill)
            
            timeDetail
            dateDetail
        }
        .onAppear() {
            self.batteryVM.startMonitor()
        }
        .onDisappear() {
            self.batteryVM.stopMonitor()
        }
    }
}

extension task_WidgetEntryView {

    var headerDate: some View {
        HStack {
        let calendar = Calendar.current
        let weekday  = calendar.component(.day, from: Date())

        Text("\(weekday) \(Date().monthAsString())")
            .foregroundColor(.white)
            .font(family == .systemLarge ? .sfProDisplayBold(size: 26) : .sfProDisplayBold(size: 18))
        }
    }
    
    var day: some View {
        Text(Date().getTodayWeekDay())
            .foregroundColor(.white)
            .font(dayTextFont)
            .padding(family == .systemLarge ? 10 : 0 )
    }
    
    var batteryStatusView: some View {
        ZStack {
            Image("battery")
            Text("\(batteryVM.remain)")
                .font(.system(size: 12))
        }
    }
    
    var timeDetail: some View {
        VStack(alignment: .center) {
            let calendar = Calendar.current
            let hours    = calendar.component(.hour, from: Date())
            let minutes  = calendar.component(.minute, from: Date())
            
            if family == .systemMedium {
                Text("\(hours):\(minutes)")
                    .font(timeTextFont)
                    .foregroundColor(Color.white.opacity(0.6))
                    .padding(family == .systemLarge ? 15 : 0 )
            } else {
                VStack(alignment: .trailing, spacing: family == .systemLarge ? -50 : -20) {
                    Text("\(hours)")
                    Text("\(minutes)")
                }
                .padding(.trailing,-60)
                .font(timeTextFont)
                .foregroundColor(Color.white.opacity(0.6))
            }
        }
    }
    
    var dateDetail: some View {
        VStack(alignment: .leading) {
            if family != .systemSmall {
                HStack(spacing: -50) {
                    headerDate
                    Spacer()
                    batteryStatusView
                        .padding(.trailing, family == .systemLarge ? 30 : 10)
                }
            } else {
                VStack(alignment: .leading) {
                    headerDate
                    Spacer()
                    batteryStatusView
                }
                .padding(.bottom, -25)
            }
            Spacer()
                .frame(height: heightSpacerFrame)
            day
        }
        .padding(20)
    }
}

// MARK: - Computed Properties
extension task_WidgetEntryView {
    var dayTextFont: Font {
        switch self.family{
        case .systemLarge:
            return .courgetteRegular(size: 44)
        case .systemMedium:
            return .courgetteRegular(size: 32)
        case .systemSmall:
            return .courgetteRegular(size: 22)
        }
    }
    
    var timeTextFont: Font {
        switch self.family{
        case .systemLarge:
            return .sfProRoundedRegular(size: 180)
        case .systemMedium:
            return .sfProRoundedRegular(size: 100)
        case .systemSmall:
            return .sfProRoundedRegular(size: 80)
        }
    }
    
    var heightSpacerFrame: CGFloat {
        switch self.family{
        case .systemLarge:
            return 260
        case .systemMedium:
            return 80
        case .systemSmall:
            return 30
        }
    }
}

@main
struct task_Widget: Widget {
    let kind: String = "task_Widget"
    
    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            task_WidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Task Widget")
        .description("This is an example widget.")
    }
}

struct task_Widget_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            task_WidgetEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent()))
                .previewContext(WidgetPreviewContext(family: .systemSmall))
            task_WidgetEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent()))
                .previewContext(WidgetPreviewContext(family: .systemMedium))
            task_WidgetEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent()))
                .previewContext(WidgetPreviewContext(family: .systemLarge))
        }
    }
}
