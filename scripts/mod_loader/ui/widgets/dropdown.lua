UiDropDown = Class.inherit(Ui)

function UiDropDown:new(values,strings,value)
	Ui.new(self)

	self.dropdownFont = deco.uifont.default.font
	self.tooltip = ""
	self.nofitx = true
	self.nofity = true
	self.values = values
	self.strings = strings or {}
	if value then
		for i, v in pairs(values) do
			if value == v then
				self.choice = i
				self.value = v
				break
			end
		end
	end
	if not self.choice then
		self.choice = 1
		self.value = values[1]
	end
	self.open = false
end

function UiDropDown:destroyDropDown()
	self.open = false
	self.root.currentDropDown = nil
	self.root.currentDropDownOwner = nil
end

function UiDropDown:createDropDown()
	self:relayout()
	if self.root.currentDropDown then
		self.root.currentDropDownOwner:destroyDropDown()
	end
	
	local uiScale = GetUiScale()

	self.open = true
	
	local items = {}
	
	local max_w = 32
	for i, v in ipairs(self.values) do
		local txt = DecoRAlignedText(self.strings[i] or tostring(v), self.dropdownFont)
		
		if txt.surface:w() > max_w then
			max_w = txt.surface:w()
		end
		
		local item = Ui()
			:width(1):heightpx(40 * uiScale)
			:decorate({
				DecoSolidHoverable(deco.colors.button, deco.colors.buttonborder),
				DecoAlign(0, 2),
				txt
			})
		table.insert(items, item)
		
		item.onclicked = function(btn, button)
			if button == 1 then
				self.choice = i
				self.value = self.values[i]
				
				self:destroyDropDown()
				self.hovered = false
				return true
			end
			return false
		end
	end
	
	local ddw = uiScale * math.max(max_w + 8, 210)
	local dropDown = Ui()
		:pospx(
			self.rect.x + self.w - ddw,
			self.rect.y + self.h + 2
		)
		:widthpx(ddw)
		:heightpx(uiScale * math.min(2 + #self.values * 40, 210))
		:decorate({ DecoFrame(nil, nil, 1 * uiScale) })

	local scrollarea = UiScrollArea()
		:width(1):height(1)
		:addTo(dropDown)

	local layout = UiBoxLayout()
		:vgap(0)
		:width(1)
		:addTo(scrollarea)
	
	for i, item in ipairs(items) do
		layout:add(item)
	end
	
	self.root.currentDropDownOwner = self
	self.root.currentDropDown = dropDown
end

function UiDropDown:draw(screen)
	if self.open then
		-- keep the dropdown owner highlighted as long as
		-- the dropdown is open for additional clarity
		self.hovered = true

		local oldClip = self.root.clippingrect
		self.root.clippingrect = nil
		--We don't want our dropdown to be clipped
		if oldClip then
			screen:unclip()
		end
		
		Ui.draw(self, screen)
		
		if oldClip then
			screen:clip(oldClip)
		end
	else
		Ui.draw(self, screen)
	end
end

function UiDropDown:clicked(button)
	if button == 1 then
		if self.open then
			self:destroyDropDown()
		else
			self:createDropDown()
		end
	end
	
	return Ui.clicked(self, button)
end

function UiDropDown:keydown(keycode)
	if self.focused then
		if self.open then
			if keycode == 27 then
				self:destroyDropDown()
			end

			return true
		else
			if
				-- enter or keypad enter
				keycode == 0x0D       or
				keycode == 0x40000058
			then
				self:createDropDown()
				return true
			end
		end
	end

	return Ui.keydown(self, keycode)
end

function UiDropDown:keyup(keycode)
	if
		self.open and self.focused and (
			keycode == 27         or
			keycode == 0x0D       or
			keycode == 0x40000058
		)
	then
		return true
	end

	return Ui.keyup(self, keycode)
end
