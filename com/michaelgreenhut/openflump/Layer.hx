package com.michaelgreenhut.openflump;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.Sprite;
import openfl.display.DisplayObjectContainer;
import openfl.geom.Matrix;
import openfl.geom.Point;
import openfl.geom.Transform;
import openfl.Lib;

/**
 * @author Michael Greenhut
 */
class Layer
{

  private var m_index:Int = 0;
  private var m_keyframes:Array<Keyframe>;
  private var m_currentTexture:String;
  private var m_previousTexture:String;
  private var m_currentLocation:Point;
  private var m_currentScale:Point;
  private var m_currentPivot:Point;
  private var m_currentSkew:Point;
  private var m_currentAlpha:Float = 1;
  private var m_image:DisplayObjectContainer;
  private var m_length:Int = 0;
  private var m_containsImage:String;
  private var m_destinationIndex:Int;
  private var m_preTweenIndex:Int = 0;
  private var m_originalMatrix:Matrix;

  public var name:String;
  public var visible:Bool = true;
  public function new()
  {
    m_keyframes = new Array<Keyframe>();
    m_preTweenIndex = m_index;
    m_image = new Sprite();
  }

  public function addKeyframe(kf:Keyframe):Void
  {
    m_keyframes.push(kf);
    m_length += kf.getDuration();
    if (kf.getRef() != null)
      m_containsImage = kf.getRef();
  }

  public function keyFrames():Array<Keyframe>
  {
    return m_keyframes;
  }

  public function back():Bool
  {
    if (m_index >= 0)
    {
      if (!m_keyframes[m_index].back())
      {
        if (m_index > 0)
        {
          m_index--;
          return true;
        }
        else
          return false;
      }

      return true;
    }

    return false;
  }

  public function advance():Bool
  {

    if (m_index < m_keyframes.length)
    {
      if (!m_keyframes[m_index].advance())
      {
        if (m_index < m_keyframes.length - 1)
        {
          m_index++;
          {
            return true;  //if the current keyframe is at the end, and there are more to go
          }
        }
        else
        {
          return false;  //if the current keyframe is at the end, and there are no more to go.
        }
      }
      return true;  //if the current keyframe isn't at the end, and there are more to go

    }
    return false;
  }

  public function process():Void
  {
    if (m_index < 0 || m_index >= m_keyframes.length)
      return;
    if (m_keyframes[m_index].getLocation() != null)
    {
      populateCurrentValues(m_index);

      var textureSprite:Sprite = FlumpTextures.get().getTextureByName(m_currentTexture);

      if (textureSprite != null)
      {
        var originalbm:Bitmap = cast(textureSprite.getChildAt(0), Bitmap);
        setImage(originalbm.bitmapData.clone());
      }
      else
      {
         //it must be a flump movie  or flipbook, and we don't need to call setImage at all.
                if (Type.getClass(m_image) != FlumpMovie)
                    m_image = FlumpParser.get().getMovieByName(m_currentTexture).clone();

                if (!cast(m_image, FlumpMovie).nextFrame())
                    cast(m_image, FlumpMovie).gotoStart();  //this loops the internal flipbook
      }

      if (m_image != null)
      {
        if (m_keyframes[m_index].getTweened()) //Stop-gap code to handle tweens
        {

          m_destinationIndex = m_index + 1;
          m_preTweenIndex = m_index;
          var nextLoc:Point = m_keyframes[m_destinationIndex].getLocation().clone();
          var nextScale:Point = m_keyframes[m_destinationIndex].getScale().clone();
          var nextPivot:Point = m_keyframes[m_destinationIndex].getPivot().clone();
          var nextAlpha:Float = m_keyframes[m_destinationIndex].getAlpha();
          var nextSkew:Point = m_keyframes[m_destinationIndex].getSkew().clone();
          m_keyframes[m_index].internalIndex();
          var multiplier:Float = m_keyframes[m_preTweenIndex].internalIndex() /m_keyframes[m_preTweenIndex].getDuration();

          m_currentAlpha = m_keyframes[m_preTweenIndex].getAlpha() + (nextAlpha - m_keyframes[m_preTweenIndex].getAlpha()) * multiplier;
          m_currentScale.x = m_keyframes[m_preTweenIndex].getScale().x + (nextScale.x - m_keyframes[m_preTweenIndex].getScale().x) * multiplier;
          m_currentScale.y = m_keyframes[m_preTweenIndex].getScale().y + (nextScale.y - m_keyframes[m_preTweenIndex].getScale().y) * multiplier;
          m_currentLocation.x = m_keyframes[m_index].getLocation().x + (nextLoc.x - m_keyframes[m_preTweenIndex].getLocation().x) * multiplier;

          m_currentLocation.y = m_keyframes[m_index].getLocation().y + (nextLoc.y - m_keyframes[m_preTweenIndex].getLocation().y) * multiplier;

          m_currentPivot.x = m_keyframes[m_index].getPivot().x + (nextPivot.x - m_keyframes[m_preTweenIndex].getPivot().x) * multiplier;
          m_currentPivot.y = m_keyframes[m_index].getPivot().y + (nextPivot.y - m_keyframes[m_preTweenIndex].getPivot().y) * multiplier;
          m_currentPivot.x *= m_currentScale.x;
          m_currentPivot.y *= m_currentScale.y;
          m_currentSkew.x = m_keyframes[m_index].getSkew().x + (nextSkew.x - m_keyframes[m_preTweenIndex].getSkew().x) * multiplier;
          m_currentSkew.y = m_keyframes[m_index].getSkew().y + (nextSkew.y - m_keyframes[m_preTweenIndex].getSkew().y) * multiplier;

        }
        m_image.scaleX = m_currentScale.x;
        m_image.scaleY = m_currentScale.y;

        m_image.x = m_currentLocation.x;
        m_image.y = m_currentLocation.y;
        if (m_image.numChildren > 0)
        {
          m_image.getChildAt(0).x = -m_currentPivot.x;
          m_image.getChildAt(0).y = -m_currentPivot.y;
        }

        //if (m_currentSkew.x != 0 || m_currentSkew.y != 0)
        {
          m_image.rotation = m_currentSkew.x * 180 / Math.PI;
        }

        m_image.visible = visible;
        m_image.alpha = m_currentAlpha;

      }
      //else
    }
    else // m_keyframes[m_index].getLocation() is never == null, so this "else" will never be executed
    {
      if (m_image != null && m_image != {})
        m_image.visible = false;
      m_currentLocation = null;
      m_currentTexture = null;
      m_currentScale = null;
      m_currentPivot = null;
    }
  }

