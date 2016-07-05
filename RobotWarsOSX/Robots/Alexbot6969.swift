//
//  Alexbot6969.swift
//  RobotWarsOSX
//
//  Created by fnord on 6/29/16.
//  Copyright © 2016 Make School. All rights reserved.
//

import Foundation
import Darwin

class Alexbot6969: Robot {
    var originPoint = CGPoint(x: 0, y: 0)
    var lastRecordedPosition = CGPoint(x: 0, y: 0)
    var shootingQueue = NSOperationQueue()
    var moveQueue = NSOperationQueue()
    var gunAngleListenerQueue = NSOperationQueue()
    var distanceFromOpponent : Double = -100
    var angleToOpponent : CGFloat = -100
    var lastDistanceFromOpponent : Double = -1000
    var gunIsInPosition : Bool = false
    var gunAngle : CGFloat {
        get{
            return angleBetweenGunHeadingDirectionAndWorldPosition(originPoint)
        }
    }
    
    
    
    var robot = Robot()
    
    
    override func run() {
        initialize()
        
        let operation1 = NSBlockOperation(block: {
            while(true){
                self.gunIsInPosition = self.isGunInPosition()
                //print(self.gunAngle)
            }
        })
        
        gunAngleListenerQueue.addOperation(operation1)
        while true {
            if !gunIsInPosition {
                turnGunToPositionIncrementalAsync(lastRecordedPosition)
                print("Angle to opponent: \(angleToOpponent)")
            }
            //moveAhead(1)
            //moveForwardAsync(1)
            moveAhead(1)
            moveBack(1)
            shootAsync()
            moveAhead(1)
            moveBack(1)
        }
    }
    
    func initialize(){
        moveQueue.qualityOfService = NSQualityOfService.UserInteractive
        moveQueue.maxConcurrentOperationCount = 8
    }
    
    override func scannedRobot(robot: Robot!, atPosition position: CGPoint) {
        /*lastDistanceFromOpponent = distanceFromOpponent
        print("Opponent position: \(position)")
        var xminx: CGFloat
        var yminy: CGFloat
        xminx = self.position().x - position.x
        yminy = self.position().y - position.y
        
        distanceFromOpponent = sqrt(pow(Double(xminx), 2.0) - pow(Double(yminy), 2.0))
        //backOutFlag = true
        turnToPositionAsync(position)*/
        lastRecordedPosition = position
        print("Last Pos from scan: \(lastRecordedPosition)")
    }
    
    override func gotHit() {
        /*shoot()
        turnRobotLeft(45)
        moveAhead(100)*/
    }
    
    override func hitWall(hitDirection: RobotWallHitDirection, hitAngle: CGFloat) {
        
        switch hitDirection {
        case .Front:
            turnRobotRightAsync(180)
            moveAhead(1)
        case .Rear:
            moveAhead(1)
        case .Left:
            turnRobotRightAsync(90)
            moveAhead(1)
        case .Right:
            turnRobotLeftAsync(90)
            moveAhead(1)
        case .None:           // should never be none, but switch must be exhaustive
            break
        }
    }
    
    override func bulletHitEnemy(bullet: Bullet!) {
        /*var xminx: CGFloat
        var yminy: CGFloat
        xminx = self.position().x - bullet.position.x
        yminy = self.position().y - bullet.position.y
        distanceFromOpponent = sqrt(pow(Double(xminx), 2.0) - pow(Double(yminy), 2.0))
        turnToPositionAsync(bullet.position)
        print("New distance: \(distanceFromOpponent)")*/
        //lastRecordedPosition = bullet.position
        print("Last Pos from bullet: \(lastRecordedPosition)")
    }
    
    
    
    func turnToPositionAsync(positionToTurnTo : CGPoint){
        let operation1 = NSBlockOperation(block: {
            self.angleToOpponent = self.angleBetweenHeadingDirectionAndWorldPosition(positionToTurnTo)
            
            if self.angleToOpponent < 180 {
                self.turnRobotRightAsync(Int(self.angleToOpponent))
            }else{
                self.turnRobotLeftAsync(Int(self.angleToOpponent))
            }
        })
        
        moveQueue.addOperation(operation1)
    }
    
    func moveForwardAsync(distance : Int){
        
        let operation1 = NSBlockOperation(block: {
            self.moveAhead(100)
        })
        
        moveQueue.addOperation(operation1)
    }
    
    func shootAsync(){
        let operation1 = NSBlockOperation(block: {
            self.shoot()
        })
        
        operation1.name = "shoot"
        self.shootingQueue.addOperation(operation1)
    }
    
    func turnRobotRightAsync(degrees: Int){
        let operation1 = NSBlockOperation(block: {
            self.turnRobotRight(degrees)
        })
        
        self.moveQueue.addOperation(operation1)
    }
    
    func turnRobotLeftAsync(degrees: Int){
        let operation1 = NSBlockOperation(block: {
            self.turnRobotLeft(degrees)
        })
        
        self.moveQueue.addOperation(operation1)
    }
    
    func turnGunLeftAsync(degrees : Int){
        let operation1 = NSBlockOperation(block: {
            self.turnGunLeft(degrees)
            print("Turning left")
        })
        
        self.moveQueue.addOperation(operation1)
    }
    
    func turnGunRightAsync(degrees : Int){
        let operation1 = NSBlockOperation(block: {
            self.turnGunRight(degrees)
            print("Turning right")
        })
        
        self.moveQueue.addOperation(operation1)
    }
    
    func turnGunToPositionAsync(positionToTurnTo : CGPoint){
        
        let operation1 = NSBlockOperation(block: {
            self.angleToOpponent = self.angleBetweenGunHeadingDirectionAndWorldPosition(positionToTurnTo)
            
            if self.angleToOpponent < 180 && self.angleToOpponent > 0 {
                self.turnGunRight(Int(self.angleToOpponent))
            }else if self.angleToOpponent > 180 || self.angleToOpponent < 0{
                self.turnGunLeft(abs(Int(self.angleToOpponent)))
            }
        })
        
        operation1.name = "TGTP"
        moveQueue.addOperation(operation1)
    }
    
    func turnGunToPositionIncrementalAsync(positionToTurnTo : CGPoint){
        print(gunAngle)
        //let operation1 = NSBlockOperation(block: {
        if self.gunAngle < 180 && self.gunAngle > 0 {
            let intGunAngle : Int = Int(self.gunAngle)
            for _ in 1...intGunAngle {
                print(intGunAngle)
                self.turnGunRightAsync(1)
            }
            //cancelActiveAction()
            moveQueue.cancelAllOperations()
        }else if self.gunAngle > 180 || self.gunAngle < 0{
            let intGunAngle : Int = Int(self.gunAngle)
            for _ in 1...abs(intGunAngle) {
                print(intGunAngle)
                self.turnGunLeftAsync(1)
            }
            //cancelActiveAction()
            moveQueue.cancelAllOperations()
        }
        // })
        //moveQueue.addOperation(operation1)
    }
    
    func turnGunToPosition(positionToTurnTo : CGPoint){
        self.angleToOpponent = self.angleBetweenGunHeadingDirectionAndWorldPosition(positionToTurnTo)
        
        if self.angleToOpponent < 180 {
            self.turnGunRight(Int(self.angleToOpponent))
        }else{
            self.turnGunLeft(Int(self.angleToOpponent))
        }
    }
    
    func sync(lock: AnyObject, closure: () -> Void){
        objc_sync_enter(lock)
        closure()
        objc_sync_exit(lock)
    }
    
    func isGunInPosition() -> Bool {
        return (-3.0...3.0).contains(gunAngle)
    }
}