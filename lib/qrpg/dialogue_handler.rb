module QuickRPG
  class DialogueHandler
    def handle(dialogue, controller)
      controller.delegate = self
      @dialogue = dialogue
      textbox = dialogue.textbox
      controller.show(textbox)
    end
    
    def textbox_closed
      @dialogue.advance
    end
  end
end