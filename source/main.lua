import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/timer"
import "CoreLibs/ui"
import "Clock"
import "PocketWatch"

pd = playdate
gfx = pd.graphics


screenHeight = pd.display.getHeight()
screenWidth = pd.display.getWidth()
pdSynth = pd.sound.synth.new(pd.sound.kWavePOVosim)

local crankChange = 0
local previousCrankChange = 0
local totalTimeCrank = 0
local totalWindCrank = 0

pd.ui.crankIndicator:start()
time = pd.getTime()
local clock = PocketWatch(time.hour, time.minute, time.second, PocketWatch.STATES.NORMAL)

function pd.update()
    clearScreen()
    pd.timer.updateTimers()
    clock:draw()
    if crankChange == previousCrankChange then
        crankChange, previousCrankChange = 0
    else
        previousCrankChange = crankChange
    end
end

function clearScreen()
    gfx.clear(gfx.kColorWhite)
end

function pd.cranked(change, acceleratedChange)
    if clock.STATE == PocketWatch.STATES.TIMESET then
        totalTimeCrank += change  -- Add/remove # of degrees crank has changed since last tick
        local minutesPerDegree = 60/360
        local totalMinutes = totalTimeCrank * minutesPerDegree  -- How many total minutes available to be added/removed

        if totalMinutes >= 1 then
            local minuteChange = math.floor(totalMinutes)
            clock:addTime(0, minuteChange, 0)
            totalTimeCrank -= (minuteChange * (1/minutesPerDegree))
            clock:playCrownSpinSound()
        elseif totalMinutes <= -1 then
            local minuteChange = math.abs(math.ceil(totalMinutes))
            clock:removeTime(0, minuteChange, 0)
            totalTimeCrank += (minuteChange * (1/minutesPerDegree))
            clock:playCrownSpinSound()
        end
        crankChange = change
    elseif clock.STATE == PocketWatch.STATES.NORMAL then
        -- We don't "unwind" by cranking the opposite direction
        if change > 0 then
            totalWindCrank += change

            local windPercentPerDegree = 10/360
            local totalWindPercentage = totalWindCrank * windPercentPerDegree
            if totalWindPercentage >= 1 then
                local windPercentChange = math.floor(totalWindPercentage)
                clock:addWindPercentage(windPercentChange)
                totalWindCrank -= (windPercentChange * (1/windPercentPerDegree))
                clock:playCrownSpinSound()
                print(clock.windPercent)
            end
        end
    end
end

function pd.BButtonDown()
    clock:removeTime(1,0,0)
end

function pd.AButtonDown()
    clock:addTime(1,0,0)
end

function pd.leftButtonDown()
    clock:normalMode()
    clock:playCrownInSound()
end

function pd.rightButtonDown()
    clock:timeSetMode()
    clock:playCrownOutSound()
end

function pd.upButtonDown()
    clock:startClock()
end

function pd.downButtonDown()
    clock:stopClock()
end



