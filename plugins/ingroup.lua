do

-- Check Member
local function check_member_autorealm(cb_extra, success, result)
  local receiver = cb_extra.receiver
  local data = cb_extra.data
  local msg = cb_extra.msg
  for k,v in pairs(result.members) do
    local member_id = v.peer_id
    if member_id ~= our_id then
      -- Group configuration
      data[tostring(msg.to.id)] = {
        group_type = 'Realm',
        settings = {
          set_name = string.gsub(msg.to.print_name, '_', ' '),
          lock_name = 'yes',
          lock_photo = 'no',
          lock_member = 'no',
          flood = 'yes'
        }
      }
      save_data(_config.moderation.data, data)
      local realms = 'realms'
      if not data[tostring(realms)] then
        data[tostring(realms)] = {}
        save_data(_config.moderation.data, data)
      end
      data[tostring(realms)][tostring(msg.to.id)] = msg.to.id
      save_data(_config.moderation.data, data)
      return send_large_msg(receiver, 'به ریلم جدید خود خوش آمدید!')
    end
  end
end
local function check_member_realm_add(cb_extra, success, result)
  local receiver = cb_extra.receiver
  local data = cb_extra.data
  local msg = cb_extra.msg
  for k,v in pairs(result.members) do
    local member_id = v.peer_id
    if member_id ~= our_id then
      -- Group configuration
      data[tostring(msg.to.id)] = {
        group_type = 'Realm',
        settings = {
          set_name = string.gsub(msg.to.print_name, '_', ' '),
          lock_name = 'yes',
          lock_photo = 'no',
          lock_member = 'no',
          flood = 'yes'
        }
      }
      save_data(_config.moderation.data, data)
      local realms = 'realms'
      if not data[tostring(realms)] then
        data[tostring(realms)] = {}
        save_data(_config.moderation.data, data)
      end
      data[tostring(realms)][tostring(msg.to.id)] = msg.to.id
      save_data(_config.moderation.data, data)
      return send_large_msg(receiver, 'ریلم افزوده شد!')
    end
  end
end
function check_member_group(cb_extra, success, result)
  local receiver = cb_extra.receiver
  local data = cb_extra.data
  local msg = cb_extra.msg
  for k,v in pairs(result.members) do
    local member_id = v.peer_id
    if member_id ~= our_id then
      -- Group configuration
      data[tostring(msg.to.id)] = {
        group_type = 'Group',
        moderators = {},
        set_owner = member_id ,
        settings = {
          set_name = string.gsub(msg.to.print_name, '_', ' '),
          lock_name = 'yes',
          lock_photo = 'no',
          lock_member = 'no',
          flood = 'yes',
        }
      }
      save_data(_config.moderation.data, data)
      local groups = 'groups'
      if not data[tostring(groups)] then
        data[tostring(groups)] = {}
        save_data(_config.moderation.data, data)
      end
      data[tostring(groups)][tostring(msg.to.id)] = msg.to.id
      save_data(_config.moderation.data, data)
      return send_large_msg(receiver, 'شما به درجه مالک گروه ارتقا یافتید.')
    end
  end
end
local function check_member_modadd(cb_extra, success, result)
  local receiver = cb_extra.receiver
  local data = cb_extra.data
  local msg = cb_extra.msg
  for k,v in pairs(result.members) do
    local member_id = v.peer_id
    if member_id ~= our_id then
      -- Group configuration
      data[tostring(msg.to.id)] = {
        group_type = 'Group',
		long_id = msg.to.peer_id,
        moderators = {},
        set_owner = member_id ,
        settings = {
          set_name = string.gsub(msg.to.print_name, '_', ' '),
          lock_name = 'yes',
          lock_photo = 'no',
          lock_member = 'no',
          flood = 'yes',
        }
      }
      save_data(_config.moderation.data, data)
      local groups = 'groups'
      if not data[tostring(groups)] then
        data[tostring(groups)] = {}
        save_data(_config.moderation.data, data)
      end
      data[tostring(groups)][tostring(msg.to.id)] = msg.to.id
      save_data(_config.moderation.data, data)
      return send_large_msg(receiver, 'گروه اضافه شد و شما به عنوان مالک گروه از نظر ربات شناخته میشوید ')
    end
  end
end
local function automodadd(msg)
  local data = load_data(_config.moderation.data)
  if msg.action.type == 'chat_created' then
    receiver = get_receiver(msg)
    chat_info(receiver, check_member_group,{receiver=receiver, data=data, msg = msg})
  end
end
local function autorealmadd(msg)
  local data = load_data(_config.moderation.data)
  if msg.action.type == 'chat_created' then
    receiver = get_receiver(msg)
    chat_info(receiver, check_member_autorealm,{receiver=receiver, data=data, msg = msg})
  end
end
local function check_member_realmrem(cb_extra, success, result)
  local receiver = cb_extra.receiver
  local data = cb_extra.data
  local msg = cb_extra.msg
  for k,v in pairs(result.members) do
    local member_id = v.id
    if member_id ~= our_id then
      -- Realm configuration removal
      data[tostring(msg.to.id)] = nil
      save_data(_config.moderation.data, data)
      local realms = 'realms'
      if not data[tostring(realms)] then
        data[tostring(realms)] = nil
        save_data(_config.moderation.data, data)
      end
      data[tostring(realms)][tostring(msg.to.id)] = nil
      save_data(_config.moderation.data, data)
      return send_large_msg(receiver, 'ریلم حذف شد!')
    end
  end
end
local function check_member_modrem(cb_extra, success, result)
  local receiver = cb_extra.receiver
  local data = cb_extra.data
  local msg = cb_extra.msg
  for k,v in pairs(result.members) do
    local member_id = v.peer_id
    if member_id ~= our_id then
      -- Group configuration removal
      data[tostring(msg.to.id)] = nil
      save_data(_config.moderation.data, data)
      local groups = 'groups'
      if not data[tostring(groups)] then
        data[tostring(groups)] = nil
        save_data(_config.moderation.data, data)
      end
      data[tostring(groups)][tostring(msg.to.id)] = nil
      save_data(_config.moderation.data, data)
      return send_large_msg(receiver, 'گروه حذف شد')
    end
  end
end
--End Check Member
function show_group_settingsmod(msg, target)
 	if not is_momod(msg) then
    	return "فقط برای مدیران!"
  	end
  	local data = load_data(_config.moderation.data)
    if data[tostring(target)] then
     	if data[tostring(target)]['settings']['flood_msg_max'] then
        	NUM_MSG_MAX = tonumber(data[tostring(target)]['settings']['flood_msg_max'])
        	print('custom'..NUM_MSG_MAX)
      	else
        	NUM_MSG_MAX = 5
      	end
    end
    local bots_protection = "Yes"
    if data[tostring(target)]['settings']['lock_bots'] then
    	bots_protection = data[tostring(target)]['settings']['lock_bots']
   	end
    local leave_ban = "no"
    if data[tostring(target)]['settings']['leave_ban'] then
    	leave_ban = data[tostring(target)]['settings']['leave_ban']
   	end
	if data[tostring(target)]['settings'] then
		if not data[tostring(target)]['settings']['lock_link'] then
			data[tostring(target)]['settings']['lock_link'] = 'no'
		end
	end
	if data[tostring(target)]['settings'] then
		if not data[tostring(target)]['settings']['lock_sticker'] then
			data[tostring(target)]['settings']['lock_sticker'] = 'no'
		end
	end
	if data[tostring(target)]['settings'] then
		if not data[tostring(target)]['settings']['public'] then
			data[tostring(target)]['settings']['public'] = 'no'
		end
	end
	if data[tostring(target)]['settings'] then
		if not data[tostring(target)]['settings']['lock_rtl'] then
			data[tostring(target)]['settings']['lock_rtl'] = 'no'
		end
	end
  local settings = data[tostring(target)]['settings']
  local text = "⚙تنظیمات #گروه :\nقفل اسم گروه : "..settings.lock_name.."\nقفل عکس گروه : "..settings.lock_photo.."\nقفل ورود اعضا : "..settings.lock_member.."\nقفل خروج اعضا : "..leave_ban.."\nحساسیت ضداسپم : "..NUM_MSG_MAX.."\nمحافظت از ورود ربات : "..bots_protection.."\nقفل لینک : "..settings.lock_link.."\nقفل RTL: "..settings.lock_rtl.."\nقفل استیکر: "..settings.lock_sticker.."\nعمومی : "..settings.public
  return text
