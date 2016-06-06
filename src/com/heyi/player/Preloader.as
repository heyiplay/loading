package com.heyi.player
{
	import com.heyi.player.loading.PreloaderLogo;
	import com.tudou.events.TweenEvent;
	import com.tudou.player.loading.PreloaderBackground;
	import com.tudou.player.config.AccessDomain;
	import com.tudou.utils.Tween;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.GradientType;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageQuality;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.NetStatusEvent;
	import flash.events.ProgressEvent;
	import flash.events.UncaughtErrorEvent;
	import flash.geom.Matrix;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.Capabilities;
	import flash.system.LoaderContext;
	import flash.system.Security;
	import flash.text.TextField;
	import flash.utils.ByteArray;
	import flash.utils.flash_proxy;
	import flash.utils.getDefinitionByName;
	import flash.utils.getTimer;
	import flash.utils.setTimeout;
	/**
	 * 预载器
	 * 
	 * @author 8088
	 */
	public class Preloader extends MovieClip 
	{
		
		public function Preloader():void 
		{
			for (var i:int = 0; i != AccessDomain.WHITE_LIST.length; i++)
			{
				Security.allowDomain(AccessDomain.WHITE_LIST[i]);
				Security.allowInsecureDomain(AccessDomain.WHITE_LIST[i]);
			}
			
			if (stage) onStage();
			else addEventListener(Event.ADDED_TO_STAGE, onStage);
		}
		
		
		// shell..
		//
		public function resize(width:Number, height:Number):void {
			if (!width || !height ) return;
			if (playerInstance && playerInstance.api && playerInstance.api.hasOwnProperty("resize")) playerInstance.api.resize(width, height);
			set_w = width;
			set_h = height;
			if (stage&&set_w&&set_h)
			{
				stage.removeEventListener(Event.RESIZE, resizeStage);
				resizeStage();
			}
		}
		
		override public function play():void { if (playerInstance) playerInstance.api.play(); }
		
		public function pause():void { if (playerInstance) playerInstance.api.pause(); }
		
		public function resume():void { if (playerInstance) playerInstance.api.resume(); }
		
		public function seek(num:Number):void { if (playerInstance) playerInstance.api.seek(num); }
		
		public function replay():void { if (playerInstance) playerInstance.api.replay(); }
		
		public function reconnect():void { if (playerInstance) playerInstance.api.reconnect(); }
		
		override public function stop():void { if (playerInstance) playerInstance.api.stop(); }
		//get set
		public function get data():Object { return playerInstance?playerInstance.api.getProperty("data"):null; }
		
		public function set data(_value:*):void { if (playerInstance) playerInstance.api.setProperty("data", _value); }
		
		public function get user():Object { return playerInstance?playerInstance.api.getProperty("user"):null; }
		
		public function set user(_value:*):void { if (playerInstance) playerInstance.api.setProperty("user", _value); }
		
		public function get config():Object { return playerInstance?playerInstance.api.getProperty("config"):null; }
		
		public function set config(_value:*):void { if (playerInstance) playerInstance.api.setProperty("config", _value); }
		
		public function get volume():Number { return playerInstance?playerInstance.api.getProperty("volume"):Number.NaN; }
		
		public function set volume(_value:Number):void { if (playerInstance) playerInstance.api.setProperty("volume", _value); }
		
		public function get language():String { return playerInstance?playerInstance.api.getProperty("language"):null; }
		
		public function set language(_value:String):void { if (playerInstance) playerInstance.api.setProperty("language", _value); }
		
		public function get quality():String { return playerInstance?playerInstance.api.getProperty("quality"):null; }
		
		public function set quality(_value:String):void { if (playerInstance) playerInstance.api.setProperty("quality", _value); }
		//get
		public function get multiLanguage():Array { return playerInstance?playerInstance.api.getProperty("multiLanguage"):null; }
		
		public function get multiQuality():Array { return playerInstance?playerInstance.api.getProperty("multiQuality"):null; }
		
		public function get time():Number { return playerInstance?playerInstance.api.getProperty("time"):Number.NaN; }
		
		public function get duration():Number { return playerInstance?playerInstance.api.getProperty("duration"):Number.NaN; }
		
		public function get loaded():Number { return playerInstance?playerInstance.api.getProperty("loaded"):Number.NaN; }
		
		public function get bytesLoaded():Number { return playerInstance?playerInstance.api.getProperty("bytesLoaded"):Number.NaN; }
		
		public function get bytesTotal():Number { return playerInstance?playerInstance.api.getProperty("bytesTotal"):Number.NaN; }
		
		public function get state():String { return playerInstance?playerInstance.api.getProperty("state"):null; }
		
		override public function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void
		{
			if (type==PLAYER_STATUS_CHANGE)
			{
				if (playerInstance) playerInstance.api.addEventListener(type, listener, useCapture, priority, useWeakReference);
				else playerStatusChangeListener = listener;
			}
			super.addEventListener(type, listener, useCapture, priority, useWeakReference);
		}
		
		override public function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void
		{
			if (type==PLAYER_STATUS_CHANGE)
			{
				if (playerInstance) playerInstance.api.removeEventListener(type, listener, useCapture);
				else playerStatusChangeListener = null;
			}
			super.removeEventListener(type, listener, useCapture);
		}
		
		
		// Internal..
		//
		
		private function onStage(evt:Event = null):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, onStage);
			
			//初始化基础场景
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
            stage.showDefaultContextMenu = false;
			stage.addEventListener(Event.RESIZE, resizeStage);
			var isykos:Boolean = false;
			if (this.loaderInfo.parameters.hasOwnProperty("playerId") && this.loaderInfo.parameters.playerId == "ykos") 
			{
				isykos = true;
			}
			
			if(!isykos) initLoading();
			resizeStage();
			
			_time = getTimer();
			flashvars = { };
			
			if (this.loaderInfo.hasOwnProperty("uncaughtErrorEvents")) this.loaderInfo["uncaughtErrorEvents"].addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onUncaughtError);
			
			if (this.loaderInfo.bytesLoaded == this.loaderInfo.bytesTotal)
			{
				onComplete();
			}
			else {
				this.loaderInfo.addEventListener(Event.OPEN, onOpen);
				this.loaderInfo.addEventListener(ProgressEvent.PROGRESS, onProgress);
				this.loaderInfo.addEventListener(Event.COMPLETE, onComplete);
			}
		}
		private function initLoading():void
		{
			//初始化loading
			loading = new Sprite();
			addChild(loading);
			bg = new PreloaderBackground();
			
			bg_shadow = new Shape();
			var alphas:Array = [0.03, .4];
			var colors:Array = [0, 0];
			var ratios:Array = [80, 255];
			var matrix:Matrix = new Matrix();
			matrix.createGradientBox(stage.stageWidth, stage.stageHeight);
			bg_shadow.graphics.clear();
			bg_shadow.graphics.beginGradientFill(GradientType.RADIAL, colors, alphas, ratios,matrix);
			bg_shadow.graphics.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
			bg_shadow.graphics.endFill();
			loading.addChild(bg_shadow);
			
			logo = new PreloaderLogo();
            loading.addChild(logo);
			
			//mark:如需增加推广素材，在此加载播放器同域下一固定素材的地址
			
			txt = new TextField();
			txt.textColor = 0x181818;
			txt.height = 20;
			txt.width = 200;
			loading.addChild(txt);
			
		}
		private function resizeStage(evt:Event=null):void
		{
			var _w:Number = set_w? set_w: stage.stageWidth;
			var _h:Number = set_h? set_h: stage.stageHeight;
			if (!loading) return;
			
			if (bg)
			{
				loading.graphics.clear();
				loading.graphics.beginBitmapFill(bg);
				loading.graphics.drawRect(0, 0, _w, _h);
				loading.graphics.endFill();
			}
			
			if (bg_shadow)
			{
				bg_shadow.width = _w;
				bg_shadow.height = _h;
			}
			
			if (logo)
			{
				logo.x = int((_w-logo.width) * .5);
				logo.y = int((_h-logo.height) * .5);
			}
			
		}
		
		private function onOpen(evt:Event):void
		{
			//...
		}
		
		private function onProgress(evt:ProgressEvent):void
		{
			if (!_size)_size = evt.bytesTotal; 
			txt.text = "载入进度：" + evt.bytesLoaded + " / " + evt.bytesTotal;
		}
		
		private function onComplete(evt:Event=null):void
		{
			// convert from bytes to Mbps
			//flashvars.bandwidth = (_size / ((getTimer() - _time) / 1000)) / 1000000 * 8;
			var _length:int = 0;
			for (var key:* in this.loaderInfo.parameters)
            {
                flashvars[key] = decodeURIComponent(this.loaderInfo.parameters[key]);
				_length++;
            }
			flashvars.length = _length;
			if (this.parent != this.stage) 
			{
				flashvars.containerUrl = this.loaderInfo.loaderURL;
				flashvars.length++;
			}
			creatPlayer();
		}
		
		private function creatPlayer():void
		{
			gotoAndStop(2);
			
			try {
				var PlayerClass:Class = getDefinitionByName("com.tudou.player.PlayerDomain").PLAYER as Class;
				var bytes:ByteArray = decode(new PlayerClass());
				loadBytes(bytes);
			}
			catch (err:ReferenceError) {
				//ignore..
			}
		}
		
		private function loadBytes(bytes:ByteArray, context:LoaderContext = null):void
		{
			var lc:LoaderContext = context || new LoaderContext(false, ApplicationDomain.currentDomain);
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loadedHandler);
			loader.loadBytes(bytes, lc);
		}
		
		private function loadedHandler(evt:Event):void
		{
			var info:LoaderInfo = evt.target as LoaderInfo;
			playerInstance = info.content;
			playerInstance.addEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
			if (flashvars.length>0) playerInstance.setFlashvars(flashvars);
			else {
				CONFIG::TEST{playerInstance.setFlashvars(new TestLoaderInfo().parameters);}
			}
			if (this.parent != this.stage)addChildAt(playerInstance as DisplayObject, 0);
			else stage.addChildAt(playerInstance as DisplayObject, 0);
		}
		
		private function onNetStatus(evt:NetStatusEvent):void
		{
			evt.preventDefault();
			
			if (evt.info.level == "error" || evt.info.code == "MediaPlayer.Is.Start")
			{
				var bmd:BitmapData = new BitmapData(stage.stageWidth, stage.stageHeight);
				if (bmd && loading)
				{
					try { bmd.draw(loading); } catch (e:SecurityError) { };
					bmp = new Bitmap(bmd);
					addChild(bmp);
					
					clear();
					
					tween = new Tween(bmp);
					tween.addEventListener(TweenEvent.END, onEnd);
					tween.easeOut().to( { alpha:0 }, 400);
				}
				else {
					destroy();
				}
			}
			
			if (evt.info.code == "MediaPlayer.Is.Ready")
			{
				if (playerStatusChangeListener != null) playerInstance.api.addEventListener(PLAYER_STATUS_CHANGE, playerStatusChangeListener);
			}
		}
		
		private function onEnd(evt:TweenEvent):void
		{
			destroy();
		}
		
		private function destroy():void  
        {
			if(stage) stage.removeEventListener(Event.RESIZE, resizeStage);
			
			clear();
			
			if (tween)
			{
				tween.removeEventListener(TweenEvent.END, onEnd);
				tween.finish();
				tween = null;
			}
			
			if (loading&& contains(loading))
			{
				removeChild(loading);
				loading = null;
			}
			
			if (bmp)
			{
				removeChild(bmp);
				bmp.bitmapData.dispose();
				bmp = null;
			}
			
            if (parent == this.stage && parent.contains(this)) 
			{
				playerInstance.removeEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
				playerInstance = null;
				parent.removeChild(this);
			}
        }
		
		private function clear():void
		{
			this.loaderInfo.removeEventListener(Event.OPEN, onOpen);
			this.loaderInfo.removeEventListener(ProgressEvent.PROGRESS, onProgress);  
            this.loaderInfo.removeEventListener(Event.COMPLETE, onComplete);
			if (txt && contains(txt)) {
				loading.removeChild(txt);
				txt = null;
			}
			
			if (logo && contains(logo)) {
				loading.removeChild(logo);
				logo = null;
			}
			
			if (bg_shadow && contains(bg_shadow))
			{
				bg_shadow.graphics.clear();
				loading.removeChild(bg_shadow);
				bg_shadow = null;
			}
			
			if (bg)
			{
				loading.graphics.clear();
				bg.dispose();
				bg = null;
			}
		}
		
		private function onUncaughtError(evt:UncaughtErrorEvent):void
		{
			evt.preventDefault();
			//ignore..
		}
		
		private function decode(data:ByteArray):ByteArray {
			if (int(Capabilities.version.split(/[ ,]+/)[1]) > 10) return data;
			if (data == null || data.length < 32) return null;
			if (data[0] == 70 || data[0] == 67) return data;
			var outputData:ByteArray = new ByteArray();
			outputData.length = data[4] | data[5] << 8 | data[6] << 16 | data[7] << 24;
			if (!new Decoder().decode(data[12], data, 17, outputData, 8, outputData.length - 8))
			{
				return null;
			}
			for (var i:int = 0; i < 8; i++)
			{
				outputData[i] = data[i];
			}
			outputData[0] = 70;
			outputData[3] = data[13] > 0?data[13]:10;
			return outputData;
		}
		
		
		private var txt:TextField;
		
		private var loading:Sprite;
		private var bg:BitmapData;
		private var bg_shadow:Shape;
		private var logo:Sprite;
		private var tween:Tween;
		private var flashvars:Object
		
		private var _time:Number;
		private var _speed:Number = 0.0;
		private var _size:Number = 0.0;
		
		private var set_w:Number;
		private var set_h:Number;
		
		private var bmp:Bitmap;
		private var playerInstance:Object;
		private var playerStatusChangeListener:Function;
		private const PLAYER_STATUS_CHANGE:String = "Player.Status.Change";
	}
	
}

