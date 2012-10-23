library hexgrid;

import 'dart:html';

import 'package:vector_math/vector_math_browser.dart';
import 'dart:math' as Math;

class Ship {
  vec2 pos;
  vec2 destPos;
  bool isSelected;
  bool isMoving;
  double direction, destDirection;
  
  
  num row, col, hexSize;
//  Ship(vec2 _pos) {
//    pos = _pos;
//    isSelected = false;
//  }
  
  Ship(num _row, num _col, num _hexSize) {
    row = _row;
    col = _col;
    hexSize = _hexSize;
    
    num yOffset;
    if (col % 2 == 1)
      yOffset = 10*hexSize;
    else
      yOffset = 0;
    
    pos = new vec2(40 + col * (7*hexSize), 20 + row * (20*hexSize) + yOffset);
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
    destPos = new vec2(40 + col * (7*hexSize), 20 + row * (20*hexSize) + yOffset);
    
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
  }
  
  bool isIntersect(vec2 touchPT) {
    vec2 dist = this.pos - touchPT;
    
    if (dist.length <= 15) {
      return true;
    }
    return false;
  }
}