end

local function set_descriptionmod(msg, data, target, about)
  if not is_momod(msg) then
    return
  end
  local data_cat = 'description'
  data[tostring(target)][data_cat] = about
  save_data(_config.moderation.data, data)
  return '#توضیحات گروه اینچنین تنظیم شد:\n'..about
end
local function get_description(msg, data)
  local data_cat = 'description'
  if not data[tostring(msg.to.id)][data_cat] then
    return 'توضیحاتی موجود نیست.'
  end
  local about = data[tostring(msg.to.id)][data_cat]
  local about = string.gsub(msg.to.print_name, "_", " ")..':\n\n'..about
  return 'درباره گروه '..about
end
local function lock_group_arabic(msg, data, target)
  if not is_momod(msg) then
    return 
  end
  local group_arabic_lock = data[tostring(target)]['settings']['lock_arabic']
  if group_arabic_lock == 'yes' then
    return 'قفل عربی هم اکنون فعال است'
  else
    data[tostring(target)]['settings']['lock_arabic'] = 'yes'
    save_data(_config.moderation.data, data)
    return 'قفل عربی فعال شد'
  end
end

local function unlock_group_arabic(msg, data, target)
  if not is_momod(msg) then
    return 
  end
  local group_arabic_lock = data[tostring(target)]['settings']['lock_arabic']
  if group_arabic_lock == 'no' then
    return 'قفل عربی هم اکنون باز است'
  else
    data[tostring(target)]['settings']['lock_arabic'] = 'no'
    save_data(_config.moderation.data, data)
    return 'قفل عربی باز شد'
  end
end

local function lock_group_bots(msg, data, target)
  if not is_momod(msg) then
    return 
  end
  local group_bots_lock = data[tostring(target)]['settings']['lock_bots']
  if group_bots_lock == 'yes' then
    return 'محافظت از ورود ربات فعال بود'
  else
    data[tostring(target)]['settings']['lock_bots'] = 'yes'
    save_data(_config.moderation.data, data)
    return 'محافظت از ورود ربات فعال شد'
  end
end

local function unlock_group_bots(msg, data, target)
  if not is_momod(msg) then
    return 
  end
  local group_bots_lock = data[tostring(target)]['settings']['lock_bots']
  if group_bots_lock == 'no' then
    return 'محافظت از ورود ربات غیرفعال بود'
  else
    data[tostring(target)]['settings']['lock_bots'] = 'no'
    save_data(_config.moderation.data, data)
    return 'محافظت از ورود ربات غیرفعال شد'
  end
end

local function lock_group_namemod(msg, data, target)
  if not is_momod(msg) then
    return 
  end
  local group_name_set = data[tostring(target)]['settings']['set_name']
  local group_name_lock = data[tostring(target)]['settings']['lock_name']
  if group_name_lock == 'yes' then
    return 'اسم گروه محافظت میشد'
  else
    data[tostring(target)]['settings']['lock_name'] = 'yes'
    save_data(_config.moderation.data, data)
    rename_chat('chat#id'..target, group_name_set, ok_cb, false)
    return 'اسم گروه از این به بعد محافظت خواهد شد'
  end
end
local function unlock_group_namemod(msg, data, target)
  if not is_momod(msg) then
    return 
  end
  local group_name_set = data[tostring(target)]['settings']['set_name']
  local group_name_lock = data[tostring(target)]['settings']['lock_name']
  if group_name_lock == 'no' then
    return 'اسم گروه محافظت نمیشد'
  else
    data[tostring(target)]['settings']['lock_name'] = 'no'
    save_data(_config.moderation.data, data)
    return 'اسم گروه محافظت نخواهد شد'
  end
end
local function lock_group_floodmod(msg, data, target)
  if not is_momod(msg) then
    return 
  end
  local group_flood_lock = data[tostring(target)]['settings']['flood']
  if group_flood_lock == 'yes' then
    return 'جلوگیری از جاری شدن پیام های پشت سرهم فعال بود'
  else
    data[tostring(target)]['settings']['flood'] = 'yes'
    save_data(_config.moderation.data, data)
    return 'جلوگیری از جاری شدن پیام های پشت سرهم فعال شد'
  end
end

local function unlock_group_floodmod(msg, data, target)
  if not is_momod(msg) then
	return 
  end
  if not is_owner(msg) then
    return "فقط مالک گروه میتواند غیرفعال کند"
  end
  local group_flood_lock = data[tostring(target)]['settings']['flood']
  if group_flood_lock == 'no' then
    return 'جلوگیری از جاری شدن پیام های پشت سرهم غیرفعال بود'
  else
    data[tostring(target)]['settings']['flood'] = 'no'
    save_data(_config.moderation.data, data)
    return 'جلوگیری از جاری شدن پیام های پشت سرهم غیرفعال شد'
  end
end

local function lock_group_membermod(msg, data, target)
  if not is_momod(msg) then
    return 
  end
  local group_member_lock = data[tostring(target)]['settings']['lock_member']
  if group_member_lock == 'yes' then
    return 'قفل ورود اعضا فعال بود'
  else
    data[tostring(target)]['settings']['lock_member'] = 'yes'
    save_data(_config.moderation.data, data)
  end
  return 'قفل ورود اعضا فعال شد'
end

local function unlock_group_membermod(msg, data, target)
  if not is_momod(msg) then
    return 
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


local function set_public_membermod(msg, data, target)
  if not is_momod(msg) then
    return 
  end
  local group_member_lock = data[tostring(target)]['settings']['public']
  local long_id = data[tostring(target)]['long_id']
  if not long_id then
	data[tostring(target)]['long_id'] = msg.to.peer_id 
	save_data(_config.moderation.data, data)
  end
  if group_member_lock == 'yes' then
    return 'گروه هم اکنون عمومی شد'
  else
    data[tostring(target)]['settings']['public'] = 'yes'
    save_data(_config.moderation.data, data)
  end
  return 'وضعیت دسترسی به گروه: عمومی'
end

local function unset_public_membermod(msg, data, target)
  if not is_momod(msg) then
    return 
  end
  local group_member_lock = data[tostring(target)]['settings']['public']
  local long_id = data[tostring(target)]['long_id']
  if not long_id then
	data[tostring(target)]['long_id'] = msg.to.peer_id 
	save_data(_config.moderation.data, data)
  end
  if group_member_lock == 'no' then
    return 'گروه عمومی نیست'
  else
    data[tostring(target)]['settings']['public'] = 'no'
    save_data(_config.moderation.data, data)
    return 'وضعیت دسترسی به گروه: عمومی نیست'
  end
end

local function lock_group_leave(msg, data, target)
  if not is_momod(msg) then
    return 
  end
  local leave_ban = data[tostring(target)]['settings']['leave_ban']
  if leave_ban == 'yes' then
    return 'از قبل این ویژگی فعال بود'
  else
    data[tostring(target)]['settings']['leave_ban'] = 'yes'
    save_data(_config.moderation.data, data)
  end
  return 'کاربرانی که از گروه خارج شوند بن خواهند شد'
end

local function unlock_group_leave(msg, data, target)
  if not is_momod(msg) then
    return 
  end
  local leave_ban = data[tostring(msg.to.id)]['settings']['leave_ban']
  if leave_ban == 'no' then
    return 'از قبل این ویژگی غیرفعال بود'
  else
    data[tostring(target)]['settings']['leave_ban'] = 'no'
    save_data(_config.moderation.data, data)
    return 'کاربرانی که از گروه خارج شوند بن نخواهند شد'
  end
end

local function unlock_group_photomod(msg, data, target)
  if not is_momod(msg) then
    return 
  end
  local group_photo_lock = data[tostring(target)]['settings']['lock_photo']
  if group_photo_lock == 'no' then
    return 'عکس گروه محافظت نمیشد'
  else
    data[tostring(target)]['settings']['lock_photo'] = 'no'
    save_data(_config.moderation.data, data)
    return 'عکس گروه محافظت نمیشود'
  end
