// Self-Propelled Props

class CPluginSelfPropelledProps extends VSLU.IScriptPlugin
{
    function Load()
    {
        VSLU.RegisterOnTickFunction("g_SelfPropelledProps.Think");

        VSLU.Hooks.RegisterHook( VSLU.Hooks.OnAllowTakeDamage, g_SelfPropelledProps.OnAllowTakeDamage );

        VSLU.HookEvent("bullet_impact", g_SelfPropelledProps.OnBulletImpact, g_SelfPropelledProps);
        VSLU.HookEvent("weapon_fire", g_SelfPropelledProps.OnWeaponFire, g_SelfPropelledProps);

        g_SelfPropelledProps.Precache();
        g_SelfPropelledProps.ParseConfigFile();

        printl("[Self-Propelled Props]\nAuthor: Sw1ft\nVersion: 1.0.1");
    }

    function Unload()
    {
        VSLU.RemoveOnTickFunction("g_SelfPropelledProps.Think");

        VSLU.Hooks.RemoveHook( VSLU.Hooks.OnAllowTakeDamage, g_SelfPropelledProps.OnAllowTakeDamage );
        
        VSLU.UnhookEvent("bullet_impact", g_SelfPropelledProps.OnBulletImpact, g_SelfPropelledProps);
        VSLU.UnhookEvent("weapon_fire", g_SelfPropelledProps.OnWeaponFire, g_SelfPropelledProps);
    }

    function OnRoundStartPost()
    {
    }

    function OnRoundEnd()
    {
    }

    function GetClassName()
    {
        return m_sClassName;
    }

    function GetScriptPluginName()
    {
        return m_sScriptPluginName;
    }

    function GetInterfaceVersion()
    {
        return m_InterfaceVersion;
    }

    static m_InterfaceVersion = 1;
    static m_sClassName = "CPluginSelfPropelledProps";
    static m_sScriptPluginName = "Self-Propelled Props";
}

class CSelfPropelledProp
{
    constructor(hEntity, hOwnerPlayer, iPropType)
    {
        m_hEntity = hEntity;
        m_hOwnerPlayer = hOwnerPlayer;

        m_iPropType = iPropType;
        m_flStartTime = Time();
        m_aPropelPoints = [];

        m_hSoundEffect = SpawnEntityFromTable("prop_dynamic", { origin = hEntity.GetOrigin(), model = "models/props_foliage/urban_pot_clay02.mdl" }) // b

        NetProps.SetPropFloat(m_hSoundEffect, "m_flModelScale", 1e-6);
        NetProps.SetPropInt(m_hSoundEffect, "m_fEffects", 60);
        NetProps.SetPropInt(m_hSoundEffect, "m_CollisionGroup", 10);
        NetProps.SetPropInt(m_hSoundEffect, "m_nRenderMode", 6);

        EmitSoundOn(g_SelfPropelledProps.THRUSTER_SOUND, m_hSoundEffect);
    }

    function Clear()
    {
        if (m_hSoundEffect.IsValid())
        {
            StopSoundOn(g_SelfPropelledProps.THRUSTER_SOUND, m_hSoundEffect);
            m_hSoundEffect.Kill();
        }

        foreach (propel_point in m_aPropelPoints)
            propel_point.Clear();
    }

    function Update()
    {
        UpdateSoundPosition();

        foreach (propel_point in m_aPropelPoints)
            propel_point.UpdateParticle();
    }

    function UpdateSoundPosition()
    {
        if (m_hSoundEffect.IsValid() && m_hEntity.IsValid())
            m_hSoundEffect.__KeyValueFromString("origin", kvstr(m_hEntity.GetOrigin()));
            // m_hSoundEffect.SetOrigin(m_hEntity.GetOrigin());
    }

    function AddPropelPoint(vecImpactPoint, vecImpactDir, bBurnDamage)
    {
        local propel_point = CSPPPropelPoint(m_hEntity, bBurnDamage, vecImpactPoint, vecImpactDir);     
        m_aPropelPoints.push(propel_point);
    }

    function GetPropelPoints() { return m_aPropelPoints.len(); }

    function GetPropelTime() { return m_flStartTime; }

    function CanExplode() { return m_bCanExplode; }

    function ForbidExploding() { m_bCanExplode = false; }

    function GetOwnerPlayer() { return m_hOwnerPlayer; }

    function GetEntity() { return m_hEntity; }

