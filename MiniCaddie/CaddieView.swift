import SwiftUI

// Der einzige Screen der App.
// View ist ein struct (kein class), weil SwiftUI Views ständig wegwirft und neu
// baut. Deshalb lebt der Zustand nicht hier, sondern im ViewModel.
struct CaddieView: View {

    // @StateObject: dieser View erzeugt und besitzt das ViewModel. Wird genau
    // einmal angelegt und überlebt alle Redraws.
    // (@State wäre nur für simple Werte wie Int/Bool; @ObservedObject nimmt man,
    // wenn das Objekt von aussen reingereicht wird.)
    @StateObject private var viewModel = CaddieViewModel()

    private let author = "Noé Schertenleib"

    var body: some View {
        // ScrollView, damit die Schläger-Liste auch auf kleinen iPhones passt.
        ScrollView {
            VStack(spacing: 28) {

                VStack(spacing: 4) {
                    Text("⛳️ Mini-Caddie")
                        .font(.largeTitle.bold())
                    Text("Swift-Experiment von \(author)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.bottom, 40)

                // Distanz-Slider. $viewModel.distance ist ein Binding (das $):
                // der Slider schreibt direkt zurück und der View aktualisiert sich.
                VStack(alignment: .leading) {
                    Text("Distanz zum Ziel: \(Int(viewModel.distance)) m")
                        .font(.headline)
                    Slider(value: $viewModel.distance, in: 50...250, step: 1)
                }

                // Wind-Slider in km/h.
                VStack(alignment: .leading) {
                    Text("Wind: \(windLabel)")
                        .font(.headline)
                    Slider(value: $viewModel.wind, in: -40...40, step: 1)
                    Text("Gegenwind (−) verlängert, Rückenwind (+) verkürzt.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                resultCard

                clubList
            }
            .padding()
        }
    }

    // Ergebnis-Card. In eine eigene Property ausgelagert, damit der body kurz bleibt.
    private var resultCard: some View {
        VStack(spacing: 12) {
            Text("Empfehlung")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            // Empfohlener Schläger, gross.
            Text(viewModel.recommendedClub?.name ?? "–")
                .font(.system(size: 44, weight: .bold, design: .rounded))

            Text("Effektive Distanz: \(Int(viewModel.effectiveDistance.rounded())) m")
                .font(.headline)

            Divider()

            Text(viewModel.reason)
                .font(.footnote)
                .lineLimit(1)                 // immer eine Zeile
                .minimumScaleFactor(0.6)      // notfalls kleiner skalieren statt umbrechen
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(15)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.secondarySystemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(.green.opacity(0.4), lineWidth: 1)
        )
    }

    // Übersicht aller Schläger. ForEach geht die Liste aus dem ViewModel durch.
    // Funktioniert, weil Club Identifiable ist (jedes Element hat ein id).
    // Der empfohlene Schläger wird grün hervorgehoben.
    private var clubList: some View {
        VStack(spacing: 0) {
            ForEach(viewModel.clubs) { club in
                let isRecommended = club == viewModel.recommendedClub

                HStack {
                    Text(club.name)
                        .fontWeight(isRecommended ? .bold : .regular)
                    Spacer()
                    Text("\(club.distance) m")
                        .foregroundStyle(isRecommended ? .primary : .secondary)
                    if isRecommended {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                            .imageScale(.small)
                    }
                }
                .font(.subheadline)
                .padding(.vertical, 5)
                .padding(.horizontal, 14)
                .background(isRecommended ? Color.green.opacity(0.12) : .clear)

                // Trennlinie zwischen den Zeilen, ausser nach der letzten.
                if club.id != viewModel.clubs.last?.id {
                    Divider()
                }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemBackground))
        )
    }

    // Wind-Text mit Vorzeichen.
    private var windLabel: String {
        let value = Int(viewModel.wind)
        switch value {
        case 0:           return "0 km/h (windstill)"
        case let v where v > 0: return "+\(v) km/h (Rückenwind)"
        default:          return "\(value) km/h (Gegenwind)"
        }
    }
}

// Live-Vorschau im Xcode-Canvas, ohne Simulator.
#Preview {
    CaddieView()
}
