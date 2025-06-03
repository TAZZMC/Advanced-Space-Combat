-- Advanced Space Combat - Pulse Projectile

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
    self:SetModel("models/effects/teleporttrail.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    
    local phys = self:GetPhysicsObject()
    if IsValid(phys) then
        phys:Wake()
        phys:SetMass(1)
        phys:EnableGravity(false)
        phys:SetDragCoefficient(0)
    end
    
    self.Damage = 75
    self.LifeTime = 3
    self.StartTime = CurTime()
    
    -- Create trail effect
    util.SpriteTrail(self, 0, Color(0, 150, 255), false, 15, 1, 0.5, 1/(15+1)*0.5, "trails/laser.vmt")
end

function ENT:Think()
    if CurTime() - self.StartTime > self.LifeTime then
        self:Remove()
        return
    end
    
    self:NextThink(CurTime() + 0.01)
    return true
end

function ENT:PhysicsCollide(data, phys)
    local hitEnt = data.HitEntity
    
    if IsValid(hitEnt) and hitEnt ~= self:GetOwner() then
        -- Deal damage
        local dmginfo = DamageInfo()
        dmginfo:SetDamage(self.Damage)
        dmginfo:SetAttacker(self:GetOwner())
        dmginfo:SetInflictor(self)
        dmginfo:SetDamageType(DMG_ENERGYBEAM)
        dmginfo:SetDamagePosition(data.HitPos)
        
        hitEnt:TakeDamageInfo(dmginfo)
        
        -- Impact effect
        local effectdata = EffectData()
        effectdata:SetOrigin(data.HitPos)
        effectdata:SetNormal(data.HitNormal)
        util.Effect("asc_pulse_impact", effectdata)
        
        self:EmitSound("asc/weapons/pulse_impact.wav", 60, 100)
    end
    
    self:Remove()
end
