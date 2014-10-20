local addon, ns = ...
local O3 = O3

ns.MailDetailWindow = O3.UI.Window:extend({
	name = 'MailDetail',
	title = 'Mail Detail',
	_weight = 2,
	managed = true,
	height = 520,
	settings = {
	},
	onShow = function (self)
		self.parent.handler:registerEvent('CLOSE_INBOX_ITEM', self)
		self.parent.handler:registerEvent('MAIL_INBOX_UPDATE', self)
	end,
	onHide = function (self)
		self.parent.handler:unregisterEvent('CLOSE_INBOX_ITEM', self)
		self.parent.handler:unregisterEvent('MAIL_INBOX_UPDATE', self)
	end,
	MAIL_INBOX_UPDATE = function (self)
		self:update(self.id)
	end,
	CLOSE_INBOX_ITEM = function (self)
		self:hide()
	end,
	setInvoiceDetails = function (self, id)
		local invoiceType, itemName, playerName, bid, buyout, deposit, consignment, moneyDelay, etaHour, etaMin = GetInboxInvoiceInfo(index)
		if invoiceType == 'buyer' then
			local buyerText = 'Item purchased : '..itemName..'\n'..'Sold by : '..playerName..'\n'..'______________________________________\n\n'..'Amount paid : '..O3:formatMoney(buyout)
			self.contentText:SetText(buyerText)
		elseif invoiceType == 'seller' then
			local buyerText = 'Item sold : '..itemName..'\n'..'Bought by : '..playerName..'\n'..'______________________________________\n\n'..'Amount received : '..O3:formatMoney(buyout)
			self.contentText:SetText(buyerText)
		end
	end,

	update = function (self, id)
		self.id = id
		local packageIcon, stationeryIcon, sender, subject, money, codAmount, daysLeft, itemCount, wasRead, wasReturned, textCreated, canReply, isGM, itemQuantity = GetInboxHeaderInfo(id)
		local bodyText, texture, isTakeable, isInvoice = GetInboxText(id)
		if (not sender) then
			self:hide()
			return
		end

		self.subjectText:SetText(subject)
		self.fromText:SetText(sender)

		if isInvoice then
			self:setInvoiceDetails(id)
		else
			self.contentText:SetText(bodyText or '')
		end

		if money and money > 0 then
			self.goldControl:show()
			self.goldControl.gold = money
		else
			self.goldControl:hide()
		end
		self.codAmount = codAmount or 0

		if isTakeable then
			self.takeCopyControl:show()
			self.takeCopyControl:setTexture(stationeryIcon)
		else
			self.takeCopyControl:hide()
		end

		for i = 1, ATTACHMENTS_MAX_RECEIVE  do
			local name, itemTexture, count, quality, canUse = GetInboxItem(self.id, i)
			local attachment = self.attachments[i]
			attachment:update(i, name, itemTexture, count, quality)
		end

		if (InboxItemCanDelete(id) and not isInvoice) then
			self.deleteControl:enable()
		else
			self.deleteControl:disable()
		end
		if canReply then
			self.replyControl:enable()
		else
			self.replyControl:disable()
		end
	end,
	createGoldControl = function (self)

		self.goldControl = O3.UI.IconButton:instance({
			parentFrame = self.content.frame,
			icon = 'Interface\\Icons\\Inv_misc_coin_01',
			offset = {10, nil, 80, nil},
			onEnter = function (iconButton)
				GameTooltip:SetOwner(iconButton.frame, "ANCHOR_RIGHT")
				GameTooltip:AddLine(O3:formatMoney(iconButton.gold), 1, 1, 1)
				CursorUpdate(iconButton.frame)
				GameTooltip:Show()
			end,
			onLeave = function (iconButton)
				GameTooltip:Hide()
				ResetCursor()
			end,
			onClick = function (iconButton)
				TakeInboxMoney(self.id)
			end,
		})
	end,
	createTakeCopyControl = function (self)
		self.takeCopyControl = O3.UI.IconButton:instance({
			parentFrame = self.content.frame,
			text = 'Click to make a permanent copy of this letter',
			onEnter = function (iconButton)
				GameTooltip:SetOwner(iconButton.frame, "ANCHOR_RIGHT")
				GameTooltip:AddLine(self.text, 1, 1, 0)
				CursorUpdate(iconButton.frame)
				GameTooltip:Show()
			end,
			onLeave = function (iconButton)
				GameTooltip:Hide()
				ResetCursor()
			end,
			onClick = function (iconButton)
				TakeInboxTextItem(self.id)
			end,
		})
		self.takeCopyControl:point('TOPLEFT', self.goldControl.frame, 'TOPRIGHT', 2, 0)
	end,
	createDetail = function (self)
		local fromLabel = self.content:createFontString({
			text = 'From :',
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
		subjectLabel:SetPoint('TOPLEFT', fromLabel, 'BOTTOMLEFT', 0, 0)

		local fromText = self.content:createFontString({
			justifyH = 'LEFT',
			color = {1,1,0},
			height = 24,
		})
		fromText:SetPoint('LEFT', fromLabel, 'RIGHT', 8, 0)
		self.fromText = fromText

		local subjectText = self.content:createFontString({
			justifyH = 'LEFT',
			color = {1,1,0},
			height = 24,
		})
		subjectText:SetPoint('LEFT', subjectLabel, 'RIGHT', 8, 0)
		self.subjectText = subjectText


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
					text = ' test ',
					lines = 10,
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
				scrollFrame.frame:EnableMouse(true)
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
		self.contentText = self.scrollFrame.scrollChild.frame

		self:createGoldControl()
		self:createTakeCopyControl()
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
			update = function(attachment, id, name, itemTexture, count, quality)
				if name then
					attachment.id = id
					attachment:setTexture(itemTexture)
					if (count > 1) then
						attachment.count:SetText(count)
					else
						attachment.count:SetText('')
					end
				else
					attachment.id = nil
					attachment.count:SetText('')
					attachment:setTexture(nil)
				end
			end,
			onClick = function (attachment)
				TakeInboxItem(self.id, attachment.id)
			end,
			onEnter = function (attachment)
				if (attachment.id) then
					GameTooltip:SetOwner(attachment.frame, "ANCHOR_RIGHT")
					if (self.codAmount > 0) then
						GameTooltip:AddLine('Take item to accept the C.O.D. amount of :'..O3:formatMoney(self.codAmount), 1, 1, 1)
					else
						GameTooltip:SetInboxItem(self.id, attachment.id)
					end
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
		local rowCount = math.floor(ATTACHMENTS_MAX_RECEIVE/2)
		for i = 1, ATTACHMENTS_MAX_RECEIVE do
			local attachment = self:createAttachment(i)
			if not lastAttachment then
				attachment:point('BOTTOMLEFT', self.content.frame, 'BOTTOMLEFT', 46, 38)
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
				self.replyControl = O3.UI.Button:instance({
					parentFrame = toolbar.frame,
					color = {0.2, 0.5, 0.2, 1},
					offset = {2, nil, 2, nil},
					text = 'Reply',
					width = 90,
					onMouseDown = function ()
						self.parent:replyToMail(self.id)
					end
				})

				self.deleteControl = O3.UI.Button:instance({
					parentFrame = self.content.frame,
					color = {0.5, 0.2, 0.2, 1},
					text = 'Delete',
					width = 90,
					onMouseDown = function ()
						DeleteInboxItem(self.id)
					end,
					postInit = function (iconButton)
						iconButton:point('TOPLEFT', self.replyControl.frame, 'TOPRIGHT', 2, 0)
					end,
				})
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

-- local CopyChat = CreateFrame('Frame', 'nChatCopy', UIParent)
-- CopyChat:SetWidth(500)
-- CopyChat:SetHeight(400)
-- CopyChat:SetPoint('LEFT', UIParent, 'LEFT', 3, 10)
-- CopyChat:SetFrameStrata('DIALOG')
-- --CopyChat:Hide()
-- CopyChat:SetBackdrop({
-- 	bgFile = [[Interface\Buttons\WHITE8x8]],
-- 	insets = {left = 3, right = 3, top = 4, bottom = 3
-- }})
-- CopyChat:SetBackdropColor(0, 0, 0, 0.7)

-- --CreateBorder(CopyChat, 12, 1, 1, 1)


-- local Scroll = CreateFrame('ScrollFrame', 'nChatCopyScroll', CopyChat, 'UIPanelScrollFrameTemplate')

-- CopyChatBox = CreateFrame('EditBox', 'nChatCopyBox', Scroll)
-- CopyChatBox:SetMultiLine(true)
-- CopyChatBox:SetAutoFocus(true)
-- CopyChatBox:EnableMouse(true)
-- CopyChatBox:SetMaxLetters(99999)
-- CopyChatBox:SetFont('Fonts\\ARIALN.ttf', 13, 'THINOUTLINE')
-- CopyChatBox:SetWidth(590)
-- CopyChatBox:SetHeight(590)
-- CopyChatBox:SetScript('OnEscapePressed', function() CopyChat:Hide() end)



-- Scroll:SetPoint('TOPLEFT', CopyChat, 'TOPLEFT', 8, -30)
-- Scroll:SetPoint('BOTTOMRIGHT', CopyChat, 'BOTTOMRIGHT', -30, 8)
-- Scroll:SetScrollChild(CopyChatBox)