class ApiController < ApplicationController

  # We use the Vonage Ruby Server SDK to simplify things. Initialization is done in config/application.rb
  @@vclient = Rails.application.config.vclient
  
  userlist = {}

  # Default Answer URL
  def answer
    #If it comes from SIP, must be a sip Interconnect, immediately connecte it
    if(params.has_key?("SipHeader_X-OpenTok-SessionId"))
      ncco= [
      {
        "action": "talk",
        "text": "Establishing Interconnect",
      },
      {
        "action": "conversation",
        "name": "cv2",
        "startOnEnter": true,
        "endOnExit": true,
      }
      ]
    # else, it is user dialing in. You can connect the user to blank Conversation with on hold streamin or
    # Ask for a pin to access the room.
    # This is the waiting Room
    else
      ncco= [
        {
          "action": "talk",
          "text": "Please Enter PIN",
        },
        { # play a music stream
          "action": "stream",
          "streamUrl": ["http://urzo.tplinkdns.com/jazz.mp3"],
          "bargeIn": "true"
        },
        { # Ask for the room PIN, right now, it's just 123
          action: 'input',
          type: ['dtmf'],
          eventUrl: [request.protocol+request.host+"/webhooks/dtmf"],
        },
       
      ]
    end
    render json: ncco
  end

  # Handles the DTM notes
  def dtmf    
    Rails.logger.debug(params)
    ncco = []
    # If the DTMF matches the room pin, let the user join the room
    if(params["dtmf"]["digits"]=="123")
      ncco = [
        {
          "action": "talk",
          "text": "Connecting to the conference",
        },
        {
          "action": "conversation",
          "name": "cv2",
          "endOnExit": false,
        }
      ]
    # or ask the user another pin
    else
      ncco = [
        {
          "action": "talk",
          "text": "PIN incorrect. Please enter correct PIN",
        },
        {
          "action": "stream",
          "streamUrl": ["http://urzo.tplinkdns.com/jazz.mp3"],
          "bargeIn": "true"
        },
        {
          action: 'input',
          type: ['dtmf'],
          eventUrl: [request.protocol+request.host+"/webhooks/dtmf"],
        },
       
      ]
    end
    render json: ncco, :status => 200
  end

  # This is the waiting room NCCO response for when you kick the user and send them back to the waiting room
  def wait_room
    ncco= [
      {
        "action": "talk",
        "text": "You are back to the Waiting Room. Please Enter a room PIN",
      },
      {
        "action": "stream",
        "streamUrl": ["http://urzo.tplinkdns.com/jazz.mp3"],
        "bargeIn": "true"
      },
      {
        action: 'input',
        type: ['dtmf'],
        eventUrl: [request.protocol+request.host+"/webhooks/dtmf"],
      },
      
    ]

    render json: ncco
  end
  
  def call_event    
    #Rails.logger.debug(params)
    render :status => 200
  end

  def rtc_event    
    #Rails.logger.debug(params)
    render :status => 200
  end
  
  # List the current calls. We use this to easily get the Caller's UUID
  def list_calls
    voice = @@vclient.voice
    render json: voice.list.to_json, :status => 200
  end

  # Call this to move the user back to Waiting room
  def move_call_to_wait
    uuid = params["uuid"] #get the UUIS
    voice = @@vclient.voice #Get our Voice Client

    #this defines where we want to send the user to
    destination = {
          type: 'ncco',
          url: [request.protocol+request.host+"/transfer/wait_room"] #get's the ncco response from def wait_room
        }
    voice.transfer(uuid, destination: destination) #initiate transfer
    render json: voice.list.to_json, :status => 200
  end

  # List the current conversations. We use this to easily get the Caller's UUID
  def list_conversations
    conv = @@vclient.conversation
    render json: conv.list.to_json, :status => 200
  end

  # list members from conversation (use list_conversation to get conv_id)
  def list_members
    conv_id =  params["conv_id"]
    member = @@vclient.conversation.member 
    render json: member.list(conversation_id: conv_id), :status => 200
  end

  # kick members from a call (use list_conversation to get conv_id and list member to get member_id)
  def kick_member #kick member from the call
    conv_id = params["conv_id"]
    member_id = params["member_id"]
    member = @@vclient.conversation.member 
    member.update(
          conversation_id: conv_id,
          member_id: member_id,
          state: 'left'
        )
    render json: member.list(conversation_id: conv_id), :status => 200
  end

  
end
