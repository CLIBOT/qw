-- data saved to moderation.json
-- check moderation plugin
do

local function create_group(msg)
     -- superuser and admins only (because sudo are always has privilege)
    if is_sudo(msg) or is_realm(msg) and is_admin1(msg) then
		local group_creator = msg.from.print_name
		create_group_chat (group_creator, group_name, ok_cb, false)
		return 'گروه [ '..string.gsub(group_name, '_', ' ')..' ] ساخته شد.'
	end
end

local function create_realm(msg)
        -- superuser and admins only (because sudo are always has privilege)
	if is_sudo(msg) or is_realm(msg) and is_admin1(msg) then
		local group_creator = msg.from.print_name
		create_group_chat (group_creator, group_name, ok_cb, false)
		return 'ریلم [ '..string.gsub(group_name, '_', ' ')..' ] ساخته شد.'
	end
end


local function killchat(cb_extra, success, result)
  local receiver = cb_extra.receiver
  local chat_id = "chat#id"..result.peer_id
  local chatname = result.print_name
  for k,v in pairs(result.members) do
    kick_user_any(v.peer_id, result.peer_id)
  end
end

local function killrealm(cb_extra, success, result)
  local receiver = cb_extra.receiver
  local chat_id = "chat#id"..result.peer_id
  local chatname = result.print_name
  for k,v in pairs(result.members) do
    kick_user_any(v.peer_id, result.peer_id)
  end
end

local function get_group_type(msg)
  local data = load_data(_config.moderation.data)
  if data[tostring(msg.to.id)] then
    if not data[tostring(msg.to.id)]['group_type'] then
		if msg.to.type == 'chat' and not is_realm(msg) then
			data[tostring(msg.to.id)]['group_type'] = 'Group'
			save_data(_config.moderation.data, data)
		elseif msg.to.type == 'channel' then
			data[tostring(msg.to.id)]['group_type'] = 'SuperGroup'
			save_data(_config.moderation.data, data)
		end
    end
		local group_type = data[tostring(msg.to.id)]['group_type']
		return group_type
	else
    return 'نوع گروه پیدا نشد.'
  end
end

local function callbackres(extra, success, result)
--vardump(result)
  local user = result.peer_id
  local name = string.gsub(result.print_name, "_", " ")
  local chat = 'chat#id'..extra.chatid
  local channel = 'channel#id'..extra.chatid
  send_large_msg(chat, user..'\n'..name)
  send_large_msg(channel, user..'\n'..name)
  return user
end

local function set_description(msg, data, target, about)
    if not is_admin1(msg) then
        return "فقط برای ادمین ها!"
    end
    local data_cat = 'description'
        data[tostring(target)][data_cat] = about
        save_data(_config.moderation.data, data)
        return 'توضیحات گروه اینچنین تنظیم شد:\n'..about
end

local function set_rules(msg, data, target)
    if not is_admin1(msg) then
        return "فقط برای ادمین ها!"
    end
    local data_cat = 'rules'
        data[tostring(target)][data_cat] = rules
        save_data(_config.moderation.data, data)
        return 'Set group rules to:\n'..rules
end
-- lock/unlock group name. bot automatically change group name when locked
local function lock_group_name(msg, data, target)
    if not is_admin1(msg) then
        return "فقط برای ادمین ها!"
    end
    local group_name_set = data[tostring(target)]['settings']['set_name']
    local group_name_lock = data[tostring(target)]['settings']['lock_name']
        if group_name_lock == 'yes' then
            return 'اسم گروه از قبل قفل بود'
        else
            data[tostring(target)]['settings']['lock_name'] = 'yes'
                save_data(_config.moderation.data, data)
                rename_chat('chat#id'..target, group_name_set, ok_cb, false)
        return 'اسم گروه قفل شد'
    end
end

local function unlock_group_name(msg, data, target)
    if not is_admin1(msg) then
        return "فقط برای ادمین ها!"
    end
    local group_name_set = data[tostring(target)]['settings']['set_name']
    local group_name_lock = data[tostring(target)]['settings']['lock_name']
        if group_name_lock == 'no' then
            return 'اسم گروه از قبل باز بود'
        else
            data[tostring(target)]['settings']['lock_name'] = 'no'
            save_data(_config.moderation.data, data)
        return 'اسم گروه باز شد'
    end
end
--lock/unlock group member. bot automatically kick new added user when locked
local function lock_group_member(msg, data, target)
    if not is_admin1(msg) then
        return "فقط برای ادمین ها!"
    end
    local group_member_lock = data[tostring(target)]['settings']['lock_member']
        if group_member_lock == 'yes' then
            return 'قفل ورود اعضا فعال است'
        else
            data[tostring(target)]['settings']['lock_member'] = 'yes'
            save_data(_config.moderation.data, data)
        end
        return 'قفل ورود اعضا فعال بود'
end

