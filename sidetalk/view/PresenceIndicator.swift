
import Foundation;
import ReactiveCocoa;
import enum Result.NoError;

class PresenceIndicator: NSView {
    internal let signal: Signal<Presence, NoError>;
    internal let initial: Presence;

    internal let size = CGFloat(10);
    internal let stroke = CGFloat(1.5);
    internal let offlineColor = NSColor.init(red: 0.7, green: 0, blue: 0, alpha: 0.95).cgColor;
    internal let onlineColor =  NSColor.init(red: 0, green: 0.8, blue: 0.15, alpha: 0.95).cgColor;

    fileprivate let ringLayer: CAShapeLayer;

    init(presenceSignal signal: Signal<Presence, NoError>, initial: Presence, frame: NSRect) {
        self.signal = signal;
        self.initial = initial;

        self.ringLayer = CAShapeLayer();

        super.init(frame: frame);
    }

    required init(coder: NSCoder) { fatalError("brocoder"); }

    override func viewDidMoveToSuperview() {
        let path = NSBezierPath.init(
            roundedRect: NSRect(origin: NSPoint(x: self.stroke, y: self.stroke), size: NSSize(width: self.size, height: self.size)),
            cornerRadius: self.size / 2
        );
        self.ringLayer.path = path?.cgPath;
        self.ringLayer.lineWidth = self.stroke;
        self.update(self.initial);
        self.layer!.addSublayer(self.ringLayer);

        self.prepare();
    }

    fileprivate func prepare() {
        self.signal.observeNext { presence in self.update(presence); };
    }

    fileprivate func update(_ presence: Presence) {
        DispatchQueue.main.async(execute: {
            // for now, only offline/online.
            switch presence {
            case .offline:
                self.ringLayer.fillColor = self.offlineColor;
                self.ringLayer.strokeColor = NSColor.white.cgColor;
            case .online:
                self.ringLayer.fillColor = self.onlineColor;
                self.ringLayer.strokeColor = NSColor.white.cgColor;
            default:
                self.ringLayer.fillColor = NSColor.clear.cgColor;
                self.ringLayer.strokeColor = NSColor.clear.cgColor;
            }
        });
    }
}
