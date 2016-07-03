do

local function get_message_callback (extra , success, result)
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
	local hash = "whitelist"
	local is_whitelisted = redis:sismember(hash, user_id)      
	if is_whitelisted then
		redis:srem(hash, user_id)
		send_large_msg(receiver, "کاربر/ربات ["..user_id.."] از لیست سفید حذف شد")
	else
		redis:sadd(hash, user_id)
		send_large_msg(receiver, "کاربر/ربات ["..user_id.."] به لیست سفید اضافه شد")
	end
	
end

local function whitelist_res (extra, success, result)
	local user_id = result.peer_id
	local receiver = extra.receiver
	local hash = "whitelist"
	local is_whitelisted = redis:sismember(hash, user_id)      
	if is_whitelisted then
		redis:srem(hash, user_id)
		send_large_msg(receiver, "کاربر/ربات ["..user_id.."] از لیست سفید حذف شد")
	else
		redis:sadd(hash, user_id)
		send_large_msg(receiver, "کاربر/ربات ["..user_id.."] به لیست سفید اضافه شد")
	end
end

local function run (msg, matches)
if matches[1] == "لیست_سفید" and is_admin1(msg) then
    local hash = "whitelist"
    local user_id = ""
	if type(msg.reply_id) ~= "nil" then
		local receiver = get_receiver(msg)
		get_message(msg.reply_id, get_message_callback, {receiver = receiver})
    elseif string.match(matches[2], '^%d+$') then
		local user_id = matches[2]
		local is_whitelisted = redis:sismember(hash, user_id)      
		if is_whitelisted then
			redis:srem(hash, user_id)
			return "کاربر/ربات ["..user_id.."] از لیست سفید حذف شد"
		else
			redis:sadd(hash, user_id)
			return "کاربر/ربات ["..user_id.."] به لیست سفید اضافه شد"
		end
	elseif not string.match(matches[2], '^%d+$') then
		local receiver = get_receiver(msg)
		local username = matches[2]
		local username = string.gsub(matches[2], '@', '')
		resolve_username(username, whitelist_res, {receiver = receiver})
	end
end

	if matches[1] == "پاکسازی" and matches[2] == 'لیست_سفید' and is_admin1(msg) then
		local hash =  'whitelist'
			redis:del(hash)
		return "لیست سفید پاکسازی شد"
	end
end

return {
    patterns = {
	  "^[#](لیست_سفید)$",
      "^[#](لیست_سفید) (.*)$",
	  "^[#](پاکسازی) (.*)$"
    },
    run = run
}
end