package com.michaelgreenhut.openflump;
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

  private var m_textures:Map<String,Sprite>;
  private static var m_flumpTextures:FlumpTextures;

  public function new()
  {
    m_textures = new Map<String,Sprite>();
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
    m_textures.set(name, textureSprite);
    textureSprite.visible = false;
  }

  public static function get():FlumpTextures
  {
    if (m_flumpTextures == null)
      m_flumpTextures = new FlumpTextures();

    return m_flumpTextures;
  }

  public function getTextureByName(name:String):Sprite
  {
    return m_textures.get(name);
  }

  public function cloneTextureByName(name:String):Sprite
  {
    var texture:Sprite = m_textures.get(name);
    var bd:BitmapData = new BitmapData(Std.int(texture.width), Std.int(texture.height),true,0xffffff);
    bd.draw(texture.getChildAt(0));
    var bm:Bitmap = new Bitmap(bd);
    var clone:Sprite = new Sprite();
    clone.addChild(bm);
    return clone;
  }

}