end

local function lock_group_links(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_link_lock = data[tostring(target)]['settings']['lock_link']
  if group_link_lock == 'yes' then
    return 'ارسال لینک از قبل ممنوع بود'
  else
    data[tostring(target)]['settings']['lock_link'] = 'yes'
    save_data(_config.moderation.data, data)
    return 'ارسال لینک ممنوع شد'
  end
end

local function unlock_group_links(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_link_lock = data[tostring(target)]['settings']['lock_link']
  if group_link_lock == 'no' then
    return 'ارسال لینک آزاد بود'
  else
    data[tostring(target)]['settings']['lock_link'] = 'no'
    save_data(_config.moderation.data, data)
    return 'ارسال لینک آزاد شد'
  end
end

local function lock_group_rtl(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_rtl_lock = data[tostring(target)]['settings']['lock_rtl']
  if group_rtl_lock == 'yes' then
    return 'RTL از قبل قفل بود'
  else
    data[tostring(target)]['settings']['lock_rtl'] = 'yes'
    save_data(_config.moderation.data, data)
    return 'RTL قفل شد'
  end
end

local function unlock_group_rtl(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_rtl_lock = data[tostring(target)]['settings']['lock_rtl']
  if group_rtl_lock == 'no' then
    return 'RTL باز بود'
  else
    data[tostring(target)]['settings']['lock_rtl'] = 'no'
    save_data(_config.moderation.data, data)
    return 'RTL باز شد'
  end
end

local function lock_group_sticker(msg, data, target)
  if not is_momod(msg) then
    return
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
  if not is_momod(msg) then
    return
  end
  local group_sticker_lock = data[tostring(target)]['settings']['lock_sticker']
  if group_sticker_lock == 'no' then
    return 'ارسال استیکر آزاد بود'
  else
    data[tostring(target)]['settings']['lock_sticker'] = 'no'
    save_data(_config.moderation.data, data)
    return 'ارسال استیکر آزاد شد'
  end
end

local function lock_group_contacts(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_rtl_lock = data[tostring(target)]['settings']['lock_contacts']
  if group_contacts_lock == 'yes' then
    return 'ارسال شماره مخاطب ممنوع بود'
  else
    data[tostring(target)]['settings']['lock_contacts'] = 'yes'
    save_data(_config.moderation.data, data)
    return 'ارسال شماره مخاطب ممنوع شد'
  end
end

local function unlock_group_contacts(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_contacts_lock = data[tostring(target)]['settings']['lock_contacts']
  if group_contacts_lock == 'no' then
    return 'ارسال شماره مخاطب آزاد بود'
  else
    data[tostring(target)]['settings']['lock_contacts'] = 'no'
    save_data(_config.moderation.data, data)
    return 'ارسال شماره مخاطب آزاد شد'
  end
end

local function enable_strict_rules(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_rtl_lock = data[tostring(target)]['settings']['strict']
  if strict == 'yes' then
    return 'تنظیمات سختیگرانه فعال بود'
  else
    data[tostring(target)]['settings']['strict'] = 'yes'
    save_data(_config.moderation.data, data)
    return 'تنظیمات سختیگرانه فعال شد'
  end
end

local function disable_strict_rules(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_contacts_lock = data[tostring(target)]['settings']['strict']
  if strict == 'no' then
    return 'تنظیمات سختیگرانه غیرفعال بود'
  else
    data[tostring(target)]['settings']['strict'] = 'no'
    save_data(_config.moderation.data, data)
    return 'تنظیمات سختیگرانه غیرفعال شد'
  end
end

local function set_rulesmod(msg, data, target)
  if not is_momod(msg) then
    return "فقط برای مدیران ممکن است!"
  end
  local data_cat = 'rules'
  data[tostring(target)][data_cat] = rules
  save_data(_config.moderation.data, data)
  return 'قوانین #گروه اینچنین تنظیم شد:\n\n'..rules
end
local function modadd(msg)
  -- superuser and admins only (because sudo are always has privilege)
   if not is_momod(msg) then
	return
  end
  if not is_admin1(msg) then
    return "شما ادمین نیستید"
  end
  local data = load_data(_config.moderation.data)
  if is_group(msg) then
    return 'گروه افزوده شده است.'
  end
    receiver = get_receiver(msg)
    chat_info(receiver, check_member_modadd,{receiver=receiver, data=data, msg = msg})
end
local function realmadd(msg)
  -- superuser and admins only (because sudo are always has privilege)
  if not is_momod(msg) then
	return
  end
  if not is_admin1(msg) then
    return "شما ادمین نیستید"
  end
  local data = load_data(_config.moderation.data)
  if is_realm(msg) then
    return 'ریلم افزوده شده است.'
  end
    receiver = get_receiver(msg)
    chat_info(receiver, check_member_realm_add,{receiver=receiver, data=data, msg = msg})
end
-- Global functions
function modrem(msg)
  -- superuser and admins only (because sudo are always has privilege)
  if not is_admin1(msg) then
    return "شما ادمین نیستید"
  end
  local data = load_data(_config.moderation.data)
  if not is_group(msg) then
    return 'گروه افزوده نشده است.'
  end
    receiver = get_receiver(msg)
    chat_info(receiver, check_member_modrem,{receiver=receiver, data=data, msg = msg})
end

function realmrem(msg)
  -- superuser and admins only (because sudo are always has privilege)
  if not is_admin1(msg) then
    return "شما ادمین نیستید"
  end
  local data = load_data(_config.moderation.data)
  if not is_realm(msg) then
    return 'ریلم افزوده نشده است.'
  end
    receiver = get_receiver(msg)
    chat_info(receiver, check_member_realmrem,{receiver=receiver, data=data, msg = msg})
end
local function get_rules(msg, data)
  local data_cat = 'rules'
  if not data[tostring(msg.to.id)][data_cat] then
    return 'قوانینی موجود نیست.'
  end
  local rules = data[tostring(msg.to.id)][data_cat]
  local rules = 'قوانین گروه:\n\n'..rules
  return rules
end

local function set_group_photo(msg, success, result)
  local data = load_data(_config.moderation.data)
  local receiver = get_receiver(msg)
  if success then
    local file = 'data/photos/chat_photo_'..msg.to.id..'.jpg'
    print('File downloaded to:', result)
    os.rename(result, file)
    print('File moved to:', file)
    chat_set_photo (receiver, file, ok_cb, false)
    data[tostring(msg.to.id)]['settings']['set_photo'] = file
    save_data(_config.moderation.data, data)
    data[tostring(msg.to.id)]['settings']['lock_photo'] = 'yes'
    save_data(_config.moderation.data, data)
    send_large_msg(receiver, 'Photo saved!', ok_cb, false)
  else
    print('Error downloading: '..msg.id)
    send_large_msg(receiver, 'Failed, please try again!', ok_cb, false)
  end
end

local function promote(receiver, member_username, member_id)
  local data = load_data(_config.moderation.data)
  local group = string.gsub(receiver, 'chat#id', '')
  if not data[group] then
    return send_large_msg(receiver, 'گروه افزوده نشده است.')
  end
  if data[group]['moderators'][tostring(member_id)] then
    return send_large_msg(receiver, member_username..' یک مدیر بود.')
  end
  data[group]['moderators'][tostring(member_id)] = member_username
  save_data(_config.moderation.data, data)
  return send_large_msg(receiver, member_username..' به درجه مدیریت ارتقا یافت.')
end

local function promote_by_reply(extra, success, result)
    local msg = result
    local full_name = (msg.from.first_name or '')..' '..(msg.from.last_name or '')
    if msg.from.username then
      member_username = '@'.. msg.from.username
    else
      member_username = full_name
    end
    local member_id = msg.from.peer_id
    if msg.to.peer_type == 'chat' then
      return promote(get_receiver(msg), member_username, member_id)
    end
end

local function demote(receiver, member_username, member_id)
  local data = load_data(_config.moderation.data)
  local group = string.gsub(receiver, 'chat#id', '')
  if not data[group] then
    return send_large_msg(receiver, 'گروه افزوده نشده است.')
  end
  if not data[group]['moderators'][tostring(member_id)] then
    return send_large_msg(receiver, member_username..' قبلا مدیر نبود.')
  end
  data[group]['moderators'][tostring(member_id)] = nil
  save_data(_config.moderation.data, data)
  return send_large_msg(receiver, member_username..' از مدیریت خارج شد.')
end

local function demote_by_reply(extra, success, result)
    local msg = result
    local full_name = (msg.from.first_name or '')..' '..(msg.from.last_name or '')
    if msg.from.username then
      member_username = '@'..msg.from.username
    else
      member_username = full_name
    end
    local member_id = msg.from.peer_id
    if msg.to.peer_type == 'chat' then
      return demote(get_receiver(msg), member_username, member_id)
    end
end

local function setowner_by_reply(extra, success, result)
  local msg = result
  local receiver = get_receiver(msg)
  local data = load_data(_config.moderation.data)
  local name_log = msg.from.print_name:gsub("_", " ")
  data[tostring(msg.to.id)]['set_owner'] = tostring(msg.from.id)
      save_data(_config.moderation.data, data)
      savelog(msg.to.id, name_log.." ["..msg.from.id.."] به ["..msg.from.id.."] درجه مالکیت ارتقا یافت")
      local text = msg.from.print_name:gsub("_", " ").." هم اکنون یک مالک است"
      return send_large_msg(receiver, text)
end

local function promote_demote_res(extra, success, result)
--vardump(result)
--vardump(extra)
      local member_id = result.peer_id
      local member_username = "@"..result.username
      local chat_id = extra.chat_id
      local mod_cmd = extra.mod_cmd
      local receiver = "chat#id"..chat_id
      if mod_cmd == 'promote' then
        return promote(receiver, member_username, member_id)
      elseif mod_cmd == 'demote' then
        return demote(receiver, member_username, member_id)
      end
end

local function mute_user_callback(extra, success, result)
	if result.service then
		local action = result.action.type
		if action == 'chat_add_user' or action == 'chat_del_user' or action == 'chat_rename' or action == 'chat_change_photo' then
			if result.action.user then
				user_id = result.action.user.peer_id
			end
		end
	else
		user_id = result.from.peer_id
	end
	local receiver = extra.receiver
	local chat_id = string.gsub(receiver, 'channel#id', '')
	if is_muted_user(chat_id, user_id) then
		mute_user(chat_id, user_id)
		send_large_msg(receiver, "["..user_id.."] از لیست کاربران بیصدا حذف شد")
	else
		unmute_user(chat_id, user_id)
		send_large_msg(receiver, " ["..user_id.."] به لیست کاربران بیصدا افزوده شد")
	end
end

local function modlist(msg)
  local data = load_data(_config.moderation.data)
  local groups = "groups"
  if not data[tostring(groups)][tostring(msg.to.id)] then
    return 'گروه افزوده نشده است.'
  end
  -- determine if table is empty
  if next(data[tostring(msg.to.id)]['moderators']) == nil then --fix way
    return 'مدیری موجود نیست.'
  end
  local i = 1
  local message = '\nلیست مدیران ' .. string.gsub(msg.to.print_name, '_', ' ') .. ':\n'
  for k,v in pairs(data[tostring(msg.to.id)]['moderators']) do
    message = message ..i..' - '..v..' [' ..k.. '] \n'
    i = i + 1
  end
  return message
end

local function callbackres(extra, success, result)
  local user = result.peer_id
  local name = string.gsub(result.print_name, "_", " ")
  local chat = 'chat#id'..extra.chatid
  send_large_msg(chat, user..'\n'..name)
  return user
end

local function callback_mute_res(extra, success, result)
	local user_id = result.peer_id
	local receiver = extra.receiver
	local chat_id = string.gsub(receiver, 'chat#id', '')
	if is_muted_user(chat_id, user_id) then
		unmute_user(chat_id, user_id)
		send_large_msg(receiver, " ["..user_id.."] از لیست کاربران بیصدا حذف شد")
	else
		mute_user(chat_id, user_id)
		send_large_msg(receiver, " ["..user_id.."] به لیست کاربران بیصدا افزوده شد")
	end
end

local function help()
  local help_text = tostring(_config.help_text)
  return help_text
end

local function cleanmember(cb_extra, success, result)
  local receiver = cb_extra.receiver
  local chat_id = "chat#id"..result.id
  local chatname = result.print_name
  for k,v in pairs(result.members) do
    kick_user(v.id, result.peer_id)
  end
end

local function killchat(cb_extra, success, result)
  local receiver = cb_extra.receiver
  local chat_id = "chat#id"..result.id
  local chatname = result.print_name
  for k,v in pairs(result.members) do
    kick_user_any(v.id, result.peer_id)
  end
end

local function killrealm(cb_extra, success, result)
  local receiver = cb_extra.receiver
  local chat_id = "chat#id"..result.id
  local chatname = result.print_name
  for k,v in pairs(result.members) do
    kick_user_any(v.id, result.peer_id)
  end
end

--[[local function user_msgs(user_id, chat_id)
  local user_info
  local uhash = 'user:'..user_id
  local user = redis:hgetall(uhash)
  local um_hash = 'msgs:'..user_id..':'..chat_id
  user_info = tonumber(redis:get(um_hash) or 0)
  return user_info
end

local function kick_zero(cb_extra, success, result)
    local chat_id = cb_extra.chat_id
    local chat = "chat#id"..chat_id
    local ci_user
    local re_user
    for k,v in pairs(result.members) do
        local si = false
        ci_user = v.peer_id
        local hash = 'chat:'..chat_id..':users'
        local users = redis:smembers(hash)
        for i = 1, #users do
            re_user = users[i]
            if tonumber(ci_user) == tonumber(re_user) then
                si = true
            end
        end
        if not si then
            if ci_user ~= our_id then
                if not is_momod2(ci_user, chat_id) then
                  chat_del_user(chat, 'user#id'..ci_user, ok_cb, true)
                end
            end
        end
    end
end

local function kick_inactive(chat_id, num, receiver)
    local hash = 'chat:'..chat_id..':users'
    local users = redis:smembers(hash)
    -- Get user info
    for i = 1, #users do
        local user_id = users[i]
        local user_info = user_msgs(user_id, chat_id)
        local nmsg = user_info
        if tonumber(nmsg) < tonumber(num) then
            if not is_momod2(user_id, chat_id) then
              chat_del_user('chat#id'..chat_id, 'user#id'..user_id, ok_cb, true)
            end
        end
    end
    return chat_info(receiver, kick_zero, {chat_id = chat_id})
end]]

local function run(msg, matches)
  local data = load_data(_config.moderation.data)
  local receiver = get_receiver(msg)
   local name_log = user_print_name(msg.from)
  local group = msg.to.id
  if msg.media then
    if msg.media.type == 'photo' and data[tostring(msg.to.id)] and data[tostring(msg.to.id)]['settings']['set_photo'] == 'waiting' and is_chat_msg(msg) and is_momod(msg) then
      load_photo(msg.id, set_group_photo, msg)
    end
  end
if msg.to.type == 'chat' then
  if is_admin1(msg) or not is_support(msg.from.id) then-- Admin only
	  if matches[1] == 'نصب_گروه' and not matches[2] then
		if not is_admin1(msg) and not is_support(msg.from.id) then-- Admin only
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] attempted to add group [ "..msg.to.id.." ]")
			return
		end
		if is_realm(msg) then
		   return 'خطا: یک ریلم است.'
		end
		savelog(msg.to.id, name_log.." ["..msg.from.id.."] added group [ "..msg.to.id.." ]")
		print("group "..msg.to.print_name.."("..msg.to.id..") added")
		return modadd(msg)
	  end
	   if matches[1] == 'نصب' and matches[2] == 'ریلم' then
		if not is_sudo(msg) then-- Admin only
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] attempted to add realm [ "..msg.to.id.." ]")
			return
		end
		if is_group(msg) then
		   return 'خطا: یک گروه است.'
		end
		savelog(msg.to.id, name_log.." ["..msg.from.id.."] added realm [ "..msg.to.id.." ]")
		print("group "..msg.to.print_name.."("..msg.to.id..") added as a realm")
		return realmadd(msg)
	  end
	  if matches[1] == 'صلب_گروه' and not matches[2] then
		if not is_admin1(msg) and not is_support(msg.from.id) then-- Admin only
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] attempted to remove group [ "..msg.to.id.." ]")
			return
		end
		if not is_group(msg) then
		   return 'خطا: یک گروه نیست.'
		end
		savelog(msg.to.id, name_log.." ["..msg.from.id.."] removed group [ "..msg.to.id.." ]")
		print("group "..msg.to.print_name.."("..msg.to.id..") removed")
		return modrem(msg)
	  end
	  if matches[1] == 'صلب' and matches[2] == 'ریلم' then
		if not is_sudo(msg) then-- Sudo only
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] attempted to remove realm [ "..msg.to.id.." ]")
			return
		end
		if not is_realm(msg) then
		   return 'خطا: یک ریلم نیست.'
		end
		savelog(msg.to.id, name_log.." ["..msg.from.id.."] removed realm [ "..msg.to.id.." ]")
		print("group "..msg.to.print_name.."("..msg.to.id..") removed as a realm")
		return realmrem(msg)
	  end
	end
  if matches[1] == 'chat_created' and msg.from.id == 0 and group_type == "group" then
    return automodadd(msg)
  end
 --[[Experimental
  if matches[1] == 'chat_created' and msg.from.id == 0 and group_type == "super_group" then
	local chat_id = get_receiver(msg)
	users = {[1]="user#id167472799",[2]="user#id170131770"}
		for k,v in pairs(users) do
			chat_add_user(chat_id, v, ok_cb, false)
		end
	--chat_upgrade(chat_id, ok_cb, false)
  end ]]
  if matches[1] == 'chat_created' and msg.from.id == 0 and group_type == "realm" then
    return autorealmadd(msg)
  end
  if msg.to.id and data[tostring(msg.to.id)] then
    local settings = data[tostring(msg.to.id)]['settings']
    if matches[1] == 'chat_add_user' then
      if not msg.service then
        return
      end
      local group_member_lock = settings.lock_member
      local user = 'user#id'..msg.action.user.id
      local chat = 'chat#id'..msg.to.id
      if group_member_lock == 'yes' and not is_owner2(msg.action.user.id, msg.to.id) then
        chat_del_user(chat, user, ok_cb, true)
      elseif group_member_lock == 'yes' and tonumber(msg.from.id) == tonumber(our_id) then
        return nil
      elseif group_member_lock == 'no' then
        return nil
      end
    end
    if matches[1] == 'chat_del_user' then
      if not msg.service then
         -- return "Are you trying to troll me?"
      end
      local user = 'user#id'..msg.action.user.id
      local chat = 'chat#id'..msg.to.id
      savelog(msg.to.id, name_log.." ["..msg.from.id.."] deleted user  "..user)
    end
    if matches[1] == 'chat_delete_photo' then
      if not msg.service then
        return
      end
      local group_photo_lock = settings.lock_photo
      if group_photo_lock == 'yes' then
        local picturehash = 'picture:changed:'..msg.to.id..':'..msg.from.id
        redis:incr(picturehash)
        ---
        local picturehash = 'picture:changed:'..msg.to.id..':'..msg.from.id
        local picprotectionredis = redis:get(picturehash)
        if picprotectionredis then
          if tonumber(picprotectionredis) == 4 and not is_owner(msg) then
            kick_user(msg.from.id, msg.to.id)
          end
          if tonumber(picprotectionredis) ==  8 and not is_owner(msg) then
            ban_user(msg.from.id, msg.to.id)
            local picturehash = 'picture:changed:'..msg.to.id..':'..msg.from.id
            redis:set(picturehash, 0)
          end
        end

        savelog(msg.to.id, name_log.." ["..msg.from.id.."] tried to deleted picture but failed  ")
        chat_set_photo(receiver, settings.set_photo, ok_cb, false)
      elseif group_photo_lock == 'no' then
        return nil
      end
    end
    if matches[1] == 'chat_change_photo' and msg.from.id ~= 0 then
      if not msg.service then
        return
      end
      local group_photo_lock = settings.lock_photo
      if group_photo_lock == 'yes' then
        local picturehash = 'picture:changed:'..msg.to.id..':'..msg.from.id
        redis:incr(picturehash)
        ---
        local picturehash = 'picture:changed:'..msg.to.id..':'..msg.from.id
        local picprotectionredis = redis:get(picturehash)
        if picprotectionredis then
          if tonumber(picprotectionredis) == 4 and not is_owner(msg) then
            kick_user(msg.from.id, msg.to.id)
          end
          if tonumber(picprotectionredis) ==  8 and not is_owner(msg) then
            ban_user(msg.from.id, msg.to.id)
          local picturehash = 'picture:changed:'..msg.to.id..':'..msg.from.id
          redis:set(picturehash, 0)
          end
        end

        savelog(msg.to.id, name_log.." ["..msg.from.id.."] tried to change picture but failed  ")
        chat_set_photo(receiver, settings.set_photo, ok_cb, false)
      elseif group_photo_lock == 'no' then
        return nil
      end
    end
    if matches[1] == 'chat_rename' then
      if not msg.service then
        return
      end
      local group_name_set = settings.set_name
      local group_name_lock = settings.lock_name
      local to_rename = 'chat#id'..msg.to.id
      if group_name_lock == 'yes' then
        if group_name_set ~= tostring(msg.to.print_name) then
          local namehash = 'name:changed:'..msg.to.id..':'..msg.from.id
          redis:incr(namehash)
          local namehash = 'name:changed:'..msg.to.id..':'..msg.from.id
          local nameprotectionredis = redis:get(namehash)
          if nameprotectionredis then
            if tonumber(nameprotectionredis) == 4 and not is_owner(msg) then
              kick_user(msg.from.id, msg.to.id)
            end
            if tonumber(nameprotectionredis) ==  8 and not is_owner(msg) then
              ban_user(msg.from.id, msg.to.id)
              local namehash = 'name:changed:'..msg.to.id..':'..msg.from.id
              redis:set(namehash, 0)
            end
          end
          savelog(msg.to.id, name_log.." ["..msg.from.id.."] tried to change name but failed  ")
          rename_chat(to_rename, group_name_set, ok_cb, false)
        end
      elseif group_name_lock == 'no' then
        return nil
      end
    end
    if matches[1] == 'تنظیم_اسم' and is_momod(msg) then
      local new_name = string.gsub(matches[2], '_', ' ')
      data[tostring(msg.to.id)]['settings']['set_name'] = new_name
      save_data(_config.moderation.data, data)
      local group_name_set = data[tostring(msg.to.id)]['settings']['set_name']
      local to_rename = 'chat#id'..msg.to.id
      rename_chat(to_rename, group_name_set, ok_cb, false)

      savelog(msg.to.id, "Group { "..msg.to.print_name.." }  name changed to [ "..new_name.." ] by "..name_log.." ["..msg.from.id.."]")
    end
    if matches[1] == 'تنظیم_عکس' and is_momod(msg) then
      data[tostring(msg.to.id)]['settings']['set_photo'] = 'waiting'
      save_data(_config.moderation.data, data)
      return 'لطفا عکس موردنظر جدید را بفرستید'
    end
    if matches[1] == 'ترفیع' and not matches[2] then
	   if not is_momod(msg) then
        return
      end
      if not is_owner(msg) then
        return "فقط مالک میتواند به افراد درجه مدیریت بدهد"
      end
      if type(msg.reply_id)~="nil" then
          msgr = get_message(msg.reply_id, promote_by_reply, false)
      end
    end
    if matches[1] == 'ترفیع' and matches[2] then
      if not is_momod(msg) then
        return
      end
      if not is_owner(msg) then
        return "فقط مالک میتواند ارتقا دهد"
      end
	local member = matches[2]
	savelog(msg.to.id, name_log.." ["..msg.from.id.."] promoted @".. member)
	local cbres_extra = {
		chat_id = msg.to.id,
        mod_cmd = 'promote',
		from_id = msg.from.id
	}
	local username = matches[2]
	local username = string.gsub(matches[2], '@', '')
	return resolve_username(username, promote_demote_res, cbres_extra)
    end
    if matches[1] == 'عزل' and not matches[2] then
	  if not is_momod(msg) then
        return
      end
      if not is_owner(msg) then
        return "فقط مالک میتواند مدیران را عزل کند"
      end
      if type(msg.reply_id)~="nil" then
          msgr = get_message(msg.reply_id, demote_by_reply, false)
      end
    end
    if matches[1] == 'عزل' and matches[2] then
      if not is_momod(msg) then
        return
      end
      if not is_owner(msg) then
        return "فقط مالک میتواند عزل کند"
      end
      if string.gsub(matches[2], "@", "") == msg.from.username and not is_owner(msg) then
        return "شما نمیتوانید خود را عزل کنید. چیه خسته شدی از مدیریت یا اشتباه زدی؟ :/"
      end
	local member = matches[2]
        savelog(msg.to.id, name_log.." ["..msg.from.id.."] demoted @".. member)
	local cbres_extra = {
	chat_id = msg.to.id,
        mod_cmd = 'demote',
	from_id = msg.from.id
	}
	local username = matches[2]
	local username = string.gsub(matches[2], '@', '')
	return resolve_username(username, promote_demote_res, cbres_extra)
    end
    if matches[1] == 'لیست_مدیران' then
      savelog(msg.to.id, name_log.." ["..msg.from.id.."] requested group modlist")
      return modlist(msg)
    end
    if matches[1] == 'درباره' then
      savelog(msg.to.id, name_log.." ["..msg.from.id.."] requested group description")
      return get_description(msg, data)
    end
    if matches[1] == 'قوانین' then
      savelog(msg.to.id, name_log.." ["..msg.from.id.."] requested group rules")
      return get_rules(msg, data)
    end
    if matches[1] == 'تنظیم' then
      if matches[2] == '_قوانین' then
        rules = matches[3]
        local target = msg.to.id
        savelog(msg.to.id, name_log.." ["..msg.from.id.."] has changed group rules to ["..matches[3].."]")
        return set_rulesmod(msg, data, target)
      end
      if matches[2] == '_درباره' then
        local data = load_data(_config.moderation.data)
        local target = msg.to.id
        local about = matches[3]
        savelog(msg.to.id, name_log.." ["..msg.from.id.."] has changed group description to ["..matches[3].."]")
        return set_descriptionmod(msg, data, target, about)
      end
    end
end
--Begin chat settings
    if matches[1] == 'قفل_کردن' then
      local target = msg.to.id
		if matches[2] == 'اسم' then
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked name ")
			return lock_group_namemod(msg, data, target)
		end
		if matches[2] == 'اعضا' then
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked member ")
			return lock_group_membermod(msg, data, target)
		end
		if matches[2] == 'اسپم' then
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked flood ")
			return lock_group_floodmod(msg, data, target)
		end
		if matches[2] == 'عربی' then
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked arabic ")
			return lock_group_arabic(msg, data, target)
		end
		if matches[2] == 'ربات' then
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked bots ")
			return lock_group_bots(msg, data, target)
		end
		if matches[2] == 'ترک' then
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked leaving ")
			return lock_group_leave(msg, data, target)
		end
		if matches[2] == 'لینک' then
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked link posting ")
			return lock_group_links(msg, data, target)
		end
		if matches[2]:lower() == 'rtl' then
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked rtl chars. in names")
			return lock_group_rtl(msg, data, target)
		end
		if matches[2] == 'استیکر' then
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked sticker posting")
			return lock_group_sticker(msg, data, target)
		end
		if matches[2] == 'مخاطب' then
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked contact posting")
			return lock_group_contacts(msg, data, target)
		end
	end
    if matches[1] == 'باز_کردن' then
		local target = msg.to.id
		if matches[2] == 'اسم' then
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] unlocked name ")
			return unlock_group_namemod(msg, data, target)
		end
		if matches[2] == 'اعضا' then
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] unlocked member ")
			return unlock_group_membermod(msg, data, target)
		end
		if matches[2] == 'عکس' then
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] unlocked photo ")
			return unlock_group_photomod(msg, data, target)
		end
		if matches[2] == 'اسپم' then
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] unlocked flood ")
			return unlock_group_floodmod(msg, data, target)
		end
		if matches[2] == 'عربی' then
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] unlocked arabic ")
			return unlock_group_arabic(msg, data, target)
		end
		if matches[2] == 'ربات' then
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] unlocked bots ")
			return unlock_group_bots(msg, data, target)
		end
		if matches[2] == 'ترک' then
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] unlocked leaving ")
			return unlock_group_leave(msg, data, target)
		end
		if matches[2] == 'لینک' then
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] unlocked link posting")
			return unlock_group_links(msg, data, target)
		end
		if matches[2]:lower() == 'rtl' then
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] unlocked RTL chars. in names")
			return unlock_group_rtl(msg, data, target)
		end
		if matches[2] == 'استیکر' then
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] unlocked sticker posting")
			return unlock_group_sticker(msg, data, target)
		end
		if matches[2] == 'مخاطب' then
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] unlocked contact posting")
			return unlock_group_contacts(msg, data, target)
		end
	end
	--End chat settings
	
  --Begin Chat mutes

  if matches[1] == 'ممنوع_کردن' and is_owner(msg) then
			local chat_id = msg.to.id
			if matches[2] == 'صدا' then
			local msg_type = 'Audio'
				if not is_muted(chat_id, msg_type..': yes') then
					savelog(msg.to.id, name_log.." ["..msg.from.id.."] set group to: mute "..msg_type)
					mute(chat_id, msg_type)
					return "حساسیت به محتوا 'صدا' فعال شد و در صورت ارسال این محتوا، محتوا موردنظر از #سوپرگروه حذف خواهد شد"
				else
					return "حساسیت به محتوا 'صدا' فعال بود"
				end
			end
			if matches[2] == 'عکس' then
			local msg_type = 'Photo'
				if not is_muted(chat_id, msg_type..': yes') then
					savelog(msg.to.id, name_log.." ["..msg.from.id.."] set group to: mute "..msg_type)
					mute(chat_id, msg_type)
					return "حساسیت به محتوا 'عکس' فعال شد و در صورت ارسال این محتوا، محتوا موردنظر از #سوپرگروه حذف خواهد شد"
				else
					return "حساسیت به محتوا 'عکس' فعال بود"
				end
			end
			if matches[2] == 'فیلم' then
			local msg_type = 'Video'
				if not is_muted(chat_id, msg_type..': yes') then
					savelog(msg.to.id, name_log.." ["..msg.from.id.."] set group to: mute "..msg_type)
					mute(chat_id, msg_type)
					return "حساسیت به محتوا 'فیلم' فعال شد و در صورت ارسال این محتوا، محتوا موردنظر از #سوپرگروه حذف خواهد شد"
				else
					return "حساسیت به محتوا 'فیلم' فعال بود"
				end
			end
			if matches[2] == 'گیف' then
			local msg_type = 'Gifs'
				if not is_muted(chat_id, msg_type..': yes') then
					savelog(msg.to.id, name_log.." ["..msg.from.id.."] set group to: mute "..msg_type)
					mute(chat_id, msg_type)
					return "حساسیت به محتوا 'گیف' فعال شد و در صورت ارسال این محتوا، محتوا موردنظر از #سوپرگروه حذف خواهد شد"
				else
					return "حساسیت به محتوا 'گیف' فعال بود"
				end
			end
			if matches[2] == 'فایل' then
			local msg_type = 'Documents'
				if not is_muted(chat_id, msg_type..': yes') then
					savelog(msg.to.id, name_log.." ["..msg.from.id.."] set group to: mute "..msg_type)
					mute(chat_id, msg_type)
					return "حساسیت به محتوا 'فایل' فعال شد و در صورت ارسال این محتوا، محتوا موردنظر از #سوپرگروه حذف خواهد شد"
				else
					return "حساسیت به محتوا 'فایل' فعال بود"
				end
			end
			if matches[2] == 'متن' then
			local msg_type = 'Text'
				if not is_muted(chat_id, msg_type..': yes') then
					savelog(msg.to.id, name_log.." ["..msg.from.id.."] set group to: mute "..msg_type)
					mute(chat_id, msg_type)
					return "حساسیت به محتوا 'متن' فعال شد و در صورت ارسال این محتوا، محتوا موردنظر از #سوپرگروه حذف خواهد شد"
				else
					return "حساسیت به محتوا 'متن' فعال بود"
				end
			end
			if matches[2] == 'همه' then
			local msg_type = 'All'
				if not is_muted(chat_id, msg_type..': yes') then
					savelog(msg.to.id, name_log.." ["..msg.from.id.."] set group to: mute "..msg_type)
					mute(chat_id, msg_type)
					return "حساسیت به محتوا تمام موارد فعال شد و در صورت ارسال هر محتوایی، تمام محتواها از #سوپرگروه حذف خواهد شد"
				else
					return "حساسیت به هر محتوایی فعال بود"
				end
			end
		end
		if matches[1] == 'ازاد_کردن' and is_owner(msg) then
			local chat_id = msg.to.id
			if matches[2] == 'صدا' then
			local msg_type = 'Audio'
				if is_muted(chat_id, msg_type..': yes') then
					savelog(msg.to.id, name_log.." ["..msg.from.id.."] set group to: unmute "..msg_type)
					unmute(chat_id, msg_type)
					return "حساسیت به محتوا 'صدا' غیرفعال شد"
				else
					return "حساسیت به محتوا 'صدا' غیرفعال بود"
				end
			end
			if matches[2] == 'عکس' then
			local msg_type = 'Photo'
				if is_muted(chat_id, msg_type..': yes') then
					savelog(msg.to.id, name_log.." ["..msg.from.id.."] set group to: unmute "..msg_type)
					unmute(chat_id, msg_type)
					return "حساسیت به محتوا 'عکس' غیرفعال شد"
				else
					return "حساسیت به محتوا 'عکس' غیرفعال بود"
				end
			end
			if matches[2] == 'فیلم' then
			local msg_type = 'Video'
				if is_muted(chat_id, msg_type..': yes') then
					savelog(msg.to.id, name_log.." ["..msg.from.id.."] set group to: unmute "..msg_type)
					unmute(chat_id, msg_type)
					return "حساسیت به محتوا 'فیلم' غیرفعال شد"
				else
					return "حساسیت به محتوا 'فیلم' غیرفعال بود"
				end
			end
			if matches[2] == 'گیف' then
			local msg_type = 'Gifs'
				if is_muted(chat_id, msg_type..': yes') then
					savelog(msg.to.id, name_log.." ["..msg.from.id.."] set group to: unmute "..msg_type)
					unmute(chat_id, msg_type)
					return "حساسیت به محتوا 'گیف' غیرفعال شد"
				else
					return "حساسیت به محتوا 'گیف' غیرفعال بود"
				end
			end
			if matches[2] == 'فایل' then
			local msg_type = 'Documents'
				if is_muted(chat_id, msg_type..': yes') then
					savelog(msg.to.id, name_log.." ["..msg.from.id.."] set group to: unmute "..msg_type)
					unmute(chat_id, msg_type)
					return "حساسیت به محتوا 'فایل' غیرفعال شد"
				else
					return "حساسیت به محتوا 'فایل' غیرفعال بود"
				end
			end
			if matches[2] == 'متن' then
			local msg_type = 'Text'
				if is_muted(chat_id, msg_type..': yes') then
					savelog(msg.to.id, name_log.." ["..msg.from.id.."] set group to: unmute message")
					unmute(chat_id, msg_type)
					return "حساسیت به محتوا متن غیرفعال شد"
				else
					return "حساسیت به محتوا متن غیرفعال بود"
				end
			end
			if matches[2] == 'همه' then
			local msg_type = 'All'
				if is_muted(chat_id, msg_type..': yes') then
					savelog(msg.to.id, name_log.." ["..msg.from.id.."] set group to: unmute "..msg_type)
					unmute(chat_id, msg_type)
					return "حساسیت به هر محتوایی غیرفعال شد"
				else
					return "حساسیت به هرمحتوایی غیرفعال بود"
				end
			end
		end

	--Begin chat muteuser
		if matches[1] == "کاربر_بیصدا" and is_momod(msg) then
		local chat_id = msg.to.id
		local hash = "mute_user"..chat_id
		local user_id = ""
			if type(msg.reply_id) ~= "nil" then
				local receiver = get_receiver(msg)
				local get_cmd = "mute_user"
				get_message(msg.reply_id, mute_user_callback, {receiver = receiver, get_cmd = get_cmd})
			elseif matches[1] == "کاربر_بیصدا" and string.match(matches[2], '^%d+$') then
				local user_id = matches[2]
				if is_muted_user(chat_id, user_id) then
					mute_user(chat_id, user_id)
					return "["..user_id.."] از لیست کاربران بیصدا حذف شد"
				else
					unmute_user(chat_id, user_id)
					return "["..user_id.."] به لیست کاربران بیصدا اضافه شد"
				end
			elseif matches[1] == "کاربر_بیصدا" and not string.match(matches[2], '^%d+$') then
				local receiver = get_receiver(msg)
				local get_cmd = "mute_user"
				local username = matches[2]
				local username = string.gsub(matches[2], '@', '')
				resolve_username(username, callback_mute_res, {receiver = receiver, get_cmd = get_cmd})
			end
		end

  --End Chat muteuser
  	if matches[1] == "لیست_ممنوعیات" and is_momod(msg) then
		local chat_id = msg.to.id
		if not has_mutes(chat_id) then
			set_mutes(chat_id)
			return mutes_list(chat_id)
		end
		savelog(msg.to.id, name_log.." ["..msg.from.id.."] requested SuperGroup muteslist")
		return mutes_list(chat_id)
	end
	if matches[1] == "لیست_کاربران_بیصدا" and is_momod(msg) then
		local chat_id = msg.to.id
		savelog(msg.to.id, name_log.." ["..msg.from.id.."] requested SuperGroup mutelist")
		return muted_user_list(chat_id)
	end

    if matches[1] == 'تنظیمات' and is_momod(msg) then
      local target = msg.to.id
      savelog(msg.to.id, name_log.." ["..msg.from.id.."] requested group settings ")
      return show_group_settingsmod(msg, target)
    end

 if matches[1] == 'عمومی' and is_momod(msg) then
    local target = msg.to.id
    if matches[2] == 'روشن' then
      savelog(msg.to.id, name_log.." ["..msg.from.id.."] set group to: public")
      return set_public_membermod(msg, data, target)
    end
    if matches[2] == 'خاموش' then
      savelog(msg.to.id, name_log.." ["..msg.from.id.."] set group to: not public")
      return unset_public_membermod(msg, data, target)
    end
  end

