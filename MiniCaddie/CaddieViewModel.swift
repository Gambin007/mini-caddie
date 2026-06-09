import Foundation
import Combine   // ObservableObject und @Published kommen aus Combine

// Ein Schläger im Bag.
// Identifiable, falls ich die Liste später mal mit ForEach anzeigen will -
// dann braucht jedes Element ein id. Hier nehme ich einfach den Namen.
struct Club: Identifiable, Equatable {
    let name: String        // z. B. "Eisen 7"
    let distance: Int       // typische Schlagweite in Metern

    var id: String { name }
}

// Hält den Zustand und die Rechen-Logik, getrennt vom View.
// ObservableObject + @Published: ändert sich ein Wert, rendert SwiftUI den View
// automatisch neu. final class, weil das ViewModel von View und Logik geteilt
// wird. @MainActor: Änderungen passieren auf dem Main-Thread (wichtig für UI).
@MainActor
final class CaddieViewModel: ObservableObject {

    // Eingaben aus den Slidern:
    @Published var distance: Double = 150   // Distanz zum Ziel in Metern
    @Published var wind: Double = 0         // km/h: minus = Gegenwind, plus = Rückenwind

    // Mein Bag. let, weil sich die Liste zur Laufzeit nicht ändert.
    let clubs: [Club] = [
        Club(name: "Driver", distance: 230),
        Club(name: "Holz 3", distance: 210),
        Club(name: "Eisen 5", distance: 170),
        Club(name: "Eisen 7", distance: 150),
        Club(name: "Eisen 9", distance: 125),
        Club(name: "PW", distance: 110),
        Club(name: "SW", distance: 80)
    ]

    // Die folgenden Werte werden bei jedem Zugriff frisch berechnet und sind
    // damit nach jeder Slider-Bewegung automatisch aktuell.

    // Faustregel: 0,5 % der Schlagweite pro km/h Wind.
    // 20 km/h sind also ca. 10 % Korrektur. Wert ruhig anpassen.
    private let windEffectPerKmh = 0.005

    // Die Distanz, die ich tatsächlich schlagen muss.
    // Wind wirkt prozentual: längere Schläge hängen länger in der Luft und
    // werden stärker beeinflusst. Gegenwind verlängert, Rückenwind verkürzt.
    var effectiveDistance: Double {
        let windAdjustment = distance * windEffectPerKmh * wind
        return distance - windAdjustment
    }

    // Schläger, dessen Distanz am nächsten an der effektiven Distanz liegt.
    var recommendedClub: Club? {
        clubs.min { lhs, rhs in
            abs(Double(lhs.distance) - effectiveDistance)
                < abs(Double(rhs.distance) - effectiveDistance)
        }
    }

    // Kurze Begründung für die Anzeige.
    var reason: String {
        guard let club = recommendedClub else {
            return "Kein passender Schläger gefunden."
        }
        let target = Int(effectiveDistance.rounded())
        return "\(club.name), weil \(club.distance) m am nächsten an \(target) m liegt."
    }
}
