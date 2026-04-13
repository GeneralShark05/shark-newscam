--- Camera Shit
--FUNCTIONS--
local function HideHUDThisFrame()
    HideHelpTextThisFrame()
    HideHudAndRadarThisFrame()
    for i = 1, 19 do
        HideHudComponentThisFrame(i)
    end
end

---------------------------------------------------------------------------
-- Toggling Cam --
---------------------------------------------------------------------------
local fovMax = 50.0
local fovMin = 1.0
local zoomSpeed = 1.5
local speedX = 10.0
local speedZ = 10.0
local startingFov = (fovMax + fovMin) * 0.5
local fov = startingFov

local function CheckInputRotation(cam, zoomvalue)
    local rightAxisX = GetDisabledControlNormal(0, 220)
    local rightAxisY = GetDisabledControlNormal(0, 221)
    local rotation = GetCamRot(cam, 2)
    if rightAxisX ~= 0.0 or rightAxisY ~= 0.0 then
        NewZ = rotation.z + rightAxisX * -1.0 * (speedZ) * (zoomvalue + 0.1)
        NewX = math.max(math.min(20.0, rotation.x + rightAxisY * -1.0 * (speedX) * (zoomvalue + 0.1)), -89.5)
        SetCamRot(cam, NewX, 0.0, NewZ, 2)
    end
end

local function HandleZoom(cam)
    if IsDisabledControlPressed(1, 15) then
        fov = math.max(fov - zoomSpeed, fovMin)
    end
    if IsDisabledControlPressed(1, 16) then
        fov = math.min(fov + zoomSpeed, fovMax)
    end
    local currentFov = GetCamFov(cam)
    if math.abs(fov - currentFov) < 0.1 then
        fov = currentFov
    end
    SetCamFov(cam, currentFov + (fov - currentFov) * 0.05)
end

