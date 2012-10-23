

class Hex {
  vec2 pos;
  num hexID;
  num size;
  bool isSelected;
  
  Hex(num _id, num _size, vec2 _pos) {
    hexID = _id;
    size = _size;
    pos = _pos;
    isSelected = false;
  }
  
  void draw(CanvasRenderingContext2D context) {
    drawSelf(context, this.pos.x, this.pos.y);
  }

  void drawSelf(CanvasRenderingContext2D context, num x, num y) {

    if (isSelected) {
      context.lineWidth = 1;
      context.strokeStyle = "red";
    } else {
      context.lineWidth = 0.5;
      context.strokeStyle = "black";
    }
    
    context.beginPath();
    context.lineTo(x, y + 6 * size);
    context.lineTo(x + 6 * size, y + 3 * size);
    context.lineTo(x + 6 * size, y - 3 * size);
    context.lineTo(x, y - 6 * size);
    context.lineTo(x - 6 * size, y - 3 * size);
    context.lineTo(x - 6 * size, y + 3 * size);
    context.closePath();
    context.stroke();
    
//    context.beginPath();
//    context.arc(x, y, size*5, 0, Math.PI * 2, false);
//    context.fill();
//    context.closePath();
//    context.stroke();
    
    //context.textAlign = "center";
    //context.lineWidth = 0.5;
    //context.strokeText(hexID.toString(), x, y);
  }
  
  bool isIntersect(vec2 touchPT) {
    vec2 dist = this.pos - touchPT;
    
    if (dist.length <= size*5) {
      return true;
    }
    return false;
  }
  
}