  private function populateCurrentValues(index:Int):Void
  {
    m_previousTexture = m_currentTexture;
    m_currentTexture = m_keyframes[index].getRef();

    m_currentScale = m_keyframes[index].getScale().clone();
    m_currentLocation = m_keyframes[index].getLocation().clone();
    m_currentPivot = m_keyframes[index].getPivot().clone();
    m_currentPivot.x *= m_currentScale.x;
    m_currentPivot.y *= m_currentScale.y;
    m_currentAlpha = m_keyframes[index].getAlpha();
    m_currentSkew = m_keyframes[index].getSkew().clone();
  }

  public function isShown():Bool
  {
    return m_image.visible;
  }

  public function setImage(bd:BitmapData):Void
  {
    /*var bm:Bitmap = new Bitmap(bd);
    m_image = new Sprite();
    m_image.addChild(bm);
    m_originalMatrix = m_image.transform.matrix.clone();*/

    if (m_currentTexture != m_previousTexture) {
      var bm:Bitmap = new Bitmap(bd);
      if (m_image.numChildren > 0 && m_image.getChildAt(0) != null) (m_image.removeChildAt(0));
      m_image.addChild(bm);
      m_originalMatrix = m_image.transform.matrix.clone();
    }
  }

  public function setMovie(mv:FlumpMovie)
  {
    m_image = mv;
  }

  public function getImage():DisplayObjectContainer
  {
    return m_image;
  }

  public function getMovie():FlumpMovie
  {
    var mv:FlumpMovie = cast(m_image, FlumpMovie);

    return mv;
  }

  public function hasImageNamed():String
  {
    return m_containsImage;
  }

  public function reset():Void
  {
    goto(0);
  }

  /*
   *  Goes to absolute frame value.
   *
   */
  public function goto(internalIndex:Int):Void
  {
    m_index = 0;

    //var count:Int = 0;
    for (i in 0...m_keyframes.length)
    {
      m_keyframes[i].reset();
    }

    while(m_index < m_keyframes.length )
    {
      if (m_index/*count*/ == internalIndex)
      {
        break;
      }
      if (!m_keyframes[m_index].advance())
      {
        m_index++;
      }
      //count++;

    }
  }

  public function clone():Layer
  {
    var layer:Layer = new Layer();
    for (i in 0...m_keyframes.length)
    {
      layer.addKeyframe(m_keyframes[i].clone());
    }
    return layer;
  }

  public function getFrame():Int
  {
    return m_index;
  }

  public function getLength():Int
  {
    return m_length;
  }

}