local holdingBMic = false
local holdingMic = false
local holdingCam = false
local camModel = "prop_v_cam_01"
local camAnimDict = "missfinale_c2mcs_1"
local camAnimName = "fin_c2_mcs_1_camman"
local camNetID = nil
local camLocalObj = nil
local engagedCamera = false
local freecam
local function exitCamera()
    PlaySoundFrontend(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", false)
    engagedCamera = false
    fov = startingFov
    RenderScriptCams(false, false, 0, true, false)
end

local headlineText = "Breaking News"
local topText = "Los Santos, SA / Weazel News Exclusive"
local subtitleText = "We bring you the LATEST NEWS live as it happens"

local function openNewsEditor()
    local input = lib.inputDialog('Weazel News Editor', {
        {
            type = 'input',
            label = 'Message',
            description = 'Main message text',
            placeholder = 'Breaking News',
            default = headlineText,
            required = true,
            min = 1,
            max = 100
        },
        {
            type = 'input',
            label = 'Title',
            description = 'Top banner title',
            placeholder = 'Los Santos, SA / Weazel News Exclusive',
            default = topText,
            required = true,
            min = 1,
            max = 100
        },
        {
            type = 'textarea',
            label = 'Bottom Text',
            description = 'Bottom ticker / subtitle text',
            placeholder = 'We bring you the LATEST NEWS live as it happens',
            default = subtitleText,
            required = true,
            min = 1,
            max = 200
        }
    })

    if not input then return end

    headlineText = input[1]
    topText = input[2]
    subtitleText = input[3]

    lib.notify({
        title = 'Weazel News',
        description = 'News text updated successfully.',
        type = 'success'
    })
end

RegisterCommand('editnews', function()
    openNewsEditor()
end, false)

exports('editnews', function()
    openNewsEditor()
end)

local function hideFrameworkHud(state)
    --exports["jg-hud"]:toggleHud(not state)
    --ExecuteCommand('hud')
    if state then
        --TriggerEvent('qbx_hud:client:hideHud')
    else
        --TriggerEvent('qbx_hud:client:showHud')
    end
end

RegisterNetEvent("shark-newscam:toggleCam")
AddEventHandler("shark-newscam:toggleCam", function()
    local ped = PlayerPedId()
    if not holdingCam then
        RequestModel(GetHashKey(camModel))
        while not HasModelLoaded(GetHashKey(camModel)) do
            Wait(100)
        end

        local plyCoords = GetOffsetFromEntityInWorldCoords(ped, 0.0, 0.0, -5.0)
        local cameraObject = CreateObject(GetHashKey(camModel), plyCoords.x, plyCoords.y, plyCoords.z, true, true, true)
        while not DoesEntityExist(cameraObject) do
            Wait(1000)
        end
        local networkID = ObjToNet(cameraObject)
        SetNetworkIdExistsOnAllMachines(networkID, true)
        NetworkSetNetworkIdDynamic(networkID, true)
        SetNetworkIdCanMigrate(networkID, false)
        AttachEntityToEntity(cameraObject, ped, GetPedBoneIndex(ped, 28422), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, true, true, false, true, 0, true)
        TaskPlayAnim(ped, 1.0, -1, -1, 50, 0, 0, 0, false, false, false) -- 50 = 32 + 16 + 2
        TaskPlayAnim(ped, camAnimDict, camAnimName, 1.0, -1, -1, 50, 0, false, false, false)
        camNetID = networkID
        camLocalObj = cameraObject
        holdingCam = true
        lib.notify({
            id = 'shark-tools:camInfo',
            description = 'To enter News cam press E \nTo Enter Movie Cam press M',
            type = 'inform'
        })

        CreateThread(function()
            while holdingCam do
                Wait(0)
                while not HasAnimDictLoaded(camAnimDict) do
                    RequestAnimDict(camAnimDict)
                    Wait(100)
                end

                if not IsEntityPlayingAnim(PlayerPedId(), camAnimDict, camAnimName, 3) then
                    TaskPlayAnim(ped, 1.0, -1, -1, 50, 0, 0, 0, false, false, false) -- 50 = 32 + 16 + 2
                    TaskPlayAnim(ped, camAnimDict, camAnimName, 1.0, -1, -1, 50, 0, false, false, false)
                end

                DisablePlayerFiring(PlayerId(), true)
                DisableControlAction(0, 25, true) -- disable aim
                DisableControlAction(0, 44, true) -- INPUT_COVER
                DisableControlAction(0, 37, true) -- INPUT_SELECT_WEAPON
                DisableControlAction(1, 16, true)
                DisableControlAction(1, 15, true)
                SetCurrentPedWeapon(ped, GetHashKey("WEAPON_UNARMED"), true)
            end
            StopAnimTask(cache.ped, camAnimDict, camAnimName, 2.0)
            RemoveAnimDict(camAnimDict)
            DetachEntity(NetToObj(camNetID), true, true)
            DeleteEntity(NetToObj(camNetID))
            if DoesEntityExist(camLocalObj) then
                DeleteEntity(camLocalObj)
            end
            RemoveAnimDict(camAnimDict)
        end)
        CreateThread(function()
            local movieMode = false
            local newsMode = false
            local newsScaleform = nil
            freecam = nil
            while holdingCam do
                Wait(10)
                if IsControlJustPressed(1, 244) then
                    --movieMode = true
                    engagedCamera = true
                    hideFrameworkHud(true)
                elseif IsControlJustPressed(1, 38) then
                    newsMode = true
                    engagedCamera = true
                    hideFrameworkHud(true)

                    newsScaleform = RequestScaleformMovie("breaking_news")
                    while not HasScaleformMovieLoaded(newsScaleform) do
                        Wait(10)
                    end

                    PopScaleformMovieFunctionVoid()
                    PushScaleformMovieFunction(newsScaleform, "breaking_news")
                    PopScaleformMovieFunctionVoid()
                    BeginScaleformMovieMethod(newsScaleform, 'SET_TEXT')
                    PushScaleformMovieMethodParameterString(headlineText)
                    PushScaleformMovieMethodParameterString(subtitleText)
                    EndScaleformMovieMethod()
                    BeginScaleformMovieMethod(newsScaleform, 'SET_SCROLL_TEXT')
                    PushScaleformMovieMethodParameterInt(0) -- top ticker
                    PushScaleformMovieMethodParameterInt(0) -- Since this is the first string, start at 0
                    PushScaleformMovieMethodParameterString(topText)
                    EndScaleformMovieMethod()
                    BeginScaleformMovieMethod(newsScaleform, 'DISPLAY_SCROLL_TEXT')
                    PushScaleformMovieMethodParameterInt(0) -- Top ticker
                    PushScaleformMovieMethodParameterInt(0) -- Index of string
                    EndScaleformMovieMethod()
                end
                if engagedCamera then
                    freecam = CreateCam("DEFAULT_SCRIPTED_FLY_CAMERA", true)
                    AttachCamToEntity(freecam, cameraObject, 0.25, 0, 0, true)
                    SetCamRot(freecam, 2.0, 1.0, GetEntityHeading(ped), 0)
                    SetCamFov(freecam, startingFov)
                    RenderScriptCams(true, false, 0, true, false)
                end

                while engagedCamera and not IsEntityDead(ped) do
                    if IsControlJustPressed(0, 177) then
                        exitCamera()
                        hideFrameworkHud(false)
                    end
                    SetEntityRotation(ped, 0, 0, NewZ, 2, true)

                    local zoomValue = (1.0 / (fovMax - fovMin)) * (fov - fovMin)
                    CheckInputRotation(freecam, zoomValue)
                    HandleZoom(freecam)
                    SetUseHiDof()
                    HideHUDThisFrame()

                    if newsMode then
                        DrawScaleformMovie(newsScaleform, 0.5, 0.63, 1.0, 1.0, 255, 255, 255, 255, 0)
                    end

                    local camHeading = GetGameplayCamRelativeHeading()
                    local camPitch = GetGameplayCamRelativePitch()
                    if camPitch < -70.0 then
                        camPitch = -70.0
                    elseif camPitch > 42.0 then
                        camPitch = 42.0
                    end
                    camPitch = (camPitch + 70.0) / 112.0

                    if camHeading < -180.0 then
                        camHeading = -180.0
                    elseif camHeading > 180.0 then
                        camHeading = 180.0
                    end
                    camHeading = (camHeading + 180.0) / 360.0

                    Citizen.InvokeNative(0xD5BB4025AE449A4E, ped, "Pitch", camPitch)
                    Citizen.InvokeNative(0xD5BB4025AE449A4E, ped, "Heading", camHeading * -1.0 + 1.0)

                    Wait(1)
                end
                if newsMode then
                    SetScaleformMovieAsNoLongerNeeded(newsScaleform)
                    newsMode = false
                end
                if IsControlJustPressed(0, 177) then
                    holdingCam = false
                    DestroyCam(freecam, false)
                    freecam = nil
                end
            end
        end)
    else
        holdingCam = false
    end
end)

---------------------------------------------------------------------------
-- Toggling Boom Mic --
---------------------------------------------------------------------------
local bMicNetId
local bMicModel = "prop_v_bmike_01"
local bMicAnimDict = "missfra1"
local bMicAnimName = "mcs2_crew_idle_m_boom"
RegisterNetEvent("shark-newscam:togglebmic")
AddEventHandler("shark-newscam:togglebmic", function()
    if not holdingBMic then
        RequestModel(GetHashKey(bMicModel))
        while not HasModelLoaded(GetHashKey(bMicModel)) do
            Wait(100)
        end

        local plyCoords = GetOffsetFromEntityInWorldCoords(cache.ped, 0.0, 0.0, -5.0)
        local bMicObject = CreateObject(GetHashKey(bMicModel), plyCoords.x, plyCoords.y, plyCoords.z, true, true, false)
        while not DoesEntityExist(bMicObject) do
            Wait(1000)
        end
        bMicNetId = ObjToNet(bMicObject)
        SetNetworkIdExistsOnAllMachines(bMicNetId, true)
        NetworkSetNetworkIdDynamic(bMicNetId, true)
        SetNetworkIdCanMigrate(bMicNetId, false)
        AttachEntityToEntity(bMicObject, cache.ped, GetPedBoneIndex(cache.ped, 28422), -0.08, 0.0, 0.0, 0.0, 0.0, 0.0, 1, 1, 0, 1, 0, 1)
        TaskPlayAnim(cache.ped, 1.0, -1, -1, 50, 0, 0, 0, false, false, false) -- 50 = 32 + 16 + 2
        TaskPlayAnim(cache.ped, bMicAnimDict, bMicAnimName, 1.0, -1, -1, 50, 0, 0, 0, 0)
        holdingBMic = true

        CreateThread(function()
            while holdingBMic do
                if holdingBMic then
                    while not HasAnimDictLoaded(bMicAnimDict) do
                        RequestAnimDict(bMicAnimDict)
                        Wait(100)
                    end

                    if not IsEntityPlayingAnim(PlayerPedId(), bMicAnimDict, bMicAnimName, 3) then
                        TaskPlayAnim(cache.ped, 1.0, -1, -1, 50, 0, 0, 0, false, false, false)
                        TaskPlayAnim(cache.ped, bMicAnimDict, bMicAnimName, 1.0, -1, -1, 50, 0, false, false, false)
                    end

                    DisablePlayerFiring(PlayerId(), true)
                    DisableControlAction(1, 16, true)
                    DisableControlAction(1, 15, true)
                    DisableControlAction(0, 25, true) -- disable aim
                    DisableControlAction(0, 44, true) -- INPUT_COVER
                    DisableControlAction(0, 37, true) -- INPUT_SELECT_WEAPON
                    SetCurrentPedWeapon(GetPlayerPed(-1), GetHashKey("WEAPON_UNARMED"), true)

                    if (cache.vehicle) or IsPedCuffed(GetPlayerPed(-1)) or holdingMic or holdingCam then
                        StopAnimTask(cache.ped, bMicAnimDict, bMicAnimName, 2.0)
                        RemoveAnimDict(bMicAnimDict)
                        DetachEntity(NetToObj(bMicNetId), true, true)
                        DeleteEntity(NetToObj(bMicNetId))
                        bMicNetId = nil
                        holdingBMic = false
                    end
                end
                Wait(100)
            end
        end)
    else
        StopAnimTask(cache.ped, bMicAnimDict, bMicAnimName, 2.0)
        RemoveAnimDict(bMicAnimDict)
        DetachEntity(NetToObj(bMicNetId), true, true)
        DeleteEntity(NetToObj(bMicNetId))
        bMicNetId = nil
        holdingBMic = false
    end
end)

---------------------------------------------------------------------------
-- Toggling the News Mic --
---------------------------------------------------------------------------
local micNetId
local micModel = 'p_ing_microphonel_01'
local micAnimDict = 'anim@heists@humane_labs@finale@keycards'
local micAnimName = 'ped_a_enter_loop'

RegisterNetEvent("shark-newscam:togglemic")
AddEventHandler("shark-newscam:togglemic", function()
    if not holdingMic then
        RequestModel(GetHashKey(micModel))
        while not HasModelLoaded(GetHashKey(micModel)) do
             Wait(100)
        end
		
		while not HasAnimDictLoaded(micAnimDict) do
			RequestAnimDict(micAnimDict)
			Wait(100)
		end

        local plyCoords = GetOffsetFromEntityInWorldCoords(cache.ped, 0.0, 0.0, -5.0)
        local micObject = CreateObject(GetHashKey(micModel), plyCoords.x, plyCoords.y, plyCoords.z, 1, 1, 1)
        while not DoesEntityExist(micObject) do
            Wait(1000)
        end
        local netid = ObjToNet(micObject)
        SetNetworkIdExistsOnAllMachines(netid, true)
        NetworkSetNetworkIdDynamic(netid, true)
        SetNetworkIdCanMigrate(netid, false)
        AttachEntityToEntity(micObject, cache.ped, GetPedBoneIndex(cache.ped, 4154), -0.0, 0.02, 0.07, 0.0, 0.0, 60.0, true, true, false, true, 0, false)
        TaskPlayAnim(cache.ped, 1.0, -1, -1, 50, 0, 0, 0, 0) -- 50 = 32 + 16 + 2
        TaskPlayAnim(cache.ped, micAnimDict, micAnimName, 1.0, -1, -1, 50, 0, 0, 0, 0)
        micNetId = netid
        holdingMic = true

        CreateThread(function()
            while holdingMic do
                if holdingMic then
                    while not HasAnimDictLoaded(micAnimDict) do
                        RequestAnimDict(micAnimDict)
                        Wait(100)
                    end

                    if not IsEntityPlayingAnim(PlayerPedId(), micAnimDict, micAnimName, 3) then
                        TaskPlayAnim(cache.ped, 1.0, -1, -1, 50, 0, 0, 0, false, false, false)
                        TaskPlayAnim(cache.ped, micAnimDict, micAnimName, 1.0, -1, -1, 50, 0, 0, 0, 0)
                    end

                    DisablePlayerFiring(PlayerId(), true)
                    DisableControlAction(1, 16, true)
                    DisableControlAction(1, 15, true)
                    DisableControlAction(0, 25, true) -- disable aim
                    DisableControlAction(0, 44, true) -- INPUT_COVER
                    DisableControlAction(0, 37, true) -- INPUT_SELECT_WEAPON
                    SetCurrentPedWeapon(GetPlayerPed(-1), GetHashKey("WEAPON_UNARMED"), true)

                    if (cache.vehicle) or IsPedCuffed(GetPlayerPed(-1)) or holdingBMic or holdingCam then
                        StopAnimTask(cache.ped, micAnimDict, micAnimName, 2.0)
                        RemoveAnimDict(micAnimDict)
                        DetachEntity(NetToObj(micNetId), true, true)
                        DeleteEntity(NetToObj(micNetId))
                        micNetId = nil
                        holdingMic = false
                    end
                end
                Wait(100)
            end
        end)
    else
        StopAnimTask(cache.ped, micAnimDict, micAnimName, 2.0)
        RemoveAnimDict(micAnimDict)
        DetachEntity(NetToObj(micNetId), true, true)
        DeleteEntity(NetToObj(micNetId))
        micNetId = nil
        holdingMic = false
    end
end)