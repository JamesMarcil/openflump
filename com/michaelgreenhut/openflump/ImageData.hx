package com.michaelgreenhut.openflump;
import openfl.geom.Point;

/**
 * ...
 * @author Michael Greenhut
 */
class ImageData
{
  public var location:Point;
  public var scale:Point;
  public var texture:String;
  public var pivot:Point;

  public function new(texture:String, location:Point, scale:Point, pivot:Point)
  {
    this.location = location;
    this.scale = scale;
    this.texture = texture;
    this.pivot = pivot;
  }

}
