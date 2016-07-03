local function run(msg)

local data = load_data(_config.moderation.data)

if data[tostring(msg.to.id)]['settings']['lock_ads'] == 'yes' then


if msg.to.type == 'channel' and not is_momod(msg) then
delete_msg(msg.id,ok_cb,false)

return 
end
end
end

return {patterns = {
".com",
".ir",
".in",
".tk",
".org",
".me",
".io",
".net",
"@gmail.com",
"@yahoo.com",
"@Gmail.com",
"@Yahoo.com",
"@GMAIL.com",
"@YAHOO.com",
"@GMAIL.COM",
"@YAHOO.COM",
"@gmail.COM",
"@yahoo.COM",
"@Gmail.Com",
"@Yahoo.Com"
}, run = run}
