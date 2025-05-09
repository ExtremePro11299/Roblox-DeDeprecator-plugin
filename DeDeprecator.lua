--!strict
local toolbar=plugin:CreateToolbar("DeDeprecator")
local deDeprecatorB=toolbar:CreateButton("DeDeprecate selected","DeDeprecate the selected objects.","rbxassetid://138146368324277")
deDeprecatorB.Enabled=false
deDeprecatorB.ClickableWhenViewportHidden=true
local infoB=toolbar:CreateButton("Supported objects","View what types of objects are supported","rbxassetid://17829948066")
infoB.ClickableWhenViewportHidden=true
local infoM=plugin:CreateDockWidgetPluginGui("DeDeprecatorInfo",DockWidgetPluginGuiInfo.new(Enum.InitialDockState.Float,false))
infoM.Title="Supported objects"
infoM:BindToClose(function() 
	infoB:SetActive(false)
end)
local infoT=Instance.new("TextLabel")
infoT.BackgroundTransparency=1
infoT.TextScaled=true
infoT.TextColor3=Color3.fromRGB(255,255,255)
infoT.Size=UDim2.fromScale(1,1)
infoT.Text="Currently supported objects: BodyVelocity, BodyGyro, BodyForce, BodyThrust, BodyAngularVelocity, Hat, Hint and Message. To add more supported objects, contribute to the plugin on GitHub. (repo in the description)"
infoT.Parent=infoM
local selection=game:GetService("Selection")
local changeHistory=game:GetService("ChangeHistoryService")
selection.SelectionChanged:Connect(function()
	if #selection:Get()==0 then
		deDeprecatorB.Enabled=false
	else
		deDeprecatorB.Enabled=true
	end
end)
deDeprecatorB.Click:Connect(function()
	local selectedObjects=selection:Get()
	if selectedObjects~={} then
		for _,v in ipairs(selectedObjects) do
			local recording
			deDeprecatorB:SetActive(true)
			if not changeHistory:IsRecordingInProgress() then
				recording=changeHistory:TryBeginRecording("DeDeprecate","DeDeprecate")
			else
				warn("Another recording is in progress. Did not record changes.")
			end
			local function replace(newInstance,v)
				newInstance.Name=v.Name
				newInstance.Parent=v.Parent
				v:Destroy()
				selection:Set({newInstance})
				assert(recording,"Recording is nil")
				changeHistory:FinishRecording(recording,Enum.FinishRecordingOperation.Commit)
				deDeprecatorB:SetActive(false)
			end
			if v:IsA("BodyVelocity") then
				local attachment=Instance.new("Attachment")
				attachment.Parent=v.Parent
				local newInstance=Instance.new("LinearVelocity")
				newInstance.VectorVelocity=v.Velocity
				newInstance.ForceLimitMode=Enum.ForceLimitMode.PerAxis
				newInstance.MaxAxesForce=v.MaxForce
				newInstance.Attachment0=attachment
				replace(newInstance,v)
			elseif v:IsA("BodyGyro") then
				local attachment=Instance.new("Attachment")
				attachment.Parent=v.Parent
				local newInstance=Instance.new("AlignOrientation")
				newInstance.CFrame=v.CFrame
				newInstance.MaxTorque=v.MaxTorque
				newInstance.Responsiveness=v.P/300
				newInstance.Mode=Enum.OrientationAlignmentMode.OneAttachment
				newInstance.Attachment0=attachment
				replace(newInstance,v)
			elseif v:IsA("BodyForce") then
				local attachment=Instance.new("Attachment")
				attachment.Parent=v.Parent
				local newInstance=Instance.new("VectorForce")
				newInstance.Force=v.Force
				newInstance.ApplyAtCenterOfMass=true
				newInstance.Attachment0=attachment
				newInstance.RelativeTo=Enum.ActuatorRelativeTo.World
				replace(newInstance,v)
			elseif v:IsA("BodyThrust") then
				local attachment=Instance.new("Attachment")
				attachment.Parent=v.Parent
				attachment.Position=v.Location
				local newInstance=Instance.new("VectorForce")
				newInstance.Force=v.Force
				newInstance.Attachment0=attachment
				replace(newInstance,v)
			elseif v:IsA("BodyAngularVelocity") then
				local attachment=Instance.new("Attachment")
				attachment.Parent=v.Parent
				local newInstance=Instance.new("AngularVelocity")
				newInstance.AngularVelocity=v.AngularVelocity
				newInstance.MaxTorque=v.MaxTorque.X
				newInstance.RelativeTo=Enum.ActuatorRelativeTo.Attachment0
				newInstance.Attachment0=attachment
				replace(newInstance,v)
			elseif v:IsA("Hat") then
				local newInstance=Instance.new("Accessory")
				newInstance.AttachmentUp=v.AttachmentUp
				newInstance.AttachmentPoint=v.AttachmentPoint
				newInstance.AttachmentRight=v.AttachmentRight
				newInstance.AttachmentForward=v.AttachmentForward
				newInstance.AttachmentPos=v.AttachmentPos
				local handle=v:FindFirstChild("Handle")
				if handle then
					handle.Parent=newInstance
				end
				replace(newInstance,v)
			elseif v:IsA("Hint") then
				local newInstance=Instance.new("TextLabel")
				newInstance.BackgroundColor3=Color3.fromRGB(0,0,0)
				newInstance.BorderColor3=Color3.fromRGB(0,0,0)
				newInstance.BorderSizePixel=0
				newInstance.Size=UDim2.new(1,0,0,20)
				newInstance.FontFace=Font.fromEnum(Enum.Font.Arimo)
				newInstance.TextScaled=true
				newInstance.Position=UDim2.fromScale(0,0)
				newInstance.TextColor3=Color3.fromRGB(255,255,255)
				newInstance.Text=v.Text
				warn("To make the new hint visible, place it inside a ScreenGui with its ScreenInsets set to None and put it inside the StarterGui.")
				replace(newInstance,v)
			elseif v:IsA("Message") then
				local newInstance=Instance.new("TextLabel")
				newInstance.BackgroundColor3=Color3.fromRGB(128,128,128)
				newInstance.BackgroundTransparency=0.5
				newInstance.BorderSizePixel=0
				newInstance.Size=UDim2.fromScale(2,2)
				newInstance.FontFace=Font.fromEnum(Enum.Font.Arimo)
				newInstance.TextSize=21
				newInstance.AnchorPoint=Vector2.new(0.5,0.5)
				newInstance.Position=UDim2.fromScale(0.5,0.5)
				newInstance.TextColor3=Color3.fromRGB(255,255,255)
				newInstance.TextStrokeTransparency=0
				newInstance.Text=v.Text
				warn("To make the new message visible, place it inside a ScreenGui with its ScreenInsets set to None and put it inside the StarterGui.")
				replace(newInstance,v)
			else
				if type(v)=="userdata" then
					warn(v.ClassName.."s","are not supported.")
				end
				changeHistory:FinishRecording(recording,Enum.FinishRecordingOperation.Cancel)
				deDeprecatorB:SetActive(false)
			end
		end
	else
		deDeprecatorB.Enabled=false
		warn("The DeDeprecate button should have been disabled earlier.")
	end
end)
infoB.Click:Connect(function()
	infoM.Enabled=not infoM.Enabled
	infoB:SetActive(infoM.Enabled)
end)