if msg.to.type == 'chat' then
    if matches[1] == 'لینک_جدید' and not is_realm(msg) then
      if not is_momod(msg) then
        return "فقط برای مدیران!"
      end
      local function callback (extra , success, result)
        local receiver = 'chat#'..msg.to.id
        if success == 0 then
           return send_large_msg(receiver, '*خطا: لینک ساخته نشد\nدلیل: ربات سازنده گروه نیست')
        end
        send_large_msg(receiver, "لینک جدید ساخته شد")
        data[tostring(msg.to.id)]['settings']['set_link'] = result
        save_data(_config.moderation.data, data)
      end
      local receiver = 'chat#'..msg.to.id
      savelog(msg.to.id, name_log.." ["..msg.from.id.."] revoked group link ")
      return export_chat_link(receiver, callback, true)
    end
    if matches[1] == 'لینک' then
      if not is_momod(msg) then
        return "فقط برای مدیران!"
      end
      local group_link = data[tostring(msg.to.id)]['settings']['set_link']
      if not group_link then
        return "ابتدا با دستور لینک جدید، لینک جدید را بسازید !"
      end
       savelog(msg.to.id, name_log.." ["..msg.from.id.."] requested group link ["..group_link.."]")
      return "لینک #گروه:\n"..group_link
    end
    if matches[1] == 'تنظیم_مالک' and matches[2] then
      if not is_owner(msg) then
        return "فقط برای مالک گروه!"
      end
      data[tostring(msg.to.id)]['set_owner'] = matches[2]
      save_data(_config.moderation.data, data)
      savelog(msg.to.id, name_log.." ["..msg.from.id.."] set ["..matches[2].."] as owner")
      local text = matches[2].." مالک شد"
      return text
    end
    if matches[1] == 'تنظیم_مالک' and not matches[2] then
      if not is_owner(msg) then
        return "فقثط برای مالک!"
      end
      if type(msg.reply_id)~="nil" then
          msgr = get_message(msg.reply_id, setowner_by_reply, false)
      end
    end
