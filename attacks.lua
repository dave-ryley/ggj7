
basicAttackSound = audio.loadSound("_audio/Basic Attack.ogg")
jumpSound = audio.loadSound("_audio/Jump.ogg")

-- All attacks should be under 1000 ms
function attack( attacker, attacked, attackType, direction )
	attackAnimation[attackType]( attacker, attacked, direction )
end

-- BASIC STRIKE ANIMATIONS

function basicStrike( obj, attacked, direction )
	local origin = obj.x

    transition.to( obj, { time = 500, x = 300*direction, delta = true, onComplete = function( )
        transition.to( obj, { time = 50, x = 300*direction, delta = true, onComplete = function( )
						audio.play(basicAttackSound,{channel = 1,duration = 1000})
            transition.to( obj, {time = 300, x = origin } )
            do_shake_obj( attacked, 3 )
        end } )
    end } )
end

function leapAttack( obj, attacked, direction )
	local returnpoint = {obj.x,obj.y}
	local curve = generate_curve(8,{
																{x = obj.x, y = obj.y},
																{x = obj.x, y = obj.y-100},
																{x = obj.x+(100*direction), y = obj.y-300},
																{x = obj.x+(400*direction),y = obj.y-300} })
	audio.play(jumpSound,{channel = 2,duration = 1000})
  transition_curve(obj,curve,{ time = 400, speed = 0.1, onComplete = function()
		transition.to(obj,{time = 70, x = attacked.x,y = attacked.y,onComplete = function()
      transition.to( obj, { time = 300, x = returnpoint[1], y = returnpoint[2]})
			audio.play(basicAttackSound,{channel = 1,duration = 1000})
      do_shake_obj( attacked, 3 )
		end } )
  end },1 )
end

function groundPound( obj, attacked, direction )

	local origin = obj.x

    transition.to( obj, { time = 300, y = -200, delta = true, onComplete = function()
        transition.to( obj, { time = 50, y = 200, delta = true, onComplete = function()
            transition.to( obj, {time = 200, x = origin } )
            do_shake_obj( attacked, 5 )
        end } )
    end } )
end

function dashAttack( obj, attacked, direction )

	local origin = obj.x

    transition.to( obj, { time = 500, x = 300*direction, delta = true, onComplete = function( )
        transition.to( obj, { time = 50, x = 300*direction, delta = true, onComplete = function( )
            transition.to( obj, {time = 300, x = origin } )
            do_shake_obj( attacked, 3 )
        end } )
    end } )
end

function growthAttack( obj, attacked, direction )

	local origin = obj.x

    transition.scaleTo( obj, { xScale = 1.2,yScale = 1.2,time = 200, onComplete = function( )
        transition.to( obj, { time = 50, x = 300*direction, delta = true, onComplete = function( )
						do_shake_obj( attacked, 3 )
						transition.to( obj, {time = 300, x = origin, onComplete = function()
							transition.scaleTo(obj,{time = 200,xScale = 1,yScale = 1})
						end } )
        end } )
    end } )
end


function do_shake_obj( obj, count )
    if not count then count = 1 end

    if count > 0 then
        shake_obj( obj, function( ) do_shake_obj( obj, count-1 ) end )
    end
end

function shake_obj( obj, onComplete )

	local origin = obj.x

    transition.to( obj, { time = 20, x = 10, delta = true, onComplete = function( )
        transition.to( obj, { time = 40, x = -20, delta = true, onComplete = function( )
            transition.to( obj, {time = 20, x = origin, onComplete = onComplete } )
        end } )
    end } )
end

attackAnimation = {
	--LEAP ATTACK ANIMATION
	["Basic Strike"] = basicStrike,
	["Leap Attack"] = leapAttack,
	["Ground Pound"] = groundPound,
	["Dash"] = dashAttack,
	["Rage"] = growthAttack
}
