
class Jeep {
    // constants
    private var mass = 1; // kg

    private var posX : Number; // px
    private var posY : Number; // px
    private var posAng : Number; // rad
    private var velX : Number; // px/fr
    private var velY : Number; // px/fr
    private var velAng : Number; // rad/fr

    private var level : Level;

    function Jeep(x : Number, y : Number, level : Level) {
        posX = x;
        posY = y;
        this.level = level;
    }

    /**
     * use physics to move the jeep one frame
     */
    function stepFrame() {
        // 1 - Collect forces
        var forceX = 0; // kg px/fr^2
        var forceY = 0; // kg px/fr^2

        // gravity
        forceY += level.gravity;

        // applied force from wheels
        // TODO

        // normal force from ground
        // TODO

        // friction from ground
        // TODO

        // 2 - apply forces to velocities
        velX += forceX / mass;
        velY += forceY / mass;

        // 3 - apply velocities to positions
        posX += velX;
        posY += velY;
    }
}
