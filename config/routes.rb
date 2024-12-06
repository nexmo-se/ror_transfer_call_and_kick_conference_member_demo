Rails.application.routes.draw do
  get "/webhooks/answer", to: "api#answer"
  get "/transfer/wait_room", to: "api#wait_room"
  match "/webhooks/answer" => "api#answer", via: :post
  match "/webhooks/call-event" => "api#call_event", via: :post
  match "/webhooks/rtc-event" => "api#rtc_event", via: :post
  match "/webhooks/dtmf", to: "api#dtmf", via: :post
  match "/transfer/wait_room", to: "api#wait_room", via: :post
  get "create_sip_interconnect", to: "api#create_sip_interconnect"

  #API
  get "list_calls", to: "api#list_calls"
  #get "move_call_to_conv", to: "api#move_call_to_conv"
  get "move_call_to_wait", to: "api#move_call_to_wait"
  get "list_conversations", to: "api#list_conversations"
  get "list_members", to: "api#list_members"
  get "kick_member", to: "api#kick_member"
end