import flash.utils.ByteArray;
class Decoder{
	
	private var code:int=0;
	private var range:int=-1;
	private var inputPos:int=5;
	private var inputData:ByteArray;
	
	public function decode(props:int,inputData:ByteArray,inputPos:int,
		outputData:ByteArray, outputPos:int, outputSize:int):Boolean
	{
		var bit:int, len:int, state:int, prevByte:int, nowPos64:int;
		var i:int, rep0:int, rep1:int, rep2:int, rep3:int;
		var posStates:int = 1 << (props / 9 / 5);
		var numPosBits:int = props / 9 % 5;
		var numPrevBits:int = props % 9;
		var posMask:int = (1 << numPosBits) - 1;
		var numStates:int = 1 << (numPrevBits + numPosBits);
		
		var posDecoders:Vector.<int> = new Vector.<int>(114, true);
		var isRepDecoders:Vector.<int> = new Vector.<int>(12, true);
		var isRepG0Decoders:Vector.<int> = new Vector.<int>(12, true);
		var isRepG1Decoders:Vector.<int> = new Vector.<int>(12, true);
		var isRepG2Decoders:Vector.<int> = new Vector.<int>(12, true);
		var isMatchDecoders:Vector.<int> = new Vector.<int>(192, true);
		var isRep0LongDecoders:Vector.<int> = new Vector.<int>(192, true);
		var decoders:Vector.<Vector.<int>> = new Vector.<Vector.<int>>(numStates, true);
		var posSlotDecoder:Vector.<BitTreeDecoder> = new Vector.<BitTreeDecoder>(4, true);
		var posAlignDecoder:BitTreeDecoder = new BitTreeDecoder(4);
		var repLenDecoder:LenDecoder = new LenDecoder(posStates);
		var lenDecoder:LenDecoder = new LenDecoder(posStates--);
		
		initBitModels(isRep0LongDecoders);
		initBitModels(isRepG0Decoders);
		initBitModels(isRepG1Decoders);
		initBitModels(isRepG2Decoders);
		initBitModels(isMatchDecoders);
		initBitModels(isRepDecoders);
		initBitModels(posDecoders);
		
		for (i = 0; i < numStates; i++)
		{
			initBitModels(decoders[i] = new Vector.<int>(0x300, true));
		}
		
		for (i = 0; i < 4; i++)
		{
			posSlotDecoder[i] = new BitTreeDecoder(6);
		}
		
		for (i = 0; i < 5; i++)
		{
			code = (code << 8) | inputData[inputPos + i];
		}
		this.inputPos += inputPos;
		this.inputData = inputData;
		while (nowPos64 < outputSize)
		{
			var posState:int = nowPos64 & posStates;
			if (decodeBit(isMatchDecoders, (state << 4) + posState) == 0)
			{
				i = ((nowPos64 & posMask) << numPrevBits) + ((prevByte & 0xFF) >>> (8 - numPrevBits));
				if (state < 7)
				{
					for (prevByte = 1; prevByte < 0x100; )
					{
						prevByte = (prevByte << 1) | decodeBit(decoders[i], prevByte);
					}
				}
				else {
					var matchByte:int = outputData[outputPos - rep0 - 1];
					for (prevByte = 1; prevByte < 0x100; matchByte <<= 1)
					{
						var matchBit:int = (matchByte >> 7) & 1;
						bit = decodeBit(decoders[i], ((1 + matchBit) << 8) + prevByte);
						prevByte = (prevByte << 1) | bit;
						if (matchBit != bit)
						{
							while (prevByte < 0x100)
							{
								prevByte = (prevByte << 1) | decodeBit(decoders[i], prevByte);
							}
							break;
						}
					}
				}
				state = state < 4?0:state < 10?state-3:state-6;
				outputData[outputPos++] = prevByte;
				nowPos64++;
			}
			else {
				if (decodeBit(isRepDecoders, state) == 1)
				{
					len = 0;
					if (decodeBit(isRepG0Decoders, state) == 0)
					{
						if (decodeBit(isRep0LongDecoders, (state << 4) + posState) == 0)
						{
							state = state < 7?9:11;
							len = 1;
						}
					}
					else {
						var distance:int;
						if (decodeBit(isRepG1Decoders, state) == 0) distance = rep1;
						else {
							if (decodeBit(isRepG2Decoders, state) == 0) distance = rep2;
							else {
								distance = rep3;
								rep3 = rep2;
							}
							rep2 = rep1;
						}
						rep1 = rep0;
						rep0 = distance;
					}
					
					if (len == 0)
					{
						len = repLenDecoder.decode(this, posState) + 2;
						state = state < 7?8:11;
					}
				}
				else {
					rep3 = rep2;
					rep2 = rep1;
					rep1 = rep0;
					state = state < 7?7:10;
					len = lenDecoder.decode(this, posState) + 2;
					var posSlot:int = posSlotDecoder[len - 2 < 4?len - 2:3].decode(this);;
					if (posSlot >= 4)
					{
						var numDirectBits:int = (posSlot >> 1) - 1;
						rep0 = ((2 | (posSlot & 1)) << numDirectBits);
						if (posSlot < 14)
						{
							var m:int = 1;
							var symbol:int = 0;
							var startIndex:int = rep0 - posSlot - 1;
							for (var bitIndex:int = 0; bitIndex < numDirectBits; bitIndex++)
							{
								bit = decodeBit(posDecoders, startIndex + m);
								m <<= 1;
								m += bit;
								symbol |= (bit << bitIndex);
							}
							rep0 += symbol;
						}
						else {
							rep0 += (decodeDirectBits(numDirectBits - 4) << 4);
							rep0 += posAlignDecoder.reverseDecode(this);
							if (rep0 < 0)
							{
								if (rep0 == -1) break;
								return false;
							}
						}
					}
					else rep0 = posSlot;
				}
				
				for (i = 0; i < len; i++)
				{
					outputData[outputPos] = outputData[outputPos - rep0 - 1];
					outputPos++;
				}
				nowPos64 += len;
				prevByte = outputData[outputPos - 1];
			}
		}
		inputData = null;
		return true;
	}
	
