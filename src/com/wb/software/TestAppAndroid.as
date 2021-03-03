package com.wb.software 
{
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.StatusEvent;
	import flash.events.TimerEvent;
	import flash.external.ExtensionContext;
	import flash.utils.Timer;
	
	[SWF(width="640", height="480", frameRate="60")]

	public final class TestAppAndroid extends Sprite
	{
		// swf metadata values (must match above!)
		private const SWF_WIDTH     :int = 640;
		private const SWF_HEIGHT    :int = 480;
		private const SWF_FRAMERATE :int = 60;

		// stored objects
		private var m_app       :TestApp          = null;
		private var m_messenger :AndroidMessenger = null;
		private var m_ane       :AndroidANE       = null;
		
		// system ui timer
		private var m_sysUiTimer :Timer = null;
		
		// consants
		private const ANDROID_TEST_CODE :int = 0xA7D401D;
		private const SYSTEM_UI_DELAY   :int = 3000;
		
		// launch image
		[Embed(source="../../../../LaunchImg.png", mimeType="image/png")]
		private var LaunchImage :Class;

		// default constructor
		public function TestAppAndroid()
		{
			// defer to superclass
			super();
			
			// load launch image
			var launchImg :Bitmap = new LaunchImage();

			// create messenger
			m_messenger = new AndroidMessenger(this,
											   SWF_WIDTH,
											   SWF_HEIGHT,
											   SWF_FRAMERATE);
			
			// create main app
			m_app = new TestApp(this,
								m_messenger,
								WBEngine.OSFLAG_ANDROID,
								false, // renderWhenIdle
								launchImg,
								true); // testMode
			
			// listen for added-to-stage
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		// addNativeExtensions() -- get native extensions up & running
		private function addNativeExtensions() :Boolean
		{
			// create extensions
			m_ane = new AndroidANE();
			
			// perform test
			if(m_ane.testANE(ANDROID_TEST_CODE) != ANDROID_TEST_CODE)
			{
				// throw error
				throw new Error("com.wb.software.TestAppAndroid.addNativeExtensions(): " +
								"ANE function test failed");
				
				// fail
				return(false);
			}
			
			// keep screen on
			m_ane.keepScreenOn();
			
			// hide system bar
			m_ane.hideSystemBar();
			
			// detect focus changes
			m_ane.detectFocusChanges();
			
			// get extension context
			var extContext :ExtensionContext = m_ane.getExtensionContext();
			
			// add status event listener
			extContext.addEventListener(StatusEvent.STATUS, onStatus);
			
			// ok
			return(true);
		}
		
		// getANE() -- get reference to native extensions
		public function getANE() :AndroidANE
		{
			// return object
			return(m_ane);
		}
		
		// getApp() -- get reference to base app
		public function getApp() :TestApp
		{
			// return object
			return(m_app);
		}
		
		// onAddedToStage() -- callback for added-to-stage notification
		private function onAddedToStage(e :Event) :void
		{
			// verify app
			if(!m_app)
				return;
			
			// add native extensions
			m_app.goingNative = addNativeExtensions();
			
			// create system ui timer
			m_sysUiTimer = new Timer(3000, 1); // 3 sec, 1x
			
			// add timer event listener
			m_sysUiTimer.addEventListener(TimerEvent.TIMER, onSysUiTimer);

			// initialize app
			m_app.init();
		}
		
		// onStatus() -- native-side event listener
		private function onStatus(e :StatusEvent) :void
		{
			// verify app
			if(!m_app)
				return;
			
			// check event type
			if(e.code)
				switch(e.code)
				{
					// sysUiVisibilityChange
					case("sysUiVisibilityChange"):
						
						// check system ui timer
						if(m_sysUiTimer)
						{
							// reset timer
							m_sysUiTimer.reset();
							
							// re-start timer
							m_sysUiTimer.start();
						}
						
						// ok
						return;
						
					// onWindowFocusChanged
					case("onWindowFocusChanged"):
						
						// inform app
						if(e.level == "true")
							m_app.onFocusReturned();
						else
							m_app.onFocusLost();
						
						// ok
						return;
				}
			
			// throw error
			throw new Error("com.wb.software.AndroidANE.onStatus(): " +
				"Invalid status message received: " + e.code ? e.code : "");
		}
		
		// onSysUiTimer() -- system ui timer callback
		private function onSysUiTimer(e :TimerEvent) :void
		{
			// re-hide system ui
			if(m_ane)
				m_ane.hideSystemBar();
		}
	}
}
