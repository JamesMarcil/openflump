package com.michaelgreenhut.openflump ;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.Sprite;
import openfl.geom.Matrix;
import openfl.geom.Point;
import openfl.geom.Rectangle;

/**
 * ...
 * @author Michael Greenhut
 */
class FlumpTextures
{

  private var _textures:Map<String,Sprite>;
  private static var _flumpTextures:FlumpTextures;

  public function new(ft:FlumpTexturesKey)
  {
    _textures = new Map<String,Sprite>();
  }

  public function makeTexture(sourcebm:Bitmap, rect:Rectangle, name:String, origin:Point):Void
  {
    var newbd:BitmapData = new BitmapData(Std.int(rect.width), Std.int(rect.height), true, 0xffffffff);
    newbd.copyPixels(sourcebm.bitmapData, rect, new Point(0, 0));
    var newbm:Bitmap = new Bitmap(newbd);
    newbm.name = name;
    newbm.x = -origin.x;
    newbm.y = -origin.y;
    var textureSprite:Sprite = new Sprite();
    textureSprite.addChild(newbm);
    textureSprite.name = name;
    _textures.set(name, textureSprite);
    textureSprite.visible = false;
  }

  public static function get():FlumpTextures
  {
    if (_flumpTextures == null)
      _flumpTextures = new FlumpTextures(new FlumpTexturesKey());

    return _flumpTextures;
  }

  public function getTextureByName(name:String):Sprite
  {
    return _textures.get(name);
  }

  public function cloneTextureByName(name:String):Sprite
  {
    var texture:Sprite = _textures.get(name);
    var bd:BitmapData = new BitmapData(Std.int(texture.width), Std.int(texture.height),true,0xffffff);
    bd.draw(texture.getChildAt(0));
    var bm:Bitmap = new Bitmap(bd);
    var clone:Sprite = new Sprite();
    clone.addChild(bm);
    return clone;
  }

}

class FlumpTexturesKey
{
  public function new()
  {

  }
}
