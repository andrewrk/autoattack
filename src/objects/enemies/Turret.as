// Those spinning turrets that shoot stuff at the player

import org.cove.flade.util.Vector;

class objects.enemies.Turret extends objects.Enemy {

    // actions
    private var actionAccelAngle : Number; // 1, 0, or -1
    private var actionFire : Boolean;

    // if it's within this angle delta, shoot
    private var angleShoot : Number = Math.PI / 5;
    
    // physics
    private var posAngle : Number; // actual angle we are pointing at
    private var angleMin : Number; // minimum angle
    private var angleMax : Number; // maximum angle
    private var angleVel : Number;
    private var maxAngleVel : Number = 0.4;
    private var acceleration : Number = 0.003;

    private var rate : Number; // frames in between shots
    private var fireDelay : Number; // # frames left till can fire

    function Turret(pos : Vector, attrs : Object, level : Level) {
        super(LevelObject.ID_TURRET, pos, attrs, objId, level, 1);
        this.angleMin = Util.normalizeAngle(
            Util.degToRad(parseFloat(attrs.srange)));
        this.angleMax = Util.normalizeAngle(
            Util.degToRad(parseFloat(attrs.erange)));
        this.rate = parseInt(attrs.rate);
        this.fireDelay = 0;
        this.posAngle = 0;
        this.angleVel = 0;
    }

    function doAI() : Void {
        think();
        physics();
        paint();
    }

    function think() : Void {
        // set these vars to do stuff
        actionAccelAngle = 0;
        actionFire = false;

        // point towards the player
        var target : Vector = level.getPlayerPos();
        var desiredAngle : Number = Util.normalizeAngle(
            Math.atan2(target.y - pos.y, target.x - pos.x));
        
        var diff : Number = Util.angleDifference(desiredAngle, posAngle);
        
        if( Math.abs(diff) < acceleration )
            actionAccelAngle = 0;
        else
            actionAccelAngle = diff / Math.abs(diff);

        // calculate time to decelerate to zero
        var t : Number = Math.abs(angleVel) / acceleration;
        // calculate distance required to stop
        var dist: Number = -0.5 * acceleration * t * t + Math.abs(angleVel) * t;
        // if our actual distance is less than that, decelerate
        if( Math.abs(diff) <= dist ) {
            // decelerate
            actionAccelAngle = -angleVel / Math.abs(angleVel);
        }

        // if we have a decent shot, fire
        if( Math.abs(diff) < angleShoot ){
            // try to shoot. physics will catch us if we try to do anything
            // illegal.
            actionFire = true; 
        }
    }

    function physics() : Void {
        // determine acceleration
        var accel : Number = actionAccelAngle * acceleration;

        // apply acceleration to velocity
        angleVel += accel;
        angleVel = Math.min(maxAngleVel, Math.max(-maxAngleVel, angleVel));

        // apply velocity to position
        posAngle = Util.normalizeAngle(angleVel+posAngle);

        // limit by min and max range
        posAngle = Math.min(angleMax, Math.max(angleMin, posAngle));

        // fire
        if( fireDelay == 0 ) {
            if( actionFire ) {
                fireDelay = rate;
                // create a bullet and put it into action
                level.shootBullet(pos, new Vector(Math.cos(posAngle), 
                    Math.sin(posAngle)), new Vector(0,0));
            }
        } else {
            fireDelay--;
        }
    }

    function paint() : Void {
        mc._rotation = Util.radToDeg(posAngle);
    }
}
