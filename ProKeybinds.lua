--[[---------------------------------------------------------

	ProKeybinds v1.0a
		by Sokik < scott@pscottgrossman.com >
	Original addon, ncBindings,
		by nightcracker < nightcracker@live.nl >
	Copyleft, All Rights Reversed.
	http://www.wowinterface.com/downloads/info18841-ProKeybinds.html

-----------------------------------------------------------]]--
local a = CreateFrame("Frame")

function CreatePanel(f, h, w, a1, p, a2, x, y)
	f:SetFrameLevel(1)
	f:SetHeight(h)
	f:SetWidth(w)
	f:SetFrameStrata("BACKGROUND")
	f:SetPoint(a1, p, a2, x, y)
	f:SetBackdrop( {
	  bgFile = "Interface\\Buttons\\WHITE8x8",
	  edgeFile = "Interface\\Buttons\\WHITE8x8",
	  tile = false, tileSize = 0, edgeSize = 1,
	  insets = { left = -1, right = -1, top = -1, bottom = -1 }
	})
	f:SetBackdropColor(.1,.1,.1)
	f:SetBackdropBorderColor(.6,.6,.6)
end

StaticPopupDialogs["PROKEYBINDS_CONFIRM_BINDING"] = {
	button1 = YES,
	button2 = NO,
	timeout = 0,
	hideOnEscape = 1,
	OnAccept = BindPadBindFrame_SetBindKey,
	whileDead = 1
}

local function Bind(self, key)
	if GetBindingFromClick(key)=="SCREENSHOT" then
		RunBinding("SCREENSHOT")
		return
	end

	if key == "LSHIFT"
	or key == "RSHIFT"
	or key == "LCTRL"
	or key == "RCTRL"
	or key == "LALT"
	or key == "RALT"
	or key == "UNKNOWN"
	or key == "LeftButton"
	or key == "RightButton"
	then return end
	
	if key == "MiddleButton" then key = "BUTTON3" end
	if key == "Button4" then key = "BUTTON4" end
	if key == "Button5" then key = "BUTTON5" end
	
	local altdown   = IsAltKeyDown() or ""
	local ctrldown  = IsControlKeyDown() or ""
	local shiftdown = IsShiftKeyDown() or ""

	if altdown==1 then altdown = "ALT-" end
	if ctrldown==1 then ctrldown = "CTRL-" end
	if shiftdown==1 then shiftdown = "SHIFT-" end
	
	key = altdown..ctrldown..shiftdown..key
	
	StaticPopupDialogs["PROKEYBINDS_CONFIRM_BINDING"].OnAccept = function()	
		SetBinding(key, self.tobind)
		SaveBindings(GetCurrentBindingSet())
		print("|cFF00FF00"..key.." |ris now bound to |cFF00FF00"..self.tobind.."|r.")
	end
	
	local current = GetBindingAction(key)
	if current=="" or current==self.tobind then
		StaticPopupDialogs["PROKEYBINDS_CONFIRM_BINDING"].OnAccept()
	else
		StaticPopupDialogs["PROKEYBINDS_CONFIRM_BINDING"].text = "|cFF00FF00"..key.."|r is currently bound to |cFF00FF00"..current.."|r.\n\nBind |cFF00FF00"..key.."|r to |cFF00FF00"..self.tobind.."|r?\n"
		StaticPopup_Show("PROKEYBINDS_CONFIRM_BINDING")
	end
end


local b = CreateFrame("Frame", "ProKeybindsFrameAnchor")
CreatePanel(b, 13, 48, "CENTER", UIParent, "CENTER", 0, 200)
b:EnableMouse(true)
b:SetMovable(true)
b:SetUserPlaced(true)
b:RegisterForDrag("LeftButton")
b:SetScript("OnDragStart", b.StartMoving)
b:SetScript("OnDragStop", b.StopMovingOrSizing)

