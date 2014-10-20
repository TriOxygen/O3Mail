local addon, ns = ...
local O3 = O3

O3:module({
	name = 'Mail',
	readable = 'Mail',
    weight = 96,
	config = {
		enabled = true,
        font = O3.Media:font('Normal'),
        fontSize = 12,
        fontStyle = 'THINOUTLINE',
        autoLoot = false,
		xOffset = 0,
		yOffset = 100,
		anchor = 'CENTER',
		anchorTo = 'CENTER',
	},        
	events = {
		MAIL_SHOW = true,

        MAIL_SHOW = true,
        MAIL_INBOX_UPDATE = true,
        MAIL_CLOSED = true,
        MAIL_SEND_INFO_UPDATE = true,
        MAIL_SEND_SUCCESS = true,
        MAIL_FAILED = true,
        MAIL_SUCCESS = true,
        CLOSE_INBOX_ITEM = true,
        MAIL_LOCK_SEND_ITEMS = true,
        MAIL_UNLOCK_SEND_ITEMS = true,
    },
	settings = {
	},
	addOptions = function (self)
	
	end,
    MAIL_SHOW = function (self)
        if (not self.mailWindow) then
            self.mailWindow = ns.MailWindow:instance({
                handler = self,
            })
        end
        self.mailWindow:show()

    end,

    postInit = function (self)
        -- MailFrame.Show = function ()
        -- end
        -- MailFrame:Hide()
        O3:destroy(MailFrame)
        O3:destroy(StationeryPopupFrame)
        O3:destroy(OpenMailFrame)
    end,
})