local function unlock_group_member(msg, data, target)
    if not is_admin1(msg) then
        return "فقط برای ادمین ها!"
    end
    local group_member_lock = data[tostring(target)]['settings']['lock_member']
        if group_member_lock == 'no' then
            return 'قفل ورود اعضا غیرفعال بود'
        else
            data[tostring(target)]['settings']['lock_member'] = 'no'
            save_data(_config.moderation.data, data)
        return 'قفل ورود اعضا غیرفعال شد'
	end
end

--lock/unlock group photo. bot automatically keep group photo when locked
local function lock_group_photo(msg, data, target)
    if not is_admin1(msg) then
        return "فقط برای ادمین ها!"
    end
    local group_photo_lock = data[tostring(target)]['settings']['lock_photo']
        if group_photo_lock == 'yes' then
            return 'عکس گروه قفل بود'
        else
            data[tostring(target)]['settings']['set_photo'] = 'waiting'
            save_data(_config.moderation.data, data)
        end
	return 'لطفا عکس جدید را ارسال کنید'
end

local function unlock_group_photo(msg, data, target)
    if not is_admin1(msg) then
        return "فقط برای ادمین ها!"
    end
    local group_photo_lock = data[tostring(target)]['settings']['lock_photo']
        if group_photo_lock == 'no' then
            return 'عکس گروه قفل نیست'
        else
            data[tostring(target)]['settings']['lock_photo'] = 'no'
            save_data(_config.moderation.data, data)
        return 'عکس گروه باز شد'
	end
end

local function lock_group_flood(msg, data, target)
    if not is_admin1(msg) then
        return "فقط برای ادمین ها!"
    end
    local group_flood_lock = data[tostring(target)]['settings']['flood']
        if group_flood_lock == 'yes' then
            return 'فلود قفل بود'
        else
            data[tostring(target)]['settings']['flood'] = 'yes'
            save_data(_config.moderation.data, data)
        return 'فلود قفل شد'
	end
end

local function unlock_group_flood(msg, data, target)
    if not is_admin1(msg) then
        return "فقط برای ادمین ها!"
    end
    local group_flood_lock = data[tostring(target)]['settings']['flood']
        if group_flood_lock == 'no' then
            return 'فلود باز بود'
        else
            data[tostring(target)]['settings']['flood'] = 'no'
            save_data(_config.moderation.data, data)
        return 'فلود قفل شد'
	end
end

local function lock_group_arabic(msg, data, target)
    if not is_admin1(msg) then
        return "فقط برای ادمین ها!"
    end
  local group_arabic_lock = data[tostring(target)]['settings']['lock_arabic']
  if group_arabic_lock == 'yes' then
    return 'قفل عربی فعال بود'
  else
    data[tostring(target)]['settings']['lock_arabic'] = 'yes'
    save_data(_config.moderation.data, data)
    return 'قفل عربی فعال شد'
  end
end

local function unlock_group_arabic(msg, data, target)
    if not is_admin1(msg) then
        return "فقط برای ادمین ها!"
    end
  local group_arabic_lock = data[tostring(target)]['settings']['lock_arabic']
  if group_arabic_lock == 'no' then
    return 'عربی/فارسی مجاز بود'
  else
    data[tostring(target)]['settings']['lock_arabic'] = 'no'
    save_data(_config.moderation.data, data)
    return 'عربی/فارسی مجاز شد'
  end
end

