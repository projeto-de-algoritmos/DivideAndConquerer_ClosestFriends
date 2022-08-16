import Foundation

class Algorithm {
    
    func closestPairOf(points: [User]) -> (minimum:Double, firstPoint: User, secondPoint:User) {
        var innerPoints = mergeSort(points, sortAccording : true)
        let result = closestPair(&innerPoints, innerPoints.count)
        return (result.minValue, result.firstPoint, result.secondPoint)
    }
    
    func closestPair(_ p : inout [User],_ n : Int) -> (minValue: Double, firstPoint: User, secondPoint: User)
    {
        if n <= 3
        {
            var i=0, j = i+1
            var minDist = Double.infinity
            var newFirst:User? = nil
            var newSecond:User? = nil
            while i<n
            {
                j = i+1
                while j < n
                {
                    if dist(p[i], p[j]) <= minDist
                    {
                        minDist = dist(p[i], p[j])
                        newFirst = p[i]
                        newSecond = p[j]
                    }
                    j+=1
                }
                i+=1
                
            }
            return (minDist, newFirst ?? User(name: Randoms.randomFakeFirstName(), coordinate: .init(latitude: 0, longitude: 0)), newSecond ?? User(name: Randoms.randomFakeFirstName(), coordinate: .init(latitude: 0, longitude: 0)))
        }
        
        
        
        let mid:Int = n/2
        let line:Double = (p[mid].coordinate.latitude + p[mid+1].coordinate.latitude)/2
        
        var leftSide = [User]()
        var rightSide = [User]()
        for s in 0..<mid
        {
            leftSide.append(p[s])
        }
        for s in mid..<p.count
        {
            rightSide.append(p[s])
        }
        
        
        let valueFromLeft = closestPair(&leftSide, mid)
        let minLeft:Double = valueFromLeft.minValue
        let valueFromRight = closestPair(&rightSide, n-mid)
        let minRight:Double = valueFromRight.minValue
        
        var min = Double.infinity
        
        var first: User
        var second: User
        
        if minLeft < minRight {
            min = minLeft
            first = valueFromLeft.firstPoint
            second = valueFromLeft.secondPoint
        }
        else {
            min = minRight
            first = valueFromRight.firstPoint
            second = valueFromRight.secondPoint
        }
        
        p = mergeSort(p, sortAccording: false)
        
        
        var strip = [User]()
        
        var i=0, j = 0
        while i<n
        {
            if abs(p[i].coordinate.latitude - line) < min
            {
                strip.append(p[i])
                j+=1
            }
            i+=1
        }
        
        
        i=0
        var x = i+1
        var temp = min
        var tempFirst: User = .init(name: Randoms.randomFakeFirstName(), coordinate: .init(latitude: 0, longitude: 0))
        var tempSecond: User = .init(name: Randoms.randomFakeFirstName(), coordinate: .init(latitude: 0, longitude: 0))
        // Get the values between the points in the strip but only if it is less min dist in Y.
        while i<j
        {
            x = i+1
            while x < j
            {
                if (abs(strip[x].coordinate.longitude - strip[i].coordinate.longitude)) > min { break }
                if dist(strip[i], strip[x]) < temp
                {
                    temp = dist(strip[i], strip[x])
                    tempFirst = strip[i]
                    tempSecond = strip[x]
                }
                x+=1
            }
            i+=1
        }
        
        if temp < min
        {
            min = temp;
            first = tempFirst
            second = tempSecond
        }
        return (min, first, second)
    }
    
    func mergeSort(_ array: [User], sortAccording : Bool) -> [User] {
        guard array.count > 1 else { return array }
        let middleIndex = array.count / 2
        let leftArray = mergeSort(Array(array[0..<middleIndex]), sortAccording: sortAccording)
        let rightArray = mergeSort(Array(array[middleIndex..<array.count]), sortAccording: sortAccording)
        return merge(leftPile: leftArray, rightPile: rightArray, sortAccording: sortAccording)
    }
    
    
    private func merge(leftPile: [User], rightPile: [User], sortAccording: Bool) -> [User] {
        
        var compare : (User, User) -> Bool
        
        // Choose to compare with X or Y.
        if sortAccording
        {
            compare = { p1,p2 in
                return p1.coordinate.latitude < p2.coordinate.latitude
            }
        }
        else
        {
            compare = { p1, p2 in
                return p1.coordinate.longitude < p2.coordinate.longitude
            }
        }
        
        var leftIndex = 0
        var rightIndex = 0
        var orderedPile = [User]()
        if orderedPile.capacity < leftPile.count + rightPile.count {
            orderedPile.reserveCapacity(leftPile.count + rightPile.count)
        }
        
        while true {
            guard leftIndex < leftPile.endIndex else {
                orderedPile.append(contentsOf: rightPile[rightIndex..<rightPile.endIndex])
                break
            }
            guard rightIndex < rightPile.endIndex else {
                orderedPile.append(contentsOf: leftPile[leftIndex..<leftPile.endIndex])
                break
            }
            
            if compare(leftPile[leftIndex], rightPile[rightIndex]) {
                orderedPile.append(leftPile[leftIndex])
                leftIndex += 1
            } else {
                orderedPile.append(rightPile[rightIndex])
                rightIndex += 1
            }
        }
        return orderedPile
    }
    
    
    func dist(_ a: User,_ b: User) -> Double
    {
        let equation:Double = (((a.coordinate.latitude-b.coordinate.latitude)*(a.coordinate.latitude-b.coordinate.latitude))) + (((a.coordinate.longitude-b.coordinate.longitude)*(a.coordinate.longitude-b.coordinate.longitude)))
        return equation.squareRoot()
    }
}


//var a = Point(0,2)
//var b = Point(6,67)
//var c = Point(43,71)
//var d = Point(1000,1000)
//var e = Point(39,107)
//var f = Point(2000,2000)
//var g = Point(3000,3000)
//var h = Point(4000,4000)
//
//
//var points = [a,b,c,d,e,f,g,h]
//let endResult = ClosestPairOf(points: points)
//print("Minimum Distance : \(endResult.minimum), The two points : (\(endResult.firstPoint.x ),\(endResult.firstPoint.y)), (\(endResult.secondPoint.x),\(endResult.secondPoint.y))")
