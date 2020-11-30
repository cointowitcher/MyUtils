extension UIView {

    // From an original idea by Florian Kugler
    // https://www.objc.io/issues/3-views/advanced-auto-layout-toolbox/
    
    class func exerciseAmbiguity(_ view: UIView) {
        #if DEBUG
        if view.hasAmbiguousLayout {
            Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
                view.exerciseAmbiguityInLayout()
            }
        } else {
            for subview in view.subviews {
                UIView.exerciseAmbiguity(subview)
            }
        }
        #endif
    }
}
