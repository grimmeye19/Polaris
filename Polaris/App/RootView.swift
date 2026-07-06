import SwiftUI

struct RootView: View {
    var body: some View {
        TabView {
            ExpeditionListView()
                .tabItem {
                    Label("Expediciones", systemImage: "sailboat")
                }

            PortView()
                .tabItem {
                    Label("Puerto", systemImage: "house.fill")
                }
        }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}
