local function history(extra, suc, result)
  for i=1, #result do
    delete_msg(result[i].id, ok_cb, false)
  end
  if tonumber(extra.con) == #result then
    send_msg(extra.chatid, ''..#result..' تا از پیام هارو خوردم 😋', ok_cb, false)
  else
    send_msg(extra.chatid, 'تعداد پیام مورد نظر شما پاک شد', ok_cb, false)
  end
end
local function run(msg, matches)
  if matches[1] == 'حذف' and is_sudo(msg) then
    if msg.to.type == 'channel' then
      if tonumber(matches[2]) > 60 or tonumber(matches[2]) < 1 then
        return "تعداد مجاز بین 1 تا 60 میباشد"
      end
      get_history(msg.to.peer_id, matches[2] + 1 , history , {chatid = msg.to.peer_id, con = matches[2]})
    else
      return "فقط در سوپرگروه ممکن است"
    end
  else
    return "شما دسترسی ندارید"
  end
end

return {
    patterns = {
        '^(حذف) (%d*)$'
    },
    run = run
}
