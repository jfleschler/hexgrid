
class Ship {
  vec2 pos;
  vec2 destPos;
  bool isP1;
  bool isSelected;
  bool isMoving;
  double destDirection;
  double shipHealth;
  
  num hexStart;
  
  num row, col, hexSize;
//  Ship(vec2 _pos) {
//    pos = _pos;
//    isSelected = false;
//  }
  
  Ship(num _row, num _col, num _hexSize, bool _isP1) {
    row = _row;
    col = _col;
    hexSize = _hexSize;
    isP1 = _isP1;
    
    shipHealth = 100.0;
    
    if (isP1) {
      hexStart = 40;
    } else {
      hexStart = canvas.width - 40;
    }
    
    num yOffset;
    if (col % 2 == 1)
      yOffset = 10*hexSize;
    else
      yOffset = 0;
    
    pos = new vec2(hexStart + (isP1 ? col : -col) * (7*hexSize), 20 + row * (20*hexSize) + yOffset);
    destPos = null;
    
    isMoving = false;
    isSelected = false;
  }
  
  void moveTo(num _row, num _col) {
    row = _row;
    col = _col;
    
    num yOffset;
    if (col % 2 == 1)
      yOffset = 10*hexSize;
    else
      yOffset = 0;
    
    isMoving = true;
    destPos = new vec2(hexStart + (isP1 ? col : -col) * (7*hexSize), 20 + row * (20*hexSize) + yOffset);
    
    destDirection = Math.atan2(destPos.y - pos.y, destPos.x - pos.x);
  }
  
  void draw(CanvasRenderingContext2D context) {
    if (destPos != null) {
      vec2 velocity = destPos - pos;
      velocity.normalize() * 3;
      pos += velocity;
    }
    
    if ( destPos != null && (destPos - pos).length < 1) {
      destPos = null;
      isMoving = false;
      destDirection = 0.0;
    }
    drawSelf(context, this.pos.x, this.pos.y);
  }

  void drawSelf(CanvasRenderingContext2D context, num x, num y) {

    if (isSelected) {
      context.lineWidth = 1;
      context.strokeStyle = "red";
      context.fillStyle = "red";
    } else {
      context.lineWidth = 0.5;
      context.strokeStyle = "black";
      context.fillStyle = "black";
    }
    
    context.save();
    context.translate(x, y);
    
    context.rotate((isP1 ? 0 : Math.PI));
    context.rotate(destDirection);

    
    context.beginPath();
    context.moveTo(0 -10, 0 - 6);
    context.lineTo(0 + 12, 0);
    context.lineTo(0 - 10, 0 + 6);
    context.lineTo(0 - 6, 0);
    context.fill();
    context.closePath();
    context.stroke();
    
    context.restore();
    
    // health bar
    context.save();
    context.translate(x, y);
    context.lineWidth = 3.5;
    context.strokeStyle = "black";
    context.fillStyle = "black";
    
    context.beginPath();
    //context.moveTo(0 -10, -9);
    //context.lineTo(0 + 10, -9);
    context.arc(0, 0, 15, 4 * Math.PI / 5  * (1 - ((shipHealth + 20) / 120.0)) + Math.PI / 5, (4 * Math.PI / 5), false);
    //context.closePath();
    context.stroke();
    
    context.lineWidth = 2;
    if (shipHealth > 60)
      context.strokeStyle = "green";
    else if (shipHealth >= 40)
      context.strokeStyle = "yellow";
    else
      context.strokeStyle = "red";

    context.beginPath();
    //context.moveTo(0 -10, -9);
    //context.lineTo(shipHealth / 5.0 - 10.0, -9);
    context.arc(0, 0, 15, 4 * Math.PI / 5  * (1 - ((shipHealth + 20) / 120.0)) + Math.PI / 5, (4 * Math.PI / 5), false);
    //context.closePath();
    context.stroke();
    
    context.restore();
    
  }
  
  bool isIntersect(vec2 touchPT) {
    vec2 dist = this.pos - touchPT;
    
    if (dist.length <= 15) {
      return true;
    }
    return false;
  }
  
  void takeDamage(double dmg) {
    shipHealth -= dmg;
  }
}
