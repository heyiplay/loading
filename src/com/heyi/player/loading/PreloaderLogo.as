package com.heyi.player.loading 
{
	import com.heyi.player.loading.HeyiPlayLogo;
	import com.heyi.player.loading.YoukuTudouLogo;
	import com.tudou.events.SchedulerEvent;
	import com.tudou.utils.Scheduler;
	import com.tudou.utils.Tween;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.filters.BlurFilter;
	import flash.geom.ColorTransform;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	/**
	 * 预载器 LOGO特效
	 * - TODO:
	 * 		设计：优酷LOGO+土豆LOGO 做粒子风暴旋转合成 》合一播放LOGO
	 * 		寓意：优酷土豆播放合一
	 * @author 8088
	 */
	public class PreloaderLogo extends Sprite
	{
		public function PreloaderLogo() 
		{
			
            rect = new Rectangle(0, 0, AREA, AREA);
            ct = new ColorTransform(.89, .89, .89, .89);
			blur = new BlurFilter(3, 3);
			point = new Point(0, 0);
            
			youkutudou_logo = new YoukuTudouLogo();
            youkutudou = new BitmapData(int(youkutudou_logo.width), int(youkutudou_logo.height), true, 0);
            youkutudou.draw(youkutudou_logo);
			
			heyiplay_logo = new HeyiPlayLogo();
			heyiplay = new BitmapData(int(heyiplay_logo.width), heyiplay_logo.height, true, 0);
			heyiplay.draw(heyiplay_logo);
			
			noise = new BitmapData(heyiplay.width, heyiplay.height, false, 0);
            noise.perlinNoise(heyiplay.width, heyiplay.height, 4, Math.floor(Math.random() * 65535), false, false, 1 | 2 | 0 | 0);
			
			effect = new BitmapData(AREA, AREA, true, 0);
            addChild(new Bitmap(effect));
			
           	if(visible) start();
		}
		
		override public function set visible(value:Boolean):void
		{
			super.visible = value;
			
			if (!value) stop();
		}
		
		
		// Internal..
		//
		private function start():void
		{
			var _x:int = 0;
            var _y:int = 0;
			var _r:Rectangle = new Rectangle();
			_r.x = int((effect.width-youkutudou.width)*.5);
			_r.y = int((effect.height-youkutudou.height)*.5);
			_r.width = youkutudou.width;
			_r.height = youkutudou.height;
            buffer = new Vector.<P>();
            while (_x < youkutudou.width)
            {
                _y = 0;
                while (_y < youkutudou.height)
                {
                    buffer.push(new P(_x, _y, youkutudou.getPixel32(_x, _y), _r, true));
                	_y++;
                }
                _x++;
            }
			
			_x = 0;
            _y = 0;
			_r.x = int((effect.width-heyiplay.width)*.5);
			_r.y = int((effect.height-heyiplay.height)*.5-4);
			_r.width = heyiplay.width;
			_r.height = heyiplay.height;
            cacher = new Vector.<P>();
			while (_x < heyiplay.width)
            {
                _y = 0;
                while (_y < heyiplay.height)
                {
                    cacher.push(new P(_x, _y, heyiplay.getPixel32(_x, _y), _r, false));
                	_y++;
                }
                _x++;
            }
			
			renderScheduler = Scheduler.setInterval(INTERVAL, render);
		}
		
		private function stop():void
		{
			renderScheduler.stop();
		}
		
        private function render(event:SchedulerEvent) : void
        {
			if (!visible) stop(); 
			var b:Number = 0.0;
			var c:Number = 0.0;
			var d:Number = 0.0;
            var i:uint = 0;
            var l:uint = 0;
            var h:uint = 0;
			var o:Number = .072;
            var p:P;
			var _p:P;
            var t:Number;
			var w:Number = youkutudou.width;
			
            effect.lock();
			effect.applyFilter(effect, rect, point, blur);
            effect.colorTransform(rect, ct);
            l = buffer.length;
			h = cacher.length;
			if (light == null && h < 1000) addLight();
            while (i < l)
            {
				if(i<h)
				{
					_p = cacher[i];
                	_p.speed +=.5;
					if (_p.speed > 0)
					{
						t = noise.getPixel(_p.ox, _p.oy);
						_p.a += ((t >> 8 & 255)) / 1000;
						_p.v = Math.PI*_p.a;
						_p.x = _p.r.x + _p.r.width*.5 + Math.cos(_p.v)*_p.s*2;
						_p.y = _p.r.y + _p.r.height*.5 + Math.sin(_p.v)*_p.s*2;
					}
				}
				
              	p = buffer[i];
                p.speed +=.5;
                if (p.speed > 0)
				{
					if(p.b)
					{
						if(p.ox<w/2)
						{
							c = p.ox;
							b = 1.5;
							d = 2.45;
						}
						else{
							c = w-p.ox;
							b = .5;
							d = 1.45;
						}
						p.a += o + c/1000;
						p.v = Math.PI*b+p.a;
						p.x += Math.cos(p.v)*10;
						p.y += Math.sin(p.v)*10;
					
						if (p.v > Math.PI*d)
                		{
                    		buffer.splice(i, 1);
							if(l<=6930) 
							{
								var j:uint;
								if(_p) j = i;
								else j = 0;
								buffer.push(cacher[j]);
								cacher.splice(j, 1);
								h--;
							}
							else l--;
                		}
					}
					else{
						
						t = noise.getPixel(p.ox, p.oy);
						p.a += ((t >> 8 & 255)) / 1000;
						p.v = Math.PI*p.a;
						
						if(p.v>5+Math.random()*5)
						{
							p.x = p.ox + p.r.x;
							p.y = p.oy + p.r.y;
						}
						else{
							p.x = p.r.x + p.r.width*.5 + Math.cos(p.v)*p.s*2;
							p.y = p.r.y + p.r.height*.5 + Math.sin(p.v)*p.s*2;
						}
						
					}
                }
				
                effect.setPixel32(p.x, p.y, p.c);
                i++;
            }
            effect.unlock();
        }
		
		private function addLight():void
		{
			if (light) return;
			light = new Light();
			light.x = 120;
			light.y = 230;
			light.alpha = 0;
			addChild(light);
			
			lightTween = new Tween(light);
			lightTween.fadeIn(800);
		}
		
		private var youkutudou_logo:YoukuTudouLogo;
        private var heyiplay_logo:HeyiPlayLogo;
		private var light:Light;
		private var lightTween:Tween;
		private var renderScheduler:Scheduler;
		
        private var rect:Rectangle;
        private var ct:ColorTransform;
		private var blur:BlurFilter;
		private var point:Point;
        private var noise:BitmapData;
		
        private var effect:BitmapData;
        private var youkutudou:BitmapData;
        private var heyiplay:BitmapData;
        private var buffer:Vector.<P>;
        private var cacher:Vector.<P>;
		
		private const AREA:int = 400;
		private const INTERVAL:int = 20;
		
	}

}

import flash.geom.Rectangle;
class P extends Object
{
    public var a:Number = 0;
	public var b:Boolean;
    public var c:uint;
    public var v:Number = 0;
    public var x:Number = 0;
    public var y:Number = 0;
    public var z:Number = 0;
    public var r:Rectangle;
	public var s:Number = 0;
    public var ox:Number = 0;
    public var oy:Number = 0;
    public var speed:Number;

    function P(_x:Number, _y:Number, _c:uint, _r:Rectangle, _b:Boolean)
    {
        this.x = _x+_r.x;
        this.y = _y+_r.y;
		this.b = _b;
        this.c = _c;
		this.r = _r;
		this.ox = _x;
		this.oy = _y;
		
		var __a:Number = ox - r.width*.5;
		var __b:Number = oy - r.height*.5;
		this.s = Math.sqrt(__a*__a + __b*__b);
		
        if(this.ox<_r.width/2) this.speed = -Math.random() * 40 - _x*.1-10;
		else this.speed = -Math.random() * 40 - (_r.width-_x)*.1-10;
    }
}