end
    if matches[1] == 'مالک' then
      local group_owner = data[tostring(msg.to.id)]['set_owner']
      if not group_owner then
        return "مالکی در گروه موجود نیست، لطفا از ادمین های ربات پرسجو کنید تا مشکل حل بشود"
      end
      savelog(msg.to.id, name_log.." ["..msg.from.id.."] used /owner")
      return "مالک گروه ["..group_owner..']'
    end
    if matches[1] == 'تغییر_مالک_گروه' then
      local receiver = "chat#id"..matches[2]
      if not is_admin1(msg) then
        return "فقط برای ادمین!"
      end
      data[tostring(matches[2])]['set_owner'] = matches[3]
      save_data(_config.moderation.data, data)
      local text = matches[3].." به عنوان مالک افزوده شد"
      send_large_msg(receiver, text)
      return
    end
    if matches[1] == 'حساسیت_ضداسپم' then
      if not is_momod(msg) then
        return "فقط برای مدیران!"
      end
      if tonumber(matches[2]) < 5 or tonumber(matches[2]) > 20 then
        return "عدد اشتباه، محدوده بین [5-20] میباشد"
      end
      local flood_max = matches[2]
      data[tostring(msg.to.id)]['settings']['flood_msg_max'] = flood_max
      save_data(_config.moderation.data, data)
      savelog(msg.to.id, name_log.." ["..msg.from.id.."] set flood to ["..matches[2].."]")
      return 'حساسیت ضداسپم به روی عدد روبرو تنظیم شد: '..matches[2]
    end