	public function decodeBit(probs:Vector.<int>, index:int):int
	{
		var prob:int = probs[index];
		var newBound:int = (range >>> 11) * prob;
		if ((code ^ 0x80000000) < (newBound ^ 0x80000000))
		{
			range = newBound;
			probs[index] = prob + ((2048 - prob) >>> 5);
			if ((range & 0xff000000) == 0)
			{
				code = (code << 8) | inputData[inputPos];
				inputPos++;
				range <<= 8;
			}
			return 0;
		}
		else {
			range-= newBound;
			code-= newBound;
			probs[index] = prob - ((prob) >>> 5);
			if ((range & 0xff000000) == 0)
			{
				code = (code << 8) | inputData[inputPos];
				inputPos++;
				range <<= 8;
			}
			return 1;
		}
	}
	
	public function decodeDirectBits(numTotalBits:int):int
	{
		var result:int = 0;
		for (var i:int = numTotalBits; i != 0; i--)
		{
			range >>>= 1;
			var t:int = ((code-range) >>> 31);
			code-= range & (t - 1);
			result = (result << 1) | (1 - t);
			if ((range & 0xff000000) == 0)
			{
				code = (code << 8) | inputData[inputPos];
				inputPos++;
				range <<= 8;
			}
		}
		return result;
	}
}

