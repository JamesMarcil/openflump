package com.michaelgreenhut.openflump;

/**
 * ...
 * @author Michael Greenhut
 */
class MovieManager
{

  private static var s_movieManager:MovieManager;

  private var m_motionFunctions:Array<Void->Bool>;

  public function new()
  {
    m_motionFunctions = new Array<Void->Bool>();
  }

  public static function get():MovieManager
  {
    if (s_movieManager == null)
      s_movieManager = new MovieManager();

    return s_movieManager;
  }

  /*
   * These are for collections of two SPECIFIC functions only, nextFrame or prevFrame.  The idea is that by using the
   * MovieManager and the animateMovies function, you only have to rely on a single enterFrame loop to process multiple movies.
   * This allows you to pause/resume them all very easily and in sync, and it saves you from ODing on enterFrame functions.
   *
   * */
  public function addAnimationFunction(animationFunc:Void->Bool):Void
  {
    Type.getClass(animationFunc);
    m_motionFunctions.push(animationFunc);
  }

  /*
   * Put a call to this in a single enterFrame function.  Stop the enterFrame function when you want to pause all the
   * movies involved.
   *
   * */
  public function animateMovies():Void
  {
    if (m_motionFunctions.length == 0)
      return;
    var numFuncs:Int = -1 * (m_motionFunctions.length-1);

    for (i in numFuncs...1)
    {
      var fn:Void->Bool = m_motionFunctions[ -i];
      var moved:Bool = fn();//Reflect.callMethod(FlumpMovie, m_motionFunctions[ -i], []);
      if (!moved)   //if this movie cannot animate any further in its given direction, remove it.
      {
        m_motionFunctions.splice( -i, 1);
      }
    }
  }

}