if msg.to.type == 'chat' then
    if matches[1] == 'پاکسازی' then
      if not is_owner(msg) then
        return "فقط مالک میتواند پاک بکند"
      end
      if matches[2] == 'اعضا' then
        if not is_owner(msg) then
          return "فقط مالک میتواند پاک بکند"
        end
        local receiver = get_receiver(msg)
        chat_info(receiver, cleanmember, {receiver=receiver})
      end
	 end
      if matches[2] == 'لیست_مدیران' then
        if next(data[tostring(msg.to.id)]['moderators']) == nil then --fix way
          return 'پاکسازی شد.'
        end
        local message = '\nلیست مدیران گروه ' .. string.gsub(msg.to.print_name, '_', ' ') .. ':\n'
        for k,v in pairs(data[tostring(msg.to.id)]['moderators']) do
          data[tostring(msg.to.id)]['moderators'][tostring(k)] = nil
          save_data(_config.moderation.data, data)
        end
        savelog(msg.to.id, name_log.." ["..msg.from.id.."] cleaned modlist")
      end
      if matches[2] == 'قوانین' then
        local data_cat = 'rules'
        data[tostring(msg.to.id)][data_cat] = nil
        save_data(_config.moderation.data, data)
        savelog(msg.to.id, name_log.." ["..msg.from.id.."] cleaned rules")
          return 'پاکسازی شد.'
      end
      if matches[2] == 'درباره' then
        local data_cat = 'description'
        data[tostring(msg.to.id)][data_cat] = nil
        save_data(_config.moderation.data, data)
        savelog(msg.to.id, name_log.." ["..msg.from.id.."] cleaned about")
          return 'پاکسازی شد.'
      end
    end
