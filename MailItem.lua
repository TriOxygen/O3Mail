local addon, ns = ...
local O3 = O3

ns.MailItem = O3.UI.Panel:extend({
	height = 24,
	type = 'Button',
	offset = {2, 2, nil, nil},
	createRegions = function (self)
		self.button = O3.UI.IconButton:instance({
			parent = self,
			icon = nil,
			parentFrame = self.frame,
			height = self.height,
			width = self.height,
			offset = {24, nil, 0, nil},
			onClick = function (iconButton)
				if (iconButton.parent.onIconClick) then
					iconButton.parent:onIconClick()
				end
			end,
			createRegions = function (iconButton)
				iconButton.count = iconButton:createFontString({
					offset = {2, nil, 2, nil},
					fontFlags = 'OUTLINE',
					text = nil,
					-- shadowOffset = {1, -1},
					fontSize = 12,
				})
			end,
		})
		self.daysDisplay = self:createPanel({
			type = 'StatusBar',
			offset = {1,nil,1,1},
			width = 5,
			postInit = function (statusBar)
				statusBar.frame:SetStatusBarTexture(O3.Media:statusBar('Default'), 'BACKGROUND')
				statusBar.frame:SetOrientation('VERTICAL')
			end,
			style = function (statusBar)
				statusBar:createOutline({
					layer = 'BORDER',
					-- gradient = 'VERTICAL',
					color = {0, 0, 0, 0.5},
					-- colorEnd = {1, 1, 1, 0.05 },
					offset = {0, 0, 0, 0},
					-- width = 2,
					-- height = 2,
				})			
			end,
			hook = function (statusBar)
				local daysDisplay = statusBar.frame
				daysDisplay:SetScript('OnEnter', function (daysDisplay)
					local days = daysDisplay:GetValue()
					GameTooltip:SetOwner(daysDisplay, "ANCHOR_RIGHT")

					if (days > 1) then
						GameTooltip:SetText(math.floor(days)..' days', 1, 1, 1)
					else
						local minutes = math.floor(days*(24*60))
						GameTooltip:SetText(math.floor(minutes/60)..' hours, '..(minutes %60)..' minutes', 1, 1, 1)
					end
					CursorUpdate(daysDisplay)
					GameTooltip:Show()
				end)

				daysDisplay:SetScript('OnLeave', function (daysDisplay)
					GameTooltip:Hide()
					ResetCursor()
				end)
			end,
		})

		self.checkBox = O3.UI.CheckBox:instance({
			on = self.on,
			off = self.off,
			offset = {9, nil, nil, nil},
			parentFrame = self.frame,
			callback = function (checkBox, value)
				if value then
					self.panel.checkedLayer:Show()
				else
					self.panel.checkedLayer:Hide()
				end
			end,
		})

		self.panel = self:createPanel({
			offset = {49, 0, 0, 0},
			style = function (panel)
				panel.sender = panel:createFontString({
					offset = {1, 75, 1, nil},
					height = 12,
					color = {0.9, 0.9, 0.1, 1},
					justifyV = 'TOP',
					justifyH = 'LEFT',
					fontSize = 10,
				})
				panel.subject = panel:createFontString({
					offset = {1, 75, nil, 1},
					height = 10,
					color = {0.9, 0.9, 0.9, 1},
					justifyV = 'BOTTOM',
					justifyH = 'LEFT',
					fontSize = 10,
				})

				panel:createOutline({
					layer = 'BORDER',
					gradient = 'VERTICAL',
					color = {1, 1, 1, 0.03 },
					colorEnd = {1, 1, 1, 0.05 },
					offset = {0, 0, 0, 0},
					-- width = 2,
					-- height = 2,
				})	
				panel.highlight = panel:createTexture({
					layer = 'ARTWORK',
					gradient = 'VERTICAL',
					color = {0,1,1,0.10},
					colorEnd = {0,0.5,0.5,0.20},
					offset = {1,1,1,1},
				})
				panel.highlight:Hide()
				panel.checkedLayer = panel:createTexture({
					layer = 'ARTWORK',
					gradient = 'VERTICAL',
					color = {0,1,0,0.20},
					colorEnd = {0,0.8,0,0.40},
					offset = {1,1,1,1},
				})
				panel.checkedLayer:Hide()										
				panel.deleteButton = O3.UI.GlyphButton:instance({
					parentFrame = panel.frame,
					bg = true,
					color = {1, 0.1, 0.1},
					offset = {nil, 24, 1, 1},
					width = 22,
					text = '',
					onClick = function (button)
						DeleteInboxItem(self.id)
					end,
				})
				panel.returnButton = O3.UI.GlyphButton:instance({
					parentFrame = panel.frame,
					bg = true,
					color = {0.1, 1, 0.1},
					offset = {nil, 1, 1, 1},
					width = 22,
					text = '',
					onClick = function (button)
						ReturnInboxItem(self.id)
					end,
				})
				panel.openButton = O3.UI.GlyphButton:instance({
					parentFrame = panel.frame,
					bg = true,
					color = {0.1, 1, 1},
					offset = {nil, 47, 1, 1},
					width = 22,
					text = '',
					onClick = function (button)
						AutoLootMailItem(self.id)
					end,
				})
			end,
		})
		self.openButton = self.panel.openButton
		self.returnButton = self.panel.returnButton
		self.deleteButton = self.panel.deleteButton
		self.icon = self.button.icon
		self.count = self.button.count
		self.subject = self.panel.subject
		self.sender = self.panel.sender
		self.countText = self.button.count
	end,
	style = function (self)
		self.bg = self:createTexture({
			layer = 'BACKGROUND',
			subLayer = -7,
			color = {0, 0, 0, 0.2},
			-- offset = {0, 0, 0, nil},
			-- height = 1,
		})
	end,
	setRead = function (self, read)
		if read then
			self.subject:SetTextColor(0.5, 0.5, 0.5, 1)
			self.sender:SetTextColor(0.5, 0.5, 0.5, 1)
		else
			self.subject:SetTextColor(0.9, 0.9, 0.9, 1)
			self.sender:SetTextColor(0.9, 0.9, 0.1, 1)
		end
	end,
	update = function (self, id)
		local packageIcon, stationeryIcon, sender, subject, money, codAmount, daysLeft, itemCount, wasRead, wasReturned, textCreated, canReply, isGM, itemQuantity = GetInboxHeaderInfo(id)
		self.id = id
		self.icon:SetTexture(packageIcon)
		self.sender:SetText(sender)
		self.subject:SetText(subject)
		-- local canDelete = InboxItemCanDelete(id)
		-- if codAmount  > 0 then
		-- 	self.moneyTexture:SetVertexColor(1,0,0)
		-- 	self.moneyTexture:Show()
		-- elseif money > 0 then
		-- 	self.moneyTexture:SetVertexColor(1,1,1)
		-- 	self.moneyTexture:Show()
		-- else
		-- 	self.moneyTexture:Hide()
		-- end

		if ((selfQuantity or 0 ) > 1) then
			self.count:SetText(selfQuantity)
		else
			self.count:SetText('')
		end

		self.openButton:enable()
		if canDelete then
			self.deleteButton:enable()
		else
			self.deleteButton:disable()
		end
		if canReply then
			self.returnButton:enable()
		else
			self.returnButton:disable()
		end
		-- self:updateChecked()

		if wasRead then
			self:setRead(true)
		else
			self:setRead(false)
		end

		local daysDisplay = self.daysDisplay.frame
		if (daysLeft >= 7) then
			daysDisplay:SetStatusBarColor(0.2, 0.5, 0.2)
			daysDisplay:SetMinMaxValues(0, 31)
		elseif (daysLeft >= 1) then
			daysDisplay:SetStatusBarColor(0.5, 0.5, 0.2)
			daysDisplay:SetMinMaxValues(0, 7)
		else
			daysDisplay:SetStatusBarColor(0.5, 0.2, 0.2)
			daysDisplay:SetMinMaxValues(0, 1)
		end
		daysDisplay:SetValue(daysLeft)
	end,
	hook = function (self)
		self.frame:SetScript('OnEnter', function (frame)
			self.panel.highlight:Show()
			GameTooltip:SetOwner(frame, "ANCHOR_RIGHT")
			-- GameTooltip:SetMailItem(self.id)
			CursorUpdate(frame)
			GameTooltip:Show()


			
			if (self.onEnter) then
				self:onEnter()
			end
		end)
		self.frame:SetScript('OnLeave', function (frame)
			GameTooltip:Hide()
			ResetCursor()

			self.panel.highlight:Hide()
			if (self.onLeave) then
				self:onLeave()
			end
		end)
		self.frame:SetScript('OnClick', function (frame)
			if (self.onClick) then
				self:onClick()
			end
		end)
	end,	
})