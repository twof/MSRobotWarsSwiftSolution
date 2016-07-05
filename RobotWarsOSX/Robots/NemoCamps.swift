//
//  LiveRobotSwift.swift
//  RobotWar
//
//  Created by Dion Larson on 7/2/15.
//  Copyright (c) 2015 Make School. All rights reserved.
//

import Foundation

class NemoCamps: Robot {
    
    enum RobotState {                    // enum for keeping track of RobotState
        case FirstMove, Camping, Firing,Turnaround, Scanning
    }
    
    var currentRobotState: RobotState = .FirstMove
    var actionIndex = 0
    var lastEnemyHit = CGFloat(0.0)
    var lastKnownPosition = CGPoint(x: 0, y: 0)
    var lastKnownPositionTimestamp = CGFloat(0.0)
    let firingTimeout = CGFloat(1.0)
    let gunToleranceAngle = CGFloat(2.0)
    
    override func run() {
        while true {
            switch currentRobotState {
            case .FirstMove:
                performFirstMoveAction()
            case .Camping:
                shoot()
            case . Scanning:
                turnGunRight(90)
            case .Firing:
                performNextFiringAction()
            case .Turnaround:
                break
            }
        }
    }
    
    func performFirstMoveAction() {
        let arenaSize = arenaDimensions()
        let bodyLength = robotBodySize().width
        
        // find and turn towards closest corner
        var currentPosition = position()
        if currentPosition.y < arenaSize.height / 2 {
            if currentPosition.x < arenaSize.width/2 {
                // bottom left
                turnRobotLeft(90)
            } else {
                // bottom right
                turnRobotRight(90)
            }
        } else {
            if currentPosition.x < arenaSize.width/2 {
                // top left
                turnRobotRight(90)
            } else {
                // top right
                turnRobotLeft(90)
            }
        }
        
        // back into closest corner
        currentPosition = position()
        if currentPosition.y < arenaSize.height/2 {
            moveBack(Int(currentPosition.y - bodyLength))
        } else {
            moveBack(Int(arenaSize.height - (currentPosition.y + bodyLength)))
        }
        
        // turn gun towards center, shoot, camp out
        turnToCenter()
        shoot()
        currentRobotState = .Camping
    }
    
    func performNextFiringAction() {
        if currentTimestamp() - lastKnownPositionTimestamp > firingTimeout {
            turnToCenter()
            currentRobotState = .Camping
        } else {
            turnToEnemyPosition(lastKnownPosition)
        }
        shoot()
    }
    
    func turnToCenter() {
        let arenaSize = arenaDimensions()
        let angle = Int(angleBetweenGunHeadingDirectionAndWorldPosition(CGPoint(x: arenaSize.width/2, y: arenaSize.height/2)))
        if angle < 0 {
            turnGunLeft(abs(angle))
        } else {
            turnGunRight(angle)
        }
    }
    
    override func scannedRobot(robot: Robot!, atPosition position: CGPoint) {
        if currentRobotState != .Firing {
            cancelActiveAction()
        }
        
        lastKnownPosition = position
        lastKnownPositionTimestamp = currentTimestamp()
        currentRobotState = .Firing
    }
    
    override func gotHit() {
        moveAhead(500)
        turnRobotRight(90)
        moveAhead(400)
        
    }
    
    override func hitWall(hitDirection: RobotWallHitDirection, hitAngle angle: CGFloat) {
        cancelActiveAction()
        
        // save old st ate
        let previousState = currentRobotState
        currentRobotState = .Turnaround
        
        // always turn directly away from wall
        if angle >= 0 {
            turnRobotLeft(Int(abs(angle)))
        } else {
            turnRobotRight(Int(abs(angle)))
        }
        
        // leave wall
        moveAhead(20)
        
        // reset to old state
        currentRobotState = previousState
        

    }
    
    override func bulletHitEnemy(bullet: Bullet!) {
        lastEnemyHit = currentTimestamp()
        currentRobotState = .Firing
    }
    
    func turnToEnemyPosition(position: CGPoint) {
        cancelActiveAction()
        
        // calculate angle between turret and enemey
        let angleBetweenTurretAndEnemy = angleBetweenGunHeadingDirectionAndWorldPosition(position)
        
        // turn if necessary
        if angleBetweenTurretAndEnemy > gunToleranceAngle {
            turnGunRight(Int(abs(angleBetweenTurretAndEnemy)))
        } else if angleBetweenTurretAndEnemy < -gunToleranceAngle {
            turnGunLeft(Int(abs(angleBetweenTurretAndEnemy)))
        }
    }
    
}