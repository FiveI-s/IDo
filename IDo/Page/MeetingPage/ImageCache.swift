import UIKit

class ImageCache {
    static let shared = ImageCache()
    private init() {}
    
    private let imageCache = NSCache<NSString, UIImage>()
    
    func cacheImage(_ image: UIImage, for key: String) {
        imageCache.setObject(image, forKey: key as NSString)
    }
    
    func getImage(for key: String) -> UIImage? {
        return imageCache.object(forKey: key as NSString)
    }
}