if msg.to.type == 'chat' then
    if matches[1] == 'خراب_کردن' and matches[2] == 'گروه' then
      if not is_admin1(msg) then
          return nil
      end
      if not is_realm(msg) then
          local receiver = get_receiver(msg)
          return modrem(msg),
          print("Closing Group..."),
          chat_info(receiver, killchat, {receiver=receiver})
      else
          return 'این یک ریلم است. احتیاط کنید'
      end
   end
    if matches[1] == 'خراب_کردن' and matches[2] == 'ریلم' then
     if not is_admin1(msg) then
         return nil
     end
     if not is_group(msg) then
        local receiver = get_receiver(msg)
        return realmrem(msg),
        print("Closing Realm..."),
        chat_info(receiver, killrealm, {receiver=receiver})
     else
        return 'این یک گروه است. احتیاط کنید'
     end
   end
    if matches[1] == 'راهنما' then
      if not is_momod(msg) or is_realm(msg) then
        return
      end
      savelog(msg.to.id, name_log.." ["..msg.from.id.."] Used /help")
      return help()
    end
    if matches[1] == 'درمورد' then 
      local cbres_extra = {
        chatid = msg.to.id
      }
      local username = matches[2]
      local username = username:gsub("@","")
      resolve_username(username,  callbackres, cbres_extra)
	  return
    end
    if matches[1] == 'حذف_غیرفعالین' then
      --send_large_msg('chat#id'..msg.to.id, 'I\'m in matches[1]')
	    if not is_momod(msg) then
	      return 'فقط مدیران میتوانند غیرفعالین رو اخراج کنند'
	    end
	    local num = 1
	    if matches[2] then
	        num = matches[2]
	    end
	    local chat_id = msg.to.id
	    local receiver = get_receiver(msg)
      return kick_inactive(chat_id, num, receiver)
    end
   end
  end
