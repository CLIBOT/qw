local function pre_process(msg)
local to = msg.to.type
local service = msg.service
	if to == 'user' and msg.fwd_from then
		if not is_support(msg.from.id) and not is_admin1(msg) then
			return
		end
		local user = 'user#id'..msg.from.id
		local from_id = msg.fwd_from.peer_id
		if msg.fwd_from.first_name then
			from_first_name = msg.fwd_from.first_name:gsub("_", " ")
		else
			from_first_name = "None"
		end
		if msg.fwd_from.last_name then
			from_last_name = msg.fwd_from.last_name:gsub("_", " ")
		else
			from_last_name = "None"
		end
		if msg.fwd_from.username then
			from_username = "@"..msg.fwd_from.username
		else
			from_username = "@[none]"
		end
		text = "اطلاعات کاربر:\n\nایدی: "..from_id.."\nاسم: "..from_first_name.."\nفامیل: "..from_last_name.."\nیوزرنیم: "..from_username
		send_large_msg(user, text)
	end
	return msg
end

local function chat_list(msg)
	i = 1
	local data = load_data(_config.moderation.data)
    local groups = 'groups'
    if not data[tostring(groups)] then
        return 'هیچ گروهی الان موجود نیست'
    end
    local message = 'لیست گروه ها:\n*از دستور [جوین (ایدی گروه] برای عضو شدن استفاده کنید*\n\n'
    for k,v in pairsByKeys(data[tostring(groups)]) do
		local group_id = v
		if data[tostring(group_id)] then
			settings = data[tostring(group_id)]['settings']
		end
		if settings then
			if not settings.public then
				public = 'no'
			else
				public = settings.public
			end
		end
        for m,n in pairsByKeys(settings) do
			--if m == 'public' then
				--public = n
			--end
			if public == 'no' then 
				group_info = ""
			elseif m == 'set_name' and public == 'yes' then
				name = n:gsub("", "")
				chat_name = name:gsub("‮", "")
				group_name_id = name .. '\n(ID: ' ..group_id.. ')\n\n'
				if name:match("[\216-\219][\128-\191]") then
					group_info = i..' - \n'..group_name_id
				else
					group_info = i..' - '..group_name_id
				end
				i = i + 1
			end
        end
		message = message..group_info
    end
        local file = io.open("./groups/lists/listed_groups.txt", "w")
        file:write(message)
        file:flush()
        file:close()
	return message
end

function super_help()
  local help_text = tostring(_config.help_text_super)
  return help_text
end

