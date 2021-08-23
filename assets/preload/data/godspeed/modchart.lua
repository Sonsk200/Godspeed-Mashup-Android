
-- this modchart is kinda basic since im not experienced with them, some parts are hardcoded becuase i find it easier
local camhudx = 0
local camhudy = 0

local sh_r = 60
local rotRateSh = 0

local middlescroll = false
local shaggymiddlescroll = false
local strumsactive = true

local intensity = 20 --higher = less intense
function setDefault(id)
	_G['defaultStrum'..id..'X'] = getActorX(id)
	_G['defaultStrum'..id..'Y'] = getActorY(id)
	_G['defaultStrum'..id..'Z'] = getActorAngle(id)	
	setActorAngle(0,id)
end
function start (song)

  
end
function update(elapsed)

    if not middlescroll and strumsactive then
        for i = 0, 17  do
            setActorX(_G['defaultStrum'..i..'X'] + (math.sin((curStep / 9.5 + i) * sh_r * math.pi)),i)
            setActorY(_G['defaultStrum'..i..'Y'] + 10 + (math.cos((curStep / 9.5 + i) * 2) * sh_r * 0.45 * math.pi) / intensity,i)
        end
    elseif not shaggymiddlescroll then
        strumsactive = true
        for i = 9, 18  do
            setActorX(_G['defaultStrum'..i..'X'] + (-275) + (math.sin((curStep / 9.5 + i) * sh_r * math.pi)),i)
            setActorY(_G['defaultStrum'..i..'Y'] + 10 + (math.cos((curStep / 9.5 + i) * 2) * sh_r * 0.45 * math.pi) / intensity,i)
        end
    else
        tweenCameraZoomIn(1, 0.5)
        strumsactive = false
        for i = 0, 8  do
            setActorX(_G['defaultStrum'..i..'X'] + (275) + (math.sin((curStep / 9.5 + i) * sh_r * math.pi)),i)
            setActorY(_G['defaultStrum'..i..'Y'] + 10 + (math.cos((curStep / 9.5 + i) * 2) * sh_r * 0.45 * math.pi) / intensity,i)
            
        end
    end

    if strumsactive and middlescroll then
        for i = 0, 9 do 
            setActorX(_G['defaultStrum'..i..'X'] - 2000,i)
        end

    
    end 

end


function stepHit(step) 

    rotRateSh = curStep / 9.5

    if curStep < 255 then
        sh_r = 6
    elseif curStep > 1200 and curStep < 1500 then
        sh_r = sh_r + ((6 - sh_r) / 32)
    elseif curStep > 2880 then
        sh_r = sh_r + ((6 - sh_r) / 32)
    elseif curStep == 1119 then
        for i = 0,8 do
            tweenFadeOut(i,0,1)
        end
    elseif curStep == 1260 then
        for i = 0,8 do
            tweenFadeOut(i,1,3)
        end

    elseif curStep == 2367 then
        for i = 0,8 do
            tweenFadeOut(i,0,1)
        end


    elseif curStep == 2431 then
        showOnlyStrums = true
        for i = 0,8 do
            tweenFadeIn(i,1,1)
        end
        for i = 9,17 do
            tweenFadeOut(i,0,1)
        end


    elseif curStep == 2480 then
        for i = 0,8 do
            tweenFadeOut(i,0,1)
        end
        for i = 9,17 do
            tweenFadeIn(i,1,1)
        end


    elseif curStep == 2560 then
        for i = 0,8 do
            tweenFadeIn(i,1,1)
        end
        for i = 9,17 do
            tweenFadeOut(i,0,1)
        end


    elseif curStep == 2610 then
        for i = 0,8 do
            tweenFadeOut(i,0,1)
        end
        for i = 9,17 do
            tweenFadeIn(i,1,1)
        end



    elseif curStep == 2688 then
        for i = 0,8 do
            tweenFadeIn(i,1,1)
        end
        for i = 9,17 do
            tweenFadeOut(i,0,1)
        end


    elseif curStep == 2735 then
        for i = 0,8 do
            tweenFadeOut(i,0,1)
        end
        for i = 9,17 do
            tweenFadeIn(i,1,1)
        end


    elseif curStep == 2815 then
        for i = 0,8 do
            tweenFadeIn(i,1,1)
        end
        for i = 9,17 do
            tweenFadeOut(i,0,1)
        end
    elseif curStep == 2865 then
        for i = 0,8 do
            tweenFadeOut(i,0,1)
        end
        for i = 9,17 do
            tweenFadeIn(i,1,1)
        end


    else
        sh_r = 60;
    end

end
function beatHit(beat)

    if curBeat == 215 then
        intensity = 14
    elseif curBeat == 248 then
        intensity = 7
    elseif curBeat == 280 then
        middlescroll = true
        intensity = 100
    elseif curBeat == 312 then
        middlescroll = false
    elseif curBeat == 375 then
        intensity = 7
    elseif curBeat == 471 then
        intensity = 10
    elseif curBeat == 479 then
        intensity = 3
    elseif curBeat == 560 then
        intensity = 7
    elseif curBeat == 592 then
        intensity = 12
        middlescroll = true
    elseif curBeat == 607 then
        shaggymiddlescroll = true
    elseif curBeat == 623 then
        shaggymiddlescroll = false

    elseif curBeat == 639 then
        shaggymiddlescroll = true
    elseif curBeat == 655 then
        shaggymiddlescroll = false

    elseif curBeat == 673 then
        shaggymiddlescroll = true
    elseif curBeat == 687 then
        shaggymiddlescroll = false

    elseif curBeat == 704 then
        shaggymiddlescroll = true
    elseif curBeat == 719 then
        shaggymiddlescroll = false
    elseif curBeat == 736 then
        showOnlyStrums = false

        

    elseif curBeat >= 728 and curBeat <= 738 then
        tweenCameraZoomIn(1, 1.5)

    end



end
---215 decrease
---248 increase
---280 middlescroll start /stop arrows
---312 middlescroll end
---375 start arrows again
---471 decrease
---479 increase a lot
---560 decrease a bit
---592 middlescroll start /stop arrows
---607 middlescroll end /start shaggy side /zoom in
---623 middlescroll start /stop shaggy side /zoom out
---640 middlescroll end /start shaggy side /zoom in
---655 middlescroll start /stop shaggy side /zomm out
---673 middlescroll end /start shaggy side /zomm in
---687 middlescroll start /stop shaggy /zoom out
---704 middlescroll end /start shaggy side /zoom in
---719 middlescroll start /stop shagyg 




