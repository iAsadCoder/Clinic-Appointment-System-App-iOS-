import SwiftUI

@main
struct ClinicAppointmentApp: App {
    @StateObject private var dataService = MockDataService.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(dataService)
        }
    }
}