    function GetPropType() { return m_iPropType; }

    function IsValid() { return m_hEntity.IsValid(); }

    m_hEntity = null;
    m_hOwnerPlayer = null;
    m_hSoundEffect = null;

    m_iPropType = null;
    m_bCanExplode = true;
    m_aPropelPoints = null;

    m_flStartTime = 0.0;
}

class CSPPPropelPoint
{
    constructor(hOwnerEntity, bBurnDamage, vecImpactPoint, vecImpactDir)
    {
        local sTargetname = "spp_chad_prop_" + (++::__spp_chad_props_count);
        local vecAngles = VSLU.Math.VectorToQAngle(vecImpactDir);

        m_hOwnerEntity = hOwnerEntity;
        m_bBurnDamage = bBurnDamage;

        hOwnerEntity.__KeyValueFromString("targetname", sTargetname);

        m_hForceThruster = SpawnEntityFromTable("phys_thruster", { // linear velocity
            origin = vecImpactPoint
            angles = kvstr(vecAngles)
            spawnflags = 29 // Start On | Apply Torque | Orient Locally | Ignore Mass
            force = g_SelfPropelledProps.Settings.flVelocityImpulse
            attach1 = sTargetname
        });

        m_hTorqueThruster = SpawnEntityFromTable("phys_thruster", { // angular velocity
            origin = vecImpactPoint
            angles = kvstr(vecAngles)
            spawnflags = 27 // Start On | Apply Force | Orient Locally | Ignore Mass
            force = g_SelfPropelledProps.Settings.flAngularVelocityImpulse
            attach1 = sTargetname
        });

        m_hParticleEffect = SpawnEntityFromTable("info_particle_system", {
            origin = vecImpactPoint
            start_active = 1
            effect_name = bBurnDamage ? g_SelfPropelledProps.FIRE_SPRAY : g_SelfPropelledProps.OXYGEN_SPRAY
            angles = kvstr(vecAngles * -1)
        });

        VSLU.AttachEntity(hOwnerEntity, m_hForceThruster);
        VSLU.AttachEntity(hOwnerEntity, m_hTorqueThruster);
        VSLU.AttachEntity(hOwnerEntity, m_hParticleEffect);

        VSLU.SetScriptScopeVar(m_hParticleEffect, "particle_reload_time", Time() + (m_bBurnDamage ? 65.0 : 5.0));
    }

    function Clear()
    {
        if (m_hForceThruster.IsValid())
            m_hForceThruster.Kill();

        if (m_hTorqueThruster.IsValid())
            m_hTorqueThruster.Kill();

        if (m_hParticleEffect.IsValid())
            m_hParticleEffect.Kill();
    }

    function UpdateParticle()
    {
        if (VSLU.GetScriptScopeVar(m_hParticleEffect, "particle_reload_time") <= Time())
        {
            VSLU.SetScriptScopeVar(m_hParticleEffect, "particle_reload_time", Time() + (m_bBurnDamage ? 65.0 : 5.0));

            VSLU.AcceptEntityInput(m_hParticleEffect, "Stop");
            VSLU.CreateTimer(0.01, VSLU.AcceptEntityInput, m_hParticleEffect, "Start");
        }
    }

    function GetParticleEffect()
    {
        return m_hParticleEffect;
    }

    m_hOwnerEntity = null;
    m_hForceThruster = null;
    m_hTorqueThruster = null;
    m_hParticleEffect = null;
    m_bBurnDamage = false;
}

g_PluginSelfPropelledProps <- CPluginSelfPropelledProps();

if (!("__spp_chad_props_count" in getroottable()))
    ::__spp_chad_props_count <- 0;

