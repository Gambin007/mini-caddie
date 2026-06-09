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
        VStack(spacing: 28) {

            VStack(spacing: 4) {
                Text("⛳️ Mini-Caddie")
                    .font(.largeTitle.bold())
                Text("Swift-Experiment von \(author)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.bottom, 24)

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

            Spacer()
        }
        .padding()
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
                .font(.callout)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.secondarySystemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(.green.opacity(0.4), lineWidth: 1)
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
