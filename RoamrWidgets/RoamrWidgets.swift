//
//  RoamrWidgets.swift
//  RoamrWidgets
//
//  Created by Aydan Hawken on 18/07/23.
//

import WidgetKit
import SwiftUI

struct Provider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: ConfigurationAppIntent())
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: configuration)
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate, configuration: configuration)
            entries.append(entry)
        }

        return Timeline(entries: entries, policy: .atEnd)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationAppIntent
}

struct RoamrWidgetsEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        VStack {
            HStack {
                Image(systemName: "magnifyingglass")
                    .resizable()
                    .frame(width: 30, height: 30)
                    .foregroundColor(.primary)
                
                Text("Search")
                    .font(.title)
                    .foregroundColor(.primary)
            }
//            HStack{
//                Button(action: {
//                    // Open app settings (replace "app-settings-url" with your actual app settings URL)
//                    if let settingsURL = URL(string: "app-settings-url") {
//                        //UIApplication.shared.open(settingsURL)
//                    }
//                }) {
//                    Text("Open App Settings")
//                }
//                
//                Button(action: {
//                    // Open all tabs (replace "all-tabs-url" with your actual URL to open all tabs)
//                    if URL(string: "all-tabs-url") != nil {
//                        //UIApplication.shared.open(allTabsURL)
//                    }
//                }) {
//                    Text("Open All Tabs")
//                }
//                
//                Button(action: {
//                    // Open themes (replace "themes-url" with your actual URL to open themes)
//                    if URL(string: "themes-url") != nil {
//                        //UIApplication.shared.open(themesURL)
//                    }
//                }) {
//                    Text("Open Themes")
//                }
//                
//                Spacer()
//            }
        }
    }
    }
    

func openSettings() {
        
    }

struct RoamrWidgets: Widget {
    let kind: String = "RoamrWidgets"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
            RoamrWidgetsEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
    }
}

extension ConfigurationAppIntent {
    fileprivate static var smiley: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        intent.favoriteEmoji = "😀"
        return intent
    }
    
    fileprivate static var starEyes: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        intent.favoriteEmoji = "🤩"
        return intent
    }
}

#Preview(as: .systemMedium) {
    RoamrWidgets()
} timeline: {
    SimpleEntry(date: .now, configuration: .smiley)
    SimpleEntry(date: .now, configuration: .starEyes)
}
