package states;

import flixel.FlxG;
import flixel.FlxState;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.addons.display.FlxBackdrop;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import flixel.FlxObject;
import flixel.addons.display.shapes.FlxShapeCircle;
import flixel.effects.particles.FlxEmitter;
import flixel.text.FlxText;
import openfl.display.BlendMode;
import flixel.util.FlxColor;
import flixel.FlxCamera;
import flixel.util.FlxCollision;

using StringTools;

class Gd extends MusicBeatState {
    var splitblocks:Array<BlockProperties> = [];
    var allblocks:FlxTypedGroup<FlxSprite>;
    var allrods:FlxTypedGroup<FlxSprite>;

    var bg:FlxBackdrop;
    var groundcolide:FlxSprite;
    var ground:FlxBackdrop;
    var line:FlxSprite;
    var groundcolide2:FlxSprite;
    var ground2:FlxBackdrop;
    var line2:FlxSprite;
    var player:FlxSprite;
    var end:FlxSprite;

    var jumptween:FlxTween;

    var killid:Array<Int> = [5, 8, 9, 39, 103, 61];
    var noninteractable:Array<Int> = [18, 19, 20, 21, 113, 114, 115, 129, 130, 131, 191, 198, 199, 503, 504, 505, 1008, 1009, 1010, 1011, 1012, 1013, 36, 1333, 141, 1022, 84, 29, 30, 67, 35, 140, 1332, 41, 106, 107, 73, 110, 15, 16, 17, 64, 48, 49, 50, 51, 52, 53, 54];
    var rods:Array<Int> = [15, 16, 17];
    var notimplemented:Array<Int> = [];
    var trigger:Array<Int> = [29, 30];

    var isdead = false;
    var highestx:Float;

    var percent:FlxText;
    
    var colorchannels:Array<ColorProperties> = [];
    var triggers:Array<{id:Int, x:Float, red:Int, green:Int, blue:Int, opacity:Float, duration:Float, target:Int}> = [];
    var finishedtriggers:Array<Dynamic> = [];
    var songoffset = 0.0;
    var bgid = 1;
    var groundid = 1;
    var gamemode = 0;
    var trail:FlxEmitter;
    var speedportal = 1;
    var speed = 1.0;
    var upsidedown = false;

    var camHUD:FlxCamera;
	var camGame:FlxCamera;

    var level = '';
    public static var storymodelol = false;
    var finished = false;
    var finishedground = true;
    var coolcolor = 0xFF008EDA;

    public function new(levellol:String) {
		super();
		
		this.level = levellol;
	}

