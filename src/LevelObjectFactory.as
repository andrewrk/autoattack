// LevelObjectFactory - based on an id and a class, return an asset

package {

    import objects.*;

    public class LevelObjectFactory {
        public static function createObject(cls : int, id : int){
            switch(cls){
                case LevelObjectEnum.DECORATION:
                    switch(id){
                        case ScrollingDecorationEnum.BASE_CAMP_FENCE:
                            return new BaseCampFenceAsset();
                        case ScrollingDecorationEnum.BASE_CAMP_ENTRANCE_FG:
                            return new BaseCampEntranceFgAsset();
                        case ScrollingDecorationEnum.CACTUS:
                            return new CactusAsset();
                        case ScrollingDecorationEnum.SKELETON_BUSH:
                            return new SkeletonBushAsset();
                        case ScrollingDecorationEnum.GOOD_BUSH:
                            return new GoodBushAsset();
                        case ScrollingDecorationEnum.CHRISTMAS_TREE:
                            return new ChristmasTreeAsset();
                        case ScrollingDecorationEnum.BIG_SAGUARO_CACTUS:
                            return new BigSaguaroCactusAsset();
                        case ScrollingDecorationEnum.BIG_DEAD_BUSH:
                            return new BigDeadBushAsset();
                        case ScrollingDecorationEnum.BLACK_BAR:
                            return new BigBlackBarAsset();
                        case ScrollingDecorationEnum.CLOUD:
                            return new CloudAsset();
                        case ScrollingDecorationEnum.BASE_CAMP_ENTRANCE_BG:
                            return new BaseCampEntranceBgAsset();
                    }
                case LevelObjectEnum.SPECIAL:
                    switch(id){
                        case SpecialObjectEnum.ACTIVATION_GATE:
                            return new ActivationGateFgAsset();
                        case SpecialObjectEnum.MOVING_PLATFORM:
                            return new UpPlatformAsset();
                    }
                case LevelObjectEnum.OBSTACLE:
                    switch(id){
                        case ObstacleEnum.BOULDER:
                            return new BreakableBoulderAsset();
                        case ObstacleEnum.DEFENSE_SHELF:
                            return new DefenseShelfAsset();
                        case ObstacleEnum.GLASS_PANE:
                            return new GlassPaneAsset();
                        case ObstacleEnum.MOUNTAIN_EXIT:
                            return new MountainExitAsset();
                        case ObstacleEnum.UP_RAMP:
                            return new UpRampAsset();
                        case ObstacleEnum.DOWN_RAMP:
                            return new DownRampAsset();
                        case ObstacleEnum.TRAP_DOOR:
                            return new TrapDoorAsset();
                        case ObstacleEnum.TRIANGLE_RAMP:
                            return new TriangleRampAsset();
                        case ObstacleEnum.ONE_WAY_SPIKE:
                            return new OneWaySpikeAsset();
                    }
                case LevelObjectEnum.POWERUP:
                    switch(id){
                        case PowerUpEnum.GAS_CAN:
                            return new GasCanAsset();
                        case PowerUpEnum.SPEED_BOOST:
                            return new SpeedBoosterAsset();
                        case PowerUpEnum.HEALTH_PACK:
                            return new HealthPackAsset();
                        case PowerUpEnum.TIME_BONUS:
                            return new TimeBonusAsset();
                        case PowerUpEnum.EXTRA_LIFE:
                            return new ExtraLifeAsset();
                    }
                case LevelObjectEnum.TRIGGER:
                    return new TriggerAsset();
                case LevelObjectEnum.ENEMY:
                    switch(id){
                        case EnemyEnum.SOLDIER:
                            return new SoldierAsset();
                        case EnemyEnum.HELICOPTER:
                            return new HelicopterAsset();
                        case EnemyEnum.TURRET:
                            return new TurretAsset();
                        case EnemyEnum.CANNON:
                            return new CannonAsset();
                        case EnemyEnum.BOMB_THROWER:
                            // TODO: replace with bomb thrower
                            return new SoldierAsset();
                    }
                case LevelObjectEnum.STATIC:
                    switch(id){
                        case StaticEnum.SWITCH:
                            return new SwitchAsset();
                        case StaticEnum.VENT:
                            return new VentAsset();
                    }
                case LevelObjectEnum.ENTITY:
                    switch(id){
                        case EntityEnum.EXPLOSIVE_BARREL:
                            return new ExplosiveBarrelAsset();
                        case EntityEnum.MINE:
                            return new MineAsset();
                        case EntityEnum.RUBBLE:
                            return new RubbleAsset();
                    }
                case LevelObjectEnum.PROJECTILE:
                case LevelObjectEnum.EXPLOSION:
                    trace(  "TODO: projectiles and explosions not handled in ",
                            "LevelObjectFactory");
                    return null;

            }

            trace("TODO: Unknown asset: class ", cls, " id ", id);
            return null;
        }
    }
}
