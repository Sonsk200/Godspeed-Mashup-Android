

function start(song) --code originally from qt

	x9 = getActorX(9)
	x10 = getActorX(10)
	x11 = getActorX(11)
	x12 = getActorX(12)

    x14 = getActorX(14)
	x15 = getActorX(15)
	x16 = getActorX(16)
	x17 = getActorX(17)
	
	y9 = getActorY(9)
	y10 = getActorY(10)
	y11 = getActorY(11)
	y12 = getActorY(12)

    y14 = getActorY(14)
	y15 = getActorY(15)
	y16 = getActorY(16)
	y17 = getActorY(17)	
end

function beatHit(beat)

    if curBeat == 72 then
        tweenPos(9, x14, y9, 1, done)
        tweenPos(10, x15, y10, 1, done)
        tweenPos(11, x16, y11, 1, done)
        tweenPos(12, x17, y12, 1, done)

        tweenPos(14, x9, y14, 1, done)
        tweenPos(15, x10, y15, 1, done)
        tweenPos(16, x11, y16, 1, done)
        tweenPos(17, x12, y17, 1, done)

    elseif curBeat == 40 then

        tweenPos(9, x9, y9+30, 1, done)
        tweenPos(10, x10, y10+30, 1, done)
        tweenPos(11, x11, y11+30, 1, done)
        tweenPos(12, x12, y12+30, 1, done)

        tweenPos(14, x14, y14-30, 1, done)
        tweenPos(15, x15, y15-30, 1, done)
        tweenPos(16, x16, y16-30, 1, done)
        tweenPos(17, x17, y17-30, 1, done)

    elseif curBeat == 133 then

        tweenPos(9, x9, y9, 0.25, done)
        tweenPos(10, x10, y10, 0.25, done)
        tweenPos(11, x11, y11, 0.25, done)
        tweenPos(12, x12, y12, 0.25, done)

        tweenPos(14, x14, y14, 0.25, done)
        tweenPos(15, x15, y15, 0.25, done)
        tweenPos(16, x16, y16, 0.25, done)
        tweenPos(17, x17, y17, 0.25, done)

    elseif curBeat == 167 then

        tweenPos(9, x9, y9-30, 1, done)
        tweenPos(10, x10, y10-30, 1, done)
        tweenPos(11, x11, y11-30, 1, done)
        tweenPos(12, x12, y12-30, 1, done)

        tweenPos(14, x14, y14+30, 1, done)
        tweenPos(15, x15, y15+30, 1, done)
        tweenPos(16, x16, y16+30, 1, done)
        tweenPos(17, x17, y17+30, 1, done)

    elseif curBeat == 229 then

        tweenPos(9, x9, y9, 0.25, done)
        tweenPos(10, x10, y10, 0.25, done)
        tweenPos(11, x11, y11, 0.25, done)
        tweenPos(12, x12, y12, 0.25, done)

        tweenPos(14, x14, y14, 0.25, done)
        tweenPos(15, x15, y15, 0.25, done)
        tweenPos(16, x16, y16, 0.25, done)
        tweenPos(17, x17, y17, 0.25, done)

    elseif curBeat == 248 then

        tweenPos(9, x9, y9+math.random(-60,60), 0.25, done)
        tweenPos(10, x10, y10+math.random(-60,60), 0.25, done)
        tweenPos(11, x11, y11+math.random(-60,60), 0.25, done)
        tweenPos(12, x12, y12+math.random(-60,60), 0.25, done)

        tweenPos(14, x14, y14+math.random(-60,60), 0.25, done)
        tweenPos(15, x15, y15+math.random(-60,60), 0.25, done)
        tweenPos(16, x16, y16+math.random(-60,60), 0.25, done)
        tweenPos(17, x17, y17+math.random(-60,60), 0.25, done)

    elseif curBeat == 272 then

        tweenPos(9, x9, y9, 0.25, done)
        tweenPos(10, x10, y10, 0.25, done)
        tweenPos(11, x11, y11, 0.25, done)
        tweenPos(12, x12, y12, 0.25, done)

        tweenPos(14, x14, y14, 0.25, done)
        tweenPos(15, x15, y15, 0.25, done)
        tweenPos(16, x16, y16, 0.25, done)
        tweenPos(17, x17, y17, 0.25, done)

    elseif curBeat == 277 then --fade out
        for i = 0,17 do
            tweenFadeOut(i,0,2)
        end





    
    end

end