local function run(msg, matches)
local to = msg.to.type
local service = msg.service
local name_log = user_print_name(msg.from)
if to == 'user' or service or is_admin1(msg) and to == "chat" or to == "channel" then
	if is_gbanned(msg.from.id) then
        return 'شما بن گلوبال شده اید.'
	end
    if matches[1] == 'پیوستن_به' then
	local data = load_data(_config.moderation.data)
	if matches[2]:lower() == 'english' and matches[3]:lower() == 'support' then
		savelog(msg.to.id, name_log.." ["..msg.from.id.."] tried to join English support")
		local target = 1041751030
		local long_id = data[tostring(target)]['long_id']
		if is_banned(msg.from.id, tostring(target)) then
			return 'شما بن شده اید.'
		end
		if data[tostring(target)]['settings']['lock_member'] == 'yes' and not is_owner2(msg.from.id, tostring(target)) then
			return 'گروه عمومی نیست.'
		end
		if is_admin1(msg) then
			user_type = 'admin'
		else
			user_type = "regular"
		end
		group_name = data[tostring(target)]['settings']['set_name']
		local chat = long_id
		local channel = long_id
		local user = msg.from.peer_id
		chat_add_user(chat, user, ok_cb, false)
		channel_invite(channel, user, ok_cb, false)
	elseif matches[2]:lower() == 'persian' and matches[3]:lower() == 'support' then
		savelog(msg.to.id, name_log.." ["..msg.from.id.."] tried to join Persian support")
		local target = 1017700355
		local long_id = data[tostring(target)]['long_id']
		if is_banned(msg.from.id, tostring(target)) then
			return 'شما بن شده اید.'
		end
		if data[tostring(target)]['settings']['lock_member'] == 'yes' and not is_owner2(msg.from.id, '36088606') then
			return 'گروه عمومی نیست.'
		end
		if is_admin1(msg) then
			user_type = 'admin'
		else
			user_type = "regular"
		end
		group_name = data[tostring(target)]['settings']['set_name']
		local chat = long_id
		local channel = long_id
		local user = msg.from.peer_id
		chat_add_user(chat, user, ok_cb, false)
		channel_invite(channel, user, ok_cb, false)
	elseif string.match(matches[2], '^%d+$') then
		local long_id = tostring(data[tostring(matches[2])]['long_id'])
		if not data[tostring(matches[2])] then
			return "گروه پیدا نشد."
		end
		group_name = data[tostring(matches[2])]['settings']['set_name']
		if is_admin1(msg) then
			user_type = 'admin'
			local receiver = get_receiver(msg)
			local chat = long_id
			local channel = long_id
			local user = msg.from.peer_id
			chat_add_user(chat, user, ok_cb, false)
			channel_set_admin(channel, user, ok_cb, false)
		end
		if is_support(msg.from.id) and not is_admin1(msg) and not is_owner2(msg.fom.id, matches[2]) then
			user_type = "support"
			local receiver = get_receiver(msg)
			local chat = long_id
			local channel = long_id
			local user = msg.from.peer_id
			chat_add_user(chat, user, ok_cb, false)
			channel_set_mod(channel, user, ok_cb, false)
		end
        if is_banned(msg.from.id, matches[2]) then
			return 'شما بن شده اید.'
		end
		if data[tostring(matches[2])]['settings']['lock_member'] == 'yes' and not is_owner2(msg.from.id, matches[2]) then
			return 'گروه عمومی نیست.'
		end
			if not is_support(msg.from.id) and not is_admin1(msg) then
				user_type = "regular"
				local chat = long_id
				local channel = long_id
				local user = msg.from.peer_id
				chat_add_user(chat, user, ok_cb, false)
				channel_invite(channel, user, ok_cb, false)
			end
		end
	end
	end

	if msg.service and user_type == "support" and msg.action.type == "chat_add_user" and msg.from.id == 0 then
		local user_id = msg.action.user.id
		local user_name = msg.action.user.print_name
		local username = msg.action.user.username
		local group_name = string.gsub(msg.to.print_name, '_', ' ')
		savelog(msg.from.id, "Added Support member "..user_name.." to chat "..group_name.." (ID:"..msg.to.id..")")
		if username then
			send_large_msg("user#id"..user_id, "پشتیبان\n@"..username.."["..user_id.."] را به گروه نامبرده افزود:\n 👥 "..group_name.." (ID:"..msg.to.id..")" )
		else
			send_large_msg("user#id"..user_id, "پشتیبان\n["..user_id.."] را به گروه نامبرده افزود:\n 👥 "..group_name.." (ID:"..msg.to.id..")" )
		end
	end
	if msg.service and user_type == "admin" and msg.action.type == "chat_add_user" and msg.from.id == 0 then
		local user_id = msg.action.user.id
		local user_name = msg.action.user.print_name
		local username = msg.action.user.username
		savelog(msg.from.id, "Added Admin "..user_name.."  "..user_id.." to chat "..group_name.." (ID:"..msg.to.id..")")
		if username then
			send_large_msg("user#id"..user_id, "ادمین\n@"..username.."["..user_id.."] را به گروه نامبرده افزود:\n 👥 "..group_name.." (ID:"..msg.to.id..")" )
		else
			send_large_msg("user#id"..user_id, "ادمین:\n["..user_id.."] را به گروه نامبرده افزود:\n 👥 "..group_name.." (ID:"..msg.to.id..")" )
		end
	end

	if msg.service and user_type == "regular" and msg.action.type == "chat_add_user" and msg.from.id == 0 then
		local user_id = msg.action.user.id
		local user_name = msg.action.user.print_name
		print("Added "..user_id.." to chat "..msg.to.print_name.." (ID:"..msg.to.id..")")
		savelog(msg.from.id, "Added "..user_name.." to chat "..msg.to.print_name.." (ID:"..msg.to.id..")")
		send_large_msg("user#id"..user_id, "اضافه کرد شمارا به گروه:\n\n"..group_name.." (ایدی:"..msg.to.id..")")
	end

	if matches[1] == 'راهنما' and msg.to.type == 'user' or matches[1] == 'راهنماپیوی' and is_admin1(msg) and msg.to.type ~= 'user' then
      	savelog(msg.to.id, name_log.." ["..msg.from.id.."] used pm help")
		text = "به رادیکال بات خوش آمدید!\n\nبرای دیدن گروه های رادیکال دستور #گروه_ها را بفرستید.\n\nبرای درخواست گروه با این ربات فوق العاده بی نظیر به کانال @Radicalir بیایید\n\nممنون از انتخاب @Radicalir !"
     	return text
    end

	if matches[1] == 'راهنما_سوپرگروه' and is_admin1(msg)then
      	savelog(msg.to.id, name_log.." ["..msg.from.id.."] Used /superhelp")
     	return super_help()
	elseif matches[1] == 'راهنما_سوپرگروه' and to == "user" then
		local name_log = user_print_name(msg.from)
      	savelog(msg.to.id, name_log.." ["..msg.from.id.."] Used /superhelp")
     	return super_help()
    end

    if matches[1] == 'گروه_ها' and is_admin1(msg)then
		return chat_list(msg)
	elseif matches[1] == 'chats' and to == 'user' then
		savelog(msg.to.id, name_log.." ["..msg.from.id.."] Used /chats")
		return chat_list(msg)
    end

	if matches[1] == 'فایل_گروه_ها' then
	savelog(msg.to.id, name_log.." ["..msg.from.id.."] Used /chatlist")
		if is_admin1(msg) and msg.to.type == 'chat' or msg.to.type == 'channel' then
			chat_list(msg)
			send_document("chat#id"..msg.to.id, "./groups/lists/listed_groups.txt", ok_cb, false)
			send_document("channel#id"..msg.to.id, "./groups/lists/listed_groups.txt", ok_cb, false)
		elseif msg.to.type == 'user' then
			chat_list(msg)
			send_document("user#id"..msg.from.id, "./groups/lists/listed_groups.txt", ok_cb, false)
		end
	end
end

return {
    patterns = {
	"^[#](راهنما)$",
	"^[#](راهنما_پیوی)$",
	"^[#](راهنما_سوپرگروه)$",
    "^[#](گروه_ها)$",
    "^[#](فایل_گروه_ها)$",
    "^[#](پیوستن_به) (%d+)$",
	"^[#](پیوستن_به) (پشتیبانی) (.*)$",
    "^[#](اخراجم_کن) (.*)$",
    "^!!tgservice (chat_add_user)$",
    },
    run = run,
	pre_process = pre_process
}