	override function create() {
        readlevel();

		allblocks = new FlxTypedGroup<FlxSprite>();
        allrods = new FlxTypedGroup<FlxSprite>();

        buildlevel(splitblocks);

		add(bg = new FlxBackdrop(Paths.image('gd/bg/' + bgid)));
		bg.scrollFactor.set(0.2, 0.2);
        bg.repeatAxes = X;
        bg.antialiasing = ClientPrefs.data.antialiasing;
        bg.scale.x = 1/4;
        bg.scale.y = 1/4;
        bg.y = -825;

        add(allblocks);
        add(allrods);

        groundcolide = new FlxSprite(0, 15).loadGraphic(Paths.image('gd/ground/' + groundid));
        groundcolide.immovable = true;
        groundcolide.scrollFactor.set(0, 1);
        groundcolide.scale.x = 100;
        groundcolide.scale.y = 1/4;
        groundcolide.updateHitbox();
        add(groundcolide);

		add(ground = new FlxBackdrop(Paths.image('gd/ground/' + groundid)));
        ground.repeatAxes = X;
        ground.antialiasing = ClientPrefs.data.antialiasing;
        ground.scale.x = 1/4;
        ground.scale.y = 1/4;
        ground.y = 15;
        ground.updateHitbox();
        ground.immovable = true;

        line = new FlxSprite(-250, 12).loadGraphic(Paths.image('gd/line'));
        line.immovable = true;
        line.scrollFactor.set(0, 1);
        line.scale.x = 1/4;
        line.scale.y = 1/4;
        add(line);

        groundcolide2 = new FlxSprite(0, -130).loadGraphic(Paths.image('gd/ground/' + groundid));
        groundcolide2.flipY = true;
        groundcolide2.immovable = true;
        groundcolide2.scrollFactor.set(0, 1);
        groundcolide2.scale.x = 100;
        groundcolide2.scale.y = 1/4;
        groundcolide2.updateHitbox();
        add(groundcolide2);

		add(ground2 = new FlxBackdrop(Paths.image('gd/ground/' + groundid)));
        ground2.flipY = true;
        ground2.repeatAxes = X;
        ground2.antialiasing = ClientPrefs.data.antialiasing;
        ground2.scale.x = 1/4;
        ground2.scale.y = 1/4;
        ground2.y = -130;
        ground2.updateHitbox();
        ground2.immovable = true;

        line2 = new FlxSprite(-250, -517).loadGraphic(Paths.image('gd/line'));
        line2.flipY = true;
        line2.immovable = true;
        line2.scrollFactor.set(0, 1);
        line2.scale.x = 1/4;
        line2.scale.y = 1/4;
        add(line2);

        trail = new FlxEmitter(0, 0, 200);
        trail.makeParticles(2, 2, 0xFFFFFFFF, 200);
        trail.acceleration.set(0, 0, 0, 0, -100, -0.5, -200, 2.5);
        trail.lifespan.set(0.2, 0.5);
        trail.alpha.set(1, 1, 0, 0);
        trail.color.set(0xFF33FFFF, 0xFF0476D0);
        trail.scale.set(0.5, 0.5, 2, 2);
        add(trail);
        trail.start(false, 0.02);

        player = new FlxSprite(30, -15).loadGraphic(Paths.image('gd/bf'), true, 256, 256);
        player.animation.add('cube', [0]);
        player.animation.add('ship', [1]);
        player.animation.add('ball', [2]);
        player.animation.play('cube');
        player.antialiasing = ClientPrefs.data.antialiasing;
        player.scale.x = (120/256) / 4;
        player.scale.y = (120/256) / 4;
        player.updateHitbox();
        player.maxVelocity.set(80, 560);
        add(player);

        end = new FlxSprite(highestx + 310, 0).loadGraphic(Paths.image('gd/end'));
        end.immovable = true;
        end.scrollFactor.set(1, 0);
        end.updateHitbox();
        add(end);
        
        switch(gamemode) {
            case 1:
                ship(player, player);
            case 2:
                ball(player, player);
            default:
                cube(player, player);
        }

		super.create();

        camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD, false);
		FlxG.cameras.setDefaultDrawTarget(camGame, true);
        FlxG.camera.follow(player, TOPDOWN_TIGHT, 1);
        FlxG.camera.maxScrollX = highestx + 400;
        FlxG.camera.maxScrollY = 120;
        FlxG.camera.targetOffset.x = 120;
        FlxG.camera.zoom = 2;

        FlxG.worldBounds.set(-100, -1000, 40000, 20000);

        percent = new FlxText(0, 10, FlxG.camera.width, '0%', 20);
		percent.setFormat(Paths.font("gdfont.ttf"), 20, 0xFFFFFFFF, CENTER, FlxTextBorderStyle.OUTLINE, 0xFF000000);
		percent.scrollFactor.set(0, 0);
        percent.cameras = [camHUD];
		percent.borderSize = 1.25;
		add(percent);

        persistentUpdate = true;
        persistentDraw = true;

