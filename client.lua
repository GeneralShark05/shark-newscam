--- Camera Shit
--FUNCTIONS--
local function HideHUDThisFrame()
    HideHelpTextThisFrame()
    HideHudAndRadarThisFrame()
    HideHudComponentThisFrame(1)
    HideHudComponentThisFrame(2)
    HideHudComponentThisFrame(3)
    HideHudComponentThisFrame(4)
    HideHudComponentThisFrame(6)
    HideHudComponentThisFrame(7)
    HideHudComponentThisFrame(8)
    HideHudComponentThisFrame(9)
    HideHudComponentThisFrame(13)
    HideHudComponentThisFrame(11)
    HideHudComponentThisFrame(12)
    HideHudComponentThisFrame(15)
    HideHudComponentThisFrame(18)
    HideHudComponentThisFrame(19)
end

---------------------------------------------------------------------------
-- Toggling Cam --
---------------------------------------------------------------------------
local fov_max = 70.0
local fov_min = 5.0
local zoomspeed = 10.0
local speed_lr = 8.0
local speed_ud = 8.0
local fov = (fov_max + fov_min) * 0.5


local function CheckInputRotation(cam, zoomvalue)
    local rightAxisX = GetDisabledControlNormal(0, 220)
    local rightAxisY = GetDisabledControlNormal(0, 221)
    local rotation = GetCamRot(cam, 2)
    if rightAxisX ~= 0.0 or rightAxisY ~= 0.0 then
        NewZ = rotation.z + rightAxisX * -1.0 * (speed_ud) * (zoomvalue + 0.1)
        NewX = math.max(math.min(20.0, rotation.x + rightAxisY * -1.0 * (speed_lr) * (zoomvalue + 0.1)), -89.5)
        SetCamRot(cam, NewX, 0.0, NewZ, 2)
    end
end

local function HandleZoom(cam)
    if not (IsPedSittingInAnyVehicle(cache.ped)) then
        if IsControlJustPressed(0, 241) then
            fov = math.max(fov - zoomspeed, fov_min)
        end
        if IsControlJustPressed(0, 242) then
            fov = math.min(fov + zoomspeed, fov_max)
        end
        local current_fov = GetCamFov(cam)
        if math.abs(fov - current_fov) < 0.1 then
            fov = current_fov
        end
        SetCamFov(cam, current_fov + (fov - current_fov) * 0.05)
    else
        if IsControlJustPressed(0, 17) then
            fov = math.max(fov - zoomspeed, fov_min)
        end
        if IsControlJustPressed(0, 16) then
            fov = math.min(fov + zoomspeed, fov_max)
        end
        local current_fov = GetCamFov(cam)
        if math.abs(fov - current_fov) < 0.1 then
            fov = current_fov
        end
        SetCamFov(cam, current_fov + (fov - current_fov) * 0.05)
    end
end

local holdingCam = false
local camModel = "prop_v_cam_01"
local camanimDict = "missfinale_c2mcs_1"
local camanimName = "fin_c2_mcs_1_camman"
local camNetID = nil
local camLocalObj = nil
local engagedCamera = false
local function exitCamera()
    PlaySoundFrontend(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", false)
    engagedCamera = false
    fov = (fov_max + fov_min) * 0.5
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
        local cameraProp = CreateObject(GetHashKey(camModel), plyCoords.x, plyCoords.y, plyCoords.z, true, true, true)
        Wait(1000)
        local networkID = ObjToNet(cameraProp)
        SetNetworkIdExistsOnAllMachines(networkID, true)
        NetworkSetNetworkIdDynamic(networkID, true)
        SetNetworkIdCanMigrate(networkID, false)
        AttachEntityToEntity(cameraProp, ped, GetPedBoneIndex(ped, 28422), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, true, true, false, true, 0, true)
        TaskPlayAnim(ped, 1.0, -1, -1, 50, 0, 0, 0, false, false, false) -- 50 = 32 + 16 + 2
        TaskPlayAnim(ped, camanimDict, camanimName, 1.0, -1, -1, 50, 0, false, false, false)
        camNetID = networkID
        camLocalObj = cameraProp
        holdingCam = true
        lib.notify({
            id = 'shark-tools:camInfo',
            description = 'To enter News cam press E \nTo Enter Movie Cam press M',
            type = 'inform'
        })

        CreateThread(function()
            while holdingCam do
                Wait(0)
                while not HasAnimDictLoaded(camanimDict) do
                    RequestAnimDict(camanimDict)
                    Wait(100)
                end

                if not IsEntityPlayingAnim(PlayerPedId(), camanimDict, camanimName, 3) then
                    TaskPlayAnim(ped, 1.0, -1, -1, 50, 0, 0, 0, false, false, false) -- 50 = 32 + 16 + 2
                    TaskPlayAnim(ped, camanimDict, camanimName, 1.0, -1, -1, 50, 0, false, false, false)
                end

                DisablePlayerFiring(PlayerId(), true)
                DisableControlAction(0, 25, true) -- disable aim
                DisableControlAction(0, 44, true) -- INPUT_COVER
                DisableControlAction(0, 37, true) -- INPUT_SELECT_WEAPON
                SetCurrentPedWeapon(ped, GetHashKey("WEAPON_UNARMED"), true)
            end
            ClearPedSecondaryTask(ped)
            DetachEntity(NetToObj(camNetID), true, true)
            DeleteEntity(NetToObj(camNetID))
            if DoesEntityExist(camLocalObj) then
                DeleteEntity(camLocalObj)
            end
            RemoveAnimDict(camanimDict)
        end)
        CreateThread(function()
            local movieMode = false
            local newsMode = false
            local newsScaleform = nil
            local freecam = nil
            while holdingCam do
                Wait(10)

                if IsControlJustPressed(1, 244) then
                    movieMode = true
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
                    ---PushScaleformMovieFunction(scaleform, "security_camera")
                    ---PopScaleformMovieFunctionVoid()
                    AttachCamToEntity(freecam, cameraProp, 0.25, 0, 0, true)
                    SetCamRot(freecam, 2.0, 1.0, GetEntityHeading(ped), 0)
                    SetCamFov(freecam, fov)
                    RenderScriptCams(true, false, 0, true, false)
                end

                while engagedCamera and not IsEntityDead(ped) do
                    if IsControlJustPressed(0, 177) then
                        exitCamera()
                        hideFrameworkHud(false)
                    end
                    SetEntityRotation(ped, 0, 0, NewZ, 2, true)

                    local zoomvalue = (1.0 / (fov_max - fov_min)) * (fov - fov_min)
                    CheckInputRotation(freecam, zoomvalue)

                    HandleZoom(freecam)
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
                end
            end
        end)
    else
        holdingCam = false
    end
end)
