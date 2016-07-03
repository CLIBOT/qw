--Begin supergrpup.lua
--Check members #Add supergroup
local function check_member_super(cb_extra, success, result)
  local receiver = cb_extra.receiver
  local data = cb_extra.data
  local msg = cb_extra.msg
  if success == 0 then
	send_large_msg(receiver, "من را ابتدا مدیر گروه کنید!")
  end
  for k,v in pairs(result) do
    local member_id = v.peer_id
    if member_id ~= our_id then
      -- SuperGroup configuration
      data[tostring(msg.to.id)] = {
        group_type = 'SuperGroup',
		long_id = msg.to.peer_id,
		moderators = {},
        set_owner = member_id ,
        settings = {
          set_name = string.gsub(msg.to.title, '_', ' '),
		  lock_emoji = 'no',
		  lock_ads = 'no',
		  lock_english = 'no',
		  lock_command = 'no',
		  lock_tag = 'no',
		  lock_link = "no",
          flood = 'yes',
		  lock_spam = 'yes',
		  lock_sticker = 'no',
		  member = 'no',
		  public = 'no',
		  lock_rtl = 'no',
		  lock_tgservice = 'no',
		  lock_contacts = 'no',
		  strict = 'no'
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
	  local text = '#سوپرگروه اضافه شد!'
      return reply_msg(msg.id, text, ok_cb, false)
    end
  end
end

--Check Members #rem supergroup
local function check_member_superrem(cb_extra, success, result)
  local receiver = cb_extra.receiver
  local data = cb_extra.data
  local msg = cb_extra.msg
  for k,v in pairs(result) do
    local member_id = v.id
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
	  local text = '#سوپرگروه حذف شد!'
      return reply_msg(msg.id, text, ok_cb, false)
    end
  end
end

--Function to Add supergroup
local function superadd(msg)
	local data = load_data(_config.moderation.data)
	local receiver = get_receiver(msg)
    channel_get_users(receiver, check_member_super,{receiver = receiver, data = data, msg = msg})
end

--Function to remove supergroup
local function superrem(msg)
	local data = load_data(_config.moderation.data)
    local receiver = get_receiver(msg)
    channel_get_users(receiver, check_member_superrem,{receiver = receiver, data = data, msg = msg})
end

--Get and output admins and bots in supergroup
local function callback(cb_extra, success, result)
local i = 1
local chat_name = string.gsub(cb_extra.msg.to.print_name, "_", " ")
local member_type = cb_extra.member_type
local text = member_type.." for "..chat_name..":\n"
for k,v in pairsByKeys(result) do
if not v.first_name then
	name = " "
else
	vname = v.first_name:gsub("‮", "")
	name = vname:gsub("_", " ")
	end
		text = text.."\n"..i.." - "..name.."["..v.peer_id.."]"
		i = i + 1
	end
    send_large_msg(cb_extra.receiver, text)
end

local function callback_clean_bots (extra, success, result)
	local msg = extra.msg
	local receiver = 'channel#id'..msg.to.id
	local channel_id = msg.to.id
	for k,v in pairs(result) do
		local bot_id = v.peer_id
		kick_user(bot_id,channel_id)
	end
end

--Get and output info about supergroup
local function callback_info(cb_extra, success, result)
local title ="مشخصات #سوپرگروه: ["..result.title.."]\n\n"
local admin_num = "تعداد ادمین: "..result.admins_count.."\n"
local user_num = "تعداد اعضا: "..result.participants_count.."\n"
local kicked_num = "تعداد اعضای مسدود: "..result.kicked_count.."\n"
local channel_id = "#ایدی : "..result.peer_id.."\n"
if result.username then
	channel_username = "یوزرنیم: @"..result.username
else
	channel_username = ""
end
local text = title..admin_num..user_num..kicked_num..channel_id..channel_username
    send_large_msg(cb_extra.receiver, text)
end

--Get and output members of supergroup
local function callback_who(cb_extra, success, result)
local text = "اعضا برای "..cb_extra.receiver
local i = 1
for k,v in pairsByKeys(result) do
if not v.print_name then
	name = " "
else
	vname = v.print_name:gsub("‮", "")
	name = vname:gsub("_", " ")
end
	if v.username then
		username = " @"..v.username
	else
		username = ""
	end
	text = text.."\n"..i.." - "..name.." "..username.." [ "..v.peer_id.." ]\n"
	--text = text.."\n"..username
	i = i + 1
end
    local file = io.open("./groups/lists/supergroups/"..cb_extra.receiver..".txt", "w")
    file:write(text)
    file:flush()
    file:close()
    send_document(cb_extra.receiver,"./groups/lists/supergroups/"..cb_extra.receiver..".txt", ok_cb, false)
	post_msg(cb_extra.receiver, text, ok_cb, false)
end

--Get and output list of kicked users for supergroup
local function callback_kicked(cb_extra, success, result)
--vardump(result)
local text = "اعضای مسدود شده #سوپرگروه "..cb_extra.receiver.."\n\n"
local i = 1
for k,v in pairsByKeys(result) do
if not v.print_name then
	name = " "
else
	vname = v.print_name:gsub("‮", "")
	name = vname:gsub("_", " ")
end
	if v.username then
		name = name.." @"..v.username
	end
	text = text.."\n"..i.." - "..name.." [ "..v.peer_id.." ]\n"
	i = i + 1
end
    local file = io.open("./groups/lists/supergroups/kicked/"..cb_extra.receiver..".txt", "w")
    file:write(text)
    file:flush()
    file:close()
    send_document(cb_extra.receiver,"./groups/lists/supergroups/kicked/"..cb_extra.receiver..".txt", ok_cb, false)
	--send_large_msg(cb_extra.receiver, text)
end

--Begin supergroup locks
local function lock_group_links(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_link_lock = data[tostring(target)]['settings']['lock_link']
  if group_link_lock == 'yes' then
    return 'ضدلینک فعال بود'
  else
    data[tostring(target)]['settings']['lock_link'] = 'yes'
    save_data(_config.moderation.data, data)
    return 'ضدلینک فعال شد'
  end
end

local function unlock_group_links(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_link_lock = data[tostring(target)]['settings']['lock_link']
  if group_link_lock == 'no' then
    return 'ضدلینک غیرفعال بود'
  else
    data[tostring(target)]['settings']['lock_link'] = 'no'
    save_data(_config.moderation.data, data)
    return 'ضدلینک غیرفعال شد'
  end
end

local function lock_group_spam(msg, data, target)
  if not is_momod(msg) then
    return
  end
  if not is_owner(msg) then
    return "فقط مالک گروه!"
  end
  local group_spam_lock = data[tostring(target)]['settings']['lock_spam']
  if group_spam_lock == 'yes' then
    return 'ضداسپم #سوپرگروه فعال بود'
  else
    data[tostring(target)]['settings']['lock_spam'] = 'yes'
    save_data(_config.moderation.data, data)
    return 'ضداسپم #سوپرگروه فعال شد'
  end
end

local function unlock_group_spam(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_spam_lock = data[tostring(target)]['settings']['lock_spam']
  if group_spam_lock == 'no' then
    return 'ضداسپم #سوپرگروه غیرفعال بود'
  else
    data[tostring(target)]['settings']['lock_spam'] = 'no'
    save_data(_config.moderation.data, data)
    return 'ضداسپم #سوپرگروه غیرفعال شد'
  end
end

local function lock_group_emoji(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_emoji_lock = data[tostring(target)]['settings']['lock_emoji']
  if group_emoji_lock == 'yes' then
    return 'ضداموجی فعال بود'
  else
    data[tostring(target)]['settings']['lock_emoji'] = 'yes'
    save_data(_config.moderation.data, data)
    return 'ضداموجی فعال شد'
  end
end

local function unlock_group_emoji(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_emoji_lock = data[tostring(target)]['settings']['lock_emoji']
  if group_emoji_lock == 'no' then
    return 'ضداموجی غیرفعال بود'
  else
    data[tostring(target)]['settings']['lock_emoji'] = 'no'
    save_data(_config.moderation.data, data)
    return 'ضداموجی غیرفعال شد'
  end
end

local function lock_group_tag(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_tag_lock = data[tostring(target)]['settings']['lock_tag']
  if group_tag_lock == 'yes' then
    return 'حساسیت به یوزرنیم روشن بود'
  else
    data[tostring(target)]['settings']['lock_tag'] = 'yes'
    save_data(_config.moderation.data, data)
    return 'حساسیت به یوزرنیم روشن شد'
  end
end

local function unlock_group_tag(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_tag_lock = data[tostring(target)]['settings']['lock_tag']
  if group_tag_lock == 'no' then
    return 'حساسیت به یوزرنیم خاموش بود'
  else
    data[tostring(target)]['settings']['lock_tag'] = 'no'
    save_data(_config.moderation.data, data)
    return 'حساسیت به یوزرنیم خاموش شد'
  end
end

local function lock_group_ads(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_ads_lock = data[tostring(target)]['settings']['lock_ads']
  if group_ads_lock == 'yes' then
    return 'حساسیت به تبلیغات سایت و ایمیل فعال بود'
  else
    data[tostring(target)]['settings']['lock_ads'] = 'yes'
    save_data(_config.moderation.data, data)
    return 'حساسیت به تبلیغات سایت و ایمیل فعال شد'
  end
end

local function unlock_group_ads(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_ads_lock = data[tostring(target)]['settings']['lock_ads']
  if group_ads_lock == 'no' then
    return 'حساسیت به تبلیغات خاموش بود'
  else
    data[tostring(target)]['settings']['lock_ads'] = 'no'
    save_data(_config.moderation.data, data)
    return 'حساسیت به تبلیغات خاموش شد'
  end
end

local function lock_group_command(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_command_lock = data[tostring(target)]['settings']['lock_command']
  if group_command_lock == 'yes' then
    return 'حساسیت به پیام دستوری(/) از قبل روشن بود'
  else
    data[tostring(target)]['settings']['lock_command'] = 'yes'
    save_data(_config.moderation.data, data)
    return 'حساسیت به پیام دستوری(/) روشن شد'
  end
end

local function unlock_group_command(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_command_lock = data[tostring(target)]['settings']['lock_command']
  if group_command_lock == 'no' then
    return 'حساسیت به پیام دستوری(/) خاموش بود'
  else
    data[tostring(target)]['settings']['lock_command'] = 'no'
    save_data(_config.moderation.data, data)
    return 'حساسیت به پیام دستوری(/) خاموش شد'
  end
end

local function lock_group_english(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_english_lock = data[tostring(target)]['settings']['lock_english']
  if group_english_lock == 'yes' then
    return 'حساسیت به حروف انگلیسی روشن بود'
  else
    data[tostring(target)]['settings']['lock_english'] = 'yes'
    save_data(_config.moderation.data, data)
    return 'پست حاوی حروف انگلیسی پاک خواهد شد'
  end
end

local function unlock_group_english(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_english_lock = data[tostring(target)]['settings']['lock_english']
  if group_english_lock == 'no' then
    return 'حساسیت به حروف انگلیسی خاموش بود'
  else
    data[tostring(target)]['settings']['lock_english'] = 'no'
    save_data(_config.moderation.data, data)
    return 'حساسیت به حروف انگلیسی خاموش شد'
  end
end

local function lock_group_number(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_number_lock = data[tostring(target)]['settings']['lock_number']
  if group_number_lock == 'yes' then
    return 'حساسیت به اعداد فارسی و انگلیسی روشن است'
  else
    data[tostring(target)]['settings']['lock_number'] = 'yes'
    save_data(_config.moderation.data, data)
    return 'پست حاوی اعداد فارسی و انگلیسی پاک خواهد شد'
  end
end

local function unlock_group_number(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_number_lock = data[tostring(target)]['settings']['lock_number']
  if group_number_lock == 'no' then
    return 'حساسیت به اعداد فارسی و انگلیسی خاموش بود'
  else
    data[tostring(target)]['settings']['lock_number'] = 'no'
    save_data(_config.moderation.data, data)
    return 'پست حاوی اعداد فارسی و انگلیسی پاک نخواهد شد'
  end
end

local function lock_group_flood(msg, data, target)
  if not is_sudo(msg) then
    return
  end
  local group_flood_lock = data[tostring(target)]['settings']['flood']
  if group_flood_lock == 'yes' then
    return 'حساسیت به مقدار اسپم فعال بود'
  else
    data[tostring(target)]['settings']['flood'] = 'yes'
    save_data(_config.moderation.data, data)
    return 'حساسیت به مقدار اسپم فعال شد'
  end
end

local function unlock_group_flood(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_flood_lock = data[tostring(target)]['settings']['flood']
  if group_flood_lock == 'no' then
    return 'حساسیت به مقدار اسپم غیرفعال بود'
  else
    data[tostring(target)]['settings']['flood'] = 'no'
    save_data(_config.moderation.data, data)
    return 'حساسیت به مقدار اسپم غیرفعال شد'
  end
end

local function lock_group_membermod(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_member_lock = data[tostring(target)]['settings']['lock_member']
  if group_member_lock == 'yes' then
    return 'ورود اعضای جدید ممنوع بود'
  else
    data[tostring(target)]['settings']['lock_member'] = 'yes'
    save_data(_config.moderation.data, data)
  end
  return 'ورود اعضای جدید ممنوع شد'
end

local function unlock_group_membermod(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_member_lock = data[tostring(target)]['settings']['lock_member']
  if group_member_lock == 'no' then
    return 'ورود اعضای جدید مجاز بود'
  else
    data[tostring(target)]['settings']['lock_member'] = 'no'
    save_data(_config.moderation.data, data)
    return 'ورود اعضای جدید مجاز شد'
  end
end

local function lock_group_rtl(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_rtl_lock = data[tostring(target)]['settings']['lock_rtl']
  if group_rtl_lock == 'yes' then
    return 'RTL ممنوع بود'
  else
    data[tostring(target)]['settings']['lock_rtl'] = 'yes'
    save_data(_config.moderation.data, data)
    return 'RTL ممنوع شد'
  end
end

local function unlock_group_rtl(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_rtl_lock = data[tostring(target)]['settings']['lock_rtl']
  if group_rtl_lock == 'no' then
    return 'RTL مجاز بود'
  else
    data[tostring(target)]['settings']['lock_rtl'] = 'no'
    save_data(_config.moderation.data, data)
    return 'RTL مجاز شد'
  end
end

local function lock_group_tgservice(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_tgservice_lock = data[tostring(target)]['settings']['lock_tgservice']
  if group_tgservice_lock == 'yes' then
    return 'پیام های سرویسی از قبل پاک میشد'
  else
    data[tostring(target)]['settings']['lock_tgservice'] = 'yes'
    save_data(_config.moderation.data, data)
    return 'پیام های سرویسی پاک خواهد شد'
  end
end

local function unlock_group_tgservice(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_tgservice_lock = data[tostring(target)]['settings']['lock_tgservice']
  if group_tgservice_lock == 'no' then
    return 'پیام های سرویسی پاک نمیشد!'
  else
    data[tostring(target)]['settings']['lock_tgservice'] = 'no'
    save_data(_config.moderation.data, data)
    return 'پیام های سرویسی پاک نخواهد شد'
  end
end

local function lock_group_sticker(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_sticker_lock = data[tostring(target)]['settings']['lock_sticker']
  if group_sticker_lock == 'yes' then
    return 'قفل ارسال استیکر فعال بود'
  else
    data[tostring(target)]['settings']['lock_sticker'] = 'yes'
    save_data(_config.moderation.data, data)
    return 'قفل ارسال استیکر فعال شد✔️'
  end
end

local function unlock_group_sticker(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_sticker_lock = data[tostring(target)]['settings']['lock_sticker']
  if group_sticker_lock == 'no' then
    return 'ارسال استیکر مجاز بود'
  else
    data[tostring(target)]['settings']['lock_sticker'] = 'no'
    save_data(_config.moderation.data, data)
    return 'ارسال استیکر مجاز شد❌'
  end
end

local function lock_group_contacts(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_contacts_lock = data[tostring(target)]['settings']['lock_contacts']
  if group_contacts_lock == 'yes' then
    return 'ارسال مخاطب مجاز شد'
  else
    data[tostring(target)]['settings']['lock_contacts'] = 'yes'
    save_data(_config.moderation.data, data)
    return 'ارسال مخاطب مجاز شد✔️'
  end
end

local function unlock_group_contacts(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_contacts_lock = data[tostring(target)]['settings']['lock_contacts']
  if group_contacts_lock == 'no' then
    return 'ارسال مخاطب از قبل مجاز بود'
  else
    data[tostring(target)]['settings']['lock_contacts'] = 'no'
    save_data(_config.moderation.data, data)
    return 'ارسال مخاطب مجاز شد❌'
  end
end

local function enable_strict_rules(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_strict_lock = data[tostring(target)]['settings']['strict']
  if group_strict_lock == 'yes' then
    return 'تنظیمات سختگیرانه فعال بود'
  else
    data[tostring(target)]['settings']['strict'] = 'yes'
    save_data(_config.moderation.data, data)
    return 'تنظیمات سختگیرانه به شدت اجرا خواهد شد'
  end
end

local function disable_strict_rules(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_strict_lock = data[tostring(target)]['settings']['strict']
  if group_strict_lock == 'no' then
    return 'تنظیمات سختگیرانه غیرفعال بود'
  else
    data[tostring(target)]['settings']['strict'] = 'no'
    save_data(_config.moderation.data, data)
    return 'تنظیمات سختگیرانه غیرفعال شد'
  end
end
--End supergroup locks

--'Set supergroup rules' function
local function set_rulesmod(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local data_cat = 'rules'
  data[tostring(target)][data_cat] = rules
  save_data(_config.moderation.data, data)
  return 'قوانین سوپرگروه تنظیم شد'
end

--'Get supergroup rules' function
local function get_rules(msg, data)
  local data_cat = 'rules'
  if not data[tostring(msg.to.id)][data_cat] then
    return 'قوانینی موجود نیست.'
  end
  local rules = data[tostring(msg.to.id)][data_cat]
  local group_name = data[tostring(msg.to.id)]['settings']['set_name']
  local rules = group_name..' قوانین:\n\n'..rules:gsub("/n", " ")
  return rules
end

--Set supergroup to public or not public function
local function set_public_membermod(msg, data, target)
  if not is_momod(msg) then
    return "فقط برای مدیران!"
  end
  local group_public_lock = data[tostring(target)]['settings']['public']
  local long_id = data[tostring(target)]['long_id']
  if not long_id then
	data[tostring(target)]['long_id'] = msg.to.peer_id
	save_data(_config.moderation.data, data)
  end
  if group_public_lock == 'yes' then
    return 'سوپرگروه هم اکنون عمومی است'
  else
    data[tostring(target)]['settings']['public'] = 'yes'
    save_data(_config.moderation.data, data)
  end
  return 'سوپرگروه هم اکنون: عمومی'
end

local function unset_public_membermod(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_public_lock = data[tostring(target)]['settings']['public']
  local long_id = data[tostring(target)]['long_id']
  if not long_id then
	data[tostring(target)]['long_id'] = msg.to.peer_id
	save_data(_config.moderation.data, data)
  end
  if group_public_lock == 'no' then
    return '#سوپرگروه عمومی نیست'
  else
    data[tostring(target)]['settings']['public'] = 'no'
	data[tostring(target)]['long_id'] = msg.to.long_id
    save_data(_config.moderation.data, data)
    return 'سوپرگروه هم اکنون: غیرعمومی'
  end
end

--Show supergroup settings; function
function show_supergroup_settingsmod(msg, target)
 	if not is_momod(msg) then
    	return
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
      if data[tostring(target)]['settings'] then
		if not data[tostring(target)]['settings']['lock_tgservice'] then
			data[tostring(target)]['settings']['lock_tgservice'] = 'no'
		end
	end
	if data[tostring(target)]['settings'] then
		if not data[tostring(target)]['settings']['lock_member'] then
			data[tostring(target)]['settings']['lock_member'] = 'no'
		end
	end
  local settings = data[tostring(target)]['settings']
  local text = "⚙تنظیمات #سوپرگروه :\nقفل تگ: "..settings.lock_tag.."\nقفل تبلیغات: "..settings.lock_ads.."\nقفل اعداد: "..settings.lock_number.."\nقفل انگلیسی: "..settings.lock_english.."\nقفل اموجی: "..settings.lock_emoji.."\nقفل دستورات: "..settings.lock_command.."\nقفل لینک : "..settings.lock_link.."\nقفل فلود: "..settings.flood.."\nحساسیت ضداسپم : "..NUM_MSG_MAX.."\nقفل اسپم: "..settings.lock_spam.."\nقفل اعضا: "..settings.lock_member.."\nقفل RTL: "..settings.lock_rtl.."\nقفل پیام سرویسی : "..settings.lock_tgservice.."\nقفل استیکر: "..settings.lock_sticker.."\nعمومی: "..settings.public.."\nتنظیمات سختگیرانه: "..settings.strict
  return text
end

local function promote_admin(receiver, member_username, user_id)
  local data = load_data(_config.moderation.data)
  local group = string.gsub(receiver, 'channel#id', '')
  local member_tag_username = string.gsub(member_username, '@', '(at)')
  if not data[group] then
    return
  end
  if data[group]['moderators'][tostring(user_id)] then
    return send_large_msg(receiver, member_username..' یک مدیر است.')
  end
  data[group]['moderators'][tostring(user_id)] = member_tag_username
  save_data(_config.moderation.data, data)
end

local function demote_admin(receiver, member_username, user_id)
  local data = load_data(_config.moderation.data)
  local group = string.gsub(receiver, 'channel#id', '')
  if not data[group] then
    return
  end
  if not data[group]['moderators'][tostring(user_id)] then
    return send_large_msg(receiver, member_tag_username..' یک مدیر نیست.')
  end
  data[group]['moderators'][tostring(user_id)] = nil
  save_data(_config.moderation.data, data)
end

local function promote2(receiver, member_username, user_id)
  local data = load_data(_config.moderation.data)
  local group = string.gsub(receiver, 'channel#id', '')
  local member_tag_username = string.gsub(member_username, '@', '(at)')
  if not data[group] then
    return send_large_msg(receiver, '#سوپرگروه اضافه نشده.')
  end
  if data[group]['moderators'][tostring(user_id)] then
    return send_large_msg(receiver, member_username..' یک مدیر است.')
  end
  data[group]['moderators'][tostring(user_id)] = member_tag_username
  save_data(_config.moderation.data, data)
  send_large_msg(receiver, member_username..' ارتقا پیدا کرد.')
end

local function demote2(receiver, member_username, user_id)
  local data = load_data(_config.moderation.data)
  local group = string.gsub(receiver, 'channel#id', '')
  if not data[group] then
    return send_large_msg(receiver, 'گروه اضافه نشده.')
  end
  if not data[group]['moderators'][tostring(user_id)] then
    return send_large_msg(receiver, member_tag_username..' یک مدیر نیست.')
  end
  data[group]['moderators'][tostring(user_id)] = nil
  save_data(_config.moderation.data, data)
  send_large_msg(receiver, member_username..' تنزل پیدا کرد.')
end

local function modlist(msg)
  local data = load_data(_config.moderation.data)
  local groups = "groups"
  if not data[tostring(groups)][tostring(msg.to.id)] then
    return '#سوپرگروه اضافه نشده.'
  end
  -- determine if table is empty
  if next(data[tostring(msg.to.id)]['moderators']) == nil then
    return 'مدیری در این گروه نیست.'
  end
  local i = 1
  local message = '\nلیست مدیرانِ ' .. string.gsub(msg.to.print_name, '_', ' ') .. ':\n'
  for k,v in pairs(data[tostring(msg.to.id)]['moderators']) do
    message = message ..i..' - '..v..' [' ..k.. '] \n'
    i = i + 1
  end
  return message
end

-- Start by reply actions
function get_message_callback(extra, success, result)
	local get_cmd = extra.get_cmd
	local msg = extra.msg
	local data = load_data(_config.moderation.data)
	local print_name = user_print_name(msg.from):gsub("‮", "")
	local name_log = print_name:gsub("_", " ")
    if get_cmd == "id" and not result.action then
		local channel = 'channel#id'..result.to.peer_id
		savelog(msg.to.id, name_log.." ["..msg.from.id.."] obtained id for: ["..result.from.peer_id.."]")
		id1 = send_large_msg(channel, result.from.peer_id)
	elseif get_cmd == 'id' and result.action then
		local action = result.action.type
		if action == 'chat_add_user' or action == 'chat_del_user' or action == 'chat_rename' or action == 'chat_change_photo' then
			if result.action.user then
				user_id = result.action.user.peer_id
			else
				user_id = result.peer_id
			end
			local channel = 'channel#id'..result.to.peer_id
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] obtained id by service msg for: ["..user_id.."]")
			id1 = send_large_msg(channel, user_id)
		end
    elseif get_cmd == "idfrom" then
		local channel = 'channel#id'..result.to.peer_id
		savelog(msg.to.id, name_log.." ["..msg.from.id.."] obtained id for msg fwd from: ["..result.fwd_from.peer_id.."]")
		id2 = send_large_msg(channel, result.fwd_from.peer_id)
    elseif get_cmd == 'channel_block' and not result.action then
		local member_id = result.from.peer_id
		local channel_id = result.to.peer_id
    if member_id == msg.from.id then
      return send_large_msg("channel#id"..channel_id, "با دستور اخراجم کن ترک کرد")
    end
    if is_momod2(member_id, channel_id) and not is_admin2(msg.from.id) then
			   return send_large_msg("channel#id"..channel_id, "شما نمیتوانید مدیران را اخراج کنید")
    end
    if is_admin2(member_id) then
         return send_large_msg("channel#id"..channel_id, "شما نمیتوانید بقیه ادمین هارا اخراج کنید")
    end
		--savelog(msg.to.id, name_log.." ["..msg.from.id.."] kicked: ["..user_id.."] by reply")
		kick_user(member_id, channel_id)
	elseif get_cmd == 'channel_block' and result.action and result.action.type == 'chat_add_user' then
		local user_id = result.action.user.peer_id
		local channel_id = result.to.peer_id
    if member_id == msg.from.id then
      return send_large_msg("channel#id"..channel_id, "با دستور اخراجم کن ترک کرد")
    end
    if is_momod2(member_id, channel_id) and not is_admin2(msg.from.id) then
			   return send_large_msg("channel#id"..channel_id, "شما نمیتوانید مدیران را اخراج کنید")
    end
    if is_admin2(member_id) then
         return send_large_msg("channel#id"..channel_id, "شما نمیتوانید بقیه ادمین هارا اخراج کنید")
    end
		savelog(msg.to.id, name_log.." ["..msg.from.id.."] kicked: ["..user_id.."] by reply to sev. msg.")
		kick_user(user_id, channel_id)
	elseif get_cmd == "del" then
		delete_msg(result.id, ok_cb, false)
		savelog(msg.to.id, name_log.." ["..msg.from.id.."] deleted a message by reply")
	elseif get_cmd == "setadmin" then
		local user_id = result.from.peer_id
		local channel_id = "channel#id"..result.to.peer_id
		channel_set_admin(channel_id, "user#id"..user_id, ok_cb, false)
		if result.from.username then
			text = "@"..result.from.username.." ادمین شد"
		else
			text = "[ "..user_id.." ]ادمین شد"
		end
		savelog(msg.to.id, name_log.." ["..msg.from.id.."] set: ["..user_id.."] as admin by reply")
		send_large_msg(channel_id, text)
	elseif get_cmd == "demoteadmin" then
		local user_id = result.from.peer_id
		local channel_id = "channel#id"..result.to.peer_id
		if is_admin2(result.from.peer_id) then
			return send_large_msg(channel_id, "شما نمیتوانید ادمین گلوبال را عزل کنید!")
		end
		channel_demote(channel_id, "user#id"..user_id, ok_cb, false)
		if result.from.username then
			text = "@"..result.from.username.." از درجه ادمین عزل شد"
		else
			text = "[ "..user_id.." ] از درجه ادمین عزل شد"
		end
		savelog(msg.to.id, name_log.." ["..msg.from.id.."] demoted: ["..user_id.."] from admin by reply")
		send_large_msg(channel_id, text)
	elseif get_cmd == "setowner" then
		local group_owner = data[tostring(result.to.peer_id)]['set_owner']
		if group_owner then
		local channel_id = 'channel#id'..result.to.peer_id
			if not is_admin2(tonumber(group_owner)) and not is_support(tonumber(group_owner)) then
				local user = "user#id"..group_owner
				channel_demote(channel_id, user, ok_cb, false)
			end
			local user_id = "user#id"..result.from.peer_id
			channel_set_admin(channel_id, user_id, ok_cb, false)
			data[tostring(result.to.peer_id)]['set_owner'] = tostring(result.from.peer_id)
			save_data(_config.moderation.data, data)
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] set: ["..result.from.peer_id.."] as owner by reply")
			if result.from.username then
				text = "@"..result.from.username.." [ "..result.from.peer_id.." ] به عنوان مالک افزوده شد"
			else
				text = "[ "..result.from.peer_id.." ] به عنوان مالک افزوده شد"
			end
			send_large_msg(channel_id, text)
		end
	elseif get_cmd == "promote" then
		local receiver = result.to.peer_id
		local full_name = (result.from.first_name or '')..' '..(result.from.last_name or '')
		local member_name = full_name:gsub("‮", "")
		local member_username = member_name:gsub("_", " ")
		if result.from.username then
			member_username = '@'.. result.from.username
		end
		local member_id = result.from.peer_id
		if result.to.peer_type == 'channel' then
		savelog(msg.to.id, name_log.." ["..msg.from.id.."] promoted mod: @"..member_username.."["..result.from.peer_id.."] by reply")
		promote2("channel#id"..result.to.peer_id, member_username, member_id)
	    --channel_set_mod(channel_id, user, ok_cb, false)
		end
	elseif get_cmd == "demote" then
		local full_name = (result.from.first_name or '')..' '..(result.from.last_name or '')
		local member_name = full_name:gsub("‮", "")
		local member_username = member_name:gsub("_", " ")
    if result.from.username then
		member_username = '@'.. result.from.username
    end
		local member_id = result.from.peer_id
		--local user = "user#id"..result.peer_id
		savelog(msg.to.id, name_log.." ["..msg.from.id.."] demoted mod: @"..member_username.."["..user_id.."] by reply")
		demote2("channel#id"..result.to.peer_id, member_username, member_id)
		--channel_demote(channel_id, user, ok_cb, false)
	elseif get_cmd == 'mute_user' then
		if result.service then
			local action = result.action.type
			if action == 'chat_add_user' or action == 'chat_del_user' or action == 'chat_rename' or action == 'chat_change_photo' then
				if result.action.user then
					user_id = result.action.user.peer_id
				end
			end
			if action == 'chat_add_user_link' then
				if result.from then
					user_id = result.from.peer_id
				end
			end
		else
			user_id = result.from.peer_id
		end
		local receiver = extra.receiver
		local chat_id = msg.to.id
		print(user_id)
		print(chat_id)
		if is_muted_user(chat_id, user_id) then
			unmute_user(chat_id, user_id)
			send_large_msg(receiver, "["..user_id.."] از لیست بیصدا حذف شد")
		elseif is_admin1(msg) then
			mute_user(chat_id, user_id)
			send_large_msg(receiver, " ["..user_id.."] به لیست بیصدا افزوده شد")
		end
	end
end
-- End by reply actions

--By ID actions
local function cb_user_info(extra, success, result)
	local receiver = extra.receiver
	local user_id = result.peer_id
	local get_cmd = extra.get_cmd
	local data = load_data(_config.moderation.data)
	--[[if get_cmd == "setadmin" then
		local user_id = "user#id"..result.peer_id
		channel_set_admin(receiver, user_id, ok_cb, false)
		if result.username then
			text = "@"..result.username.." ادمین شد"
		else
			text = "[ "..result.peer_id.." ] ادمین شد"
		end
			send_large_msg(receiver, text)]]
	if get_cmd == "demoteadmin" then
		if is_admin2(result.peer_id) then
			return send_large_msg(receiver, "شما نمیتوانید ادمین گلوبال را عزل کنید")
		end
		local user_id = "user#id"..result.peer_id
		channel_demote(receiver, user_id, ok_cb, false)
		if result.username then
			text = "@"..result.username.." از ادمین عزل شد"
			send_large_msg(receiver, text)
		else
			text = "[ "..result.peer_id.." ] از ادمین عزل شد"
			send_large_msg(receiver, text)
		end
	elseif get_cmd == "promote" then
		if result.username then
			member_username = "@"..result.username
		else
			member_username = string.gsub(result.print_name, '_', ' ')
		end
		promote2(receiver, member_username, user_id)
	elseif get_cmd == "demote" then
		if result.username then
			member_username = "@"..result.username
		else
			member_username = string.gsub(result.print_name, '_', ' ')
		end
		demote2(receiver, member_username, user_id)
	end
end

-- Begin resolve username actions
local function callbackres(extra, success, result)
  local member_id = result.peer_id
  local member_username = "@"..result.username
  local get_cmd = extra.get_cmd
	if get_cmd == "res" then
		local user = result.peer_id
		local name = string.gsub(result.print_name, "_", " ")
		local channel = 'channel#id'..extra.channelid
		send_large_msg(channel, user..'\n'..name)
		return user
	elseif get_cmd == "id" then
		local user = result.peer_id
		local channel = 'channel#id'..extra.channelid
		send_large_msg(channel, user)
		return user
  elseif get_cmd == "invite" then
    local receiver = extra.channel
    local user_id = "user#id"..result.peer_id
    channel_invite(receiver, user_id, ok_cb, false)
	--[[elseif get_cmd == "channel_block" then
		local user_id = result.peer_id
		local channel_id = extra.channelid
    local sender = extra.sender
    if member_id == sender then
      return send_large_msg("channel#id"..channel_id, "با دستور اخراجم کن ترک کرد")
    end
		if is_momod2(member_id, channel_id) and not is_admin2(sender) then
			   return send_large_msg("channel#id"..channel_id, "شما نمیتوانید مدیران را اخراج کنید")
    end
    if is_admin2(member_id) then
         return send_large_msg("channel#id"..channel_id, "شما نمیتوانید ادمین هارا اخراج کنید")
    end
		kick_user(user_id, channel_id)
	elseif get_cmd == "setadmin" then
		local user_id = "user#id"..result.peer_id
		local channel_id = extra.channel
		channel_set_admin(channel_id, user_id, ok_cb, false)
		if result.username then
			text = "@"..result.username.." ادمین شد"
			send_large_msg(channel_id, text)
		else
			text = "@"..result.peer_id.." ادمین شد"
			send_large_msg(channel_id, text)
		end
	elseif get_cmd == "setowner" then
		local receiver = extra.channel
		local channel = string.gsub(receiver, 'channel#id', '')
		local from_id = extra.from_id
		local group_owner = data[tostring(channel)]['set_owner']
		if group_owner then
			local user = "user#id"..group_owner
			if not is_admin2(group_owner) and not is_support(group_owner) then
				channel_demote(receiver, user, ok_cb, false)
			end
			local user_id = "user#id"..result.peer_id
			channel_set_admin(receiver, user_id, ok_cb, false)
			data[tostring(channel)]['set_owner'] = tostring(result.peer_id)
			save_data(_config.moderation.data, data)
			savelog(channel, name_log.." ["..from_id.."] set ["..result.peer_id.."] as owner by username")
		if result.username then
			text = member_username.." [ "..result.peer_id.." ] added as owner"
		else
			text = "[ "..result.peer_id.." ] added as owner"
		end
		send_large_msg(receiver, text)
  end]]
	elseif get_cmd == "promote" then
		local receiver = extra.channel
		local user_id = result.peer_id
		--local user = "user#id"..result.peer_id
		promote2(receiver, member_username, user_id)
		--channel_set_mod(receiver, user, ok_cb, false)
	elseif get_cmd == "demote" then
		local receiver = extra.channel
		local user_id = result.peer_id
		local user = "user#id"..result.peer_id
		demote2(receiver, member_username, user_id)
	elseif get_cmd == "demoteadmin" then
		local user_id = "user#id"..result.peer_id
		local channel_id = extra.channel
		if is_admin2(result.peer_id) then
			return send_large_msg(channel_id, "شما نمیتوانید ادمین گلوبال را عزل کنید")
		end
		channel_demote(channel_id, user_id, ok_cb, false)
		if result.username then
			text = "@"..result.username.." از ادمین عزل شد"
			send_large_msg(channel_id, text)
		else
			text = "@"..result.peer_id.." از ادمین عزل شد"
			send_large_msg(channel_id, text)
		end
		local receiver = extra.channel
		local user_id = result.peer_id
		demote_admin(receiver, member_username, user_id)
	elseif get_cmd == 'mute_user' then
		local user_id = result.peer_id
		local receiver = extra.receiver
		local chat_id = string.gsub(receiver, 'channel#id', '')
		if is_muted_user(chat_id, user_id) then
			unmute_user(chat_id, user_id)
			send_large_msg(receiver, " ["..user_id.."] از لیست بیصدا حذف شد")
		elseif is_owner(extra.msg) then
			mute_user(chat_id, user_id)
			send_large_msg(receiver, " ["..user_id.."] به لیست بیصدا افزوده شد")
		end
	end
end
--End resolve username actions

--Begin non-channel_invite username actions
local function in_channel_cb(cb_extra, success, result)
  local get_cmd = cb_extra.get_cmd
  local receiver = cb_extra.receiver
  local msg = cb_extra.msg
  local data = load_data(_config.moderation.data)
  local print_name = user_print_name(cb_extra.msg.from):gsub("‮", "")
  local name_log = print_name:gsub("_", " ")
  local member = cb_extra.username
  local memberid = cb_extra.user_id
  if member then
    text = 'کاربری @'..member..' در این #سوپرگروه وجود ندارد.'
  else
    text = 'کاربری ['..memberid..'] در این #سوپرگروه وجود ندارد.'
  end
if get_cmd == "channel_block" then
  for k,v in pairs(result) do
    vusername = v.username
    vpeer_id = tostring(v.peer_id)
    if vusername == member or vpeer_id == memberid then
     local user_id = v.peer_id
     local channel_id = cb_extra.msg.to.id
     local sender = cb_extra.msg.from.id
      if user_id == sender then
        return send_large_msg("channel#id"..channel_id, "با دستور اخراجم کن ترک کرد")
      end
      if is_momod2(user_id, channel_id) and not is_admin2(sender) then
        return send_large_msg("channel#id"..channel_id, "شما نمیتوانید مدیران را اخراج کنید")
      end
      if is_admin2(user_id) then
        return send_large_msg("channel#id"..channel_id, "شما نمیتوانید بقیه ادمین هارا اخراج کنید")
      end
      if v.username then
        text = ""
        savelog(msg.to.id, name_log.." ["..msg.from.id.."] kicked: @"..v.username.." ["..v.peer_id.."]")
      else
        text = ""
        savelog(msg.to.id, name_log.." ["..msg.from.id.."] kicked: ["..v.peer_id.."]")
      end
      kick_user(user_id, channel_id)
      return
    end
  end
elseif get_cmd == "setadmin" then
   for k,v in pairs(result) do
    vusername = v.username
    vpeer_id = tostring(v.peer_id)
    if vusername == member or vpeer_id == memberid then
      local user_id = "user#id"..v.peer_id
      local channel_id = "channel#id"..cb_extra.msg.to.id
      channel_set_admin(channel_id, user_id, ok_cb, false)
      if v.username then
        text = "@"..v.username.." ["..v.peer_id.."] به درجه ادمین ترفیع پیدا کرد"
        savelog(msg.to.id, name_log.." ["..msg.from.id.."] set admin @"..v.username.." ["..v.peer_id.."]")
      else
        text = "["..v.peer_id.."] به درجه ادمین ترفیع پیدا کرد"
        savelog(msg.to.id, name_log.." ["..msg.from.id.."] set admin "..v.peer_id)
      end
	  if v.username then
		member_username = "@"..v.username
	  else
		member_username = string.gsub(v.print_name, '_', ' ')
	  end
		local receiver = channel_id
		local user_id = v.peer_id
		promote_admin(receiver, member_username, user_id)

    end
    send_large_msg(channel_id, text)
    return
 end
 elseif get_cmd == 'setowner' then
	for k,v in pairs(result) do
		vusername = v.username
		vpeer_id = tostring(v.peer_id)
		if vusername == member or vpeer_id == memberid then
			local channel = string.gsub(receiver, 'channel#id', '')
			local from_id = cb_extra.msg.from.id
			local group_owner = data[tostring(channel)]['set_owner']
			if group_owner then
				if not is_admin2(tonumber(group_owner)) and not is_support(tonumber(group_owner)) then
					local user = "user#id"..group_owner
					channel_demote(receiver, user, ok_cb, false)
				end
					local user_id = "user#id"..v.peer_id
					channel_set_admin(receiver, user_id, ok_cb, false)
					data[tostring(channel)]['set_owner'] = tostring(v.peer_id)
					save_data(_config.moderation.data, data)
					savelog(channel, name_log.."["..from_id.."] set ["..v.peer_id.."] as owner by username")
				if result.username then
					text = member_username.." ["..v.peer_id.."] مالک شد"
				else
					text = "["..v.peer_id.."] مالک شد"
				end
			end
		elseif memberid and vusername ~= member and vpeer_id ~= memberid then
			local channel = string.gsub(receiver, 'channel#id', '')
			local from_id = cb_extra.msg.from.id
			local group_owner = data[tostring(channel)]['set_owner']
			if group_owner then
				if not is_admin2(tonumber(group_owner)) and not is_support(tonumber(group_owner)) then
					local user = "user#id"..group_owner
					channel_demote(receiver, user, ok_cb, false)
				end
				data[tostring(channel)]['set_owner'] = tostring(memberid)
				save_data(_config.moderation.data, data)
				savelog(channel, name_log.."["..from_id.."] set ["..memberid.."] توسط یوزرنیم مالک شد")
				text = "["..memberid.."] مالک شد"
			end
		end
	end
 end
send_large_msg(receiver, text)
end
--End non-channel_invite username actions

--'Set supergroup photo' function
local function set_supergroup_photo(msg, success, result)
  local data = load_data(_config.moderation.data)
  if not data[tostring(msg.to.id)] then
      return
  end
  local receiver = get_receiver(msg)
  if success then
    local file = 'data/photos/channel_photo_'..msg.to.id..'.jpg'
    print('File downloaded to:', result)
    os.rename(result, file)
    print('File moved to:', file)
    channel_set_photo(receiver, file, ok_cb, false)
    data[tostring(msg.to.id)]['settings']['set_photo'] = file
    save_data(_config.moderation.data, data)
    send_large_msg(receiver, 'عکس ذخیره شد!', ok_cb, false)
  else
    print('Error downloading: '..msg.id)
    send_large_msg(receiver, 'خطا، لطفا دوباره تلاش کنید!', ok_cb, false)
  end
end

--Run function
local function run(msg, matches)
	if msg.to.type == 'chat' then
		if matches[1] == 'تبدیل به سوپرگروه' then
			if not is_admin1(msg) then
				return
			end
			local receiver = get_receiver(msg)
			chat_upgrade(receiver, ok_cb, false)
		end
	elseif msg.to.type == 'channel'then
		if matches[1] == 'تبدیل_به_سوپرگروه' then
			if not is_admin1(msg) then
				return
			end
			return "هم اکنون #سوپرگروه است"
		end
	end
	if msg.to.type == 'channel' then
	local support_id = msg.from.id
	local receiver = get_receiver(msg)
	local print_name = user_print_name(msg.from):gsub("‮", "")
	local name_log = print_name:gsub("_", " ")
	local data = load_data(_config.moderation.data)
		if matches[1] == 'نصب_گروه' and not matches[2] then
			if not is_admin1(msg) and not is_support(support_id) then
				return
			end
			if is_super_group(msg) then
				return reply_msg(msg.id, '#سوپرگروه افزوده شده است.', ok_cb, false)
			end
			print("SuperGroup "..msg.to.print_name.."("..msg.to.id..") added")
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] added SuperGroup")
			superadd(msg)
			set_mutes(msg.to.id)
			channel_set_admin(receiver, 'user#id'..msg.from.id, ok_cb, false)
		end

		if matches[1] == 'حذف_گروه' and is_admin1(msg) and not matches[2] then
			if not is_super_group(msg) then
				return reply_msg(msg.id, '#سوپرگروه افزوده نشده است.', ok_cb, false)
			end
			print("SuperGroup "..msg.to.print_name.."("..msg.to.id..") removed")
			superrem(msg)
			rem_mutes(msg.to.id)
		end

		if not data[tostring(msg.to.id)] then
			return
		end
		if matches[1] == "اطلاعات" then
			if not is_owner(msg) then
				return
			end
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] requested SuperGroup info")
			channel_info(receiver, callback_info, {receiver = receiver, msg = msg})
		end

		if matches[1] == "ادمین_ها" then
			if not is_owner(msg) and not is_support(msg.from.id) then
				return
			end
			member_type = 'Admins'
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] requested SuperGroup Admins list")
			admins = channel_get_admins(receiver,callback, {receiver = receiver, msg = msg, member_type = member_type})
		end

		if matches[1] == "مالک" then
			local group_owner = data[tostring(msg.to.id)]['set_owner']
			if not group_owner then
				return "مالکی نیست، به ادمین های ربات اطلاع دهید"
			end
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] used /owner")
			return "مالک #سوپرگروه ["..group_owner..']'
		end

		if matches[1] == "لیست_مدیران" then
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] requested group modlist")
			return modlist(msg)
			-- channel_get_admins(receiver,callback, {receiver = receiver})
		end

		if matches[1] == "ربات_ها" and is_momod(msg) then
			member_type = 'Bots'
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] requested SuperGroup bots list")
			channel_get_bots(receiver, callback, {receiver = receiver, msg = msg, member_type = member_type})
		end

		if matches[1] == "افراد" and not matches[2] and is_momod(msg) then
			local user_id = msg.from.peer_id
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] requested SuperGroup users list")
			channel_get_users(receiver, callback_who, {receiver = receiver})
		end

		if matches[1] == "اخراج_شدگان" and is_momod(msg) then
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] requested Kicked users list")
			channel_get_kicked(receiver, callback_kicked, {receiver = receiver})
		end

		if matches[1] == 'پاککن' and is_momod(msg) then
			if type(msg.reply_id) ~= "nil" then
				local cbreply_extra = {
					get_cmd = 'del',
					msg = msg
				}
				delete_msg(msg.id, ok_cb, false)
				get_message(msg.reply_id, get_message_callback, cbreply_extra)
			end
		end

		if matches[1] == 'بلاک' and is_momod(msg) then
			if type(msg.reply_id) ~= "nil" then
				local cbreply_extra = {
					get_cmd = 'channel_block',
					msg = msg
				}
				get_message(msg.reply_id, get_message_callback, cbreply_extra)
			elseif matches[1] == 'بلاک' and matches[2] and string.match(matches[2], '^%d+$') then
				--[[local user_id = matches[2]
				local channel_id = msg.to.id
				if is_momod2(user_id, channel_id) and not is_admin2(user_id) then
					return send_large_msg(receiver, "شما نمیتوانید مدیران را اخراج کنید")
				end
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] kicked: [ user#id"..user_id.." ]")
				kick_user(user_id, channel_id)]]
				local get_cmd = 'channel_block'
				local msg = msg
				local user_id = matches[2]
				channel_get_users (receiver, in_channel_cb, {get_cmd=get_cmd, receiver=receiver, msg=msg, user_id=user_id})
			elseif matches[1] == "بلاک" and matches[2] and not string.match(matches[2], '^%d+$') then
			--[[local cbres_extra = {
					channelid = msg.to.id,
					get_cmd = 'channel_block',
					sender = msg.from.id
				}
			    local username = matches[2]
				local username = string.gsub(matches[2], '@', '')
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] kicked: @"..username)
				resolve_username(username, callbackres, cbres_extra)]]
			local get_cmd = 'channel_block'
			local msg = msg
			local username = matches[2]
			local username = string.gsub(matches[2], '@', '')
			channel_get_users (receiver, in_channel_cb, {get_cmd=get_cmd, receiver=receiver, msg=msg, username=username})
			end
		end

		if matches[1] == 'ایدی' then
			if type(msg.reply_id) ~= "nil" and is_momod(msg) and not matches[2] then
				local cbreply_extra = {
					get_cmd = 'id',
					msg = msg
				}
				get_message(msg.reply_id, get_message_callback, cbreply_extra)
			elseif type(msg.reply_id) ~= "nil" and matches[2] == "from" and is_momod(msg) then
				local cbreply_extra = {
					get_cmd = 'idfrom',
					msg = msg
				}
				get_message(msg.reply_id, get_message_callback, cbreply_extra)
			elseif msg.text:match("@[%a%d]") then
				local cbres_extra = {
					channelid = msg.to.id,
					get_cmd = 'id'
				}
				local username = matches[2]
				local username = username:gsub("@","")
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] requested ID for: @"..username)
				resolve_username(username,  callbackres, cbres_extra)
			else
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] requested SuperGroup ID")
				return "ایدی #سوپرگروه " ..string.gsub(msg.to.print_name, "_", " ").. ":\n\n"..msg.to.id
			end
		end

		if matches[1] == 'اخراجم_کن' then
			if msg.to.type == 'channel' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] left via kickme")
				channel_kick("channel#id"..msg.to.id, "user#id"..msg.from.id, ok_cb, false)
			end
		end

		if matches[1] == 'لینک_جدید' and is_momod(msg)then
			local function callback_link (extra , success, result)
			local receiver = get_receiver(msg)
				if success == 0 then
					send_large_msg(receiver, '*خطا: ناموفق بودن ربات هنگام دریافت لینک\nدلیل: صاحب اصلی #سوپرگروه نبودن\nاگر شما لینک را دارید با دستور #تنظیم_لینک آنرا تنظیم کنید')
					data[tostring(msg.to.id)]['settings']['set_link'] = nil
					save_data(_config.moderation.data, data)
				else
					send_large_msg(receiver, "لینک جدید ساخته شد")
					data[tostring(msg.to.id)]['settings']['set_link'] = result
					save_data(_config.moderation.data, data)
				end
			end
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] attempted to create a new SuperGroup link")
			export_channel_link(receiver, callback_link, false)
		end

		if matches[1] == 'تنظیم_لینک' and is_owner(msg) then
			data[tostring(msg.to.id)]['settings']['set_link'] = 'waiting'
			save_data(_config.moderation.data, data)
			return 'لطفا لینک جدید را ارسال کنید'
		end

		if msg.text then
			if msg.text:match("^(https://telegram.me/joinchat/%S+)$") and data[tostring(msg.to.id)]['settings']['set_link'] == 'waiting' and is_owner(msg) then
				data[tostring(msg.to.id)]['settings']['set_link'] = msg.text
				save_data(_config.moderation.data, data)
				return "لینک جدید تنظیم شد"
			end
		end

		if matches[1] == 'لینک' then
			if not is_momod(msg) then
				return
			end
			local group_link = data[tostring(msg.to.id)]['settings']['set_link']
			if not group_link then
				return "ابتدا با دستور #لینک_جدید لینک جدید را بسازید\nاگر من سازنده گروه نیستم با دستور #تنظیم_لینک لینک را تنظیم کنید"
			end
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] requested group link ["..group_link.."]")
			return "لینک گروه:\n"..group_link
		end

		if matches[1] == "دعوت" and is_sudo(msg) then
			local cbres_extra = {
				channel = get_receiver(msg),
				get_cmd = "invite"
			}
			local username = matches[2]
			local username = username:gsub("@","")
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] invited @"..username)
			resolve_username(username,  callbackres, cbres_extra)
		end

		if matches[1] == 'درمورد' and is_owner(msg) then
			local cbres_extra = {
				channelid = msg.to.id,
				get_cmd = 'res'
			}
			local username = matches[2]
			local username = username:gsub("@","")
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] resolved username: @"..username)
			resolve_username(username,  callbackres, cbres_extra)
		end

		--[[if matches[1] == 'اخراج' and is_momod(msg) then
			local receiver = channel..matches[3]
			local user = "user#id"..matches[2]
			chaannel_kick(receiver, user, ok_cb, false)
		end]]

			if matches[1] == 'تنظیم_ادمین' then
				if not is_support(msg.from.id) and not is_owner(msg) then
					return
				end
			if type(msg.reply_id) ~= "nil" then
				local cbreply_extra = {
					get_cmd = 'setadmin',
					msg = msg
				}
				setadmin = get_message(msg.reply_id, get_message_callback, cbreply_extra)
			elseif matches[1] == 'تنظیم_ادمین' and matches[2] and string.match(matches[2], '^%d+$') then
			--[[]	local receiver = get_receiver(msg)
				local user_id = "user#id"..matches[2]
				local get_cmd = 'setadmin'
				user_info(user_id, cb_user_info, {receiver = receiver, get_cmd = get_cmd})]]
				local get_cmd = 'setadmin'
				local msg = msg
				local user_id = matches[2]
				channel_get_users (receiver, in_channel_cb, {get_cmd=get_cmd, receiver=receiver, msg=msg, user_id=user_id})
			elseif matches[1] == 'تنظیم_ادمین' and matches[2] and not string.match(matches[2], '^%d+$') then
				--[[local cbres_extra = {
					channel = get_receiver(msg),
					get_cmd = 'setadmin'
				}
				local username = matches[2]
				local username = string.gsub(matches[2], '@', '')
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] set admin @"..username)
				resolve_username(username, callbackres, cbres_extra)]]
				local get_cmd = 'setadmin'
				local msg = msg
				local username = matches[2]
				local username = string.gsub(matches[2], '@', '')
				channel_get_users (receiver, in_channel_cb, {get_cmd=get_cmd, receiver=receiver, msg=msg, username=username})
			end
		end

		if matches[1] == 'عزل_ادمین' then
			if not is_support(msg.from.id) and not is_owner(msg) then
				return
			end
			if type(msg.reply_id) ~= "nil" then
				local cbreply_extra = {
					get_cmd = 'demoteadmin',
					msg = msg
				}
				demoteadmin = get_message(msg.reply_id, get_message_callback, cbreply_extra)
			elseif matches[1] == 'عزل_ادمین' and matches[2] and string.match(matches[2], '^%d+$') then
				local receiver = get_receiver(msg)
				local user_id = "user#id"..matches[2]
				local get_cmd = 'demoteadmin'
				user_info(user_id, cb_user_info, {receiver = receiver, get_cmd = get_cmd})
			elseif matches[1] == 'عزل_ادمین' and matches[2] and not string.match(matches[2], '^%d+$') then
				local cbres_extra = {
					channel = get_receiver(msg),
					get_cmd = 'demoteadmin'
				}
				local username = matches[2]
				local username = string.gsub(matches[2], '@', '')
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] demoted admin @"..username)
				resolve_username(username, callbackres, cbres_extra)
			end
		end

		if matches[1] == 'تنظیم_مالک' and is_owner(msg) then
			if type(msg.reply_id) ~= "nil" then
				local cbreply_extra = {
					get_cmd = 'setowner',
					msg = msg
				}
				setowner = get_message(msg.reply_id, get_message_callback, cbreply_extra)
			elseif matches[1] == 'تنظیم_مالک' and matches[2] and string.match(matches[2], '^%d+$') then
		--[[	local group_owner = data[tostring(msg.to.id)]['set_owner']
				if group_owner then
					local receiver = get_receiver(msg)
					local user_id = "user#id"..group_owner
					if not is_admin2(group_owner) and not is_support(group_owner) then
						channel_demote(receiver, user_id, ok_cb, false)
					end
					local user = "user#id"..matches[2]
					channel_set_admin(receiver, user, ok_cb, false)
					data[tostring(msg.to.id)]['set_owner'] = tostring(matches[2])
					save_data(_config.moderation.data, data)
					savelog(msg.to.id, name_log.." ["..msg.from.id.."] set ["..matches[2].."] as owner")
					local text = "[ "..matches[2].." ] added as owner"
					return text
				end]]
				local	get_cmd = 'setowner'
				local	msg = msg
				local user_id = matches[2]
				channel_get_users (receiver, in_channel_cb, {get_cmd=get_cmd, receiver=receiver, msg=msg, user_id=user_id})
			elseif matches[1] == 'تنظیم_مالک' and matches[2] and not string.match(matches[2], '^%d+$') then
				local	get_cmd = 'setowner'
				local	msg = msg
				local username = matches[2]
				local username = string.gsub(matches[2], '@', '')
				channel_get_users (receiver, in_channel_cb, {get_cmd=get_cmd, receiver=receiver, msg=msg, username=username})
			end
		end

		if matches[1] == 'ترفیع' then
		  if not is_momod(msg) then
				return
			end
			if not is_owner(msg) then
				return "فقط مالک/ادمین میتواند ترفیع دهد"
			end
			if type(msg.reply_id) ~= "nil" then
				local cbreply_extra = {
					get_cmd = 'promote',
					msg = msg
				}
				promote = get_message(msg.reply_id, get_message_callback, cbreply_extra)
			elseif matches[1] == 'ترفیع' and matches[2] and string.match(matches[2], '^%d+$') then
				local receiver = get_receiver(msg)
				local user_id = "user#id"..matches[2]
				local get_cmd = 'promote'
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] promoted user#id"..matches[2])
				user_info(user_id, cb_user_info, {receiver = receiver, get_cmd = get_cmd})
			elseif matches[1] == 'ترفیع' and matches[2] and not string.match(matches[2], '^%d+$') then
				local cbres_extra = {
					channel = get_receiver(msg),
					get_cmd = 'promote',
				}
				local username = matches[2]
				local username = string.gsub(matches[2], '@', '')
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] promoted @"..username)
				return resolve_username(username, callbackres, cbres_extra)
			end
		end

		if matches[1] == 'مدیر_ویژه_ترفیع' and is_sudo(msg) then
			channel = get_receiver(msg)
			user_id = 'user#id'..matches[2]
			channel_set_mod(channel, user_id, ok_cb, false)
			return "اوکی"
		end
		if matches[1] == 'مدیر_ویژه_عزل' and is_sudo(msg) then
			channel = get_receiver(msg)
			user_id = 'user#id'..matches[2]
			channel_demote(channel, user_id, ok_cb, false)
			return "اوکی"
		end

		if matches[1] == 'عزل' then
			if not is_momod(msg) then
				return
			end
			if not is_owner(msg) then
				return "فقط مالک/پشتیبان/ادمین میتواند ترفیع بدهد"
			end
			if type(msg.reply_id) ~= "nil" then
				local cbreply_extra = {
					get_cmd = 'demote',
					msg = msg
				}
				demote = get_message(msg.reply_id, get_message_callback, cbreply_extra)
			elseif matches[1] == 'عزل' and matches[2] and string.match(matches[2], '^%d+$') then
				local receiver = get_receiver(msg)
				local user_id = "user#id"..matches[2]
				local get_cmd = 'demote'
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] demoted user#id"..matches[2])
				user_info(user_id, cb_user_info, {receiver = receiver, get_cmd = get_cmd})
			elseif matches[1] == 'عزل' and matches[2] and not string.match(matches[2], '^%d+$') then
				local cbres_extra = {
					channel = get_receiver(msg),
					get_cmd = 'demote'
				}
				local username = matches[2]
				local username = string.gsub(matches[2], '@', '')
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] demoted @"..username)
				return resolve_username(username, callbackres, cbres_extra)
			end
		end

		if matches[1] == "تنظیم_اسم" and is_momod(msg) then
			local receiver = get_receiver(msg)
			local set_name = string.gsub(matches[2], '_', '')
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] renamed SuperGroup to: "..matches[2])
			rename_channel(receiver, set_name, ok_cb, false)
		end

		if msg.service and msg.action.type == 'chat_rename' then
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] renamed SuperGroup to: "..msg.to.title)
			data[tostring(msg.to.id)]['settings']['set_name'] = msg.to.title
			save_data(_config.moderation.data, data)
		end

		if matches[1] == "تنظیم_درباره" and is_momod(msg) then
			local receiver = get_receiver(msg)
			local about_text = matches[2]
			local data_cat = 'description'
			local target = msg.to.id
			data[tostring(target)][data_cat] = about_text
			save_data(_config.moderation.data, data)
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] set SuperGroup description to: "..about_text)
			channel_set_about(receiver, about_text, ok_cb, false)
			return "توضیحات تنظیم شد.\n\nگروه را انتخاب کنید تا تغییرات را ببینید."
		end

		if matches[1] == "تنظیم_یوزرنیم" and is_admin1(msg) then
			local function ok_username_cb (extra, success, result)
				local receiver = extra.receiver
				if success == 1 then
					send_large_msg(receiver, "یوزرنیم #سوپرگروه تنظیم شد.")
				elseif success == 0 then
					send_large_msg(receiver, "عملیات تنظیم یوزرنیم #سوپرگروه ناموفق بود.\nممکنه یوزرنیم گرفته شده باشد.\n\nنکته: برای یوزرنیم میتوانید از حروف a تا z و اعداد 0 تا 9 استفاده کنید\nحداقل تعداد کاراکتر ها 5 میباشد.")
				end
			end
			local username = string.gsub(matches[2], '@', '')
			channel_set_username(receiver, username, ok_username_cb, {receiver=receiver})
		end

		if matches[1] == 'تنظیم_قوانین' and is_momod(msg) then
			rules = matches[2]
			local target = msg.to.id
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] has changed group rules to ["..matches[2].."]")
			return set_rulesmod(msg, data, target)
		end

		if msg.media then
			if msg.media.type == 'photo' and data[tostring(msg.to.id)]['settings']['set_photo'] == 'waiting' and is_momod(msg) then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] set new SuperGroup photo")
				load_photo(msg.id, set_supergroup_photo, msg)
				return
			end
		end
		if matches[1] == 'تنظیم_عکس' and is_momod(msg) then
			data[tostring(msg.to.id)]['settings']['set_photo'] = 'waiting'
			save_data(_config.moderation.data, data)
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] started setting new SuperGroup photo")
			return 'لطفا عکس جدید را بفرستید'
		end

		if matches[1] == 'پاکسازی' then
			if not is_momod(msg) then
				return
			end
			if not is_momod(msg) then
				return "فقط مالک میتواند پاک کند"
			end
			if matches[2] == 'لیست_مدیران' then
				if next(data[tostring(msg.to.id)]['moderators']) == nil then
					return 'هیچ مدیری(مدیرانی) در این #سوپرگروه نیست.'
				end
				for k,v in pairs(data[tostring(msg.to.id)]['moderators']) do
					data[tostring(msg.to.id)]['moderators'][tostring(k)] = nil
					save_data(_config.moderation.data, data)
				end
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] cleaned modlist")
				return 'لیست مدیران پاک شد'
			end
			if matches[2] == 'قوانین' then
				local data_cat = 'rules'
				if data[tostring(msg.to.id)][data_cat] == nil then
					return "قوانین تنظیم شد"
				end
				data[tostring(msg.to.id)][data_cat] = nil
				save_data(_config.moderation.data, data)
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] cleaned rules")
				return 'قوانین پاک شد'
			end
			if matches[2] == 'درباره' then
				local receiver = get_receiver(msg)
				local about_text = ' '
				local data_cat = 'description'
				if data[tostring(msg.to.id)][data_cat] == nil then
					return 'درباره تنظیم نشده است'
				end
				data[tostring(msg.to.id)][data_cat] = nil
				save_data(_config.moderation.data, data)
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] cleaned about")
				channel_set_about(receiver, about_text, ok_cb, false)
				return "درباره پاک شد"
			end
			if matches[2] == 'لیست_کاربران_بیصدا' then
				chat_id = msg.to.id
				local hash =  'mute_user:'..chat_id
					redis:del(hash)
				return "لیست بیصدا پاک شد"
			end
			if matches[2] == 'یوزرنیم' and is_admin1(msg) then
				local function ok_username_cb (extra, success, result)
					local receiver = extra.receiver
					if success == 1 then
						send_large_msg(receiver, "یوزرنیم #سوپرگروه برداشته شد.")
					elseif success == 0 then
						send_large_msg(receiver, "عملیات برداشتن یوزرنیم #سوپرگروه با شکست مواجه شد.")
					end
				end
				local username = ""
				channel_set_username(receiver, username, ok_username_cb, {receiver=receiver})
			end
			if matches[2] == "ربات_ها" and is_momod(msg) then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] kicked all SuperGroup bots")
				channel_get_bots(receiver, callback_clean_bots, {msg = msg})
			end
		end

		if matches[1] == 'قفل_کردن' and is_momod(msg) then
			local target = msg.to.id
			if matches[2] == 'لینک' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked link posting ")
				return lock_group_links(msg, data, target)
			end
			if matches[2] == 'اسپم' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked spam ")
				return lock_group_spam(msg, data, target)
			end
            if matches[2] == 'اموجی' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked emoji ")
				return lock_group_emoji(msg, data, target)
			end
            if matches[2] == 'تگ' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked tag ")
				return lock_group_tag(msg, data, target)
			end
            if matches[2] == 'تبلیغات' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked ads ")
				return lock_group_ads(msg, data, target)
			end
            if matches[2] == 'دستورات' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked command ")
				return lock_group_command(msg, data, target)
			end
            if matches[2] == 'انگلیسی' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked english ")
				return lock_group_english(msg, data, target)
			end
            if matches[2] == 'اعداد' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked number ")
				return lock_group_number(msg, data, target)
			end
			if matches[2] == 'فلود' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked flood ")
				return lock_group_flood(msg, data, target)
			end
			if matches[2] == 'اعضا' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked member ")
				return lock_group_membermod(msg, data, target)
			end
			if matches[2]:lower() == 'rtl' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked rtl chars. in names")
				return lock_group_rtl(msg, data, target)
			end
			if matches[2] == 'پیام سرویسی' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked Tgservice Actions")
				return lock_group_tgservice(msg, data, target)
			end
			if matches[2] == 'استیکر' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked sticker posting")
				return lock_group_sticker(msg, data, target)
			end
			if matches[2] == 'مخاطب' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked contact posting")
				return lock_group_contacts(msg, data, target)
			end
			if matches[2] == 'سختگیرانه' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked enabled strict settings")
				return enable_strict_rules(msg, data, target)
			end
		end

		if matches[1] == 'باز_کردن' and is_momod(msg) then
			local target = msg.to.id
			if matches[2] == 'لینک' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] unlocked link posting")
				return unlock_group_links(msg, data, target)
			end
			if matches[2] == 'اسپم' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] unlocked spam")
				return unlock_group_spam(msg, data, target)
			end
            if matches[2] == 'اموجی' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] unlocked emoji posting")
				return unlock_group_emoji(msg, data, target)
			end
            if matches[2] == 'تگ' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] unlocked tag posting")
				return unlock_group_tag(msg, data, target)
			end
            if matches[2] == 'تبلیغات' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] unlocked ads posting")
				return unlock_group_ads(msg, data, target)
			end
			if matches[2] == 'دستورات' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] unlocked command posting")
				return unlock_group_command(msg, data, target)
			end
            if matches[2] == 'انگلیسی' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] unlocked english posting")
				return unlock_group_english(msg, data, target)
			end
            if matches[2] == 'اعداد' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] unlocked number posting")
				return unlock_group_number(msg, data, target)
			end
			if matches[2] == 'فلود' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] unlocked flood")
				return unlock_group_flood(msg, data, target)
			end
			if matches[2] == 'اعضا' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] unlocked member ")
				return unlock_group_membermod(msg, data, target)
			end
			if matches[2]:lower() == 'rtl' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] unlocked RTL chars. in names")
				return unlock_group_rtl(msg, data, target)
			end
			if matches[2] == 'پیام سرویسی' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] unlocked tgservice actions")
				return unlock_group_tgservice(msg, data, target)
			end
			if matches[2] == 'استیکر' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] unlocked sticker posting")
				return unlock_group_sticker(msg, data, target)
			end
			if matches[2] == 'مخاطب' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] unlocked contact posting")
				return unlock_group_contacts(msg, data, target)
			end
			if matches[2] == 'سختگیرانه' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked disabled strict settings")
				return disable_strict_rules(msg, data, target)
			end
		end

		if matches[1] == 'حساسیت_ضداسپم' then
			if not is_momod(msg) then
				return
			end
			if tonumber(matches[2]) < 5 or tonumber(matches[2]) > 20 then
				return "عدد اشتباه است، محدوده بین [5-20] است"
			end
			local flood_max = matches[2]
			data[tostring(msg.to.id)]['settings']['flood_msg_max'] = flood_max
			save_data(_config.moderation.data, data)
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] set flood to ["..matches[2].."]")
			return 'حساسیت ضداسپم تنظیم شد به روی: '..matches[2]
		end
		if matches[1] == 'عمومی' and is_momod(msg) then
			local target = msg.to.id
			if matches[2] == 'روشن' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] set group to: public")
				return set_public_membermod(msg, data, target)
			end
			if matches[2] == 'خاموش' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] set SuperGroup to: not public")
				return unset_public_membermod(msg, data, target)
			end
		end

		if matches[1] == 'ممنوع_کردن' and is_owner(msg) then
			local chat_id = msg.to.id
			if matches[2] == 'صدا' then
			local msg_type = 'Audio'
				if not is_muted(chat_id, msg_type..': yes') then
					savelog(msg.to.id, name_log.." ["..msg.from.id.."] set SuperGroup to: mute "..msg_type)
					mute(chat_id, msg_type)
					return "حساسیت به محتوا 'صدا' فعال شد و در صورت ارسال این محتوا، محتوا موردنظر از #سوپرگروه حذف خواهد شد"
				else
					return "حساسیت به محتوا 'صدا' فعال بود"
				end
			end
			if matches[2] == 'عکس' then
			local msg_type = 'Photo'
				if not is_muted(chat_id, msg_type..': yes') then
					savelog(msg.to.id, name_log.." ["..msg.from.id.."] set SuperGroup to: mute "..msg_type)
					mute(chat_id, msg_type)
					return "حساسیت به محتوا 'عکس' فعال شد و در صورت ارسال این محتوا، محتوا موردنظر از #سوپرگروه حذف خواهد شد"
				else
					return "حساسیت به محتوا 'عکس' فعال بود"
				end
			end
			if matches[2] == 'فیلم' then
			local msg_type = 'Video'
				if not is_muted(chat_id, msg_type..': yes') then
					savelog(msg.to.id, name_log.." ["..msg.from.id.."] set SuperGroup to: mute "..msg_type)
					mute(chat_id, msg_type)
					return "حساسیت به محتوا 'فیلم' فعال شد و در صورت ارسال این محتوا، محتوا موردنظر از #سوپرگروه حذف خواهد شد"
				else
					return "حساسیت به محتوا 'فیلم' فعال بود"
				end
			end
			if matches[2] == 'گیف' then
			local msg_type = 'Gifs'
				if not is_muted(chat_id, msg_type..': yes') then
					savelog(msg.to.id, name_log.." ["..msg.from.id.."] set SuperGroup to: mute "..msg_type)
					mute(chat_id, msg_type)
					return "حساسیت به محتوا 'گیف' فعال شد و در صورت ارسال این محتوا، محتوا موردنظر از #سوپرگروه حذف خواهد شد"
				else
					return "حساسیت به محتوا 'گیف' فعال بود"
				end
			end
			if matches[2] == 'فایل' then
			local msg_type = 'Documents'
				if not is_muted(chat_id, msg_type..': yes') then
					savelog(msg.to.id, name_log.." ["..msg.from.id.."] set SuperGroup to: mute "..msg_type)
					mute(chat_id, msg_type)
					return "حساسیت به محتوا 'فایل' فعال شد و در صورت ارسال این محتوا، محتوا موردنظر از #سوپرگروه حذف خواهد شد"
				else
					return "حساسیت به محتوا 'فایل' فعال بود"
				end
			end
			if matches[2] == 'متن' then
			local msg_type = 'Text'
				if not is_muted(chat_id, msg_type..': yes') then
					savelog(msg.to.id, name_log.." ["..msg.from.id.."] set SuperGroup to: mute "..msg_type)
					mute(chat_id, msg_type)
					return "حساسیت به محتوا 'متن' فعال شد و در صورت ارسال این محتوا، محتوا موردنظر از #سوپرگروه حذف خواهد شد"
				else
					return "حساسیت به محتوا 'متن' فعال بود"
				end
			end
			if matches[2] == 'همه' then
			local msg_type = 'All'
				if not is_muted(chat_id, msg_type..': yes') then
					savelog(msg.to.id, name_log.." ["..msg.from.id.."] set SuperGroup to: mute "..msg_type)
					mute(chat_id, msg_type)
					return "حساسیت به محتوا تمام موارد فعال شد و در صورت ارسال هر محتوایی، تمام محتواها از #سوپرگروه حذف خواهد شد"
				else
					return "حساسیت به هر محتوایی فعال بود"
				end
			end
		end
		if matches[1] == 'ازاد_کردن' and is_momod(msg) then
			local chat_id = msg.to.id
			if matches[2] == 'صدا' then
			local msg_type = 'Audio'
				if is_muted(chat_id, msg_type..': yes') then
					savelog(msg.to.id, name_log.." ["..msg.from.id.."] set SuperGroup to: unmute "..msg_type)
					unmute(chat_id, msg_type)
					return "حساسیت به محتوا 'صدا' غیرفعال شد"
				else
					return "حساسیت به محتوا 'صدا' غیرفعال بود"
				end
			end
			if matches[2] == 'عکس' then
			local msg_type = 'Photo'
				if is_muted(chat_id, msg_type..': yes') then
					savelog(msg.to.id, name_log.." ["..msg.from.id.."] set SuperGroup to: unmute "..msg_type)
					unmute(chat_id, msg_type)
					return "حساسیت به محتوا 'عکس' غیرفعال شد"
				else
					return "حساسیت به محتوا 'عکس' غیرفعال بود"
				end
			end
			if matches[2] == 'فیلم' then
			local msg_type = 'Video'
				if is_muted(chat_id, msg_type..': yes') then
					savelog(msg.to.id, name_log.." ["..msg.from.id.."] set SuperGroup to: unmute "..msg_type)
					unmute(chat_id, msg_type)
					return "حساسیت به محتوا 'فیلم' غیرفعال شد"
				else
					return "حساسیت به محتوا 'فیلم' غیرفعال بود"
				end
			end
			if matches[2] == 'گیف' then
			local msg_type = 'Gifs'
				if is_muted(chat_id, msg_type..': yes') then
					savelog(msg.to.id, name_log.." ["..msg.from.id.."] set SuperGroup to: unmute "..msg_type)
					unmute(chat_id, msg_type)
					return "حساسیت به محتوا 'گیف' غیرفعال شد"
				else
					return "حساسیت به محتوا 'گیف' غیرفعال بود"
				end
			end
			if matches[2] == 'فایل' then
			local msg_type = 'Documents'
				if is_muted(chat_id, msg_type..': yes') then
					savelog(msg.to.id, name_log.." ["..msg.from.id.."] set SuperGroup to: unmute "..msg_type)
					unmute(chat_id, msg_type)
					return "حساسیت به محتوا 'فایل' غیرفعال شد"
				else
					return "حساسیت به محتوا 'فایل' غیرفعال بود"
				end
			end
			if matches[2] == 'متن' then
			local msg_type = 'Text'
				if is_muted(chat_id, msg_type..': yes') then
					savelog(msg.to.id, name_log.." ["..msg.from.id.."] set SuperGroup to: unmute message")
					unmute(chat_id, msg_type)
					return "حساسیت به محتوا 'متن' غیرفعال شد"
				else
					return "حساسیت به محتوا 'متن' غیرفعال بود"
				end
			end
			if matches[2] == 'همه' then
			local msg_type = 'All'
				if is_muted(chat_id, msg_type..': yes') then
					savelog(msg.to.id, name_log.." ["..msg.from.id.."] set SuperGroup to: unmute "..msg_type)
					unmute(chat_id, msg_type)
					return "حساسیت به هر محتوایی غیرفعال شد"
				else
					return "حساسیت به هرمحتوایی غیرفعال بود"
				end
			end
		end


		if matches[1] == "کاربر_بیصدا" and is_momod(msg) then
			local chat_id = msg.to.id
			local hash = "mute_user"..chat_id
			local user_id = ""
			if type(msg.reply_id) ~= "nil" then
				local receiver = get_receiver(msg)
				local get_cmd = "mute_user"
				muteuser = get_message(msg.reply_id, get_message_callback, {receiver = receiver, get_cmd = get_cmd, msg = msg})
			elseif matches[1] == "کاربر_بیصدا" and matches[2] and string.match(matches[2], '^%d+$') then
				local user_id = matches[2]
				if is_muted_user(chat_id, user_id) then
					unmute_user(chat_id, user_id)
					savelog(msg.to.id, name_log.." ["..msg.from.id.."] removed ["..user_id.."] from the muted users list")
					return "["..user_id.."] از لیست بیصدا حذف شد"
				elseif is_owner(msg) then
					mute_user(chat_id, user_id)
					savelog(msg.to.id, name_log.." ["..msg.from.id.."] added ["..user_id.."] to the muted users list")
					return "["..user_id.."] به لیست بیصدا افزوده شد"
				end
			elseif matches[1] == "کاربر_بیصدا" and matches[2] and not string.match(matches[2], '^%d+$') then
				local receiver = get_receiver(msg)
				local get_cmd = "mute_user"
				local username = matches[2]
				local username = string.gsub(matches[2], '@', '')
				resolve_username(username, callbackres, {receiver = receiver, get_cmd = get_cmd, msg=msg})
			end
		end

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
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] requested SuperGroup settings ")
			return show_supergroup_settingsmod(msg, target)
		end

		if matches[1] == 'قوانین' then
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] requested group rules")
			return get_rules(msg, data)
		end

		if matches[1] == 'راهنما' and not is_owner(msg) then
			text = "برای دیدن راهنما، لطفا دستور #راهنما_سوپرگروه را به پیوی @TeleGold بفرستید"
			reply_msg(msg.id, text, ok_cb, false)
		elseif matches[1] == 'راهنما' and is_owner(msg) then
			local name_log = user_print_name(msg.from)
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] Used /superhelp")
			return super_help()
		end

		if matches[1] == 'peer_id' and is_admin1(msg)then
			text = msg.to.peer_id
			reply_msg(msg.id, text, ok_cb, false)
			post_large_msg(receiver, text)
		end

		if matches[1] == 'msg.to.id' and is_admin1(msg) then
			text = msg.to.id
			reply_msg(msg.id, text, ok_cb, false)
			post_large_msg(receiver, text)
		end

		--Admin Join Service Message
		if msg.service then
		local action = msg.action.type
			if action == 'chat_add_user_link' then
				if is_owner2(msg.from.id) then
					local receiver = get_receiver(msg)
					local user = "user#id"..msg.from.id
					savelog(msg.to.id, name_log.." Admin ["..msg.from.id.."] joined the SuperGroup via link")
					channel_set_admin(receiver, user, ok_cb, false)
				end
				if is_support(msg.from.id) and not is_owner2(msg.from.id) then
					local receiver = get_receiver(msg)
					local user = "user#id"..msg.from.id
					savelog(msg.to.id, name_log.." Support member ["..msg.from.id.."] joined the SuperGroup")
					channel_set_mod(receiver, user, ok_cb, false)
				end
			end
			if action == 'chat_add_user' then
				if is_owner2(msg.action.user.id) then
					local receiver = get_receiver(msg)
					local user = "user#id"..msg.action.user.id
					savelog(msg.to.id, name_log.." Admin ["..msg.action.user.id.."] added to the SuperGroup by [ "..msg.from.id.." ]")
					channel_set_admin(receiver, user, ok_cb, false)
				end
				if is_support(msg.action.user.id) and not is_owner2(msg.action.user.id) then
					local receiver = get_receiver(msg)
					local user = "user#id"..msg.action.user.id
					savelog(msg.to.id, name_log.." Support member ["..msg.action.user.id.."] added to the SuperGroup by [ "..msg.from.id.." ]")
					channel_set_mod(receiver, user, ok_cb, false)
				end
			end
		end
		if matches[1] == 'msg.to.peer_id' then
			post_large_msg(receiver, msg.to.peer_id)
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
	"^[#](حذف_گروه)$",
	"^[#](حرکت) (.*)$",
	"^[#](اطلاعات)$",
	"^[#](ادمین_ها)$",
	"^[#](مالک)$",
	"^[#](لیست_مدیران)$",
	"^[#](ربات_ها)$",
	"^[#](افراد)$",
	"^[#](اخراج_شدگان)$",
    "^[#](بلاک) (.*)",
	"^[#](بلاک)",
	"^[#](تبدیل_به_سوپرگروه)$",
	"^[#](ایدی)$",
	"^[#](ایدی) (.*)$",
	"^[#](اخراجم_کن)$",
	"^[#](اخراج) (.*)$",
	"^[#](لینک_جدید)$",
	"^[#](تنظیم_لینک)$",
	"^[#](لینک)$",
	"^[#](درمورد) (.*)$",
	"^[#](تنظیم_ادمین) (.*)$",
	"^[#](تنظیم_ادمین)",
	"^[#](عزل_ادمین) (.*)$",
	"^[#](عزل_ادمین)",
	"^[#](تنظیم_مالک) (.*)$",
	"^[#](تنظیم_مالک)$",
	"^[#](ترفیع) (.*)$",
	"^[#](ترفیع)",
	"^[#](عزل) (.*)$",
	"^[#](عزل)",
	"^[#](تنظیم_اسم) (.*)$",
	"^[#](تنظیم_درباره) (.*)$",
	"^[#](تنظیم_قوانین) (.*)$",
	"^[#](تنظیم_عکس)$",
	"^[#](تنظیم_یوزرنیم) (.*)$",
	"^[#](پاککن)$",
	"^[#](قفل_کردن) (.*)$",
	"^[#](باز_کردن) (.*)$",
	"^[#](ممنوع_کردن) ([^%s]+)$",
	"^[#](ازاد_کردن) ([^%s]+)$",
	"^[#](کاربر_بیصدا)$",
	"^[#](کاربر_بیصدا) (.*)$",
	"^[#](عمومی) (.*)$",
	"^[#](تنظیمات)$",
	"^[#](قوانین)$",
	"^[#](درباره)$",
	"^[#](حساسیت_ضداسپم) (%d+)$",
	"^[#](پاکسازی) (.*)$",
	"^[#](راهنما)$",
	"^[#](لیست_ممنوعیات)$",
	"^[#](لیست_کاربران_بیصدا)$",
    "(مدیر_ویژه_ترفیع) (.*)",
	"(مدیر_ویژه_عزل) (.*)",
    "^(https://telegram.me/joinchat/%S+)$",
	"msg.to.peer_id",
	"%[(document)%]",
	"%[(photo)%]",
	"%[(video)%]",
	"%[(audio)%]",
	"%[(contact)%]",
	"^!!tgservice (.+)$",
  },
  run = run,
  pre_process = pre_process
}
--End supergrpup.lua
--By @Rondoozle
