#!/usr/bin/env swift
import AppKit

// Renders Vremena's app icon: a deep-blue rounded square with two clock faces,
// echoing the "more than one time" idea. Outputs a 1024×1024 PNG.

let size = 1024.0
let image = NSImage(size: NSSize(width: size, height: size))
image.lockFocus()
let ctx = NSGraphicsContext.current!.cgContext

// Background gradient
let bgRect = NSRect(x: 0, y: 0, width: size, height: size)
let path = NSBezierPath(roundedRect: bgRect, xRadius: size * 0.22, yRadius: size * 0.22)
path.addClip()
let colors = [NSColor(calibratedRed: 0.16, green: 0.22, blue: 0.45, alpha: 1).cgColor,
              NSColor(calibratedRed: 0.07, green: 0.10, blue: 0.24, alpha: 1).cgColor] as CFArray
let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors, locations: [0, 1])!
ctx.drawLinearGradient(gradient, start: CGPoint(x: 0, y: size), end: CGPoint(x: size, y: 0), options: [])

func drawClock(center: CGPoint, radius: CGFloat, hour: CGFloat, minute: CGFloat, faceAlpha: CGFloat) {
    // Face
    let faceRect = NSRect(x: center.x - radius, y: center.y - radius, width: radius * 2, height: radius * 2)
    NSColor(calibratedWhite: 1.0, alpha: faceAlpha).setFill()
    NSBezierPath(ovalIn: faceRect).fill()
    // Ring
    let ring = NSBezierPath(ovalIn: faceRect.insetBy(dx: radius * 0.06, dy: radius * 0.06))
    NSColor(calibratedRed: 0.16, green: 0.22, blue: 0.45, alpha: 0.25).setStroke()
    ring.lineWidth = radius * 0.05
    ring.stroke()
    // Hands
    func hand(angleHours: CGFloat, length: CGFloat, width: CGFloat) {
        let angle = (CGFloat.pi / 2) - (angleHours / 12.0) * (2 * CGFloat.pi)
        let end = CGPoint(x: center.x + cos(angle) * length, y: center.y + sin(angle) * length)
        let p = NSBezierPath()
        p.move(to: center)
        p.line(to: end)
        p.lineWidth = width
        p.lineCapStyle = .round
        NSColor(calibratedRed: 0.10, green: 0.13, blue: 0.30, alpha: 1).setStroke()
        p.stroke()
    }
    hand(angleHours: hour, length: radius * 0.5, width: radius * 0.11)            // hour hand
    hand(angleHours: minute / 5.0, length: radius * 0.72, width: radius * 0.07)   // minute hand
    // Hub
    let hub = radius * 0.08
    NSColor(calibratedRed: 0.10, green: 0.13, blue: 0.30, alpha: 1).setFill()
    NSBezierPath(ovalIn: NSRect(x: center.x - hub, y: center.y - hub, width: hub * 2, height: hub * 2)).fill()
}

// Two overlapping clocks: a back one (faint) and a front one (bright).
drawClock(center: CGPoint(x: size * 0.62, y: size * 0.40), radius: size * 0.24, hour: 4, minute: 40, faceAlpha: 0.45)
drawClock(center: CGPoint(x: size * 0.40, y: size * 0.58), radius: size * 0.30, hour: 10, minute: 10, faceAlpha: 1.0)

image.unlockFocus()

guard let tiff = image.tiffRepresentation,
      let rep = NSBitmapImageRep(data: tiff),
      let png = rep.representation(using: .png, properties: [:]) else {
    fatalError("Could not render icon")
}
let out = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "icon_1024.png"
try! png.write(to: URL(fileURLWithPath: out))
print("Wrote \(out)")
