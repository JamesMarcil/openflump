package com.michaelgreenhut.openflump;
import openfl.geom.Point;

/**
 * ...
 * @author Michael Greenhut
 * TODO: put loc and scale for standard, untransformed instances.
 */
class Keyframe
{

  private var m_duration:Int;
  private var m_index:Int = 0;
  private var m_ref:String;
  private var m_location:Point;
  private var m_scale:Point;
  private var m_pivot:Point;
  private var m_tweened:Bool;
  private var m_ease:Float;
  private var m_alpha:Float;
  private var m_skew:Point;

  public function new(duration:Int, ref:String = null, location:Point = null, scale:Point = null, pivot:Point = null, tweened:Bool = false, ease:Float = 0, alpha:Float = 1, skew:Point = null )
  {
    m_duration = duration;
    m_location = location;
    m_ref = ref;
    if (scale == null)
      scale = new Point(1, 1);
    m_scale = scale;
    m_pivot = pivot;
    m_tweened = tweened;
    m_ease = ease;
    m_alpha = alpha;
    if (skew == null)
      m_skew = new Point(0, 0);
    else
      m_skew = skew;
  }

  public function clone():Keyframe
  {
    return new Keyframe(m_duration,m_ref,m_location,m_scale,m_pivot,m_tweened,m_ease,m_alpha,m_skew);
  }

  public function back():Bool
  {
    if (m_index > 0)
      m_index--;

    return (m_index > 0);
  }

  public function advance():Bool
  {
    if (m_index < m_duration)
      m_index++;

    return (m_index < m_duration);
  }

  public function reset():Void
  {
    m_index = 0;
  }

  public function internalIndex():Int
  {
    return m_index;
  }

  public function getRef():String
  {
    return m_ref;
  }

  public function getDuration():Int
  {
    return m_duration;
  }

  public function getLocation():Point
  {
    return m_location;
  }

  public function getSkew():Point
  {
    return m_skew;
  }

  public function getScale():Point
  {
    return m_scale;
  }

  public function getPivot():Point
  {
    return m_pivot;
  }

  public function getTweened():Bool
  {
    return m_tweened;
  }

  public function getEase():Float
  {
    return m_ease;
  }

  public function getAlpha():Float
  {
    return m_alpha;
  }

}
