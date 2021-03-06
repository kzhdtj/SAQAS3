package sh.saqoo.net.detectface {

	import sh.saqoo.debug.ObjectDumper;

	import flash.display.Graphics;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	import flash.utils.IDataInput;
	import flash.utils.IDataOutput;
	import flash.utils.IExternalizable;

	/**
	 * @author Saqoosha
	 */
	public class FaceInfo implements IExternalizable {
		
		
		public var id:String;
		public var bounds:Rectangle;
		public var rightEye:Point;
		public var leftEye:Point;
		public var features:Dictionary;
		
		public var sAvg:Number;
		public var sMin:Number;
		public var sMax:Number;


		public function FaceInfo(data:XML = null, scale:Number = 1.0) {
			if (data) parse(data, scale);
		}
		
		
		public function parse(data:XML, scale:Number = 1.0):void {
			id = data.@id;
			bounds = new Rectangle(parseFloat(data.bounds.@x) * scale, parseFloat(data.bounds.@y) * scale, parseFloat(data.bounds.@width) * scale, parseFloat(data.bounds.@height) * scale);
			if (data.hasOwnProperty('right-eye')) rightEye = new Point(parseFloat(data['right-eye'].@x) * scale, parseFloat(data['right-eye'].@y) * scale);
			if (data.hasOwnProperty('left-eye')) leftEye = new Point(parseFloat(data['left-eye'].@x) * scale, parseFloat(data['left-eye'].@y) * scale);
			if (data.hasOwnProperty('features')) {
				sAvg = parseFloat(data.features.attribute('s-avg'));
				sMin = parseFloat(data.features.attribute('s-min'));
				sMax = parseFloat(data.features.attribute('s-max'));
				features = new Dictionary();
				for each (var feat:XML in data.features.point) {
					var f:FeaturePoint = new FeaturePoint(feat.@id, parseFloat(feat.@x) * scale, parseFloat(feat.@y) * scale, parseFloat(feat.@s));
					features[f.id] = f;
				}
			}
		}
		
		
		public function getFeaturePointByName(name:String):FeaturePoint {
			return features ? features[name] || null : null;
		}
		
		
		public function getFeaturePoints(names:Array, full:Boolean = true):Vector.<Point> {
			var tmp:Vector.<Point> = new Vector.<Point>();
			for each (var name:String in names) {
				var fp:FeaturePoint = getFeaturePointByName(name);
				if (full && !fp) return null;
				tmp.push(fp);
			}
			return tmp;
		}
		
		
		public function getAverageScore(names:Array):Number {
			var score:Number = 0;
			for each (var name:String in names) {
				var fp:FeaturePoint = getFeaturePointByName(name);
				if (fp) score += fp.s;
			}
			score /= names.length;
			return score;
		}
		
		
		public function transform(mtx:Matrix):void {
//			if (bounds) {
//				var tl:Point = mtx.transformPoint(bounds.topLeft);
//				var br:Point = mtx.transformPoint(bounds.bottomRight);
//			}
			if (rightEye) rightEye = mtx.transformPoint(rightEye);
			if (leftEye) leftEye = mtx.transformPoint(leftEye);
			if (features) {
				var keys:Array = [];
				for (var key:String in features) keys.push(key);
				for each (key in keys.sort()) {
					var fp:FeaturePoint = features[key];
					var p:Point = mtx.transformPoint(fp);
					fp.x = p.x;
					fp.y = p.y;
				}
			}
		}


		public function drawDebugInfo(graphics:Graphics, scale:Number = 1):void {
			// bounds
			graphics.lineStyle(0, 0x808080, 0.8);
//			graphics.drawRect(bounds.x * scale, bounds.y * scale, bounds.width * scale, bounds.height * scale);
			
			// face
			_drawFeatures(graphics, PointNames.FACE, scale);

			// right eye
			if (rightEye) {
				graphics.lineStyle(0, 0xff0000, 0.8);
				_drawFeatures(graphics, PointNames.RIGHT_EYE, scale);
				graphics.lineStyle(0, 0x00aaff, 0.8);
				graphics.moveTo((rightEye.x - 8) * scale, (rightEye.y - 8) * scale);
				graphics.lineTo((rightEye.x + 8) * scale, (rightEye.y + 8) * scale);
				graphics.moveTo((rightEye.x + 8) * scale, (rightEye.y - 8) * scale);
				graphics.lineTo((rightEye.x - 8) * scale, (rightEye.y + 8) * scale);
			}
			var p:FeaturePoint = getFeaturePointByName('PR');
			if (p) {
				graphics.lineStyle(0, 0xff0000, 0.8);
				graphics.moveTo((p.x - 3) * scale, p.y * scale);
				graphics.lineTo((p.x + 3) * scale, p.y * scale);
				graphics.moveTo(p.x * scale, (p.y - 3) * scale);
				graphics.lineTo(p.x * scale, (p.y + 3) * scale);
			}

			// right eyebrow
			graphics.lineStyle(0, 0x00ff00, 0.8);
			_drawFeatures(graphics, PointNames.RIGHT_BROW, scale);

			// left eye
			if (leftEye) {
				graphics.lineStyle(0, 0xff0000, 0.8);
				_drawFeatures(graphics, PointNames.LEFT_EYE, scale);
				graphics.lineStyle(0, 0x00aaff, 0.8);
				graphics.moveTo((leftEye.x - 8) * scale, (leftEye.y - 8) * scale);
				graphics.lineTo((leftEye.x + 8) * scale, (leftEye.y + 8) * scale);
				graphics.moveTo((leftEye.x + 8) * scale, (leftEye.y - 8) * scale);
				graphics.lineTo((leftEye.x - 8) * scale, (leftEye.y + 8) * scale);
			}
			p = getFeaturePointByName('PL');
			if (p) {
				graphics.lineStyle(0, 0xff0000, 0.8);
				graphics.moveTo((p.x - 3) * scale, p.y * scale);
				graphics.lineTo((p.x + 3) * scale, p.y * scale);
				graphics.moveTo(p.x * scale, (p.y - 3) * scale);
				graphics.lineTo(p.x * scale, (p.y + 3) * scale);
			}

			// left eyebrow
			graphics.lineStyle(0, 0x00ff00, 0.8);
			_drawFeatures(graphics, PointNames.LEFT_BROW, scale);

			// nose
			graphics.lineStyle(0, 0x0000ff, 0.8);
			_drawFeatures(graphics, PointNames.NOSE_VERTICAL_LINE, scale, false);
			_drawFeatures(graphics, PointNames.NOSE_BOTTOM_LINE, scale, false);

			// mouth
			graphics.lineStyle(0, 0xffcc00, 0.8);
			_drawFeatures(graphics, PointNames.MOUTH_ROUND, scale);
			_drawFeatures(graphics, PointNames.MOUTH_MIDDLE_LINE, scale, false);
		}


		private function _drawFeatures(graphics:Graphics, pointIds:Array, scale:Number = 1, close:Boolean = true):void {
			if (!features) return;
			if (close) pointIds.push(pointIds[0]);
			try {
				var f:FeaturePoint = features[pointIds[0]];
				graphics.moveTo(f.x * scale, f.y * scale);
				var n:int = pointIds.length;
				for (var i:int = 1; i < n; i++) {
					f = features[pointIds[i]];
					graphics.lineTo(f.x * scale, f.y * scale);
				}
			} catch (e:Error) {
				trace('draw error:', pointIds, pointIds[i]);
			}
		}


		public function readExternal(input:IDataInput):void {
			parse(input.readObject());
		}


		public function writeExternal(output:IDataOutput):void {
			output.writeObject(toXML());
		}
		
		
		public function clone():FaceInfo {
			return new FaceInfo(toXML());
		}
		
		
		public function toXML():XML {
			var xml:XML = <face id={id}><bounds x={bounds.x} y={bounds.y} width={bounds.width} height={bounds.height}/></face>;
			if (rightEye) xml.appendChild(<right-eye x={int(rightEye.x * 1000) / 1000} y={int(rightEye.y * 1000) / 1000}/>);
			if (leftEye) xml.appendChild(<left-eye x={int(leftEye.x * 1000) / 1000} y={int(leftEye.y * 1000) / 1000}/>);
			if (features) {
				var f:XML = <features s-avg={sAvg} s-min={sMin} s-max={sMax}/>;
				for each (var fp:FeaturePoint in features) {
					f.appendChild(<point id={fp.id} x={int(fp.x * 1000) / 1000} y={int(fp.y * 1000) / 1000} s={fp.s}/>);
				}
				xml.appendChild(f);
			}
			return xml;
		}
		
		
		public function toString():String {
			return ObjectDumper.dumpToText({
				bounds: bounds,
				rightEye: rightEye,
				leftEye: leftEye,
				features: features,
				sMin: sMin,
				sMax: sMax,
				sAvg: sAvg
			}, 5, 0, 'FaceInfo: ');
		}
	}
}
