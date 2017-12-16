
import Foundation

class ShadowLayer: CALayer {
    private var _width: CGFloat = 0;
    var width: CGFloat {
        get { return self._width; }
        set {
            self._width = newValue;
            DispatchQueue.main.async(execute: { self.setNeedsDisplay(); });
        }
    }
    private var _radius: CGFloat = 3;
    var radius: CGFloat {
        get { return self._radius; }
        set {
            self._radius = newValue;
            DispatchQueue.main.async(execute: { self.setNeedsDisplay(); });
        }
    }

    override func draw(in ctx: CGContext) {
        // retina?
        self.contentsScale = NSScreen.main!.backingScaleFactor;

        // don't bother drawing anything if we have no width.
        if self._width <= 0 { return; }

        // generate the initial box image.
        let width = min(self._width + self._radius + (3 * self._radius * (self._width / (self.frame.width - (2 * self._radius)))), self.frame.width - (2 * self._radius));
        let bounds = CGRect(origin: CGPoint(x: self.frame.width - self._radius - width, y: self._radius),
                            size: CGSize(width: width, height: self.frame.height - (2 * self._radius)));
        let path = NSBezierPath(roundedRect: bounds, cornerRadius: self._radius);

        let box = NSImage(size: self.frame.size, flipped: false) { rect in
            NSColor.black.set();
            path!.fill();
            return true;
        };

        // create the blur filter.
        let blurFilter = CIFilter(name: "CIGaussianBlur")!;
        blurFilter.setDefaults();
        blurFilter.setValue(self._radius, forKey: "inputRadius");

        // feed the image into the filter.
        let cgImage = box.cgImage(forProposedRect: nil, context: NSGraphicsContext.current, hints: nil)!;
        let ciImage = CIImage(cgImage: cgImage);
        blurFilter.setValue(ciImage, forKey: "inputImage");

        // now get it back out of the filter. :/
        let rep = NSCIImageRep(ciImage: blurFilter.outputImage!);
        let final = NSImage(size: box.size);
        final.addRepresentation(rep);

        // actually draw the contents to the layer.
        XUIGraphicsPushContext(ctx);
        let frame = NSRect(origin: NSPoint.zero, size: self.frame.size);
        final.draw(in: frame, from: frame, operation: .copy, fraction: 1.0);
        XUIGraphicsPopContext();
    }
}