g_SelfPropelledProps <-
{
    // constants
    TYPE_PROPANE_TANK = 0
    TYPE_OXYGEN_TANK = 1

    // PROPANE_TANK_CENTER_OFFSET = Vector(-6.96, -7.6, -0.64)
    // OXYGEN_TANK_CENTER_OFFSET = Vector(-2.24, 0.0, 14.64)

    PROPANE_TANK_CENTER_OFFSET = Vector(-6.890398, 7.331800, -0.257751)
    OXYGEN_TANK_CENTER_OFFSET = Vector(-1.924805, 0.007080, 17.011475)

    THRUSTER_SOUND = "PhysicsCannister.ThrusterLoop"
    FIRE_SPRAY = "fire_small_flameouts" // fire_small_02, fire_small_flameouts, fire_small_base, inferno_small_fire_2
    OXYGEN_SPRAY = "extinguisher_cloud"

    // vars
    vecBulletImpacts = []
    aPropelledProps = []

    ParseConfigFile = function()
    {
        this = ::g_SelfPropelledProps;

        local tData;

        local function SerializeSettings()
        {
            local sData = "{";

            foreach (key, val in Settings)
            {
                switch (typeof val)
                {
                case "string":
                    sData = format("%s\n\t%s = \"%s\"", sData, key, val);
                    break;
                
                case "float":
                    sData = format("%s\n\t%s = %f", sData, key, val);
                    break;
                
                case "integer":
                case "bool":
                    sData = sData + "\n\t" + key + " = " + val;
                    break;
                }
            }

            sData = sData + "\n}";
            StringToFile("self_propelled_props/settings.nut", sData);
        }

        if (tData = FileToString("self_propelled_props/settings.nut"))
        {
            try
            {
                tData = compilestring("return " + tData)();

                foreach (key, val in Settings)
                {
                    if (tData.rawin(key))
                    {
                        Settings[key] = tData[key];
                    }
                }
            }
            catch (error)
            {
                SerializeSettings();
            }
        }
        else
        {
            SerializeSettings();
        }
    }

    Precache = function()
    {
        PrecacheEntityFromTable( { classname = "info_particle_system", effect_name = "fire_small_flameouts" } );
        PrecacheEntityFromTable( { classname = "info_particle_system", effect_name = "extinguisher_cloud" } );

        PrecacheEntityFromTable( { classname = "ambient_generic", message = "PhysicsCannister.ThrusterLoop" } );

        PrecacheEntityFromTable( { classname = "prop_dynamic", model = "models/props_foliage/urban_pot_clay02.mdl" } );
    }

    OnWeaponFire = function(params)
    {
        // started firing, clear the array
        ::g_SelfPropelledProps.vecBulletImpacts.clear();
    }

    OnBulletImpact = function(params)
    {
        // collect all bullet impacts into the array
        ::g_SelfPropelledProps.vecBulletImpacts.push( Vector(params["x"], params["y"], params["z"]) );
    }

    OnAllowTakeDamage = function(applyDamage, tDamageInfo) // hooked scriptedmode's function
    {
        // OnWeaponFire -> OnBulletImpact [x times] -> OnAllowTakeDamage
        this = ::g_SelfPropelledProps;

        if (tDamageInfo["DamageType"] & DMG_BULLET && !(tDamageInfo["DamageType"] & DMG_BLAST))
        {
            if (tDamageInfo["Victim"] && tDamageInfo["Attacker"] && tDamageInfo["Victim"].GetClassname() == "prop_physics" && tDamageInfo["Attacker"].GetClassname() == "player")
            {
                local sModel = NetProps.GetPropString(tDamageInfo["Victim"], "m_ModelName");

                local bPropaneTank = (sModel == "models/props_junk/propanecanister001a.mdl");
                local bOxygenTank = (!bPropaneTank && sModel == "models/props_equipment/oxygentank01.mdl");

                if (bPropaneTank || bOxygenTank)
                {
                    OnHitProp(tDamageInfo["Attacker"],
                            tDamageInfo["Victim"],
                            tDamageInfo["Attacker"].EyePosition(),
                            bPropaneTank ? TYPE_PROPANE_TANK : TYPE_OXYGEN_TANK,
                            bPropaneTank || tDamageInfo["DamageType"] & DMG_BURN);

                    applyDamage.value = false;
                    return HOOK_STOP;
                }
            }
        }

        return HOOK_CONTINUE;
    }

    OnHitProp = function(hInflictor, hEntity, vecAttackOrigin, iPropType, bBurnDamage)
    {
        this = ::g_SelfPropelledProps;

        local vecCenter;
        local worldSpaceToEntityLocalSpace = matrix3x4();

        if (iPropType == TYPE_PROPANE_TANK) // get center of the prop
            vecCenter = hEntity.GetOrigin() + RotatePosition(Vector(0, 0, 0), hEntity.GetAngles(), PROPANE_TANK_CENTER_OFFSET);
        else
            vecCenter = hEntity.GetOrigin() + RotatePosition(Vector(0, 0, 0), hEntity.GetAngles(), OXYGEN_TANK_CENTER_OFFSET);
        
        worldSpaceToEntityLocalSpace = worldSpaceToEntityLocalSpace.SetTransformation(vecCenter, hEntity.GetAngles()).Invert();

        foreach (point in vecBulletImpacts)
        {
            local bImpactPoint = false;

            local vecLocalPoint = worldSpaceToEntityLocalSpace.VectorTransform(point);
            local flImpactRadiusSqr = vecLocalPoint.Length2DSqr();
            local flImpactHeight = vecLocalPoint.z;

            if (iPropType == TYPE_PROPANE_TANK)
            {
                // not sure if there's better way to calc which bullet actually hitted the prop
                // it's complex to use trace a line because bullets can hit through the wall, also if network property 'm_hOwnerEntity' is set, you can't trace a line to the prop, great.
                // of course I need to use crutches to develop any scripts.. thanks valve, why the hell 'Location' key in damage info table is always zero vector??

                if (flImpactRadiusSqr <= 48.3025 && VSLU.Math.Between(flImpactHeight, -10.868, 11.0)) // sqrt(48.3025) = 6.95
                {
                    bImpactPoint = true;
                }
            }
            else if (flImpactRadiusSqr <= 8.38682 && VSLU.Math.Between(flImpactHeight, -16.9505, 14.8646)) // sqrt(8.38682) = 2.896
            {
                bImpactPoint = true;
            }

            if (bImpactPoint)
                AddPropelPointToProp(hInflictor, hEntity, point, point - vecAttackOrigin, iPropType, bBurnDamage);
        }
    }

    AddPropelPointToProp = function(hInflictor, hEntity, vecImpactPoint, vecImpactDir, iPropType, bBurnDamage)
    {
        this = ::g_SelfPropelledProps;

        local hProp = null;

        foreach (prop in aPropelledProps)
        {
            if (prop.GetEntity() == hEntity)
            {
                if (Settings.nMaxPropelPoints > 0 && prop.GetPropelPoints() >= Settings.nMaxPropelPoints)
                    return;

                hProp = prop;
                break;
            }
        }

        if ( !hProp )
        {
            if (Settings.nMaxPropelPoints <= 0)
                return;

            hProp = CSelfPropelledProp(hEntity, hInflictor, iPropType);
            aPropelledProps.push(hProp);
        }

        hProp.AddPropelPoint(vecImpactPoint, vecImpactDir, bBurnDamage);
    }

    Think = function()
    {
        this = ::g_SelfPropelledProps;

        for (local i = 0; i < aPropelledProps.len(); ++i)
        {
            local hProp = aPropelledProps[i];

            if (!hProp.IsValid())
            {
                hProp.Clear();
                aPropelledProps.remove(i);
                --i;
            }
            else if (Settings.flLifeTime > 0.0 && hProp.CanExplode() && Time() - hProp.GetPropelTime() >= Settings.flLifeTime)
            {
                hProp.GetEntity().TakeDamage(1e6, DMG_BLAST, hProp.GetOwnerPlayer());

                if (hProp.GetPropType() == TYPE_OXYGEN_TANK)
                {
                    hProp.ForbidExploding();
                    hProp.Update();
                }
                else
                {
                    hProp.Clear();
                    aPropelledProps.remove(i);
                    --i;
                }
            }
            else if (Settings.flLifeTime > 0.0 && Time() - hProp.GetPropelTime() >= Settings.flLifeTime + 1.95)
            {
                hProp.Clear();
                aPropelledProps.remove(i);
                --i;
            }
            else
            {
                hProp.Update();
            }
        }
    }

    Settings =
    {
        flVelocityImpulse = 400.0
        flAngularVelocityImpulse = 800.0
        flLifeTime = 5.0
        nMaxPropelPoints = 3
    }
};

