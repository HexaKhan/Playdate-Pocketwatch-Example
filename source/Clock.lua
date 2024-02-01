--Create a Clock "class" (OOP is not native to LUA, this is done through CoreLibs)
class('Clock').extends(Object)
function Clock:init(startHours, startMinutes, startSeconds, runClock)
    local startHours = startHours or 0
    local startMinutes = startMinutes or 0
    local startSeconds = startSeconds or 0
    local runClock = runClock or false 
    self.time = self:convertToSeconds(startHours, startMinutes, startSeconds)
    print("total seconds: " .. self.time)

    self.timer = pd.timer.new(1000, function() self:tickClock() end) -- function() is required to call self Class methods per pd devforum
    if runClock == true then
        self.timer.repeats = true
        self.clockRunning = true
    else
        self:stopClock()
    end


    --- Clock Drawing Variables---
    self.clockCenterX = screenWidth/2 - 40
    self.clockCenterY = screenHeight/2

    self.outerClockRadius = (screenHeight/2) * 0.90
    self.innerClockRadius = self.outerClockRadius * 0.90
    self.centerDotRadius = self.outerClockRadius * 0.05
    
    -- length of the hands compared to the clock's radius
    self.secondHandLength = self.innerClockRadius * 0.90
    self.minuteHandLength = self.innerClockRadius * 0.70
    self.hourHandLength = self.innerClockRadius * 0.50

    -- Outward digit positioning in relation to the clock's radius
    self.numberLength = self.innerClockRadius * 0.85
    
end

function Clock:convertToSeconds(hours, minutes, seconds)
    local secondsInMinute = 60
    local secondsInHour = secondsInMinute * 60
    return (hours * secondsInHour) + (minutes * secondsInMinute) + (seconds)
end

function Clock:getTime()
    local time = self.time
    local currentHour = math.floor(time/self:convertToSeconds(1,0,0))
    time -= self:convertToSeconds(currentHour, 0, 0)
    local currentMinute = math.floor(time/self:convertToSeconds(0,1,0))
    time -= self:convertToSeconds(0, currentMinute, 0)
    currentSecond = time
    return currentHour, currentMinute, currentSecond
end

function Clock:setTime(seconds)
    self.time = seconds
end

function Clock:printTime()
    print("Clock time is:", self.time)
end

function Clock:updateClock()
    -- 86,400 seconds = 1 day
    local daySeconds = 86400
    if self.time < 0 then  --If time is negative, calculate time by subtracting from 86400
        self.time = (daySeconds - math.abs(math.fmod(self.time, daySeconds)))
    elseif self.time >= daySeconds then --If time is more thann 86400, roll over left over time
        self.time = math.fmod(self.time, daySeconds)
    end
end

function Clock:addTime(hours, minutes, seconds)
    self.time += self:convertToSeconds(hours, minutes, seconds)
    self:updateClock()
end

function Clock:removeTime(hours, minutes, seconds)
    self.time -= self:convertToSeconds(hours, minutes, seconds)
    self:updateClock()
end

function Clock:tickClock()
    self:addTime(0,0,1)
    self:playTickSound()
end

function Clock:startClock()
    self.timer:start()
    self.clockRunning = true
end

function Clock:stopClock()
    self.timer:pause()
    self.timer:reset()
    self.clockRunning = false
end

function Clock:draw()
    self:drawMainClockParts()
end

function Clock:playTickSound()
    pdSynth:playNote('a',0.5,0.015)
end


function Clock:drawMainClockParts()
    local hour, minute, second = self:getTime()
    local hourAngle = (hour + minute / 60) * 30
    if hourAngle >= 360 then hourAngle -= 360 end
    local minuteAngle = (minute + second / 60) * 6
    local secondAngle = second * 6

    -- Debug Info
    -- gfx.setColor(gfx.kColorBlack)
    -- gfx.drawText(self.time, 10, 10)
    
    -- gfx.drawText("Hour: " .. hour, 10, 30)
    -- gfx.drawText("Minute: " .. minute, 10, 45)
    -- gfx.drawText("Second: " .. second, 10, 60)

    -- gfx.drawText("Hour: " .. hourAngle, 10, 175)
    -- gfx.drawText("Minute: " .. minuteAngle, 10, 190)
    -- gfx.drawText("Second: " .. secondAngle, 10, 205)

    ---gfx.drawText("Crank Change: " .. crankChange, screenWidth - 150, screenHeight - 20)
    -- 

    gfx.setColor(gfx.kColorBlack)
    gfx.fillCircleAtPoint(self.clockCenterX, self.clockCenterY, self.outerClockRadius)
    gfx.setColor(gfx.kColorWhite)
    gfx.fillCircleAtPoint(self.clockCenterX, self.clockCenterY, self.innerClockRadius)
    gfx.setColor(gfx.kColorBlack)
    gfx.fillCircleAtPoint(self.clockCenterX, self.clockCenterY, self.centerDotRadius)
    
    -- Draw Hour, Minute, Second hands
    gfx.setColor(gfx.kColorBlack)
    gfx.setLineWidth(5)
    gfx.drawLine(
        self.clockCenterX,
        self.clockCenterY,
        self.clockCenterX + math.sin(math.rad(hourAngle)) * self.hourHandLength,
        self.clockCenterY - math.cos(math.rad(hourAngle)) * self.hourHandLength)

    gfx.setLineWidth(3)
    gfx.drawLine(
        self.clockCenterX,
        self.clockCenterY,
        self.clockCenterX + math.sin(math.rad(minuteAngle)) * self.minuteHandLength,
        self.clockCenterY - math.cos(math.rad(minuteAngle)) * self.minuteHandLength)
    
    gfx.setLineWidth(1)
    gfx.drawLine(
        self.clockCenterX,
        self.clockCenterY,
        self.clockCenterX + math.sin(math.rad(secondAngle)) * self.secondHandLength,
        self.clockCenterY - math.cos(math.rad(secondAngle)) * self.secondHandLength)

    -- Draw digits around clock
    local currentAngle = 0
    for i=1,12 do 
        currentAngle += 30 -- 360/12 digits
        gfx.drawTextAligned(
            i,
            self.clockCenterX + math.sin(math.rad(currentAngle)) * self.numberLength,
            self.clockCenterY - math.cos(math.rad(currentAngle)) * self.numberLength - 7, --Still need to figure out best way to "align" the y text when drawing, added manual adjustment for now
            kTextAlignment.center)
    end
end