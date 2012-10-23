library hexgrid;

import 'dart:html';
import 'package:vector_math/vector_math_browser.dart';
import 'dart:math' as Math;

class Missile {
  vec2 pos;
  vec2 lastPos;
  vec2 velocity;
  
  Missile(vec2 _pos, vec2 _velocity) {
    pos = _pos;
    lastPos = _pos;
    velocity = _velocity;
  }
  
  void draw(CanvasRenderingContext2D context) {
    this.pos.x = this.pos.x + this.velocity.x;
    this.pos.y = this.pos.y + this.velocity.y;
    
    drawSelf(context, this.pos.x, this.pos.y);
  }

  void drawSelf(CanvasRenderingContext2D context, num x, num y) {
    context.save();

    try {
      context.lineWidth = 0.5;
      context.fillStyle = "black";
      context.strokeStyle = "black";

      context.beginPath();
      context.arc(x, y, 1.0, 0, Math.PI * 2, false);
      context.fill();
      context.closePath();
      context.stroke();
      
      context.lineWidth = 2;
      context.strokeStyle = "red";
      context.beginPath();
      context.moveTo(x, y);
      context.lineTo(x - this.velocity.x, y - this.velocity.y);
      context.closePath();
      context.stroke();
      
    } finally {
      context.restore();
    }
  }
}