        FlxG.sound.playMusic(Paths.inst(level), 1, false);
        FlxG.sound.music.pause();
        new FlxTimer().start(0, function(tmr:FlxTimer) {
            FlxG.sound.music.time = (songoffset * 1000) - 1500;
            FlxG.sound.music.play();
        });
    }

    override function update(elapsed:Float) {
        if((controls.PAUSE || getpercent() >= 100) && !finished) {
            finished = true;
            FlxG.sound.playMusic(Paths.music('freakyMenu'));
            if(storymodelol) {
                MusicBeatState.switchState(new StoryMenuState());
            } else {
                MusicBeatState.switchState(new FreeplayState());
            }
        }

        if(!isdead) {
            player.x += 30 * elapsed * speed;
        }

        var tempfin:Array<Float> = [];
        var doesexist = false;
        for(i in triggers) {
            if((!finishedtriggers.contains(i.x)) && player.x >= i.x) {
                switch(i.id) {
                    case 29 | 30:
                        for(color in colorchannels) {
                            if(color.id == i.target) {
                                doesexist = true;
                                if(i.duration > 0) {
                                    FlxTween.tween(color, { red:i.red, green:i.green, blue:i.blue, opacity:i.opacity }, i.duration);
                                } else {
                                    color.red = i.red;
                                    color.green = i.green;
                                    color.blue = i.blue;
                                    color.opacity = i.opacity;
                                }
                            }
                        }
                    default:
                        doesexist = true;
                        trace('trigger:' + i.id + ' couldnt be found');
                }
                if(doesexist) {
                    tempfin.push(i.x);
                } else {
                    colorchannels.push(new ColorProperties(i.target, i.red, i.green, i.blue, i.opacity, false));
                }
            }
        }
        for(i in tempfin) {
            finishedtriggers.push(i);
        }

        var jumpinorsmth = FlxG.keys.anyPressed([SPACE, UP, W]) || FlxG.mouse.pressed;
        var justjumpinorsmth = FlxG.keys.anyJustPressed([SPACE, UP, W]) || FlxG.mouse.justPressed;

        switch(gamemode) {
            case 1:
                if(jumpinorsmth) {
                    if(if(upsidedown) player.isTouching(FLOOR) else player.isTouching(CEILING)) {
                        FlxTween.tween(player, { angle:Math.round(player.angle / 90) * 90 }, 3 * elapsed);
                    } else {
                        player.angle -= 125 * elapsed * (if(upsidedown) -1 else 1);
                    }
                    if(player.angle < -25) {
                        player.angle = -25;
                    }
                    if(player.angle > 25) {
                        player.angle = 25;
                    }
                    player.velocity.y -= 900 * elapsed * (if(upsidedown) -1 else 1);
                } else if(if(upsidedown) player.isTouching(CEILING) else player.isTouching(FLOOR)) {
                    player.velocity.y = 0 * (if(upsidedown) -1 else 1);
                    FlxTween.tween(player, { angle:Math.round(player.angle / 90) * 90 }, 3 * elapsed);
                } else {
                    player.angle += 110 * elapsed * (if(upsidedown) -1 else 1);
                    if(player.angle < -25) {
                        player.angle = -25;
                    }
                    if(player.angle > 25) {
                        player.angle = 25;
                    }
                    player.velocity.y += 900 * elapsed * (if(upsidedown) -1 else 1);
                }
            case 2:
                if((if(upsidedown) player.isTouching(CEILING) else player.isTouching(FLOOR))) {
                    if(justjumpinorsmth){
                        upsidedown = !upsidedown;
                        gravity();
                    }
                }
                player.angle += 400 * elapsed * (if(upsidedown) -1 else 1);
            default:
                if((if(upsidedown) player.isTouching(CEILING) else player.isTouching(FLOOR))) {
                    if(player.angle % 90 != 0) {
                        jumptween = FlxTween.tween(player, { angle:Math.round(player.angle / 90) * 90 }, 3 * elapsed);
                    }
                    if(jumpinorsmth) {
                        jumptween.cancel();
                        player.velocity.y = -player.maxVelocity.y * (if(upsidedown) -1 else 1);
                    }
                } else {
                    player.angle += 400 * elapsed * (if(upsidedown) -1 else 1);
                }
        }

        allblocks.forEach(function(block:FlxSprite) {
            if(block.isOnScreen() && splitblocks[block.ID].used == false) {
                switch(splitblocks[block.ID].id) {
                    case 18 | 19 | 20 | 21 | 113 | 114 | 115 | 41 | 106 | 107 | 48 | 49 | 50 | 51 | 52 | 53 | 54:
                        block.color = coolcolor;
                        block.blend = ADD;
                    case 9 | 191 | 198 | 199 | 61:
                        block.color = 0xFF000000;
                    default:
                        for(color in colorchannels) {
                            if(color.id == splitblocks[block.ID].colorid) {
                                setcolorr(block, color);
                            }
                        }
                }
                FlxG.overlap(player, block, function(object1:FlxObject, object2:FlxObject) {
                    switch(splitblocks[block.ID].id) {
                        case 36:
                            if(justjumpinorsmth) {
                                splitblocks[block.ID].used = true;
                                player.velocity.y = -player.maxVelocity.y * 0.95 * (if(upsidedown) -1 else 1); //done
                            }
                        case 84:
                            if(justjumpinorsmth) {
                                splitblocks[block.ID].used = true;
                                upsidedown = !upsidedown;
                                gravity();
                            }
                        case 141:
                            if(justjumpinorsmth) {
                                splitblocks[block.ID].used = true;
                                player.velocity.y = -player.maxVelocity.y * 0.5 * (if(upsidedown) -1 else 1);
                            }
                        case 1022:
                            if(justjumpinorsmth) {
                                splitblocks[block.ID].used = true;
                                upsidedown = !upsidedown;
                                gravity();
                                player.velocity.y = -player.maxVelocity.y * 0.91 * (if(upsidedown) -1 else 1);
                            }
                        case 1333:
                            if(justjumpinorsmth) {
                                splitblocks[block.ID].used = true;
                                player.velocity.y = -player.maxVelocity.y * 2.11 * (if(upsidedown) -1 else 1);
                            }
                        case 67:
                            splitblocks[block.ID].used = true;
                            upsidedown = !upsidedown;
                            player.velocity.y = -player.maxVelocity.y * 0.9 * (if(upsidedown) -1 else 1);
                            gravity();
                        case 35:
                            splitblocks[block.ID].used = true;
                            player.velocity.y = -player.maxVelocity.y * 33.5 * (if(upsidedown) -1 else 1); //done
                        case 140:
                            splitblocks[block.ID].used = true;
                            player.velocity.y = -player.maxVelocity.y * 0.9 * (if(upsidedown) -1 else 1);
                        case 1332:
                            splitblocks[block.ID].used = true;
                            player.velocity.y = -player.maxVelocity.y * 52.7 * (if(upsidedown) -1 else 1);
                    }
                });
            }
        });

        percent.text = getpercent() + '%';

        super.update(elapsed);

        allblocks.forEach(function(block:FlxSprite) {
            if(block.isOnScreen()) {
                var kill = false;
                for(coolid in killid) {
                    if(coolid == splitblocks[block.ID].id) {
                        kill = true;
                    }
                }
                if(kill) {
                    FlxG.overlap(player, block, dead);
                } else {
                    switch(splitblocks[block.ID].id) {
                        case 12:
                            FlxG.overlap(player, block, cube);
                        case 13:
                            FlxG.overlap(player, block, ship);
                        case 47:
                            FlxG.overlap(player, block, ball);
                        case 45:
                            FlxG.overlap(player, block, function(object1:FlxObject, object2:FlxObject) {
                                FlxTween.tween(FlxG.camera.flashSprite, { scaleX:-1 }, 0.25);
                            });
                        case 46:
                            FlxG.overlap(player, block, function(object1:FlxObject, object2:FlxObject) {
                                FlxTween.tween(FlxG.camera.flashSprite, { scaleX:1 }, 0.25);
                            });
                        case 200 | 201 | 202 | 203 | 1334:
                            FlxG.overlap(player, block, speedchange);
                        case 10:
                            FlxG.overlap(player, block, function(object1:FlxObject, object2:FlxObject) {
                                upsidedown = false;
                                gravity();
                            });
                        case 11:
                            FlxG.overlap(player, block, function(object1:FlxObject, object2:FlxObject) {
                                upsidedown = true;
                                gravity();
                            });
                        default:
                            var nonin = false;
                            for(coolid in noninteractable) {
                                if(coolid == splitblocks[block.ID].id) {
                                    nonin = true;
                                }
                            }
                            if(!nonin) {
                                if(!FlxG.collide(player, block)) {
                                    FlxG.overlap(player, block, dead);
                                }
                            }
                    }
                }
            }
        });

        trail.x = player.x + 5;
        if(player.flipY) {
            trail.y = player.y + 5;
        } else {
            trail.y = player.y + 25;
        }

        if(gamemode != 0) {
            FlxG.collide(player, groundcolide2);
        } else if(finishedground) {
            groundcolide2.y = player.y - 127 - 500;
            ground2.y = player.y - 127 - 500;
            line2.y = player.y - 3 - 500;
        }
        FlxG.collide(player, groundcolide);

        for(i in colorchannels) {
            switch(i.id) {
                case 1000:
                    setcolorr(bg, i);
                case 1001:
                    setcolorr(groundcolide, i);
                    setcolorr(ground, i);
                    setcolorr(groundcolide2, i);
                    setcolorr(ground2, i);
                case 1002:
                    setcolorr(line, i);
                    setcolorr(line2, i);
            }
        }
        /*
        trace('len:' + colorchannels.length);
        for(i in colorchannels) {
            trace('id:' + i.id + ', r' + i.red + ' g' + i.green + ' b' + i.blue + ' o' + i.opacity + ', blending:' + i.blend);
        }
        */
    }

    function gravity() {
        if(gamemode == 2) {
            player.flipY = false;
        } else {
            if(player.flipY != upsidedown) {
                player.flipY = upsidedown;
                player.angle += 180;
            }
        }
        if(upsidedown) {
            switch(gamemode) {
                case 1:
                    allblocks.forEach(function(block:FlxSprite) {
                        block.allowCollisions = FlxObject.ANY;
                    });
                    player.acceleration.y = 0;
                default:
                    allblocks.forEach(function(block:FlxSprite) {
                        block.allowCollisions = FlxObject.DOWN;
                    });
                    player.acceleration.y = -2550;
            }
        } else {
            switch(gamemode) {
                case 1:
                    allblocks.forEach(function(block:FlxSprite) {
                        block.allowCollisions = FlxObject.ANY;
                    });
                    player.acceleration.y = 0;
                default:
                    allblocks.forEach(function(block:FlxSprite) {
                        block.allowCollisions = FlxObject.UP;
                    });
                    player.acceleration.y = 2550;
            }
        }
    }

    function cube(object1:FlxObject, object2:FlxObject) {
        finishedground = false;
        gamemode = 0;
        FlxTween.tween(groundcolide, { y:15 }, 0.25);
        FlxTween.tween(ground, { y:15 }, 0.25);
        FlxTween.tween(line, { y:12 }, 0.25);
        FlxTween.tween(groundcolide2, { y:player.y - 127 - 500 }, 0.25, {onComplete: function(twn:FlxTween) {
			finishedground = true;
		}});
        FlxTween.tween(ground2, { y:player.y - 127 - 500 }, 0.25);
        FlxTween.tween(line2, { y:player.y - 3 - 500 }, 0.25);
        gravity();
        player.animation.play('cube');
    }

    function ship(object1:FlxObject, object2:FlxObject) {
        gamemode = 1;
        var coolgroundy = ((Math.floor(-(-object2.y) / 30) + 7) * 30) + 15;
        if(coolgroundy > 15) {
            coolgroundy = 15;
        }
        FlxTween.tween(groundcolide, { y:coolgroundy }, 0.25);
        FlxTween.tween(ground, { y:coolgroundy }, 0.25);
        FlxTween.tween(line, { y:coolgroundy - 3 }, 0.25);
        FlxTween.tween(groundcolide2, { y:coolgroundy - 427 }, 0.25);
        FlxTween.tween(ground2, { y:coolgroundy - 427 }, 0.25);
        FlxTween.tween(line2, { y:coolgroundy - 303 }, 0.25);
        gravity();
        player.animation.play('ship');
    }

    function ball(object1:FlxObject, object2:FlxObject) {
        gamemode = 2;
        var coolgroundy = ((Math.floor(-(-object2.y) / 30) + 8) * 30) + 15;
        if(coolgroundy > 15) {
            coolgroundy = 15;
        }
        FlxTween.tween(groundcolide, { y:coolgroundy }, 0.25);
        FlxTween.tween(ground, { y:coolgroundy }, 0.25);
        FlxTween.tween(line, { y:coolgroundy - 3 }, 0.25);
        FlxTween.tween(groundcolide2, { y:coolgroundy - 367 }, 0.25);
        FlxTween.tween(ground2, { y:coolgroundy - 367 }, 0.25);
        FlxTween.tween(line2, { y:coolgroundy - 243 }, 0.25);
        gravity();
        player.animation.play('ball');
    }

    function speedchange(object1:FlxObject, object2:FlxObject) {
        switch(splitblocks[object2.ID].id) {
            case 200:
                speedportal = 1;
            case 201:
                speedportal = 0;
            case 202:
                speedportal = 2;
            case 203:
                speedportal = 3;
            case 1334:
                speedportal = 4;
        }
        changespeed();
    }

    function changespeed() {
        switch(speedportal) {
            case 1:
                speed = 8.36820083682;
            case 0:
                speed = 10.3761348898;
            case 2:
                speed = 12.9032258065;
            case 3:
                speed = 15.5945419103;
            case 4:
                speed = 19.1846522782;
        }
    }

    function readlevel() {
        var r = ~/[;]+/g;
        //to get level data from your levels go to https://gdcolon.com/gdsave/
        //then click on a level, after that click on view level data (inner string)
        //then paste it in the data folder
        var modsbooltxt:Bool = false;
        #if MODS_ALLOWED
        modsbooltxt = FileSystem.exists(Paths.modFolders('data/geometry-dash/' + level + '.txt'));
        #end
        var levelshi:String;
        if(modsbooltxt) {
            levelshi = sys.io.File.getContent(Paths.modFolders('data/geometry-dash/' + level + '.txt'));
        } else {
            levelshi = sys.io.File.getContent(Paths.txt('geometry-dash/' + level));
        }
        var splitlevelshi = r.split(levelshi);
        var levelinitdata = splitlevelshi[0].split(',');
        var coolprevnum:String = '';
        for(i in 0...levelinitdata.length) {
            if(i % 2 == 0) {
                coolprevnum = levelinitdata[i];
            } else {
                //level id stuff in https://wyliemaster.github.io/gddocs/#/resources/client/level-components/inner-level-string
                switch(coolprevnum) {
                    case 'kS38':
                        for(colordata in levelinitdata[i].split('|')) {
                            var colorinitdata = colordata.split('_');
                            var extremelycoolprevnumber = 0;
                            var colorid = 0;
                            var blending = false;
                            var red = 255;
                            var green = 255;
                            var blue = 255;
                            var opacity = 255;
                            for(z in 0...colorinitdata.length) {
                                if(z % 2 == 0) {
                                    extremelycoolprevnumber = Std.parseInt(colorinitdata[z]);
                                } else {
                                    //color stuff in https://wyliemaster.github.io/gddocs/#/resources/client/level-components/color-string
                                    switch(extremelycoolprevnumber) {
                                        case 1:
                                            red = Std.parseInt(colorinitdata[z]);
                                        case 2:
                                            green = Std.parseInt(colorinitdata[z]);
                                        case 3:
                                            blue = Std.parseInt(colorinitdata[z]);
                                        case 4:
                                            if(Std.parseFloat(colorinitdata[z]) == 1)
                                                blending = true;
                                        case 6:
                                            colorid = Std.parseInt(colorinitdata[z]);
                                        case 7:
                                            opacity = Std.parseInt(colorinitdata[z]);
                                        default:
                                            //trace('prevnum:' + extremelycoolprevnumber + ' cant be read');
                                    }
                                }
                            }
                            colorchannels.push(new ColorProperties(colorid, red, green, blue, opacity, blending));
                        }
                    case 'kA13':
                        songoffset = Std.parseInt(levelinitdata[i]);
                    case 'kA6':
                        bgid = Std.parseInt(levelinitdata[i]) + 1;
                    case 'kA7':
                        groundid = Std.parseInt(levelinitdata[i]) + 1;
                    case 'kA2':
                        gamemode = Std.parseInt(levelinitdata[i]);
                    case 'kA4':
                        speedportal = Std.parseInt(levelinitdata[i]);
                        changespeed();
                    case 'kA11':
                        if(Std.parseFloat(levelinitdata[i]) == 1) {
                            upsidedown = true;
                            if(gamemode != 2) {
                                player.flipY = upsidedown;
                                player.angle += 180;
                            }
                        }
                    default:
                        //trace('prevnum:' + coolprevnum + ' cant be read');
                }
            }
        }
        var len = splitlevelshi.length - 1;
        for(i in 0...len) {
            var coolthing = splitlevelshi[i + 1].split(',');
            var prevnum = 0;
            var lolid:Int = 1;
            var lolxpos:Float = 0;
            var lolypos:Float = 0;
            var lolrot:Float = 0;
            var lolscale:Float = 1;
            var lolfx:Bool = false;
            var lolfy:Bool = false;
            var lolcolor:Int = -2;
            var lolred:Int = 255;
            var lolgreen:Int = 255;
            var lolblue:Int = 255;
            var lolopacity:Float = 1;
            var lolduration:Float = 0;
            var targetcol:Int = -1;
            for(i in 0...coolthing.length) {
                if(i % 2 == 0) {
                    prevnum = Std.parseInt(coolthing[i]);
                } else {
                    //object id stuff in https://wyliemaster.github.io/gddocs/#/resources/client/level-components/level-object
                    switch(prevnum) {
                        case 1:
                            lolid = Std.parseInt(coolthing[i]);
                        case 2:
                            lolxpos = Std.parseFloat(coolthing[i]);
                            if(lolxpos > highestx)
                                highestx = lolxpos;
                        case 3:
                            lolypos = Std.parseFloat(coolthing[i]);
                        case 4:
                            if(Std.parseFloat(coolthing[i]) == 1)
                                lolfx = true;
                        case 5:
                            if(Std.parseFloat(coolthing[i]) == 1)
                                lolfy = true;
                        case 6:
                            lolrot = Std.parseFloat(coolthing[i]);
                        case 7:
                            lolred = Std.parseInt(coolthing[i]);
                        case 8:
                            lolgreen = Std.parseInt(coolthing[i]);
                        case 9:
                            lolblue = Std.parseInt(coolthing[i]);
                        case 10:
                            lolduration = Std.parseFloat(coolthing[i]);
                        case 21:
                            lolcolor = Std.parseInt(coolthing[i]);
                        case 23:
                            targetcol = Std.parseInt(coolthing[i]);
                        case 32:
                            lolscale = Std.parseFloat(coolthing[i]);
                        case 35:
                            lolopacity = Std.parseFloat(coolthing[i]);
                        default:
                            //trace('prevnum:' + prevnum + ' cant be read');
                    }
                }
            }
            splitblocks.push(new BlockProperties(lolid, lolxpos, lolypos, lolrot, lolscale, lolfx, lolfy, lolcolor, lolred, lolgreen, lolblue, lolopacity, lolduration, targetcol));
        }

        return splitblocks;
    }

    function buildlevel(blocks:Array<BlockProperties>) {
        var num = 0;
        for(i in blocks) {
            var block = new FlxSprite(i.xpos, -i.ypos).loadGraphic(Paths.image('gd/blocks/' + i.id));
            block.ID = num;
            block.antialiasing = ClientPrefs.data.antialiasing;
            var kill = false;
            for(killlol in killid) {
                if(killlol == i.id) {
                    kill = true;
                }
            }
            block.scale.x = i.sca / 4;
            block.scale.y = i.sca / 4;
            block.angle = i.rot;
            block.updateHitbox();
            block.x = 15 - (block.width / 2) + i.xpos;
            block.y = 15 - (block.height / 2) - i.ypos;
            var hitboxwidththing = 0;
            var hitboxheightthing = 0;
            if(kill) {
                hitboxwidththing = 12;
                hitboxheightthing = 6;
            }
            block.width -= hitboxwidththing * 2;
            block.height -= hitboxheightthing * 2;
            block.offset.x += hitboxwidththing;
            block.offset.y += hitboxheightthing;
            block.x += hitboxwidththing;
            block.y += hitboxheightthing;
            block.immovable = true;
            block.flipX = i.fx;
            block.flipY = i.fy;
            if(gamemode == 0) {
                block.allowCollisions = FlxObject.UP;
            }
            if(trigger.contains(i.id)) {
                block.visible = false;
                triggers.push({id:i.id, x:i.xpos, red:i.red, green:i.green, blue:i.blue, opacity:i.opacity, duration:i.duration, target:i.targetcolor});
            }
            if(rods.contains(i.id)) {
                var rod = new FlxSprite(i.xpos, -i.ypos).loadGraphic(Paths.image('gd/blocks/rod'));
                rod.ID = num;
                rod.antialiasing = ClientPrefs.data.antialiasing;
                rod.scale.x = i.sca / 8;
                rod.scale.y = i.sca / 8;
                rod.angle = i.rot;
                rod.updateHitbox();
                rod.x = 15 - (rod.width / 2) + i.xpos;
                rod.y = 15 - (rod.height / 2) - i.ypos;
                rod.immovable = true;
                rod.flipX = i.fx;
                rod.flipY = i.fy;
                rod.color = coolcolor;
                allrods.add(rod);
            }
            allblocks.add(block);
            num += 1;
        }
        triggers.sort(function(a, b) {
           if(a.x < b.x) return -1;
           else if(a.x > b.x) return 1;
           else return 0;
        });
        //trace(triggers);
    }

    function setcolorr(coolobject:FlxSprite, channel:ColorProperties) {
        if(coolobject != null) {
            coolobject.color = FlxColor.fromRGB(channel.red, channel.green, channel.blue, Math.round(channel.opacity * 255));
            if(channel.blend) {
                coolobject.blend = ADD;
            }
        }
    }

    function getpercent() {
        var coolpercent = Math.round((player.x / (highestx + 310)) * 1000) / 10;
        if(coolpercent < 0) {
            coolpercent = 0;
        }
        if(coolpercent > 100) {
            coolpercent = 100;
        }
        return coolpercent;
    }

    function dead(object1:FlxObject, object2:FlxObject) {
        /*
        if(!isdead) {
            trail.end(false, 0.01);
            FlxTween.tween(player, { x:player.x, y:player.y }, 0.25);
            FlxTween.tween(player.scale, { x:0, y:0 }, 0.25);
            var circle:FlxShapeCircle;
            circle = new FlxShapeCircle(player.x, player.y , 0, {color: 0xFFFFFFFF}, 0xFFFFFFFF);
		    add(circle);
            FlxTween.tween(circle, { radius:40, alpha:0, x:circle.x - 30, y:circle.y - 30 }, 0.25);
            var emitter = new FlxEmitter(player.x + 15, player.y + 15, 200);
            emitter.makeParticles(2, 2, 0xFFFFFFFF, 200);
            emitter.acceleration.set(0, 0, 0, 0, 200, 200, 400, 400);
		    add(emitter);
            emitter.start(false, 0.01);
            trail.kill();
            FlxG.sound.play(Paths.sound('death'), 1);
            isdead = true;
            trace('DEADDDDDDD!!');
            MusicBeatState.resetState();
        }
        */
    }
}

