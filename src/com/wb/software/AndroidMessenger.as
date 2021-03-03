package com.wb.software
{
	public class AndroidMessenger extends WBMessenger
	{
		// calling class
		private var m_caller :TestAppAndroid = null;
		
		// default constructor
		public function AndroidMessenger(caller       :TestAppAndroid,
										 swfWidth     :int,
										 swfHeight    :int,
										 swfFrameRate :int)
		{
			// defer to superclass
			super(swfWidth,
				  swfHeight,
				  swfFrameRate);
			
			// save caller
			m_caller = caller;
		}
		
		// send() -- override specific to this app
		override public function send(message :String, ...argv) :int
		{
			// verify caller
			if(!m_caller)
				return(0);
			
			// get native extensions
			var ane :AndroidANE = m_caller.getANE();
			
			// verify native extensions
			if(!ane)
				return(0);
			
			// check message
			if(message)
			{
				// process message
				switch(message)
				{
				// getLongestDisplaySide()
				case("getLongestDisplaySide"):
					
					// return the value
					return(ane.getLongestDisplaySide());
				
				// hideSystemBar()
				case("hideSystemBar"):
					
					// pass it on
					ane.hideSystemBar();
					
					// ok
					return(1);
					
				// messageBox()
				case("messageBox"):
					
					// check content
					if(argv.length != 2)
						break;
					
					// display message box
					ane.messageBox(argv[0] as String, argv[1] as String);
					
					// re-hide system ui
					ane.hideSystemBar();
			
					// ok
					return(1);
				}
			}
			
			// throw error
			throw new Error("com.wb.software.AndroidMessenger.send(): " +
				"Internal message cannot be sent due to invalid data: " +
				message);
			
			// failed
			return(0);
		}
	}
}