local function lock_group_rtl(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_rtl_lock = data[tostring(target)]['settings']['lock_rtl']
  if group_rtl_lock == 'yes' then
    return 'قفل RTL فعال بود'
  else
    data[tostring(target)]['settings']['lock_rtl'] = 'yes'
    save_data(_config.moderation.data, data)
    return 'قفل RTL فعال شد'
  end
end

local function unlock_group_rtl(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_rtl_lock = data[tostring(target)]['settings']['lock_rtl']
  if group_rtl_lock == 'no' then
    return 'قفل RTL غیرفعال بود'
  else
    data[tostring(target)]['settings']['lock_rtl'] = 'no'
    save_data(_config.moderation.data, data)
    return 'قفل RTL غیرفعال شد'
  end
end

local function lock_group_links(msg, data, target)
    if not is_admin1(msg) then
        return "فقط برای ادمین ها!"
    end
  local group_link_lock = data[tostring(target)]['settings']['lock_link']
  if group_link_lock == 'yes' then
    return 'ارسال لینک ممنوع بود'
  else
    data[tostring(target)]['settings']['lock_link'] = 'yes'
    save_data(_config.moderation.data, data)
    return 'ارسال لینک ممنوع شد'
  end
end

local function unlock_group_links(msg, data, target)
    if not is_admin1(msg) then
        return "فقط برای ادمین ها!"
    end
  local group_link_lock = data[tostring(target)]['settings']['lock_link']
  if group_link_lock == 'no' then
    return 'ارسال لینک مجاز بود'
  else
    data[tostring(target)]['settings']['lock_link'] = 'no'
    save_data(_config.moderation.data, data)
    return 'ارسال لینک مجاز شد'
  end
end

local function lock_group_spam(msg, data, target)
    if not is_admin1(msg) then
        return "فقط برای ادمین ها!"
    end
  local group_spam_lock = data[tostring(target)]['settings']['lock_spam']
  if group_spam_lock == 'yes' then
    return 'ارسال اسپم فعال بود'
  else
    data[tostring(target)]['settings']['lock_spam'] = 'yes'
    save_data(_config.moderation.data, data)
    return 'ارسال اسپم فعال شد'
  end
end

local function unlock_group_spam(msg, data, target)
    if not is_admin1(msg) then
        return "فقط برای ادمین ها!"
    end
  local group_spam_lock = data[tostring(target)]['settings']['lock_spam']
  if group_spam_lock == 'no' then
    return 'ارسال اسپم فعال نبود'
  else
    data[tostring(target)]['settings']['lock_spam'] = 'no'
    save_data(_config.moderation.data, data)
    return 'ارسال اسپم غیرفعال شد'
  end
end

local function lock_group_rtl(msg, data, target)
    if not is_admin1(msg) then
        return "فقط برای ادمین ها!"
    end
  local group_rtl_lock = data[tostring(target)]['settings']['lock_rtl']
  if group_rtl_lock == 'yes' then
    return 'RTL قفل بود'
  else
    data[tostring(target)]['settings']['lock_rtl'] = 'yes'
    save_data(_config.moderation.data, data)
    return 'RTL قفل شد'
  end
end

local function unlock_group_rtl(msg, data, target)
    if not is_admin1(msg) then
        return "فقط برای ادمین ها!"
    end
  local group_rtl_lock = data[tostring(target)]['settings']['lock_rtl']
  if group_rtl_lock == 'no' then
    return 'RTL غیرفعال بود'
  else
    data[tostring(target)]['settings']['lock_rtl'] = 'no'
    save_data(_config.moderation.data, data)
    return 'RTL غیرفعال شد'
  end
end

local function lock_group_sticker(msg, data, target)
    if not is_admin1(msg) then
        return "فقط برای ادمین ها!"
    end
  local group_sticker_lock = data[tostring(target)]['settings']['lock_sticker']
  if group_sticker_lock == 'yes' then
    return 'ارسال استیکر ممنوع بود'
  else
    data[tostring(target)]['settings']['lock_sticker'] = 'yes'
    save_data(_config.moderation.data, data)
    return 'ارسال استیکر ممنوع شد'
  end
end

local function unlock_group_sticker(msg, data, target)
    if not is_admin1(msg) then
        return "فقط برای ادمین ها!"
    end
	local group_sticker_lock = data[tostring(target)]['settings']['lock_sticker']
	if group_sticker_lock == 'no' then
		return 'ارسال استیکر مجاز بود'
	else
		data[tostring(target)]['settings']['lock_sticker'] = 'no'
		save_data(_config.moderation.data, data)
		return 'ارسال استیکر مجاز شد'
	end
end

local function set_public_membermod(msg, data, target)
    if not is_admin1(msg) then
        return "فقط برای ادمین ها!"
    end
	local group_public_lock = data[tostring(target)]['settings']['public']
	if group_public_lock == 'yes' then
		return 'گروه عمومی بود'
	else
		data[tostring(target)]['settings']['public'] = 'yes'
		save_data(_config.moderation.data, data)
	end
  return 'گروه عمومی شد'
end

local function unset_public_membermod(msg, data, target)
    if not is_admin1(msg) then
        return "فقط برای ادمین ها!"
    end
	local group_public_lock = data[tostring(target)]['settings']['public']
	if group_public_lock == 'no' then
		return 'گروه عمومی نیست'
	else
		data[tostring(target)]['settings']['public'] = 'no'
		save_data(_config.moderation.data, data)
		return 'گروه خصوصی شد'
	end
end

-- show group settings
local function show_group_settings(msg, data, target)
    local data = load_data(_config.moderation.data, data)
    if not is_admin1(msg) then
        return "فقط برای ادمین ها!"
    end
	if data[tostring(target)]['settings'] then
		if not data[tostring(target)]['settings']['public'] then
			data[tostring(target)]['settings']['public'] = 'no'
		end
	end
    local settings = data[tostring(target)]['settings']
    local text = "⚙تنظیمات #گروه :\nقفل اسم گروه : "..settings.lock_name.."\nقفل عکس گروه : "..settings.lock_photo.."\nقفل ورود اعضا : "..settings.lock_member.."\nقفل خروج اعضا : "..leave_ban.."\nحساسیت ضداسپم : "..NUM_MSG_MAX.."\nمحافظت از ورود ربات : "..bots_protection.."\nقفل لینک : "..settings.lock_link.."\nقفل RTL: "..settings.lock_rtl.."\nقفل استیکر: "..settings.lock_sticker.."\nعمومی : "..settings.public
end

-- show SuperGroup settings
local function show_super_group_settings(msg, data, target)
    local data = load_data(_config.moderation.data, data)
    if not is_admin1(msg) then
        return "فقط برای ادمین ها!"
    end
	if data[tostring(msg.to.id)]['settings'] then
		if not data[tostring(msg.to.id)]['settings']['public'] then
			data[tostring(msg.to.id)]['settings']['public'] = 'no'
		end
	end
		if data[tostring(target)]['settings'] then
		if not data[tostring(target)]['settings']['lock_rtl'] then
			data[tostring(target)]['settings']['lock_rtl'] = 'no'
		end
	end
	if data[tostring(target)]['settings'] then
		if not data[tostring(target)]['settings']['lock_member'] then
			data[tostring(target)]['settings']['lock_member'] = 'no'
		end
	end
    local settings = data[tostring(target)]['settings']
    local text = "⚙تنظیمات #سوپرگروه :\n💲قفل یوزرنیم: "..settings.lock_tag.."\n#⃣قفل هشتگ: "..settings.lock_hashtag.."\n🌐قفل سایت: "..settings.lock_site.."\n📮قفل ایمیل: "..settings.lock_email.."\n🔢قفل اعداد: "..settings.lock_number.."\n🔠قفل انگلیسی: "..settings.lock_english.."\n😌قفل اموجی: "..settings.lock_emoji.."\n💮قفل دستورات: "..settings.lock_command.."\n🔖قفل لینک : "..settings.lock_link.."\n👀قفل فلود: "..settings.flood.."\n💪حساسیت ضداسپم : "..NUM_MSG_MAX.."\n♒️قفل اسپم: "..settings.lock_spam.."\n👥قفل اعضا: "..settings.lock_member.."\n↔️قفل RTL: "..settings.lock_rtl.."\n🚸قفل پیام سرویسی : "..settings.lock_tgservice.."\n📑قفل استیکر: "..settings.lock_sticker.."\n🌍عمومی: "..settings.public.."\n👊تنظیمات سختگیرانه: "..settings.strict
    return text
end

local function returnids(cb_extra, success, result)
	local i = 1
    local receiver = cb_extra.receiver
    local chat_id = "chat#id"..result.peer_id
    local chatname = result.print_name
    local text = 'کاربران در '..string.gsub(chatname,"_"," ")..' (ایدی: '..result.peer_id..'):\n\n'
    for k,v in pairs(result.members) do
		if v.print_name then
			local username = ""
			text = text ..i..' - '.. string.gsub(v.print_name,"_"," ") .. "  [" .. v.peer_id .. "] \n\n"
		    i = i + 1
		end
    end
	local file = io.open("./groups/lists/"..result.peer_id.."memberlist.txt", "w")
	file:write(text)
	file:flush()
	file:close()
end

local function cb_user_info(cb_extra, success, result)
	local receiver = cb_extra.receiver
	if result.first_name then
		first_name = result.first_name:gsub("_", " ")
	else
		first_name = "None"
	end
	if result.last_name then
		last_name = result.last_name:gsub("_", " ")
	else
		last_name = "None"
	end
	if result.username then
		username = "@"..result.username
	else
		username = "@[none]"
	end
	text = "اطلاعات کاربر:\n\nایدی: "..result.peer_id.."\nنام: "..first_name.."\nنام خانوادگی: "..last_name.."\nیوزرنیم: "..username
	send_large_msg(receiver, text)
end

local function admin_promote(msg, admin_id)
	if not is_sudo(msg) then
        return "Access denied!"
    end
	local admins = 'admins'
	if not data[tostring(admins)] then
		data[tostring(admins)] = {}
		save_data(_config.moderation.data, data)
	end
	if data[tostring(admins)][tostring(admin_id)] then
		return admin_id..' یک ادمین بود.'
	end
	data[tostring(admins)][tostring(admin_id)] = admin_id
	save_data(_config.moderation.data, data)
	return admin_id..' یک ادمین شد.'
end

local function admin_demote(msg, admin_id)
    if not is_sudo(msg) then
        return "اطلاعات ناقص!"
    end
    local data = load_data(_config.moderation.data)
        local admins = 'admins'
	if not data[tostring(admins)] then
		data[tostring(admins)] = {}
		save_data(_config.moderation.data, data)
	end
	if not data[tostring(admins)][tostring(admin_id)] then
		return admin_id..' ادمین نبود.'
	end
	data[tostring(admins)][tostring(admin_id)] = nil
	save_data(_config.moderation.data, data)
	return admin_id..' از ادمینی درامد.'
end

local function admin_list(msg)
    local data = load_data(_config.moderation.data)
	local admins = 'admins'
	if not data[tostring(admins)] then
		data[tostring(admins)] = {}
		save_data(_config.moderation.data, data)
	end
	local message = 'لیست ادمین های گلوبال:\n'
	for k,v in pairs(data[tostring(admins)]) do
		message = message .. '- (at)' .. v .. ' [' .. k .. '] ' ..'\n'
	end
	return message
end

local function groups_list(msg)
	local data = load_data(_config.moderation.data)
	local groups = 'groups'
	if not data[tostring(groups)] then
		return 'گروهی موجود نیست'
	end
	local message = 'لیست گروه ها:\n'
	for k,v in pairs(data[tostring(groups)]) do
		if data[tostring(v)] then
			if data[tostring(v)]['settings'] then
			local settings = data[tostring(v)]['settings']
				for m,n in pairs(settings) do
					if m == 'set_name' then
						name = n
					end
				end
                local group_owner = "No owner"
                if data[tostring(v)]['set_owner'] then
                        group_owner = tostring(data[tostring(v)]['set_owner'])
                end
                local group_link = "No link"
                if data[tostring(v)]['settings']['set_link'] then
					group_link = data[tostring(v)]['settings']['set_link']
				end
				message = message .. '- '.. name .. ' (' .. v .. ') ['..group_owner..'] \n {'..group_link.."}\n"
			end
		end
	end
    local file = io.open("./groups/lists/groups.txt", "w")
	file:write(message)
	file:flush()
	file:close()
    return message
end
local function realms_list(msg)
    local data = load_data(_config.moderation.data)
	local realms = 'realms'
	if not data[tostring(realms)] then
		return 'ریلمی موجود نیست'
	end
	local message = 'لیست ریلم ها:\n'
	for k,v in pairs(data[tostring(realms)]) do
		local settings = data[tostring(v)]['settings']
		for m,n in pairs(settings) do
			if m == 'set_name' then
				name = n
			end
		end
		local group_owner = "No owner"
		if data[tostring(v)]['admins_in'] then
			group_owner = tostring(data[tostring(v)]['admins_in'])
		end
		local group_link = "No link"
		if data[tostring(v)]['settings']['set_link'] then
			group_link = data[tostring(v)]['settings']['set_link']
		end
		message = message .. '- '.. name .. ' (' .. v .. ') ['..group_owner..'] \n {'..group_link.."}\n"
	end
	local file = io.open("./groups/lists/realms.txt", "w")
	file:write(message)
	file:flush()
	file:close()
    return message
end
local function admin_user_promote(receiver, member_username, member_id)
        local data = load_data(_config.moderation.data)
        if not data['admins'] then
                data['admins'] = {}
            save_data(_config.moderation.data, data)
        end
        if data['admins'][tostring(member_id)] then
            return send_large_msg(receiver, '@'..member_username..' ادمین بود.')
        end
        data['admins'][tostring(member_id)] = member_username
        save_data(_config.moderation.data, data)
	return send_large_msg(receiver, '@'..member_username..' ادمین شد.')
end

local function admin_user_demote(receiver, member_username, member_id)
    local data = load_data(_config.moderation.data)
    if not data['admins'] then
		data['admins'] = {}
        save_data(_config.moderation.data, data)
	end
	if not data['admins'][tostring(member_id)] then
		send_large_msg(receiver, "@"..member_username..' ادمین نیست.')
		return
    end
	data['admins'][tostring(member_id)] = nil
	save_data(_config.moderation.data, data)
	send_large_msg(receiver, 'Admin @'..member_username..' از ادیمینی درامد.')
end

local function username_id(cb_extra, success, result)
   local mod_cmd = cb_extra.mod_cmd
   local receiver = cb_extra.receiver
   local member = cb_extra.member
   local text = 'کاربری در این گروه @'..member..' موجود نیست.'
   for k,v in pairs(result.members) do
      vusername = v.username
      if vusername == member then
        member_username = member
        member_id = v.peer_id
        if mod_cmd == 'addadmin' then
            return admin_user_promote(receiver, member_username, member_id)
        elseif mod_cmd == 'removeadmin' then
            return admin_user_demote(receiver, member_username, member_id)
        end
      end
   end
   send_large_msg(receiver, text)
end

local function res_user_support(cb_extra, success, result)
   local receiver = cb_extra.receiver
   local get_cmd = cb_extra.get_cmd
   local support_id = result.peer_id
	if get_cmd == 'addsupport' then
		support_add(support_id)
		send_large_msg(receiver, "کاربر ["..support_id.."] به تیم پشتیبانی افزوده شد")
	elseif get_cmd == 'removesupport' then
		support_remove(support_id)
		send_large_msg(receiver, "کاربر ["..support_id.."] از تیم پشتیبانی حذف شد")
	end
end

local function set_log_group(target, data)
  if not is_admin1(msg) then
    return
  end
  local log_group = data[tostring(target)]['log_group']
  if log_group == 'yes' then
    return 'گزارش گروه فعال بود'
  else
    data[tostring(target)]['log_group'] = 'yes'
    save_data(_config.moderation.data, data)
    return 'گزارش گروه فعال شد'
  end
end

local function unset_log_group(msg)
  if not is_admin1(msg) then
    return
  end
  local log_group = data[tostring(target)]['log_group']
  if log_group == 'no' then
    return 'گزارش گروه فعال نبود'
  else
    data[tostring(target)]['log_group'] = 'no'
    save_data(_config.moderation.data, data)
    return 'گزارش گروه غیرفعال شد'
  end
end

local function help()
local help_text = tostring(_config.help_text_realm)
  return help_text
end

function run(msg, matches)
   	local name_log = user_print_name(msg.from)
		if matches[1] == 'گزارش' and is_owner(msg) then
		local receiver = get_receiver(msg)
		savelog(msg.to.id, "log file created by owner/support/admin")
		send_document(receiver,"./groups/logs/"..msg.to.id.."log.txt", ok_cb, false)
    end

	if matches[1] == 'افراد' and msg.to.type == 'chat' and is_momod(msg) then
		local name = user_print_name(msg.from)
		savelog(msg.to.id, name.." ["..msg.from.id.."] requested member list ")
		local receiver = get_receiver(msg)
		chat_info(receiver, returnids, {receiver=receiver})
		local file = io.open("./groups/lists/"..msg.to.id.."memberlist.txt", "r")
		text = file:read("*a")
        send_large_msg(receiver,text)
        file:close()
	end
	if matches[1] == 'لیست_افراد' and is_momod(msg) then
		local name = user_print_name(msg.from)
		savelog(msg.to.id, name.." ["..msg.from.id.."] requested member list in a file")
		local receiver = get_receiver(msg)
		chat_info(receiver, returnids, {receiver=receiver})
		send_document("chat#id"..msg.to.id,"./groups/lists/"..msg.to.id.."memberlist.txt", ok_cb, false)
	end

	if matches[1] == 'کیست' and is_momod(msg) then
		local receiver = get_receiver(msg)
		local user_id = "user#id"..matches[2]
		user_info(user_id, cb_user_info, {receiver = receiver})
	end

	if not is_sudo(msg) then
		if is_realm(msg) and is_admin1(msg) then
			print("Admin detected")
		else
			return
		end
 	end

    if matches[1] == 'ساخت_گروه' and matches[2] then
        group_name = matches[2]
        group_type = 'group'
        return create_group(msg)
    end

	--[[ Experimental
	if matches[1] == 'ساخت_سوپرگروه' and matches[2] then
	if not is_sudo(msg) or is_admin1(msg) and is_realm(msg) then
		return "You cant create groups!"
	end
        group_name = matches[2]
        group_type = 'super_group'
        return create_group(msg)
    end]]

    if matches[1] == 'ساخت_ریلم' and matches[2] then
			if not is_sudo(msg) then
				return "Sudo users only !"
			end
        group_name = matches[2]
        group_type = 'realm'
        return create_realm(msg)
    end

    local data = load_data(_config.moderation.data)
    local receiver = get_receiver(msg)
			if matches[1] == 'تنظیم_درباره' and matches[2] == 'گروه' and is_realm(msg) then
				local target = matches[3]
				local about = matches[4]
				return set_description(msg, data, target, about)
			end
			if matches[1] == 'تنظیم_درباره' and matches[2] == 'سوپرگروه'and is_realm(msg) then
				local channel = 'channel#id'..matches[3]
				local about_text = matches[4]
				local data_cat = 'description'
				local target = matches[3]
				channel_set_about(channel, about_text, ok_cb, false)
				data[tostring(target)][data_cat] = about_text
				save_data(_config.moderation.data, data)
				return "توضیحات برای گروه مورد نظر تنظیم شد ["..matches[2]..']'
			end
			if matches[1] == 'تنظیم_قوانین' then
				rules = matches[3]
				local target = matches[2]
				return set_rules(msg, data, target)
			end
			if matches[1] == 'قفل_کردن' then
				local target = matches[2]
				if matches[3] == 'اسم' then
					return lock_group_name(msg, data, target)
				end
				if matches[3] == 'اعضا' then
					return lock_group_member(msg, data, target)
				end
				if matches[3] == 'عکس' then
					return lock_group_photo(msg, data, target)
				end
				if matches[3] == 'فلود' then
					return lock_group_flood(msg, data, target)
				end
				if matches[2] == 'عربی' then
					return lock_group_arabic(msg, data, target)
				end
				if matches[3] == 'لینک' then
					return lock_group_links(msg, data, target)
				end
				if matches[3] == 'اسپم' then

					return lock_group_spam(msg, data, target)
				end
				if matches[3] == 'rtl' then
					return unlock_group_rtl(msg, data, target)
				end
				if matches[3] == 'استیکر' then
					return lock_group_sticker(msg, data, target)
				end
			end
			if matches[1] == 'باز_کردن' then
				local target = matches[2]
				if matches[3] == 'اسم' then
					return unlock_group_name(msg, data, target)
				end
				if matches[3] == 'اعضا' then
					return unlock_group_member(msg, data, target)
				end
				if matches[3] == 'عکس' then
					return unlock_group_photo(msg, data, target)
				end
				if matches[3] == 'فلود' then
					return unlock_group_flood(msg, data, target)
				end
				if matches[3] == 'عربی' then
					return unlock_group_arabic(msg, data, target)
				end
				if matches[3] == 'لینک' then
					return unlock_group_links(msg, data, target)
				end
				if matches[3] == 'اسپم' then
					return unlock_group_spam(msg, data, target)
				end
				if matches[3] == 'rtl' then
					return unlock_group_rtl(msg, data, target)
				end
				if matches[3] == 'استیکر' then
					return unlock_group_sticker(msg, data, target)
				end
			end

		if matches[1] == 'تنظیمات' and matches[2] == 'گروه' and data[tostring(matches[3])]['settings'] then
			local target = matches[3]
			text = show_group_settingsmod(msg, target)
			return text.."\nایدی: "..target.."\n"
		end
		if  matches[1] == 'تنظیمات' and matches[2] == 'سوپرگروه' and data[tostring(matches[3])]['settings'] then
			local target = matches[3]
			text = show_supergroup_settingsmod(msg, target)
			return text.."\nID: "..target.."\n"
		end

		if matches[1] == 'تنظیم_اسم' and is_realm(msg) then
			local settings = data[tostring(matches[2])]['settings']
			local new_name = string.gsub(matches[2], '_', ' ')
			data[tostring(msg.to.id)]['settings']['set_name'] = new_name
			save_data(_config.moderation.data, data)
			local group_name_set = data[tostring(msg.to.id)]['settings']['set_name']
			local to_rename = 'chat#id'..msg.to.id
			rename_chat(to_rename, group_name_set, ok_cb, false)
			savelog(msg.to.id, "Realm { "..msg.to.print_name.." }  name changed to [ "..new_name.." ] by "..name_log.." ["..msg.from.id.."]")
        end

		if matches[1] == 'تنظیم_اسم_گروه' and is_admin1(msg) then
		    local new_name = string.gsub(matches[3], '_', ' ')
		    data[tostring(matches[2])]['settings']['set_name'] = new_name
		    save_data(_config.moderation.data, data)
		    local group_name_set = data[tostring(matches[2])]['settings']['set_name']
		    local chat_to_rename = 'chat#id'..matches[2]
			local channel_to_rename = 'channel#id'..matches[2]
		    rename_chat(to_rename, group_name_set, ok_cb, false)
			rename_channel(channel_to_rename, group_name_set, ok_cb, false)
			savelog(matches[3], "Group { "..group_name_set.." }  name changed to [ "..new_name.." ] by "..name_log.." ["..msg.from.id.."]")
		end

    	if matches[1] == 'راهنما' and is_realm(msg) then
      		savelog(msg.to.id, name_log.." ["..msg.from.id.."] Used /help")
     		return help()
    	end
		--[[if matches[1] == 'تنظیم' then
			if matches[2] == 'گزارش_گروه' and is_sudo(msg) then
				local target = msg.to.peer_id
                savelog(msg.to.peer_id, name_log.." ["..msg.from.id.."] set as log group")
				return set_log_group(target, data)
			end
		end
		if matches[1] == 'حذف' then
			if matches[2] == 'گزارش_گروه' and is_sudo(msg) then
				local target = msg.to.id
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] set as log group")
				return unset_log_group(target, data)
			end
		end]]
		if matches[1] == 'خراب_کردن' and matches[2] == 'گروه' and matches[3] then
			if not is_admin1(msg) then
				return
			end
			if is_realm(msg) then
				local receiver = 'chat#id'..matches[3]
				return modrem(msg),
				print("Closing Group: "..receiver),
				chat_info(receiver, killchat, {receiver=receiver})
			else
				return 'خطا: گروه '..matches[3]..' پیدا نشد'
			end
		end
		if matches[1] == 'خراب_کردن' and matches[2] == 'ریلم' and matches[3] then
			if not is_admin1(msg) then
				return
			end
			if is_realm(msg) then
				local receiver = 'chat#id'..matches[3]
				return realmrem(msg),
				print("Closing realm: "..receiver),
				chat_info(receiver, killrealm, {receiver=receiver})
			else
				return 'خطا: ریلم '..matches[3]..' پیدا نشد'
			end
		end
		if matches[1] == 'حذف' and matches[2] then
			-- Group configuration removal
			data[tostring(matches[2])] = nil
			save_data(_config.moderation.data, data)
			local groups = 'groups'
			if not data[tostring(groups)] then
				data[tostring(groups)] = nil
				save_data(_config.moderation.data, data)
			end
			data[tostring(groups)][tostring(matches[2])] = nil
			save_data(_config.moderation.data, data)
			send_large_msg(receiver, 'گروه '..matches[2]..' حذف شد')
		end

		if matches[1] == 'chat_add_user' then
		    if not msg.service then
		        return
		    end
		    local user = 'user#id'..msg.action.user.id
		    local chat = 'chat#id'..msg.to.id
		    if not is_admin1(msg) and is_realm(msg) then
				  chat_del_user(chat, user, ok_cb, true)
			end
		end
		if matches[1] == 'افزودن_ادمین' then
		    if not is_sudo(msg) then-- Sudo only
				return
			end
			if string.match(matches[2], '^%d+$') then
				local admin_id = matches[2]
				print("user "..admin_id.." has been promoted as admin")
				return admin_promote(msg, admin_id)
			else
			  local member = string.gsub(matches[2], "@", "")
				local mod_cmd = "addadmin"
				chat_info(receiver, username_id, {mod_cmd= mod_cmd, receiver=receiver, member=member})
			end
		end
		if matches[1] == 'حذف_ادمین' then
		    if not is_sudo(msg) then-- Sudo only
				return
			end
			if string.match(matches[2], '^%d+$') then
				local admin_id = matches[2]
				print("user "..admin_id.." has been demoted")
				return admin_demote(msg, admin_id)
			else
			local member = string.gsub(matches[2], "@", "")
				local mod_cmd = "removeadmin"
				chat_info(receiver, username_id, {mod_cmd= mod_cmd, receiver=receiver, member=member})
			end
		end
		if matches[1] == 'پشتیبانی' and matches[2] then
			if string.match(matches[2], '^%d+$') then
				local support_id = matches[2]
				print("User "..support_id.." has been added to the support team")
				support_add(support_id)
				return "کاربر ["..support_id.."] به تیم پشتیبانی افزوده شد"
			else
				local member = string.gsub(matches[2], "@", "")
				local receiver = get_receiver(msg)
				local get_cmd = "addsupport"
				resolve_username(member, res_user_support, {get_cmd = get_cmd, receiver = receiver})
			end
		end
		if matches[1] == '-پشتیبانی' then
			if string.match(matches[2], '^%d+$') then
				local support_id = matches[2]
				print("User "..support_id.." has been removed from the support team")
				support_remove(support_id)
				return "کاربر ["..support_id.."] از تیم پشتیبانی حذف شد"
			else
				local member = string.gsub(matches[2], "@", "")
				local receiver = get_receiver(msg)
				local get_cmd = "removesupport"
				resolve_username(member, res_user_support, {get_cmd = get_cmd, receiver = receiver})
			end
		end
		if matches[1] == 'نوع'then
             local group_type = get_group_type(msg)
			return group_type
		end
		if matches[1] == 'لیست' then
			if matches[2] == 'ادمین_ها' then
				return admin_list(msg)
			end
			if matches[2] == 'پشتیبان' and not matches[2] then
				return support_list()
			end
		end
		
		if matches[1] == 'لیست' and matches[2] == 'گروه_ها' then
			if msg.to.type == 'chat' or msg.to.type == 'channel' then
				groups_list(msg)
				send_document("chat#id"..msg.to.id, "./groups/lists/groups.txt", ok_cb, false)
				send_document("channel#id"..msg.to.id, "./groups/lists/groups.txt", ok_cb, false)
				return "لیست گروه ساخته شد" --group_list(msg)
			elseif msg.to.type == 'user' then
				groups_list(msg)
				send_document("user#id"..msg.from.id, "./groups/lists/groups.txt", ok_cb, false)
				return "لیست گروه ساخته شد" --group_list(msg)
			end
		end
		if matches[1] == 'لیست' and matches[2] == 'ریلم_ها' then
			if msg.to.type == 'chat' or msg.to.type == 'channel' then
				realms_list(msg)
				send_document("chat#id"..msg.to.id, "./groups/lists/realms.txt", ok_cb, false)
				send_document("channel#id"..msg.to.id, "./groups/lists/realms.txt", ok_cb, false)
				return "لیست ریلم ساخته شد" --realms_list(msg)
			elseif msg.to.type == 'user' then
				realms_list(msg)
				send_document("user#id"..msg.from.id, "./groups/lists/realms.txt", ok_cb, false)
				return "لیست ریلم ساخته شد" --realms_list(msg)
			end
		end
   		if matches[1] == 'درمورد' and is_momod(msg) then
      		local cbres_extra = {
        		chatid = msg.to.id
     		}
      	local username = matches[2]
      	local username = username:gsub("@","")
      	savelog(msg.to.id, name_log.." ["..msg.from.id.."] Used /res "..username)
      	return resolve_username(username,  callbackres, cbres_extra)
    end
end

return {
  patterns = {
    "^[#](ساخت_گروه) (.*)$",
	"^[#](ساخت_سوپرگروه) (.*)$",
    "^[#](ساخت_ریلم) (.*)$",
    "^[#](تنظیم_درباره) (%d+) (.*)$",
    "^[#](تنظیم_قوانین) (%d+) (.*)$",
    "^[#](تنظیم_اسم) (.*)$",
    "^[#](تنظیم_اسم_گروه) (%d+) (.*)$",
    "^[#](تنظیم_اسم) (%d+) (.*)$",
    "^[#](قفل_کردن) (%d+) (.*)$",
    "^[#](باز_کردن) (%d+) (.*)$",
	"^[#](ممنوع_کردن) (%d+)$",
	"^[#](ازاد_کردن) (%d+)$",
    "^[#](تنظیمات) (.*) (%d+)$",
    "^[#](لیست_افراد)$",
    "^[#](افراد)$",
	"^[#](کیست) (.*)",
    "^[#](نوع)$",
    "^[#](خراب_کردن) (گروه) (%d+)$",
    "^[#](خراب_کردن) (ریلم) (%d+)$",
	"^[#](حذف) (%d+)$",
    "^[#](افزودن_ادمین) (.*)$", -- sudoers only
    "^[#](حذف_ادمین) (.*)$", -- sudoers only
	"[#](پشتیبانی)$",
	"^[#](پشتیبانی) (.*)$",
    "^[#](-پشتیبانی) (.*)$",
    "^[#](لیست) (.*)$",
    "^[#](گزارش)$",
    "^[#](راهنما)$",
    "^!!tgservice (.+)$",
  },
  run = run
}
end