class ColorProperties {
    public var id:Int;
    public var red:Int;
    public var green:Int;
    public var blue:Int;
    public var opacity:Float;
    public var blend:Bool;

	public function new(coolid:Int = 1, tred:Int = 255, tgreen:Int = 255, tblue:Int = 255, topacity:Float = 1, tblend:Bool = false) {
		this.id = coolid;
        this.red = tred;
        this.green = tgreen;
        this.blue = tblue;
        this.opacity = topacity;
        this.blend = tblend;
	}
}

class BlockProperties {
    public var id:Int;
    public var xpos:Float;
    public var ypos:Float;
    public var rot:Float;
    public var sca:Float;
    public var fx:Bool;
    public var fy:Bool;
    public var colorid:Int;
    public var red:Int;
    public var green:Int;
    public var blue:Int;
    public var opacity:Float;
    public var duration:Float;
    public var targetcolor:Int;
    public var used:Bool;

	public function new(coolid:Int = 1, coolx:Float = 0, cooly:Float = 0, coolrot:Float = 0, coolscale:Float = 1, coolfx:Bool = false, coolfy:Bool = false, coolcolor:Int = 1,
    tred:Int = 255, tgreen:Int = 255, tblue:Int = 255, topacity:Float = 1, tduration:Float = 0, ttargetcolor:Int = -1) {
		this.id = coolid;
        this.xpos = coolx;
        this.ypos = cooly;
        this.rot = coolrot;
        this.sca = coolscale;
        this.fx = coolfx;
        this.fy = coolfy;
        this.colorid = coolcolor;
        this.red = tred;
        this.green = tgreen;
        this.blue = tblue;
        this.opacity = topacity;
        this.duration = tduration;
        this.targetcolor = ttargetcolor;
	}
}
