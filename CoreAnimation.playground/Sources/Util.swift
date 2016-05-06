
import UIKit
import XCPlayground

public class FrameView : UIView {
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        self.setup()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override class func layerClass() -> AnyClass {
        return CAGradientLayer.self
    }
    
    public func setup() {
        let layer = self.layer as! CAGradientLayer
        layer.colors = [UIColor.whiteColor().CGColor, UIColor.lightGrayColor().CGColor]
        layer.startPoint = CGPointMake(0, 0)
        layer.endPoint = CGPointMake(0, 1)
    }
}

public func createFrame(frameClass: AnyClass? = nil) -> UIView {
    let frameClass = (frameClass as? UIView.Type) ?? FrameView.self
    let frame = frameClass.init(frame: CGRectMake(0, 0, 576, 320))
    XCPlaygroundPage.currentPage.liveView = frame
    return frame
}

public func createStar(count:Int, inRect rect:CGRect) -> UIBezierPath {
    let angle = 180*(Double(count)-2)/Double(count)/3
    let size = rect.size
    let raidus = min(size.height, size.width)/2 - 1
    let length = raidus * CGFloat(cos(angle*1.5/180 * M_PI)/cos(angle/180 * M_PI))
    var pt = CGPointMake(size.width/2, size.height/2 - raidus)
    
    let path = UIBezierPath()
    path.moveToPoint(pt)
    
    var offset = angle/2-90
    for i in 0..<count*2-1 {
        offset += (i%2 == 0) ? 180 - angle : -angle*2
        let r = CGFloat(offset/180 * M_PI)
        pt.x += length * cos(r)
        pt.y += length * sin(r)
        path.addLineToPoint(pt)
    }
    path.closePath()
    return path
}

public class EventHandler {
    public var handler : (AnyObject? -> Void)?
    @objc public func onEvent(sender:AnyObject? = nil) {
        self.handler?(sender)
    }
    
    public required init(handler: AnyObject? -> Void) {
        self.handler = handler
    }
    
    public convenience init(control: UIControl, forEvent event:UIControlEvents, handler: AnyObject? -> Void) {
        self.init(handler: handler)
        control.addTarget(self, action: #selector(onEvent), forControlEvents: event)
    }
}

public class TimerHandler : EventHandler {
    private var timer : NSTimer?
    public func invalidate() {
        self.timer?.fire()
        self.timer?.invalidate()
    }
    public convenience init(interval: NSTimeInterval, repeats: Bool, handler: AnyObject? -> Void) {
        self.init(handler: handler)
        self.timer = NSTimer.scheduledTimerWithTimeInterval(interval, target: self, selector: #selector(onEvent), userInfo: nil, repeats: repeats)
    }
}

public class AnimationDelegate : NSObject {
    public enum EventType {
        case Start(anim:CAAnimation)
        case Stop(flag:Bool)
    }
    
    public var handler : (EventType -> Void)?
    public required init(handler: EventType -> Void) {
        self.handler = handler
    }

    public override func animationDidStart(anim: CAAnimation) {
        self.handler?(.Start(anim:anim))
    }
    
    public override func animationDidStop(anim: CAAnimation, finished flag: Bool) {
        self.handler?(.Stop(flag: flag))
    }
}
