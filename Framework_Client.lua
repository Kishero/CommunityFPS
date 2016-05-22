																																																																																																		--[[
					  ____                                      _ _           _____ ____  ____  
				|	 / ___|___  _ __ ___  _ __ ___  _   _ _ __ (_) |_ _   _  |  ___|  _ \/ ___| 	|
				|	| |   / _ \| '_ ` _ \| '_ ` _ \| | | | '_ \| | __| | | | | |_  | |_) \___ \ 	|
				|	| |__| (_) | | | | | | | | | | | |_| | | | | | |_| |_| | |  _| |  __/ ___) |	|
				|	 \____\___/|_| |_| |_|_| |_| |_|\__,_|_| |_|_|\__|\__, | |_|   |_|   |____/ 	|
					                                                  |___/                     
						

																																																																																														]]

local settings = { 
	JumpEnabled = true;
}

local debug = {
	Print = true;
}

local logF = print
local function print(...)
	if debug.Print then
		logF(...)
	end 
end

local function gs(s) return game:GetService(s.."Service") end -- This is the definition of lazy, I love me
local rs = gs'Run'
local uis = gs'UserInput'
local cp = game:GetService'ContentProvider'

local wfc = game.WaitForChild
local ffc = game.FindFirstChild

local plr = game.Players.LocalPlayer
local mouse = plr:GetMouse()
local cam = game.Workspace.CurrentCamera
local storage = game.ReplicatedStorage
local char, humanoid, torso, hrp, head, lhip, rhip --Likely no need for this as we will be creating a custom humanoid


-- Shortcuts
local v3 			= Vector3.new
local nv			= v3()
local v2			= Vector2.new
local nv2			= v2()
local cf			= CFrame.new
local nc			= cf()
local ca			= CFrame.Angles
local ffa			= CFrame.fromAxisAngle
local ud			= UDim.new
local nud			= ud()
local ud2			= UDim2.new
local nud2			= ud2()
local dot 			= function(x, y) 		return x.x * y.x + x.y * y.y + x.z * y.z end
local dot2			= function(x, y) 		return x.x * y.x + x.y * y.y end
local floor			= function(x) 			return x - x % 1 end
local ceil			= function(x) 			return x + (1 - x % 1) end
local round			= function(x) 			return floor(x + .5) end
local lerp			= function(x, y, a) 	return x + (y - x) * a end
local clamp			= function(n, l, h) 	if n < l then return l end if n > h then return h end return n end
local random		= math.random
local sort			= table.sort
local atan2			= math.atan2
local huge			= math.huge
local cos			= math.cos
local sin			= math.sin
local tan			= math.tan
local rad			= math.rad
local abs			= math.abs
local acos			= math.acos
local asin			= math.asin
local atan			= math.atan
local atan2			= math.atan2
local pi			= math.pi
local tau			= pi*2
local e				= 2.71828183
local randomseed	= math.randomseed
local setmetatable	= setmetatable
local tick			= tick
local new 			= Instance.new
local ray			= Ray.new
local raycast		= function(...) return game.Workspace:FindPartOnRayWithIgnoreList(...) end

local drawray, draw, tramsformModel
do -- extra
	function drawray(ray)
		local part = Instance.new("Part", workspace);
		part.FormFactor = Enum.FormFactor.Custom;
		part.Material = Enum.Material.Neon;
		part.TopSurface = Enum.SurfaceType.Smooth;
		part.BottomSurface = Enum.SurfaceType.Smooth;
		part.Size = Vector3.new(1, ray.Direction.magnitude, 1);
		part.CFrame = CFrame.new(ray.Origin + ray.Direction/2, ray.Origin + ray.Direction) * CFrame.Angles(pi/2,0,0);
		part.Anchored = true;
		part.CanCollide = false;
		part.BrickColor = BrickColor.Yellow();
		part.Transparency = .2
		spawn(function()
			rs.RenderStepped:wait()
			part:Destroy()
		end)
	end
	
	function draw(p, c)
		local part =  Instance.new("Part", game.Workspace)
		part.Size = Vector3.new(.2,.2,.2)
		part.BrickColor = BrickColor.new(c)
		part.Anchored = true
		part.CanCollide = false
		part.CFrame = CFrame.new(p)
		spawn(function()
			rs.RenderStepped:wait()
			part:Destroy()
		end)
	end
	
	
	-- @EgoMoose
	function transformModel(model, cframe, center) -- Same errors as SetPrimaryPartCFrame;
		local center = center or (model.PrimaryPart and model.PrimaryPart.CFrame or model:GetModelCFrame())
		for _, child in ipairs(model:GetChildren()) do
			if child:IsA("BasePart") then
				child.CFrame = cframe:toWorldSpace(center:toObjectSpace(child.CFrame))
			end
			transformModel(child, cframe, center)
		end
	end
end


randomseed(tick()) for i = 1, 4 do random() end -- Makes math.random even more 'random'

-- Modules
local time 		= {}
local mathF		= {} -- A math library for math functions
local particle	= {}
local player 	= {}
local Game 		= {}
local run 		= {}

do -- Time Scope
	local self = time
	local lastFrame = tick()
	local n = 0
	local tick = tick
	
	self.deltaTime = function() -- Generic DT
		local rdt = tick() - lastFrame
		return rdt < .009 and rdt or .001 --Fix the bug that occurs when you tab out
	end
	
	self.smoothDeltaTime = function() -- Theoretically should produce more smooth results
		return time.deltaTime() + (n)/(n + 1)
	end
	
	self.step = function () -- This is called every time the framework steps or updates
		lastFrame = tick()
		n = n + 1 -- This should maybe be added on the DT and SDT functions only?
	end
	
end;

do -- Mathf Scope
	local self = mathF
	local ptos = nc.pointToObjectSpace
	
	self.IK = function(r0, r1, c, p) --Could be more optimized and accurate, generic 2-chain only
		local t = ptos(c, p)
		local tx, ty, tz = t.x, t.y, t.z
		
		local d = (tx * tx + ty * ty + tz * tz)^.5 --Whoop inverse square stuff
		local nx, ny, nz = tx/d, ty/d, tz/d
		d = r0 + r1 < d and r0 + r1 or d
		local l = (r1 * r1 - r0 * r0 - d * d)/(2 * r0 * d)
		local h = (1 - l * l)^.5
		local a = atan2(-h, -l)
		
		local j0 = c * cf(nv, t) * ca(a, 0, 0)
		return j0, j0 * cf(0, 0, -r0) * ca(-2 * a, 0, 0)
	end

	self.BulletInterp= function(p0,v0,a)
		local p = p0 + ((a) * time.deltaTime()) + (v0 * time.deltaTime())
		local v = v0 + (a * time.deltaTime())
		return p,v
	end

	self.drawParticle= function(p0,p1)
		local p0,p0V=cam:WorldToScreenPoint(p0)
		local p1,p1V=cam:WorldToScreenPoint(p1)
		local p1r=ray(cam.CoordinateFrame.p,(p1-cam.CoordinateFrame.p).Unit*(p1-cam.CoordinateFrame.p).Magnitude*10)
		local v=workspace:FindPartOnRay(p1r,plr.Character) --Make sure it is not obstructed
		
		local p=Instance.new("Frame",plr.PlayerGui.particle)
		p.BorderSizePixel=0
		p.BackgroundColor3=Color3.new(.5,.5,.3)
		--p.Rotation=atan2(p1.y-p0.y,p1.x-p0.x)/(pi/180)
		--p.Size=ud2(0,p0.x-p1.x,0,p0.y-p1.y/4)
 		p.Size=ud2(0,4,0,4)
		p.Position=not p0V and not p0V and ud2(-100,0,0,0) or not p1V and ud2(-100,0,0,0) or v and ud2(-100,0,0) or ud2(0,p1.x,0,p1.y)
		spawn(function()
			rs.RenderStepped:wait() p:Destroy()
		end)
	end
	
	--Test stuff
	spawn(function() --Messy quick shit
		for i=1,1000 do
			wait(1)
			spawn(function()
				local t=tick()
				local p0=v3(0,25,0)
				local p1=p0
				local v0=((game.Workspace.d.CFrame.lookVector)*-4000)
				rs.RenderStepped:connect(function()
					if tick()-t > 20 then return end
					local newp,newv = self.BulletInterp(p0,v0,v3(0,-75,0))
					--print(newp,"	",newv)
					p0=newp
					v0=newv
					
					local r=Ray.new(p0,(p1-p0).Unit*(p0-p1).Magnitude)
					--drawray(r)
					self.drawParticle(p0,p1)
					p1=p0
				end)
			end)
			wait(1)
		end
	end)

	spawn(function() 
		local i = 1 
		while wait() do
			local a = game.Workspace.p0.CFrame
			local b = game.Workspace.t.Position
			
			game.Workspace.t.CFrame = cf(b + v3(0,0,sin(i)))
			i = i + .12
			
			local c0, c1 = mathF.IK(4,4,a,b)
			game.Workspace.p1.CFrame = game.Workspace.p1.CFrame:lerp(c0*cf(0,0,-2), time.smoothDeltaTime()*time.deltaTime()*400) --Smooth hybrid delta time, looks good but not as good as simply smooth delta; nice to show off the example
			game.Workspace.p2.CFrame = game.Workspace.p2.CFrame:lerp(c1*cf(0,0,-2), time.smoothDeltaTime()*time.deltaTime()*400)
		end
	end)

end;

--Partilce effect scope
do
	
end;

do -- Player Scope
	local clone = game.clone
	local self = player
	
	local user = game.Players.LocalPlayer
	local chr = wfc(game.Workspace,user.Name)
	
	-- Gun subscope generator thingy
	self.loadGun = function(prop, model)
		local self = {}
		
		local rate = prop.rate or 400
		local stored= prop.stored or 1024
		local mag = prop.mag or 32 -- I didn't add chamber stuff as I don't 100% know how that works
		
		local model=model or prop.model and prop.model:clone() or Instance.new("Part")
		
		return self
	end

end;

do -- Game Scope
	local self = Game
	
	local currentGunp = 0 -- 0=None,1=prim,2=sec,3=knife
	local currentGun
	
	self.LoadGun = function(p, dat, model)
		currentGun = player.loadGun({})
		currentGunp = p
	end
end;

do -- Run Scope
	local framework = { -- Run everything, note that this should be in a prioritized order
		time;		
	}
	
	rs.RenderStepped:connect(function() -- Could be optimized?
		for _,v in pairs(framework) do
			v.step()
		end
	end)
	
end;

Game.LoadGun(1)