end

local function pre_process(msg)
  if not msg.text and msg.media then
    msg.text = '['..msg.media.type..']'
  end
  return msg
end

return {
  patterns = {
  "^[#](نصب_گروه)$",
  "^[#](نصب) (ریلم)$",
  "^[#](صلب_گروه)$",
  "^[#](صلب) (ریلم)$",
  "^[#](قوانین)$",
  "^[#](درباره)$",
  "^[#](تنظیم_اسم) (.*)$",
  "^[#](تنظیم_عکس)$",
  "^[#](ترفیع) (.*)$",
  "^[#](ترفیع)",
  "^[#](راهنما)$",
  "^[#](پاکسازی) (.*)$",
  "^[#](خراب_کردن) (گروه)$",
  "^[#](خراب_کردن) (ریلم)$",
  "^[#](عزل) (.*)$",
  "^[#](عزل)",
  "^[#](تنظیم)([^%s]+) (.*)$",
  "^[#](قفل_کردن) (.*)$",
  "^[#](باز_کردن) (.*)$",
  "^[#](تنظیم_مالک) (%d+)$",
  "^[#](تنظیم_مالک)",
  "^[#](مالک)$",
  "^[#](درمورد) (.*)$",
  "^[#](تغییر_مالک_گروه) (%d+) (%d+)$",-- (group id) (owner id)
  "^[#](انبلاک) (.*)$",
  "^[#](حساسیت_ضداسپم) (%d+)$",
  "^[#](تنظیمات)$",
  "^[#](عمومی) (.*)$",
  "^[#](لیست_مدیران)$",
  "^[#](لینک_جدید)$",
  "^[#](لینک)$",
  "^[#](ممنوع_کردن) ([^%s]+)$",
  "^[#](ازاد_کردن) ([^%s]+)$",
  "^[#](کاربر_بیصدا)$",
  "^[#](کاربر_بیصدا) (.*)$",
  "^[#](لیست_ممنوعیات)$",
  "^[#](لیست_کاربران_بیصدا)$",
  "^[#](حذف_غیرفعالین)$",
  "^[#](حذف_غیرفعالین) (%d+)$",
  "%[(document)%]",
  "%[(photo)%]",
  "%[(video)%]",
  "%[(audio)%]",
  "^!!tgservice (.+)$",
  },
  run = run,
  pre_process = pre_process
}
end