b.text = b:CreateFontString(nil, "OVERLAY")
b.text:SetFont("Fonts\\FRIZQT__.ttf", 8)
b.text:SetPoint("BOTTOMLEFT", b, "BOTTOMLEFT", 3, 3)
b.text:SetText("ProKeybinds")

local f = CreateFrame("Frame", "ProKeybindsFrame", b)
CreatePanel(f, 205, 205, "TOPLEFT", b, "BOTTOMLEFT", 0, -5)

b.closebutton = CreateFrame("Button", _, b, "UIPanelCloseButton")
b.closebutton:SetPoint("TOPRIGHT", f, "TOPRIGHT", 5, 20)
b.closebutton:SetWidth(20)
b.closebutton:SetHeight(20)

local bf = CreateFrame("Button", _, f)
CreatePanel(bf, 65, 205, "TOP", f, "BOTTOM", 0, -10)

local g, h = CreateFrame("Frame", _, bf), CreateFrame("Frame", _, bf)
CreatePanel(g, 10, 2, "TOP", f, "BOTTOM", -40, 0)
CreatePanel(h, 10, 2, "TOP", f, "BOTTOM", 40, 0)

bf:EnableMouse(true)
bf:EnableKeyboard(true)
bf:EnableMouseWheel(true)
bf:Hide()

bf.closebutton = CreateFrame("Button", _, bf, "UIPanelCloseButton")
bf.closebutton:SetPoint("TOPRIGHT", bf, "TOPRIGHT", 1, 0)
bf.closebutton:SetWidth(20)
bf.closebutton:SetHeight(20)

bf.any = bf:CreateFontString(nil, "OVERLAY")
bf.any:SetFont("Fonts\\FRIZQT__.TTF", 8)
bf.any:SetPoint("TOP", bf, "TOP", 0, -10)
bf.any:SetText("Press any key to bind.")

bf.spelltext = bf:CreateFontString(nil, "OVERLAY")
bf.spelltext:SetFont("Fonts\\FRIZQT__.TTF", 10)
bf.spelltext:SetPoint("TOP", bf.any, "BOTTOM", 0, -8)
bf.spelltext:SetTextColor(0, 1, 0)

bf.current = bf:CreateFontString(nil, "OVERLAY")
bf.current:SetFont("Fonts\\FRIZQT__.TTF", 8)
bf.current:SetPoint("TOP", bf.spelltext, "BOTTOM", 0, -8)
bf.current:SetText("For mouse/scrollwheel hover over this frame.")

bf:HookScript("OnHide", function() StaticPopup_Hide("PROKEYBINDS_CONFIRM_BINDING") end)
bf:SetScript("OnMousedown", Bind)
bf:SetScript("OnKeyDown", Bind)
bf:SetScript("OnMouseWheel", function(self, key)
	if key > 0 then
		Bind(self, "MOUSEWHEELUP")
	else
		Bind(self, "MOUSEWHEELDOWN")
	end
end)

local function MacroUpdate()
	local macroexists = false
	for i=1,36 do
		btn = ProKeybinds[i]
		if btn.type=="MACRO" and GetMacroInfo(btn.id)==nil then
			btn.icon:SetTexture(nil)
			btn.text:SetText("")
			btn.type = nil
			btn.id = nil
			bf:Hide()
		elseif btn.type=="MACRO" then
			macroexists = true
		end
	end
	if macroexists==false then
		a:UnregisterEvent("MACRO_UPDATE")
	end
end

local function RegisterForMacroChanges()
	local isRegistered = a:IsEventRegistered("UPDATE_MACROS")
	if isRegistered then
	else
		a:RegisterEvent("UPDATE_MACROS")
		a:SetScript("OnEvent", MacroUpdate)
	end
end

local function OpenBindingsFrame(tobind)
	bf.tobind = tobind
	bf.spelltext:SetText(bf.tobind)
	bf:Show()
end

