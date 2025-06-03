-- Advanced Space Combat - Pulse Projectile Client

include("shared.lua")

function ENT:Draw()
    -- Don't draw the model, use particle effects instead
end

function ENT:Initialize()
    -- Create glow effect
    local dlight = DynamicLight(self:EntIndex())
    if dlight then
        dlight.pos = self:GetPos()
        dlight.r = 0
        dlight.g = 150
        dlight.b = 255
        dlight.brightness = 2
        dlight.decay = 1000
        dlight.size = 100
        dlight.dietime = CurTime() + 0.1
    end
end
