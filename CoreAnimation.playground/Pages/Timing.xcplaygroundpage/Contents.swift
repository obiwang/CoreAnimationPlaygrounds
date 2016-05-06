import UIKit

let v = createFrame()
let duration = 100.0
let w = CGFloat(50)
var now : CFTimeInterval = 0

let layer = CALayer()
layer.bounds = CGRectMake(0, 0, w, w)
layer.backgroundColor = UIColor.lightGrayColor().CGColor
layer.position = v.center
v.layer.addSublayer(layer)

let slider = UISlider()
v.addSubview(slider)
var rc = slider.frame
rc.origin.y = v.frame.size.height - rc.size.height
rc.size.width = v.frame.size.width
slider.frame = rc
slider.maximumValue = Float(duration)

let labelLayer = UILabel(frame:CGRectMake(5, 5, 300, 100))
labelLayer.numberOfLines = 0
labelLayer.font = UIFont(name: "Courier", size: 15)
v.addSubview(labelLayer)

let labelAnim = UILabel(frame:CGRectMake(0, 5, rc.size.width - 5, 100))
labelAnim.numberOfLines = 0
labelAnim.textAlignment = NSTextAlignment.Right
labelAnim.font = UIFont(name: "Courier", size: 15)
v.addSubview(labelAnim)

let speedStepper = UIStepper(frame: CGRectMake(30, rc.origin.y - 40, 0, 0))
speedStepper.value = 0
v.addSubview(speedStepper)
var stepperRect = speedStepper.frame
stepperRect.size.width = stepperRect.origin.x
stepperRect.origin.x = 0
let speedLabel = UILabel(frame: stepperRect)
speedLabel.textAlignment = .Center
v.addSubview(speedLabel)

let speedHandler = EventHandler(control: speedStepper, forEvent: .ValueChanged) { _ in
    let newSpeed = speedStepper.value
    let oldSpeed = Double(layer.speed)
    
    if newSpeed == 0 {
        let pauseTime = layer.convertTime(CACurrentMediaTime(), fromLayer: nil)
        layer.speed = 0
        layer.timeOffset = pauseTime
    } else if oldSpeed == 0 {
        layer.speed = Float(newSpeed)
        let pauseTime = layer.timeOffset
        layer.beginTime = 0
        layer.timeOffset = 0
        let timeSincePause = layer.convertTime(CACurrentMediaTime(), fromLayer: nil) - pauseTime
        layer.beginTime = timeSincePause
    } else {
        let beginTime = layer.beginTime
        layer.beginTime = 0
        layer.timeOffset = 0
        var tp = layer.convertTime(CACurrentMediaTime(), fromLayer: nil) / oldSpeed
        
        layer.speed = Float(newSpeed)
        layer.beginTime = tp - (tp-beginTime) * oldSpeed/newSpeed
    }
    
    speedLabel.text = "\(Int(newSpeed))"
}

stepperRect = speedStepper.frame
stepperRect.origin.x += speedStepper.frame.size.width + 50
let offsetStepper = UIStepper(frame: stepperRect)
offsetStepper.value = 0
offsetStepper.stepValue = 10
offsetStepper.minimumValue = -200
offsetStepper.maximumValue = 200
v.addSubview(offsetStepper)
stepperRect.size.width = 40
stepperRect.origin.x -= 40
let offsetLabel = UILabel(frame: stepperRect)
offsetLabel.textAlignment = .Center
v.addSubview(offsetLabel)

let offsetHandler = EventHandler(control: offsetStepper, forEvent: .ValueChanged) { _ in
    layer.timeOffset = offsetStepper.value
    speedHandler.onEvent()
    offsetLabel.text = "\(Int(offsetStepper.value))"
}

let timerHandler = TimerHandler(interval: 1.0/10, repeats: true) { _ in
    let pos = layer.presentationLayer()!.position
    let p = layer.convertTime(CACurrentMediaTime(), fromLayer: nil)
    let a = (layer.speed != 0) ? (p - now) : 0 + layer.timeOffset
    let postion = String(format: "  Position:%10.2f\n", pos.x)
    let at = String(format: "ActiveTime:%10.2f\n", a)
    let pt = String(format: "ParentTime:%10.2f\n", p)
    let st = String(format: " BeginTime:%10.2f\n", layer.beginTime)
    let offset = String(format: "TimeOffset:%10.2f", layer.timeOffset)
    labelLayer.text = "<Layer>\n" + postion + at + pt + st + offset
}

let a = CABasicAnimation(keyPath: "position.x")
a.fromValue = w/2
a.toValue = rc.size.width - w/2
a.duration = duration
a.repeatCount = HUGE
a.autoreverses = true
a.fillMode = kCAFillModeBackwards
a.delegate = AnimationDelegate { e in
    switch e {
    case .Start(let anim):
        now = anim.beginTime
        let offset = String(format: "TimeOffset:%10.2f\n", anim.timeOffset)
        let duration = String(format: "Duration:%10.2f\n", anim.duration)
        let begin = String(format: "BeginTime:%10.2f\n\n", anim.beginTime)
        labelAnim.text = "<Animation>\n" + duration + offset + begin
        break
    case .Stop:
        timerHandler.invalidate()
        labelAnim.text = (labelAnim.text ?? "") + "[END]"
        break
    }
}

let sliderHandler = EventHandler (control: slider, forEvent: .ValueChanged) { _ in
    if let anim = layer.animationForKey("test") {
        layer.timeOffset = Double(slider.value) + anim.beginTime
    }
}

//a.speed = 2
now = layer.convertTime(CACurrentMediaTime(), fromLayer: nil)
speedHandler.onEvent()
now = layer.convertTime(CACurrentMediaTime(), fromLayer: nil)
//a.beginTime = (now + 2) * Double(layer.speed)
//layer.timeOffset = 5
//a.beginTime = now + 4// * Double(layer.speed)
layer.addAnimation(a, forKey: "test")
//layer.beginTime = 0
//layer.beginTime = -2
//layer.timeOffset = (now + 2) * Double(layer.speed)

//: [Next](@next)
