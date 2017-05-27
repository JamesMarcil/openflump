package com.michaelgreenhut.openflump;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.geom.Point;
import openfl.geom.Rectangle;
import openfl.Lib;
import haxe.xml.Fast;
import openfl.Assets;

/**
 * @author Michael Greenhut
 * Flump was created at Three Rings by Charlie Groves, Tim Conkling, and Bruno Garcia.
 * This Flump parser for openFL was created by Michael Greenhut.
 * For directions on how to use Flump, visit:
 * http://threerings.github.io/flump/
 * Note that this parser makes use of XML only (at the moment), so be sure to export your Flump files
 * using the XML option.
 *
 *
 */
class FlumpParser
{
  private static var s_flumpParser:FlumpParser;

  private var m_fast:Fast;
  private var m_atlas:Bitmap;
  private var m_flumpMovie:FlumpMovie;
  private var m_movies:Array<FlumpMovie>;
  private var m_loadedPaths:Array<String>;

  public function new()
  {
    m_loadedPaths = new Array<String>();
    m_movies = new Array<FlumpMovie>();
  }

  public function loadPath(resourcePath:String):Void
  {
    if (Lambda.indexOf(m_loadedPaths, resourcePath) != -1)
    {
      return;
    }
    var text:String = Assets.getText(resourcePath);
    m_fast = new Fast(Xml.parse(text));
    m_loadedPaths.push(resourcePath);
    makeTextures();
    makeMovies();
  }

  public static function get():FlumpParser
  {
    if (s_flumpParser == null)
      s_flumpParser = new FlumpParser();

    return s_flumpParser;
  }

  public function textToPoint(text:String):Point
  {
    var pointArray:Array<String> = text.split(",");
    return new Point(Std.parseFloat(pointArray[0]), Std.parseFloat(pointArray[1]));
  }

  public function textToRect(text:String):Rectangle
  {
    var rectArray:Array<String> = text.split(",");
    return new Rectangle(Std.parseFloat(rectArray[0]), Std.parseFloat(rectArray[1]), Std.parseFloat(rectArray[2]), Std.parseFloat(rectArray[3]));
  }

  private function makeTextures():Void
  {
    for (textureGroups in m_fast.node.resources.nodes.textureGroups)
    {
      for (textureGroup in textureGroups.nodes.textureGroup)
      {
        for (atlas in textureGroup.nodes.atlas)
        {
          var bd:BitmapData = Assets.getBitmapData("assets/"+atlas.att.file);
          var bm:Bitmap = new Bitmap(bd);
          for (texture in atlas.nodes.texture)
          {
            var rectArray:Array<String> = texture.att.rect.split(",");
            var pointArray:Array<String> = texture.att.origin.split(",");
            var rect:Rectangle = textToRect(texture.att.rect);
            var origin:Point = textToPoint(texture.att.origin);
            FlumpTextures.get().makeTexture(bm, rect, texture.att.name,origin);
          }
        }
      }
    }
  }

  private function makeMovies():Void
  {

    for (movie in m_fast.node.resources.nodes.movie)
    {
      var fm:FlumpMovie = new FlumpMovie();
      fm.name = movie.att.name;
      for (layer in movie.nodes.layer)
      {
        var movieLayer:Layer = new Layer();
        movieLayer.name = layer.att.name;
        for (keyframe in layer.nodes.kf)
        {
          //var kf:Keyframe = new Keyframe(Std.int(keyframe.node.duration));
          var ref:String = "";
          var loc:Null<Point> = null;
          var scale:Null<Point> = null;
          var pivot:Null<Point> = new Point(0,0);
          var tweened:Bool = false;
          var ease:Null<Float> = null;
          var skew:Null<Point> = new Point(0,0);
          var alpha:Float = 1;
          if (keyframe.has.ref)
          {
            ref = keyframe.att.ref;
          }
          //fix by gigbig@libero.it
          loc = keyframe.has.loc ? textToPoint(keyframe.att.loc) : new Point(0, 0);

          if (keyframe.has.tweened)
          {
            tweened = keyframe.att.tweened == "false" ? false : true;
          }
          else
            tweened = true;
          if (keyframe.has.scale)
          {
            scale = textToPoint(keyframe.att.scale);
          }
          if (keyframe.has.pivot)
          {
            pivot = textToPoint(keyframe.att.pivot);
          }
          if (keyframe.has.skew)
          {
            skew = textToPoint(keyframe.att.skew);
          }
          if (keyframe.has.ease)
          {
            tweened = true;
            ease = Std.parseFloat(keyframe.att.ease);
          }
          if (keyframe.has.alpha)
          {
            alpha = Std.parseFloat(keyframe.att.alpha);
          }
          var kf:Keyframe = new Keyframe(Std.parseInt(keyframe.att.duration), ref, loc, scale, pivot, tweened, ease, alpha, skew);
          movieLayer.addKeyframe(kf);
        }
        fm.addLayer(movieLayer);
      }
      //fm.process();
      m_movies.push(fm);
    }
  }

  public function getMovieByName(name:String):FlumpMovie
  {
    for (i in 0...m_movies.length)
    {
      if (m_movies[i].name == name)
      {
        var movieToReturn:FlumpMovie = m_movies[i];
        //m_movies.splice(i, 1);
        return movieToReturn;
      }
    }

    return null;
  }

}
