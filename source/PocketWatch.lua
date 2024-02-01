class('PocketWatch').extends(Clock)
-- Still not sure if this is the "proper" way to do static class variables, but the only way that worked for me
PocketWatch.STATES = {
    NORMAL = 0,
    TIMESET = 1
}

function PocketWatch:init(startHours, startMinutes, startSeconds, startState)
    self.STATE = startState
    if self.STATE == nil then
        print("EXCEPTION: PocketWatch self.STATE is nil!")
    end

    local runClock = true
    if self.STATE == PocketWatch.STATES.TIMESET then
        runClock = false
    end
    
    PocketWatch.super.init(self, startHours, startMinutes, startSeconds, runClock)

    self.crownImageTable = gfx.imagetable.new("art/crown")
    self.windPercent = 100
end

function PocketWatch:normalMode()
    self.STATE = PocketWatch.STATES.NORMAL
    self:startClock()
end

function PocketWatch:timeSetMode()
    self.STATE = PocketWatch.STATES.TIMESET
    self:stopClock()
end

function PocketWatch:addWindPercentage(percentage)
    self.windPercent += percentage
end

function PocketWatch:playCrownInSound()
    pdSynth:playNote('D',1,0.015)
end

function PocketWatch:playCrownOutSound()
    pdSynth:playNote('B',1,0.015)
end

function PocketWatch:playCrownSpinSound()
    pdSynth:playNote('b',0.5,0.015)
end

function PocketWatch:draw()
    self:drawMainClockParts()
    self:drawPocketWatchParts()
end

function PocketWatch:drawPocketWatchParts()
    local crownImageIndex = nil
    if self.STATE == PocketWatch.STATES.NORMAL then
        crownImageIndex = 1
    elseif self.STATE == PocketWatch.STATES.TIMESET then
        crownImageIndex = 2
        pd.ui.crankIndicator:update()
    end

    -- We must scale the image first or else getSize() will return the original image size
    local crownImage = self.crownImageTable:getImage(crownImageIndex):scaledImage(self.outerClockRadius * 0.003)
    local crownImageWidth, crownImageHeight = crownImage:getSize()
    local crownImageX = self.clockCenterX + (self.outerClockRadius * 0.95)
    local crownImageY = self.clockCenterY - (crownImageHeight/2)
    crownImage:draw(crownImageX, crownImageY)
    

    
end
