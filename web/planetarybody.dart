
class PlanetaryBody {
  final String name;
  final String color;
  final vec2 pos;

  num bodySize;
  
  PlanetaryBody(this.name, this.color, this.bodySize, this.pos) {
    bodySize = normalizePlanetSize(bodySize);
  }

  num normalizePlanetSize(num r) {
    return log(r + 1) * (1000.0 / 100.0);
  }
  
  void draw(CanvasRenderingContext2D context) {
    drawSelf(context, this.pos.x, this.pos.y);
  }

  void drawSelf(CanvasRenderingContext2D context, num x, num y) {
    context.save();

    try {
      context.lineWidth = 0.5;
      context.fillStyle = color;
      context.strokeStyle = color;

      if (bodySize >= 2.0) {
        context.shadowOffsetX = 2;
        context.shadowOffsetY = 2;
        context.shadowBlur = 2;
        context.shadowColor = "#ddd";
      }

      context.beginPath();
      context.arc(x, y, bodySize, 0, Math.PI * 2, false);
      context.fill();
      context.closePath();
      context.stroke();

      context.shadowOffsetX = 0;
      context.shadowOffsetY = 0;
      context.shadowBlur = 0;

      context.beginPath();
      context.arc(x, y, bodySize, 0, Math.PI * 2, false);
      context.fill();
      context.closePath();
      context.stroke();
      
      // draw orbital radius
      context.strokeStyle = "black";
      context.beginPath();
      context.arc(x, y, bodySize * 5, 0, Math.PI * 2, false);
      
      context.closePath();
      context.stroke();
      
    } finally {
      context.restore();
    }
  }
}