class LenDecoder{
	
	private var lowCoder:Vector.<BitTreeDecoder> = new Vector.<BitTreeDecoder>(16, true);
	private var midCoder:Vector.<BitTreeDecoder> = new Vector.<BitTreeDecoder>(16, true);
	private var highCoder:BitTreeDecoder = new BitTreeDecoder(8);
	private var choice:Vector.<int> = new Vector.<int>(2, true);
	
	public function LenDecoder(posStates:int)
	{
		initBitModels(choice);
		for (var i:int = 0; i < posStates; i++)
		{
			lowCoder[i] = new BitTreeDecoder(3);
			midCoder[i] = new BitTreeDecoder(3);
		}
	}
	
	public function decode(decoder:Decoder, posState:int):int
	{
		if (decoder.decodeBit(choice, 0) == 0)
		{
			return lowCoder[posState].decode(decoder);
		}
		var symbol:int = 8;
		if (decoder.decodeBit(choice, 1) == 0)
		{
			symbol += midCoder[posState].decode(decoder);
		}
		else {
			symbol += 8 + highCoder.decode(decoder);
		}
		return symbol;
	}
}

class BitTreeDecoder{
	
	private var numBitLevels:int;
	private var models:Vector.<int>;
	
	public function BitTreeDecoder(level:int)
	{
		models = new Vector.<int>(1 << level, true);
		initBitModels(models);
		numBitLevels = level;
	}
	
	public function decode(decoder:Decoder):int
	{
		var m:int = 1;
		for (var bitIndex:int = numBitLevels; bitIndex != 0; bitIndex--)
		{
			m = (m << 1) + decoder.decodeBit(models, m);
		}
		return m - (1 << numBitLevels);
	}
	
	public function reverseDecode(decoder:Decoder):int
	{
		var m:int = 1;
		var symbol:int = 0;
		for (var bitIndex:int = 0; bitIndex < numBitLevels; bitIndex++)
		{
			var bit:int = decoder.decodeBit(models, m);
			m <<= 1;
			m += bit;
			symbol |= (bit << bitIndex);
		}
		return symbol;
	}
}

function initBitModels(probs:Vector.<int>):void
{
	for (var i:int = 0, n:int = probs.length; i < n; i++)
	{
		probs[i] = 1024;
	}
}