local function OnEnter(self)
	if GetCursorInfo() then return end
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
	local bound = ""
	if self.type=="ITEM" then
		GameTooltip:SetHyperlink(select(2,GetItemInfo(self.id)))
		bound = "ITEM "..GetItemInfo(self.id)
	elseif self.type=="MACRO" then
		GameTooltip:SetText(self.id)
		bound = "MACRO "..self.id
	elseif self.type=="SPELL" then
		GameTooltip:SetSpellByID(self.id)
		bound = "SPELL "..GetSpellInfo(self.id)
	end
	local keybind = {GetBindingKey(bound)}
	GameTooltip:AddLine(GetBindingKey(bound) and "|cFF00FF00Binds: "..table.concat(keybind, ", ").."|r")
	GameTooltip:Show()
end

local function OnReceiveDrag(self)
	local oldid, oldtype = self.id, self.type
	if oldtype=="SPELL" and IsSpellKnown(oldid)==false and IsShiftKeyDown()==nil then
		print("|cFF00FF00ERROR:|r Spell is locked to button since it cannot be reliably moved or replaced. Hold shift to override this precaution.")
		return
	end
	
	local texture, macrotext
	if GetCursorInfo()=="spell" then
		local spellid = select(2,GetSpellBookItemInfo(select(2,GetCursorInfo()), "BOOKTYPE_SPELL"))
		texture = select(3,GetSpellInfo(spellid))
		self.type = "SPELL"
		self.id = spellid
	elseif GetCursorInfo()=="item" then
		local itemid = select(2,GetCursorInfo())
		texture = select(10,GetItemInfo(itemid))
		self.type = "ITEM"
		self.id = itemid
	elseif GetCursorInfo()=="macro" then
		local macroid = select(2,GetCursorInfo())
		macrotext, texture = GetMacroInfo(macroid)
		self.type = "MACRO"
		self.id = macrotext
		RegisterForMacroChanges()
	elseif GetCursorInfo()=="companion" then
		print("|cFF00FF00ERROR:|r Blizzard doesn't allow you to bind buttons directly to mounts or non-combat pets. Make a macro.")
	elseif GetCursorInfo()=="petaction" then
		print("|cFF00FF00ERROR:|r Blizzard doesn't give addons access to pet actions but they are bindable in other ways.")
	end
	
	if texture then
		self.icon:SetTexture(texture)
	end
	
	if macrotext then
		self.text:SetText(macrotext)
	else
		self.text:SetText("")
	end
	
	ClearCursor()
	OnEnter(self)
	bf:Hide()
	
	if oldtype=="MACRO" then
		PickupMacro(oldid)
		MacroUpdate()
	elseif oldtype=="ITEM" then
		PickupItem(oldid)
	elseif oldtype=="SPELL" and IsSpellKnown(oldid) then
		PickupSpell(oldid)
	end
end	

local function OnStartDrag(self)
	if self.type=="MACRO" then
		PickupMacro(self.id)
		self.type = nil
		MacroUpdate()
	elseif self.type=="ITEM" then
		PickupItem(self.id)
	elseif self.type=="SPELL" then
		if IsSpellKnown(self.id) then
			PickupSpell(self.id)
		elseif IsShiftKeyDown()==nil then
			print("|cFF00FF00ERROR:|r Spell is locked to button since it cannot be reliably moved or replaced. Hold shift to override this precaution.")
			return
		end
	end	
	
	self.icon:SetTexture(nil)
	self.text:SetText("")
	self.type = nil
	self.id = nil
	bf:Hide()
end

local function OnClick(self, click)
	if GetCursorInfo() then
		self:GetScript("OnReceiveDrag")(self)
	elseif self.type then			
		local tobind = ""
		if self.type=="ITEM" then
			tobind = "ITEM "..GetItemInfo(self.id)
		elseif self.type=="MACRO" then
			tobind = "MACRO "..self.id
		elseif self.type=="SPELL" then
			tobind = "SPELL "..GetSpellInfo(self.id)
		end
		
		if click=="RightButton" then
			local a = {}
			for i=1, 10000 do
				a[i] = select(i,GetBindingKey(tobind))
				if not a[i] then break end
			end
			for i=1,#a do
				SetBinding(a[i])
			end
			print("All bindings cleared for |cFF00FF00"..tobind.."|r.")
		else
			OpenBindingsFrame(tobind)
		end
	end
