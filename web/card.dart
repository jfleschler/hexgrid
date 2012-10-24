
class Card {
  vec2 pos;
  bool isSelected;
  String cardType;
  
  Card(String _type) {
    //pos = _pos;
    cardType = _type;
    
    isSelected = false;
  }
  
  void draw(CanvasRenderingContext2D context, vec2 pos) {
    this.pos = pos;
    drawSelf(context, pos);
  }
  
  void drawSelf(CanvasRenderingContext2D context, vec2 pos) {
    context.save();
    context.translate(pos.x, pos.y);
    
    context.lineWidth = 1;
    
    if (isSelected) {
      context.strokeStyle = "red";
      context.fillStyle = "red";
    } else {
      context.strokeStyle = "black";
      context.fillStyle = "black";
    }
    
    if (cardType == "ship") {
      context.rotate(-1 *  Math.PI / 5);
      context.beginPath();
      context.moveTo(0 -10, 0 - 6);
      context.lineTo(0 + 12, 0);
      context.lineTo(0 - 10, 0 + 6);
      context.lineTo(0 - 6, 0);
      context.fill();
      context.closePath();
      context.stroke();
    }
    
    // draw border
    context.beginPath();
    context.arc(0, 0, 20.0, 0, Math.PI * 2, false);
    context.closePath();
    context.stroke();
    
    context.restore();
  }
  
  bool isIntersect(vec2 touchPT) {
    vec2 dist = this.pos - touchPT;
    
    if (dist.length <= 20) {
      return true;
    }
    return false;
  }
}
