
-- All attacks should be under 1000 ms
function attack( attacker, attacked, attackType, direction )
	attackAnimation[attackType]( attacker, attacked, direction )
end

-- BASIC STRIKE ANIMATIONS

function basicStrike( obj, attacked, direction )

	local origin = obj.x

    transition.to( obj, { time = 500, x = 300*direction, delta = true, onComplete = function( )
        transition.to( obj, { time = 50, x = 300*direction, delta = true, onComplete = function( )
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

  transition_curve(obj,curve,{ time = 400, speed = 0.1, onComplete = function()
		transition.to(obj,{time = 70, x = attacked.x,y = attacked.y,onComplete = function()
      transition.to( obj, { time = 300, x = returnpoint[1], y = returnpoint[2]})
      do_shake_obj( attacked, 3 )
		end } )
  end },1 )
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
	["basic strike"] = basicStrike,
	["leap attack"] = leapAttack
}
