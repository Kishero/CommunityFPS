																																																																																																		--[[
					  ____                                      _ _           _____ ____  ____  
				|	 / ___|___  _ __ ___  _ __ ___  _   _ _ __ (_) |_ _   _  |  ___|  _ \/ ___| 	|
				|	| |   / _ \| '_ ` _ \| '_ ` _ \| | | | '_ \| | __| | | | | |_  | |_) \___ \ 	|
				|	| |__| (_) | | | | | | | | | | | |_| | | | | | |_| |_| | |  _| |  __/ ___) |	|
				|	 \____\___/|_| |_| |_|_| |_| |_|\__,_|_| |_|_|\__|\__, | |_|   |_|   |____/ 	|
					                                                  |___/                     
						

																																																																																														]]

local settings = { --YellowTide added this, I am unsure what it is for
	JumpEnabled = true;
}

local debug = { --Debug settings
	Print = true; --Allow output printing
}

local logF = print
local function print(...) --Custom log function
	if debug.Print then
		logF(...)
	end 
end

local function gs(s) return game:GetService(s.."Service") end -- This is the definition of lazy, I love me
local rs = gs'Run' --Run service
local uis = gs'UserInput' --User input service
--local cp = gs'ContentProvider' --CP service

local wfc = game.WaitForChild --WaitForChild
local ffc = game.FindFirstChild --FindFirstChild

local plr = game.Players.LocalPlayer --The user
local mouse = plr:GetMouse() --The player's mouse [Depricated? Use UIS.]
local cam = game.Workspace.CurrentCamera --Client's camera
local storage = game.ReplicatedStorage --Rep storage
local char, humanoid, torso, hrp, head, lhip, rhip --Likely no need for this as we will be creating a custom humanoid


-- Shortcuts
local clone 		= game.clone

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
local deg			= pi/180
local randomseed	= math.randomseed
local setmetatable	= setmetatable
local tick			= tick
local new 			= Instance.new
local ray			= Ray.new
local raycast		= function(...) return game.Workspace:FindPartOnRayWithIgnoreList(...) end
local ptos 			= nc.pointToObjectSpace
local tos			= nc.toObjectSpace

local drawray, draw, tramsformModel, weldModel
do -- Debug funcs
	function drawray(ray) --Render a ray
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
	
	function draw(p, c) --Draw a part with a specific color at a specific location
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
	--Move a model
	function transformModel(model, cframe, center) -- Same errors as SetPrimaryPartCFrame;
		local center = center or (model.PrimaryPart and model.PrimaryPart.CFrame or model:GetModelCFrame())
		for _, child in ipairs(model:GetChildren()) do
			if child:IsA("BasePart") then
				child.CFrame = cframe:toWorldSpace(center:toObjectSpace(child.CFrame))
			end
			transformModel(child, cframe, center)
		end
	end
	
	function weldModel(model,basepart)
		local weldcframes={}
		local children=model:GetChildren()
		basepart=basepart
		local welds={}
		welds[0]=basepart
		local basecframe=basepart and basepart.CFrame
		for i=1,#children do
			if children[i]:IsA("BasePart") then
				weldcframes[i]=tos(basecframe,children[i].CFrame)
			end
		end
		for i=1,#children do
			if children[i]:IsA("BasePart") then
				local newweld=new("Motor6D",basepart)
				newweld.Part0=basepart
				newweld.Part1=children[i]
				newweld.C0=weldcframes[i]
				welds[i]=newweld
				children[i].Anchored=false
			end
		end
		basepart.Anchored=false
		return welds
	end
	
end


randomseed(tick()) for i = 1, 4 do random() end -- Makes math.random even more 'random'

-- Modules
local time 		= {} -- We are the time gods (This is for time related functions)
local mathF		= {} -- A math library for math functions
local particle	= {} -- Particle effect functions
local player 	= {} -- Player logic
local Game 		= {} -- Game logic
local run 		= {} -- Runs all code

do -- Time Scope
	local self = time --When I set self=[module name] I make the module quicker to reference and give it a more universal name
	local lastFrame = tick() --The time in which the previous frame existed at
	local n = 0	--Number of DTs or frames that have passed
	local tick = tick --Quicker reference to tick
	
	self.deltaTime = function() -- Generic DT
		local rdt = tick() - lastFrame --Easy, current frame time - last frame time = current frame delay or delta time
		return rdt < .009 and rdt or .001 --Fix the bug that occurs when you tab out
	end
	
	self.smoothDeltaTime = function() -- Theoretically should produce more smooth results
		return time.deltaTime() + (n)/(n + 1) --SDT = dt + n/n+1, this results in a less accurate but more usable number
	end
	
	self.step = function () -- This is called every time the framework steps or updates
		lastFrame = tick() --Reset the previous frame
		n = n + 1 -- This should maybe be added on the DT and SDT functions only?
	end
	
end;

do -- Mathf Scope
	local self = mathF
	
	self.IK = function(r0, r1, c, p) --Could be more optimized and accurate, generic 2-chain IK only
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

	self.BulletInterp= function(p0,v0,a) --Simple bullet physics, this interpolates the position and velocity by using the previous position and velocity
		local p = p0 + ((a) * time.deltaTime()) + (v0 * time.deltaTime())
		local v = v0 + (a * time.deltaTime())
		return p,v
	end
	
	--Test IK
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

--Particle effect scope
do
	local self=particle
	
	local frames={} --Free frames
	local rframes={} --Used frames
	
	self.drawParticle= function(p0,p1)
		local p0,p0V=cam:WorldToScreenPoint(p0) --Get the position on the screen for p0 and the current position
		local p1,p1V=cam:WorldToScreenPoint(p1)
		local p1r=ray(cam.CoordinateFrame.p,(p1-cam.CoordinateFrame.p).Unit*(p1-cam.CoordinateFrame.p).Magnitude*10)
		local v=workspace:FindPartOnRay(p1r,plr.Character) -- <- Make sure it is not obstructed ^
		
		--Recycle frames to use less cpu
		if #frames <1 then
			frames[1]=Instance.new("Frame",game.Players.LocalPlayer.PlayerGui.particle)
			frames[1].BorderSizePixel=0
			frames[1].BackgroundColor3=Color3.new(.5,.5,.3)
		end
		
		local pid=#frames
		local p=frames[pid]
		rframes[#rframes+1]=p
		table.remove(frames,pid)
		
		p.Visible=true
		
		-- v Need work
		--p.Rotation=atan2(p1.y-p0.y,p1.x-p0.x)/(pi/180)
		--p.Size=ud2(0,p0.x-p1.x,0,p0.y-p1.y/4)
		
 		p.Size=ud2(0,8,0,8)
		p.Position=((v or not p0V or not p1V) and ud2(-1,0,0,0) ) or ud2(0,p1.x,0,p1.y) --If obstructed then move off screen, else move to screen space
		
		spawn(function()
			rs.RenderStepped:wait() --Recycle v
			frames[#frames+1]=p
			p.Visible=false
		end)
	end
	
	--Test particle render and bullet interpolator
	uis.InputBegan:connect(function(i)
		if i.UserInputType==Enum.UserInputType.Keyboard then
			spawn(function()
				local t=tick()
				local p0=wfc(game.Workspace,"Test").Barrel.Position
				local v0=game.Workspace.Test.Barrel.CFrame.lookVector*1024
				while tick()-t<5 do
					local p1,v0=mathF.BulletInterp(p0,v0,v3(0,-9.83,0))
					self.drawParticle(p0,p1)
					p0=p1
					rs.RenderStepped:wait()
				end
			end)
		end
	end)

end;

do -- Player Scope
	local self = player
	
	local user = plr --Unneeded
	local chr = wfc(game.Workspace,user.Name) --Could be moved to the begininng of the script
	
	-- Gun subscope generator thingy
	self.loadGun = function(prop, model)
		local self = {} --Subscope data
		
		local rate = prop.rate or 400
		local stored= prop.stored or 1024
		local mag = prop.mag or 32 -- I didn't add chamber stuff as I don't 100% know how that works
		
		local model=model or error("NO GUN MODEL!")

		model.Handle.CFrame=cf(model.Handle.Position) -- Fail v
		weldModel(model,model.Handle) --Divise a way to fix any rotational errors
		model.Parent=game.Workspace
		
		local gOffset=prop.gOffset
		
		local shots={}
		
		self.step=function()
			model.Handle.CFrame=cam.CoordinateFrame*gOffset
		end
		
		return self
	end

end;

do -- Game Scope
	local self = Game
	
	local currentGunp = 0 -- 0=None,1=prim,2=sec,3=knife | The gun position in the inventory
	local currentGun --Array for the currently equipped gun
	
	self.LoadGun = function(p, dat, model) --Load a new gun
		currentGun = player.loadGun(dat,model)
		currentGunp = p
	end
	
	self.step=function()
		if currentGun and currentGun.step then
			currentGun.step()
		end
	end
end;

do -- Run Scope
	local framework = { -- Run everything, note that this should be in a prioritized order
		time;
		Game;
	}
	
	rs.RenderStepped:connect(function() -- Could be optimized?
		for _,v in pairs(framework) do
			v.step()
		end
	end)
	
end;

--Run code

Game.LoadGun(1,require(storage.Modules.Test),storage.Models.Test:Clone())