end

local function SetupButton(self)
	self:SetWidth(30)
	self:SetHeight(30)
	self:RegisterForClicks("AnyUp")
	self:RegisterForDrag("LeftButton")
	
	self.icon = self:CreateTexture()
	self.icon:SetWidth(30)
	self.icon:SetHeight(30)	
	self.icon:SetTexCoord(.08, .92, .08, .92)
	self.icon:SetPoint("TOPLEFT", self, 4, -4)
	self.icon:SetPoint("BOTTOMRIGHT", self, -4, 4)
	self.icon:SetTexture(texture)
	
	self.text = self:CreateFontString(nil, "OVERLAY")
	self.text:SetFont("Fonts\\FRIZQT__.TTF", 8, "THINOUTLINE")
	self.text:SetPoint("BOTTOMRIGHT", -2, 5)
	
	self:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-SquareQuickslot")
	
	self:SetScript("OnReceiveDrag", OnReceiveDrag)
	self:SetScript("OnDragStart", OnStartDrag)
	self:SetScript("OnEnter", OnEnter)
	self:SetScript("OnClick", OnClick)
	self:SetScript("OnLeave", function() GameTooltip:Hide() end)
	
	local texture, macrotext
	if self.type=="ITEM" then
		texture = select(10,GetItemInfo(self.id))
	elseif self.type=="MACRO" then
		if GetMacroInfo(self.id)=="" then
			texture = false
			macrotext = false
			self.type = nil
			self.id = nil
		else
			macrotext, texture = GetMacroInfo(self.id)
			RegisterForMacroChanges()
		end
	elseif self.type=="SPELL" then
		texture = select(3,GetSpellInfo(self.id))
	end
	
	if texture then
		self.icon:SetTexture(texture)
	end
	
	if macrotext then
		self.text:SetText(macrotext)
	else
		self.text:SetText("")
	end
end

local function OnPlayerEnteringWorld()
	ProKeybinds = ProKeybinds or {}
	local newrowbutton, lastbutton
	for i=1,36 do
		if not ProKeybinds[i] then ProKeybinds[i] = {type = false, id = false} end
		local btn = CreateFrame("Button", "PKButton"..i, f, "SecureActionButtonTemplate")
		btn.type = ProKeybinds[i].type
		btn.id = ProKeybinds[i].id
		SetupButton(btn)
		if i==1 then
			btn:SetPoint("TOPLEFT", 10, -10)
			lastbutton, newrowbutton = btn, btn
		elseif (i-1)/6==floor((i-1)/6) then
			btn:SetPoint("TOP", newrowbutton, "BOTTOM", 0, -1)
			lastbutton, newrowbutton = btn, btn
		else
			btn:SetPoint("LEFT", lastbutton, "RIGHT", 1, 0)
			lastbutton = btn
		end	
		ProKeybinds[i] = btn
	end
	a:UnregisterEvent("PLAYER_ENTERING_WORLD")
	b:Hide()
end

a:RegisterEvent("PLAYER_ENTERING_WORLD")
a:SetScript("OnEvent", OnPlayerEnteringWorld)

b:RegisterEvent("PLAYER_REGEN_DISABLED")
b:SetScript("OnEvent", function()
	b:Hide()
end)

SLASH_PROKEYBIND1 = "/pkb"
SLASH_PROKEYBIND2 = "/pkeybind"
SLASH_PROKEYBIND3 = "/pkeybinds"
SLASH_PROKEYBIND4 = "/probind"
SLASH_PROKEYBIND5 = "/probinds"
SLASH_PROKEYBIND6 = "/prokeybinds"
SlashCmdList.PROKEYBIND = function()
	if InCombatLockdown()== nil then
		if b:IsShown() then
			b:Hide()
		else
			b:Show()
		end
	else
		print("|cFF00FF00ERROR:|r Cannot edit bindings in combat.")
	end
end