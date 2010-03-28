package reflex.behaviors
{
	import flash.display.InteractiveObject;
	import flash.events.Event;
	import flash.geom.Point;
	
	import reflex.events.ButtonEvent;
	
	public class ScrollBehavior extends StepBehavior
	{
		public var track:InteractiveObject;
		public var thumb:InteractiveObject;
		
		[Bindable]
		public var horizontal:Boolean = false;
		
		private var _percent:Number = 0;
		private var dragPercent:Number;
		private var dragPoint:Number;
		private var dragging:Boolean;
		private var forwardPress:Boolean;
		
		public function ScrollBehavior(target:InteractiveObject = null)
		{
			super(target);
			bindProperty("horizontal", "target.horizontal");
			bindPropertyListener(onPosition, "position.percent");
			bindEventListener("press", onTrackPress, "track");
			bindEventListener("hold", onTrackHold, "track");
			bindEventListener("press", onThumbPress, "thumb");
			bindEventListener("drag", onThumbDrag, "thumb");
			bindEventListener("release", onThumbRelease, "thumb");
			bindEventListener("releaseOutside", onThumbRelease, "thumb");
			bindPropertyListener(onResize, "target.width");
			bindPropertyListener(onResize, "target.height");
		}
		
		[Bindable(event="percentChange")]
		public function get percent():Number
		{
			return _percent;
		}
		
		override public function set target(value:InteractiveObject):void
		{
			super.target = value;
			
			if (target == null) {
				return;
			}
			
			track = getSkinPart("track");
			thumb = getSkinPart("thumb");
			ButtonEvent.initialize(track);
			ButtonEvent.initialize(thumb);
			
			if (track.width > track.height) {
				horizontal = true;
			}
			
			updatePosition();
		}
		
		protected function onPosition(percent:Number):void
		{
			if (thumb == null || track == null) {
				return;
			}
			
			if (!dragging) {
				_percent = position.percent;
				updatePosition();
				dispatchEvent(new Event("percentChange"));
			}
		}
		
		protected function onTrackPress(event:ButtonEvent):void
		{
			var size:Number = horizontal ? track.width : track.height;
			forwardPress = (horizontal ? track.parent.mouseX - track.x : track.parent.mouseY - track.y) > (size * position.percent);
			
			if (forwardPress) {
				position.skipForward();
			} else {
				position.skipBackward();
			}
			event.updateAfterEvent();
		}
		
		protected function onTrackHold(event:ButtonEvent):void
		{
			var size:Number = horizontal ? track.width : track.height;
			var forwardHold:Boolean = (horizontal ? track.parent.mouseX - track.x : track.parent.mouseY - track.y) > (size * position.percent);
			
			if (forwardPress != forwardHold) {
				return;
			}
			
			if (forwardPress) {
				position.skipForward();
			} else {
				position.skipBackward();
			}
			event.updateAfterEvent();
		}
		
		protected function onThumbPress(event:ButtonEvent):void
		{
			dragging = true;
			dragPoint = horizontal ? thumb.parent.mouseX : thumb.parent.mouseY;
			dragPercent = _percent;
		}
		
		protected function onThumbDrag(event:ButtonEvent):void
		{
			var mousePoint:Number = horizontal ? thumb.parent.mouseX : thumb.parent.mouseY;
			var size:Number = horizontal ? track.width - thumb.width : track.height - thumb.height;
			var delta:Number = (mousePoint - dragPoint) / size;
			_percent = dragPercent + delta;
			_percent = _percent <= 0 ? 0 : (_percent >= 1 ? 1 : _percent);
			position.percent = _percent;
			updatePosition();
			dispatchEvent(new Event("percentChange"));
			
			event.updateAfterEvent();
		}
		
		protected function onThumbRelease(event:ButtonEvent):void
		{
			dragging = false;
		}
		
		protected function onResize(size:Number):void
		{
			updatePosition();
		}
		
		
		protected function updatePosition():void
		{
			var p:Point = new Point();
			if (horizontal) {
				p.x = (track.width - thumb.width) * _percent + track.x;
				p = thumb.parent.globalToLocal( track.parent.localToGlobal(p) );
				thumb.x = Math.round(p.x);
			} else {
				p.y = (track.height - thumb.height) * _percent + track.y;
				p = thumb.parent.globalToLocal( track.parent.localToGlobal(p) );
				thumb.y = Math.round(p.y);
			}
		}
		
	}
}
