do
-- Will leave the group if be added
local function run(msg, matches)
local bot_id = our_id 
local receiver = get_receiver(msg)
    if matches[1] == 'ترک_گروه' and is_admin1(msg) then
       chat_del_user("chat#id"..msg.to.id, 'user#id'..bot_id, ok_cb, false)
	   leave_channel(receiver, ok_cb, false)
    elseif msg.service and msg.action.type == "chat_add_user" and msg.action.user.id == tonumber(bot_id) and not is_admin1(msg) then
       send_large_msg(receiver, 'اینجا جزو گروه های من نیست و من توسط سازنده ربات به این گروه اضافه نشدم.', ok_cb, false)
       chat_del_user(receiver, 'user#id'..bot_id, ok_cb, false)
	   leave_channel(receiver, ok_cb, false)
    end
end
 
return {
  patterns = {
    "^[#](ترک_گروه)$",
    "^!!tgservice (.+)$",
  },
  run = run
}
end
