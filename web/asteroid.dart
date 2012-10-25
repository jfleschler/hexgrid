
class Asteroid {
  vec2 pos;
  vec2 vel;
  
  num bodySize;
  num mass;
  
  Asteroid(vec2 _pos, num _bodySize) {
    pos = _pos;
    bodySize = normalizePlanetSize(_bodySize);
    vel = new vec2(0,0);
    
    mass = 10;
  }
  
  num normalizePlanetSize(num r) {
    return log(r + 1) * (1000.0 / 100.0);
  }
  
  void draw(CanvasRenderingContext2D context) {
    //vel *= new vec2(0.99, 0.99);
    pos += vel;
    
    drawSelf(context, pos);
  }
  
  void drawSelf(CanvasRenderingContext2D context, vec2 pos) {
    context.save();
    context.translate(pos.x, pos.y);
    
    context.lineWidth = 1;
    context.fillStyle = "gray";
    context.strokeStyle = "black";
    
    context.beginPath();
    context.arc(0, 0, bodySize, 0, Math.PI * 2, false);
    context.fill();
    context.closePath();
    context.stroke();
    
    context.restore();
  }
  
  bool isIntersect(vec2 touchPT) {
    vec2 dist = this.pos - touchPT;
    
    if (dist.length <= bodySize) {
      return true;
    }
    return false;
  }
}
