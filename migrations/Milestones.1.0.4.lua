if global.delayed_chat_message == nil then
  global.delayed_chat_messages = {}
else 
  global.delayed_chat_messages = {global.delayed_chat_message}
  global.delayed_chat_message = nil
end