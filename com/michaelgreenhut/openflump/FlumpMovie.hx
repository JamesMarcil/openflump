package com.michaelgreenhut.openflump;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.LineScaleMode;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.geom.Point;
import openfl.geom.Rectangle;
import openfl.geom.Transform;
import openfl.Lib;
import openfl.display.DisplayObjectContainer;

/**
 * @author Michael Greenhut
 */
class FlumpMovie extends Sprite
{

  private static var s_count:Int = 0;

  private var m_layers:Array<Layer>;
  private var m_callback:Void->Void;
  private var m_internalX:Float;
  private var m_internalY:Float;

  public var key:Int;

  public function new()
  {
    super();
    key = Std.random(99999);
    m_layers = new Array<Layer>();
  }

  public function layers():Array<Layer>
  {
    return m_layers;
  }

  public function clone():FlumpMovie
  {
    var fm:FlumpMovie = new FlumpMovie();
    for (i in 0...m_layers.length)
    {
      fm.addLayer(m_layers[i].clone());
    }

    return fm;
  }

  public override function toString():String
  {
    var returnString:String = "[";
    for (i in 0...m_layers.length)
    {
      if (m_layers[i].getImage() == null)
        returnString += "null";
      else
      {
        for (j in 0...m_layers[i].getLength())
          returnString += ("image: " + m_layers[i].hasImageNamed());
      }
    }
    returnString += "]";

    return returnString;
  }

  public function addLayer(layer:Layer):Void
  {
    m_layers.push(layer);
    if (layer.hasImageNamed() != null)
    {
      var textureSprite:Sprite = FlumpTextures.get().getTextureByName(layer.hasImageNamed());
      if (textureSprite == null)
      {
        var mv:FlumpMovie = FlumpParser.get().getMovieByName(layer.hasImageNamed());
        layer.setMovie(mv);
      }
      else
      {
        var originalbm:Bitmap = cast(textureSprite.getChildAt(0), Bitmap);
        layer.setImage(originalbm.bitmapData.clone());
      }
    }
  }

  public function process():Void
  {
    for (i in 0...m_layers.length)
    {
      m_layers[i].process();
      checkForImage(m_layers[i]);
    }
  }

  public function getLayer(name:String):Layer
  {
    for (i in 0...m_layers.length)
    {
      if (m_layers[i].name == name)
        return m_layers[i];
    }

    return null;
  }

  public function internalX():Float
  {
    return m_internalX;
  }

  public function internalY():Float
  {
    return m_internalY;
  }

  public function checkForImage(layer:Layer):Void
  {
    if (layer.getImage() != null)
    {
      var image:DisplayObjectContainer = layer.getImage();
      if (layer.isShown())
      {
        addChild(image);
        s_count++;
      }
      else
      {
        if (contains(image))
        {
          removeChild(image);
        }
      }
      m_internalX = image.x;
      m_internalY = image.y;

    }
  }

  public function play(callb:Void->Void = null):Void
  {
    m_callback = callb;
    process();
    if (!hasEventListener(Event.ENTER_FRAME))
      addEventListener(Event.ENTER_FRAME, playInternal);
  }

  public function rewind(callb:Void->Void = null):Void
  {
    m_callback = callb;
    process();
    if (!hasEventListener(Event.ENTER_FRAME))
      addEventListener(Event.ENTER_FRAME, rewindInternal);
  }

  private function playInternal(e:Event):Void
  {
    if (!nextFrame())
    {
      removeEventListener(Event.ENTER_FRAME, playInternal);
      if (m_callback != null)
        m_callback();
    }
  }

  private function rewindInternal(e:Event):Void
  {

    if (!prevFrame())
    {
      removeEventListener(Event.ENTER_FRAME, rewindInternal);
      if (m_callback != null)
        m_callback();
    }
  }

  public function nextFrame():Bool
  {
    var more:Bool = false;
    for (i in 0...m_layers.length)
    {
      more = m_layers[i].advance();
      m_layers[i].process();
      checkForImage(m_layers[i]);
    }

    return more;
  }

  public function prevFrame():Bool
  {
    var more:Bool = false;
    for (i in 0...m_layers.length)
    {
      more = m_layers[i].back();
      m_layers[i].process();
      checkForImage(m_layers[i]);
    }

    return more;
  }

  public function gotoEnd():Void
  {
    for (i in 0...m_layers.length)
    {
      m_layers[i].goto(m_layers[i].getLength());
      m_layers[i].process();
    }
  }


  //needs work
  public function gotoStart():Void
  {
    for (i in 0...m_layers.length)
    {
      m_layers[i].goto(0);
      m_layers[i].process();
    }
  }

}
