local addon, ns = ...
local O3 = O3

ns.ComposeMailWindow = O3.UI.Window:extend({
	name = 'ComposeDetail',
	title = 'Compose Detail',
	managed = true,
	_weight = 1,
	height = 520,
	settings = {
	},
	onShow = function (self)
		self.parent.handler:registerEvent('MAIL_SEND_INFO_UPDATE', self)
		self.parent.handler:registerEvent('MAIL_FAILED', self)
		self.parent.handler:registerEvent('MAIL_SEND_SUCCESS', self)
		SetSendMailShowing(true)
	end,
	onHide = function (self)
		self.parent.handler:unregisterEvent('MAIL_SEND_INFO_UPDATE', self)
		self.parent.handler:unregisterEvent('MAIL_FAILED', self)
		self.parent.handler:unregisterEvent('MAIL_SEND_SUCCESS', self)
		SetSendMailShowing(false)
	end,

	MAIL_SEND_INFO_UPDATE = function (self)
		self:update()
	end,
	MAIL_FAILED = function (self)
	end,
	MAIL_SEND_SUCCESS = function (self)
		self.contentText.frame:SetText('')
		self.subjectText.frame:SetText('')
		--self.toText.frame:SetText('')
		self:update()
		self.moneyControl:setMoney(0)
		self.codCheckBox:setValue(false)
		O3.UI.EditBox:clearKeyboardFocus()
		self.toText:enable()
	end,
	update = function (self)
		for i = 1, ATTACHMENTS_MAX_SEND  do
			local name, itemTexture, count, quality = GetSendMailItem(i)
			if (self.subjectText.frame:GetText() == '' and name) then
				self.subjectText.frame:SetText(name)
			end
			local attachment = self.attachments[i]
			attachment:update(name, itemTexture, count, quality)
		end
	end,
	createDetail = function (self)
		local toLabel = self.content:createFontString({
			text = 'To :',
			justifyH = 'RIGHT',
			offset = {8, nil, 30, nil},
			width = 80,
			height = 24,
		})

		local subjectLabel = self.content:createFontString({
			text = 'Subject :',
			justifyH = 'RIGHT',
			width = 80,
			height = 24,
		})
		subjectLabel:SetPoint('TOPLEFT', toLabel, 'BOTTOMLEFT', 0, 0)
		
		local goldLabel = self.content:createFontString({
			text = 'Gold :',
			justifyH = 'RIGHT',
			width = 80,
			height = 24,
		})
		goldLabel:SetPoint('TOPLEFT', subjectLabel, 'BOTTOMLEFT', 0, 0)

		local toText = O3.UI.EditBox:instance({
			justifyH = 'LEFT',
			parentFrame = self.content.frame,
			offset = {nil, 8, nil, nil},
			color = {1,1,0},
			height = 22,
			onTabPressed = function (toText, frame)
				O3.UI.EditBox:clearKeyboardFocus()
				self.subjectText.frame:Enable()
			end,
		})
		toText:point('LEFT', toLabel, 'RIGHT', 8, 0)
		self.toText = toText

		local subjectText = O3.UI.EditBox:instance({
			justifyH = 'LEFT',
			parentFrame = self.content.frame,
			offset = {nil, 8, nil, nil},
			color = {1,1,0},
			height = 22,
			onTabPressed = function (subjectText, frame)
				O3.UI.EditBox:clearKeyboardFocus()
				self.moneyControl:enable()
			end,			
		})
		subjectText:point('LEFT', subjectLabel, 'RIGHT', 8, 0)
		self.subjectText = subjectText

		self.moneyControl = O3.UI.GoldEditBox:instance({
			height = 24,
			parentFrame = self.content.frame,
			onTabPressed = function (moneyControl, frame)
				O3.UI.EditBox:clearKeyboardFocus()
				self.contentText.frame:Enable()
			end,
		})
		self.moneyControl:point('TOP', subjectLabel, 'BOTTOM', 0, 0)
		self.moneyControl:point('LEFT', goldLabel, 'RIGHT', 8, 0)

		self.codCheckBox = O3.UI.CheckBox:instance({
			on = self.on,
			off = self.off,
			parentFrame = self.content.frame,
			callback = function (checkBox, value)

			end,
		})
		self.codCheckBox:point('LEFT', self.moneyControl.frame, 'RIGHT', 10, 0)

		local codLabel = self.content:createFontString({
			text = 'C.O.D.',
			justifyH = 'LEFT',
			width = 80,
			height = 24,
		})
		codLabel:SetPoint('LEFT', self.codCheckBox.frame, 'RIGHT', 4, 0)

		self.scrollFrame = self.content:createPanel({
			type = 'ScrollFrame',
			offset = {8, 8, nil, 74},
			style = function (scrollFrame)

				scrollFrame:createTexture({
					layer = 'BACKGROUND',
					subLayer = 0,
					color = {0.2 , 0.2 , 0.2, 0.15},
					-- offset = {0, 0, 0, nil},
					-- height = 1,
				})
				scrollFrame.outline = scrollFrame:createOutline({
					layer = 'ARTWORK',
					subLayer = 3,
					gradient = 'VERTICAL',
					color = {1, 1, 1, 0.08 },
					colorEnd = {1, 1, 1, 0.12 },
					offset = {1, 1, 1, 1},
				})
				scrollFrame.outline = scrollFrame:createOutline({
					layer = 'BACKGROUND',
					color = {0, 0, 0, 1 },
					offset = {0, 0, 0, 0},
				})
			end,
			createRegions = function (scrollFrame)
				scrollFrame.scrollChild = O3.UI.EditBox:instance({
					parentFrame = scrollFrame.parentFrame,
					justifyH = 'LEFT',
					justifyV = 'TOP',
					--offset = {0, nil, 0, nil},
					width = 400,
					height = 400,
					lines = 2,
					onEscapePressed = function (editBox)
						editBox.frame:Disable()
					end,
					style = function (editBox)

					end,
					onCursorChanged =  function (editBox, frame, x, y, width, height)
						local frame = editBox.frame
						y = -1*y
						local scrollHeight = scrollFrame.frame:GetHeight()
						local contentHeight =  math.ceil(frame:GetHeight())
						local scrollMax = scrollFrame.frame:GetVerticalScrollRange()
						local scrollPos = scrollFrame.frame:GetVerticalScroll()
						if y < scrollPos then
							scrollFrame.frame:SetVerticalScroll(y)
						elseif contentHeight < scrollHeight then
							scrollFrame.frame:SetVerticalScroll(0)
						else
							if y > contentHeight - (height*2) then
								scrollFrame.frame:SetVerticalScroll(scrollMax)
							elseif y > scrollHeight then
								scrollFrame.frame:SetVerticalScroll(y-scrollHeight+height*2)
							end
						end
					end,
				})
			end,
			hook = function (scrollFrame)
				scrollFrame.frame:SetScript('OnMouseDown', function ()
					scrollFrame.scrollChild.frame:Enable()
				end)	
			end,
			postInit = function (scrollFrame)
				scrollFrame:point('TOPLEFT', subjectLabel, 'BOTTOMLEFT', 0, -40)
				scrollFrame.frame:SetScrollChild(scrollFrame.scrollChild.frame)
				scrollFrame.frame:SetVerticalScroll(0)
				scrollFrame.frame:SetHorizontalScroll(0)
				scrollFrame.frame:UpdateScrollChildRect()
			end,
		})
		self.contentText = self.scrollFrame.scrollChild

		self:createAttachments()
	end,
	createAttachment = function (self, id)

		return O3.UI.IconButton:instance({
			parentFrame = self.content.frame,
			id = id,
			createRegions = function (attachment)
				attachment.count = attachment:createFontString({
					offset = {2, nil, 2, nil},
					fontFlags = 'OUTLINE',
					text = nil,
					-- shadowOffset = {1, -1},
					fontSize = 12,
				})
			end,
			update = function(attachment, name, itemTexture, count, quality)
				if name then
					attachment.name = name
					attachment:setTexture(itemTexture)
					if (count > 1) then
						attachment.count:SetText(count)
					else
						attachment.count:SetText('')
					end
				else
					attachment.name = nil
					attachment.count:SetText('')
					attachment:setTexture(nil)
				end
			end,
			onMouseUp = function (attachment)
				ClickSendMailItemButton(attachment.id)
			end,
			onEnter = function (attachment)
				if attachment.name then
					GameTooltip:SetOwner(attachment.frame, "ANCHOR_RIGHT")
					GameTooltip:SetSendMailItem(self.id, attachment.id)
					CursorUpdate(attachment.frame)
					GameTooltip:Show()
				end
			end,
			onLeave = function (attachment)
				GameTooltip:Hide()			
			end,
		})
	end,
	createAttachments = function (self)
		self.attachments = {}
		local lastAttachment = nil
		local rowCount = math.floor(ATTACHMENTS_MAX_SEND/2)
		for i = 1, ATTACHMENTS_MAX_SEND do
			local attachment = self:createAttachment(i)
			if not lastAttachment then
				attachment:point('BOTTOMLEFT', self.content.frame, 'BOTTOMLEFT', 78, 38)
			elseif i % rowCount == 1 then
				attachment:point('TOPLEFT', self.attachments[i-rowCount].frame, 'BOTTOMLEFT', 0, 0)
			else
				attachment:point('TOPLEFT', lastAttachment.frame, 'TOPRIGHT', 0, 0)
			end
			lastAttachment = attachment
			self.attachments[i] = attachment
		end
	end,
	createMailControls = function (self)
		O3.UI.Toolbar:instance({
			height = self.settings.itemsTopGap+2,
			parentFrame = self.frame,
			offset = {0, 0, self.settings.headerHeight-1, nil},
			createRegions = function (toolbar)
				self.sendControl = O3.UI.Button:instance({
					parentFrame = toolbar.frame,
					color = {0.1, 0.9, 0.1, 1},
					offset = {2, nil, 2, nil},
					text = 'Send',
					width = 90,
					onClick = function ()
						local recipient = self.toText.frame:GetText()
						local subject = self.subjectText.frame:GetText()
						local body = self.contentText.frame:GetText()
						SetSendMailCOD(0)
						SetSendMailMoney(0)
						if (self.codCheckBox.value and (self.moneyControl.money or 0 )> 0 ) then
							SetSendMailCOD(self.moneyControl.money)
						elseif ((self.moneyControl.money or 0 ) > 0) then
							SetSendMailMoney(self.moneyControl.money)
						end
						SelectStationery(1)
						SendMail(recipient, subject, body)
						
					end
				}, self.content)
			end
		})	
	end,
	postInit = function (self, parent)
		self.parent = parent
	end,
	postCreate = function (self)
		self:createDetail()


		self:createMailControls()
		-- self:createFilterTextControl()
		-- self:createFilterControls()
		self.frame:SetPoint('TOP', 250, -200)
	end,
})