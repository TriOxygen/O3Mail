local addon, ns = ...
local O3 = O3

ns.MailWindow = O3.UI.PagerWindow:extend({
	name = 'O3Mail',
	titleText = 'Mail',
	_weight = 3,
	numTotal = 999999,
	closeWithEscape = true,
	managed = true,
	itemCount = 18,
	settings = {
		itemsTopGap = 24,
		itemsBottomGap = 0,
		itemHeight = 24,
	},
	checkedItems = {},
	MAIL_CLOSED = function (self)
		self:hide()
		self.handler:unregisterEvent('MAIL_INBOX_UPDATE', self)
	end,
	MAIL_INBOX_UPDATE = function (self)
		self:pageTo(self.page or 1)
	end,

	onShow = function (self)
		table.wipe(self.checkedItems)
		self.handler:registerEvent('MAIL_INBOX_UPDATE', self)
		self.handler:registerEvent('MAIL_CLOSED', self)
		CheckInbox()
	end,
	toggleCheck = function (self, id)
		self.checkedItems[id] = not self.checkedItems[id]
		self.items[id]:updateChecked()
	end,
	setChecked = function (self, id, checked)
		self.checkedItems[id] = checked
		if (self.items[id]) then
			self.items[id]:updateChecked()
		end
	end,
	createItem = function (self)
		return ns.MailItem:instance({
			height = self.settings.itemHeight,
			parentFrame = self.frame,
			onClick = function (mailItem)
				if (not self.detailWindow) then
					self.detailWindow = ns.MailDetailWindow:new(self)
				end
				self.detailWindow:show()
				self.detailWindow:update(mailItem.id)
			end,
		})
	end,
	replyToMail = function (self, id)
		if (not self.composeWindow) then
			self.composeWindow = ns.ComposeMailWindow:instance({
				parent = self,
			})
		end
		local packageIcon, stationeryIcon, sender, subject, money, codAmount, daysLeft, itemCount, wasRead, wasReturned, textCreated, canReply, isGM, itemQuantity = GetInboxHeaderInfo(id)
		self.composeWindow:show()
		self.composeWindow.toText.frame:SetText(sender)
		self.composeWindow.subjectText.frame:SetText('Re : '..subject)
	end,
	onHide = function (self)
		if (self.detailWindow) then
			self.detailWindow:hide()
		end
		if (self.composeWindow) then
			self.composeWindow:hide()
		end
		CloseMail()
		self.handler:unregisterEvent('MAIL_CLOSED', self)
	end,
	getNumItems = function (self, calculateDelta)
		local numItems, numTotal = GetInboxNumItems() 
		self.numItems = numItems
		self.numTotal = numTotal
	end,
	postCreate = function (self)
		self:createItems()
		self:createFooterControls()
		self:reset()
		O3.UI.Toolbar:instance({
			height = self.settings.itemsTopGap+2,
			parentFrame = self.frame,
			offset = {0, 0, self.settings.headerHeight-1, nil},
			createRegions = function (toolbar)
				O3.UI.Button:instance({
					text = 'Compose',
					color = {0.1, 0.9, 0.1, 1},
					width = 80,
					offset = {2, nil, 2, nil},
					parentFrame = toolbar.frame,
					onClick = function (button)
						if (not self.composeWindow) then
							self.composeWindow = ns.ComposeMailWindow:instance({
								parent = self,
							})
						end
						self.composeWindow:show()
					end,
				})
			end
		})
	end,

})
