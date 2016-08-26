
function attack( attacker, attacked, attackType, direction )
	attackAnimation[attackType]( attacker, attacked, direction )
end

function basicStrike( obj, attacked, direction )

	local origin = obj.x

    transition.to( obj, { time = 500, x = 300*direction, delta = true, onComplete = function( )
        transition.to( obj, { time = 50, x = 300*direction, delta = true, onComplete = function( )
            transition.to( obj, {time = 300, x = origin } )
            do_shake_obj( attacked, 3 )
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
	
	["basic strike"] = basicStrike
}