VSLU.ScriptPluginsHelper.AddScriptPlugin(g_PluginSelfPropelledProps);


/* here's the first code where I calculated angular and linear velocity manually, without phys_thruster entity

class CSelfPropelledProp
{
    constructor(hEntity, hOwnerPlayer, iPropType)
    {
        m_hEntity = hEntity;
        m_hOwnerPlayer = hOwnerPlayer;

        m_iPropType = iPropType;
        m_flStartTime = Time();
        m_aPropelPoints = [];

        m_flVelocityImpulse = g_SelfPropelledProps.flVelocityImpulse;
        m_flAngularVelocityImpulse = g_SelfPropelledProps.flAngularVelocityImpulse;

        // m_hSoundEffect = SpawnEntityFromTable("prop_physics", { health = 100000, origin = hEntity.GetOrigin(), model = "models/props_equipment/oxygentank01.mdl" });
        m_hSoundEffect = SpawnEntityFromTable("info_target", { origin = hEntity.GetOrigin() });
        EmitSoundOn(g_SelfPropelledProps.THRUSTER_SOUND, m_hSoundEffect);
    }

    function Clear()
    {
        if (m_hSoundEffect.IsValid())
        {
            StopSoundOn(g_SelfPropelledProps.THRUSTER_SOUND, m_hSoundEffect);
            m_hSoundEffect.Kill();
        }

        foreach (propel_point in m_aPropelPoints)
            propel_point.Clear();
    }

    function Simulate()
    {
        if (m_aPropelPoints.len() > 0)
        {
            local entityLocalSpaceToWorldSpace = matrix3x4();
            entityLocalSpaceToWorldSpace.AngleMatrix(m_hEntity.GetAngles());

            local flImpulseFraction = pow(0.8, m_aPropelPoints.len() - 1); // slow down the impulse if there's more than one propel point
            local flVelocityImpulse = m_flVelocityImpulse * flImpulseFraction;

            foreach (propel_point in m_aPropelPoints)
                propel_point.Simulate(flVelocityImpulse, m_flAngularVelocityImpulse, entityLocalSpaceToWorldSpace);
        }
    }

    function UpdateSoundPosition()
    {
        if (m_hSoundEffect.IsValid() && m_hEntity.IsValid())
            m_hSoundEffect.__KeyValueFromString("origin", kvstr(m_hEntity.GetOrigin()));
            // m_hSoundEffect.SetOrigin(m_hEntity.GetOrigin());
    }

    function AddPropelPoint(entityInvertedMatrix, entityInvertedRotationMatrix, vecTargetCenter, vecImpactEnd, vecImpactStart, bBurnDamage)
    {
        local vecImpactPoint = vecImpactEnd;

        local vecImpactDir = (vecImpactPoint - vecImpactStart).Normalize();
        local vecCenterDir = (vecTargetCenter - vecImpactPoint).Normalize();

        local vecAngularDirection = vecImpactDir.Cross(vecCenterDir).Normalize();

        // FIXME: completely wrong
        local theta = acos(vecCenterDir.Dot(vecImpactDir)); // if further from center then more force

        if (theta > PI / 2)
            theta = PI - theta;

        theta /= PI / 2;

        local vecLocalImpactPoint = entityInvertedMatrix * vecImpactPoint; // transform to local space
        local vecLocalImpactDir = entityInvertedRotationMatrix * vecImpactDir;
        local vecLocalAngularDirection = entityInvertedRotationMatrix * vecAngularDirection;

        local propel_point = CSPPPropelPoint(m_hEntity,
                                        vecLocalImpactPoint,
                                        vecLocalImpactDir,
                                        vecLocalAngularDirection,
                                        vecImpactPoint,
                                        vecImpactDir,
                                        theta,
                                        m_iPropType
                                        bBurnDamage);
        
        m_aPropelPoints.push(propel_point);
    }

    function GetPropelPoints() { return m_aPropelPoints.len(); }

    function GetPropelTime() { return m_flStartTime; }

    function CanExplode() { return m_bCanExplode; }

    function ForbidExploding() { m_bCanExplode = false; }

    function GetOwnerPlayer() { return m_hOwnerPlayer; }

    function GetEntity() { return m_hEntity; }

    function GetPropType() { return m_iPropType; }

    function IsValid() { return m_hEntity.IsValid(); }

    m_hEntity = null;
    m_hOwnerPlayer = null;
    m_hSoundEffect = null;

    m_iPropType = null;
    m_bCanExplode = true;
    m_aPropelPoints = null;

    m_flStartTime = 0.0;
    m_flVelocityImpulse = 0.0;
    m_flAngularVelocityImpulse = 0.0;
}

class CSPPPropelPoint
{
    constructor(hOwnerEntity, vecImpactPoint, vecImpactDir, vecAngularDirection, vecImpactPointWorld, vecImpactDirWorld, flForceFraction, iPropType, bBurnDamage)
    {
        m_hOwnerEntity = hOwnerEntity;

        m_vecImpactPoint = vecImpactPoint;
        m_vecImpactDir = vecImpactDir;
        m_vecAngularDirection = vecAngularDirection;

        m_flForceFraction = flForceFraction;

        m_hParticleEffect = SpawnEntityFromTable("info_particle_system", {
            origin = vecImpactPointWorld
            start_active = 1
            effect_name = bBurnDamage ? g_SelfPropelledProps.FIRE_SPRAY : g_SelfPropelledProps.OXYGEN_SPRAY
            angles = kvstr(VectorToQAngle2(vecImpactDirWorld) * -1)
        });

        AttachEntity(hOwnerEntity, m_hParticleEffect);
    }

    function Clear()
    {
        if (m_hParticleEffect.IsValid())
            m_hParticleEffect.Kill();
    }

    function Simulate(flVelocityImpulse, flAngularVelocityImpulse, entityLocalSpaceToWorldSpace) // matrix
    {
        local vecImpactPoint = m_hOwnerEntity.GetOrigin() + (entityLocalSpaceToWorldSpace * m_vecImpactPoint);
        local vecImpactDir = entityLocalSpaceToWorldSpace * m_vecImpactDir;
        local vecAngularDirection = entityLocalSpaceToWorldSpace * m_vecAngularDirection;

        m_hOwnerEntity.ApplyLocalAngularVelocityImpulse(vecAngularDirection * m_flForceFraction * flAngularVelocityImpulse);
        m_hOwnerEntity.ApplyAbsVelocityImpulse(vecImpactDir * flVelocityImpulse);
    }

    function GetParticleEffect()
    {
        return m_hParticleEffect;
    }

    m_hOwnerEntity = null;
    m_hParticleEffect = null;
    m_flForceFraction = null;
    
    // in local space
    m_vecImpactPoint = null;
    m_vecImpactDir = null;
    m_vecAngularDirection = null;
}

g_PluginSelfPropelledProps <- CPluginSelfPropelledProps();

g_SelfPropelledProps <-
{
    TYPE_PROPANE_TANK = 0
    TYPE_OXYGEN_TANK = 1

    PROPANE_TANK_CENTER_OFFSET = Vector(-6.890398, 7.331800, -0.257751)
    OXYGEN_TANK_CENTER_OFFSET = Vector(-1.924805, 0.007080, 17.011475)

    THRUSTER_SOUND = "PhysicsCannister.ThrusterLoop"
    FIRE_SPRAY = "fire_small_flameouts" // fire_small_02, fire_small_flameouts, fire_small_base, inferno_small_fire_2
    OXYGEN_SPRAY = "extinguisher_cloud"

    flVelocityImpulse = 30.0
    flAngularVelocityImpulse = 60.0
    flLifeTime = 5.0
    nMaxPropelPoints = 3

    vecBulletImpacts = []
    aPropelledProps = []

    OnWeaponFire = function(params)
    {
        ::g_SelfPropelledProps.vecBulletImpacts.clear();
    }

    OnBulletImpact = function(params)
    {
        ::g_SelfPropelledProps.vecBulletImpacts.push( Vector(params["x"], params["y"], params["z"]) );
    }

    OnAllowTakeDamage = function(applyDamage, tDamageInfo) // hooked scriptedmode's function
    {
        // OnWeaponFire -> OnBulletImpact [x times] -> OnAllowTakeDamage
        this = ::g_SelfPropelledProps;

        if (tDamageInfo["DamageType"] & DMG_BULLET && !(tDamageInfo["DamageType"] & DMG_BLAST))
        {
            if (tDamageInfo["Victim"] && tDamageInfo["Attacker"] && tDamageInfo["Victim"].GetClassname() == "prop_physics" && tDamageInfo["Attacker"].GetClassname() == "player")
            {
                local sModel = NetProps.GetPropString(tDamageInfo["Victim"], "m_ModelName");

                local bPropaneTank = (sModel == "models/props_junk/propanecanister001a.mdl");
                local bOxygenTank = (!bPropaneTank && sModel == "models/props_equipment/oxygentank01.mdl");

                if (bPropaneTank || bOxygenTank)
                {
                    OnHitProp(tDamageInfo["Attacker"],
                            tDamageInfo["Victim"],
                            tDamageInfo["Attacker"].EyePosition(),
                            bPropaneTank ? TYPE_PROPANE_TANK : TYPE_OXYGEN_TANK,
                            bPropaneTank || tDamageInfo["DamageType"] & DMG_BURN);

                    applyDamage.value = false;
                    return HOOK_STOP;
                }
            }
        }

        return HOOK_CONTINUE;
    }

    OnHitProp = function(hInflictor, hEntity, vecAttackOrigin, iPropType, bBurnDamage)
    {
        this = ::g_SelfPropelledProps;

        local vecCenter;
        local worldSpaceToEntityLocalSpace = matrix3x4();

        if (iPropType == TYPE_PROPANE_TANK) // get center of the prop
            vecCenter = hEntity.GetOrigin() + RotatePosition(Vector(0, 0, 0), hEntity.GetAngles(), PROPANE_TANK_CENTER_OFFSET);
        else
            vecCenter = hEntity.GetOrigin() + RotatePosition(Vector(0, 0, 0), hEntity.GetAngles(), OXYGEN_TANK_CENTER_OFFSET);
        
        worldSpaceToEntityLocalSpace = worldSpaceToEntityLocalSpace.SetTransformation(vecCenter, hEntity.GetAngles()).Invert();

        foreach (point in vecBulletImpacts)
        {
            local bImpactPoint = false;

            local vecLocalPoint = worldSpaceToEntityLocalSpace.VectorTransform(point);
            local flImpactRadiusSqr = vecLocalPoint.Length2DSqr();
            local flImpactHeight = vecLocalPoint.z;

            if (iPropType == TYPE_PROPANE_TANK)
            {
                if (flImpactRadiusSqr <= 48.3025 && Math.Between(flImpactHeight, -10.568, 10.3)) // sqrt(48.3025) = 6.95
                {
                    bImpactPoint = true;
                }
            }
            else if (flImpactRadiusSqr <= 8.38682 && Math.Between(flImpactHeight, -16.9505, 14.8646)) // sqrt(8.38682) = 2.896
            {
                bImpactPoint = true;
            }

            if (bImpactPoint)
                AddPropelPointToProp(hInflictor, hEntity, vecCenter, point, vecAttackOrigin, iPropType, bBurnDamage);
        }
    }

    AddPropelPointToProp = function(hInflictor, hEntity, vecTargetCenter, vecImpactPoint, vecAttackOrigin, iPropType, bBurnDamage)
    {
        this = ::g_SelfPropelledProps;

        local hProp = null;

        foreach (prop in aPropelledProps)
        {
            if (prop.GetEntity() == hEntity)
            {
                if (nMaxPropelPoints > 0 && prop.GetPropelPoints() >= nMaxPropelPoints)
                    return;

                hProp = prop;
                break;
            }
        }

        if (!hProp)
        {
            hProp = CSelfPropelledProp(hEntity, hInflictor, iPropType);
            aPropelledProps.push(hProp);
        }

        local entityInvertedMatrix = matrix3x4().WorldSpaceToEntityLocalSpace(hEntity);
        local entityInvertedRotationMatrix = clone entityInvertedMatrix;

        entityInvertedRotationMatrix.ResetTranslation();

        hProp.AddPropelPoint(entityInvertedMatrix, entityInvertedRotationMatrix, vecTargetCenter, vecImpactPoint, vecAttackOrigin, bBurnDamage);
    }

    Think = function()
    {
        this = ::g_SelfPropelledProps;

        for (local i = 0; i < aPropelledProps.len(); ++i)
        {
            local hProp = aPropelledProps[i];

            if (!hProp.IsValid())
            {
                hProp.Clear();
                aPropelledProps.remove(i);
                --i;
            }
            else if (flLifeTime > 0.0 && hProp.CanExplode() && Time() - hProp.GetPropelTime() >= flLifeTime)
            {
                hProp.GetEntity().TakeDamage(1e6, DMG_BLAST, hProp.GetOwnerPlayer());

                if (hProp.GetPropType() == TYPE_OXYGEN_TANK)
                {
                    hProp.ForbidExploding();
                    hProp.Simulate();
                    hProp.UpdateSoundPosition();
                }
                else
                {
                    hProp.Clear();
                    aPropelledProps.remove(i);
                    --i;
                }
            }
            else if (flLifeTime > 0.0 && Time() - hProp.GetPropelTime() >= flLifeTime + 1.95)
            {
                hProp.Clear();
                aPropelledProps.remove(i);
                --i;
            }
            else
            {
                hProp.Simulate();
                hProp.UpdateSoundPosition();
            }
        }
    }
};

g_PluginSelfPropelledProps.Load();

*/