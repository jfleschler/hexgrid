library hexgrid;

import 'dart:html';

import 'package:vector_math/vector_math_browser.dart';
import 'dart:math' as Math;

import 'hex.dart';
import 'ship.dart';

//Variables
CanvasElement canvas;

double fpsAverage;
num renderTime;

num numRows = 7;
num numCols = 10;

List<List<Hex>> hexes;
List<List<Hex>> hexesP2;
List<Ship> shipsP1;

Ship selectedShip;


//---------------------------------------------------------------------------------------------------------------------
void main() {
  canvas = query("#container");
  
  hexes = [];
  hexesP2 = [];
  shipsP1 = [];
  
  num hexSize = 3;
  num yOffset = 0;


  for(num row = 0; row < numRows; row++) {
    hexes.add(new List<Hex>());
    hexesP2.add(new List<Hex>());
    for(num col = 0; col < numCols; col++) {
      if (col % 2 == 1)
        yOffset = 10*hexSize;
      else
        yOffset = 0;
      
      // PLAYER 1 HEX
      Hex newHex = new Hex(row*numCols + col, hexSize, new vec2(40 + col * (7*hexSize), 20 + row * (20*hexSize) + yOffset));
      hexes[row].add(newHex);
      
      // PLAYER 2 HEX
      Hex newHex2 = new Hex(row*numCols + col, hexSize, new vec2(canvas.width - 40 - col * (7*hexSize), 20 + row * (20*hexSize) + yOffset));
      hexesP2[row].add(newHex2);
    }
  }
  
  shipsP1.add(new Ship(3, 0, 3));
  shipsP1.add(new Ship(2, 0, 3));
  
  canvas.parent.rect.then((ElementRect rect) {
    requestRedraw();
  });
  
  canvas.on.mouseUp.add((MouseEvent event) {
    event.preventDefault();
    vec2 pt = new vec2(event.clientX - canvas.offsetLeft, event.clientY - canvas.offsetTop);
    
    bool didPickShip = false;
    for (Ship s in shipsP1) {
      
      if(s.isIntersect(pt)) {
        if (selectedShip != null)
          selectedShip.isSelected = false;
        
        s.isSelected = true;
        didPickShip = true;
        selectedShip = s;
        break;
      }
    }
    
    if (didPickShip) {
      selectHex(selectedShip.row,selectedShip.col);
    } else {
      bool didMoveShip = false;
      if (selectedShip != null && !selectedShip.isMoving) {
        for(num row = 0; row < numRows; row++) {
          for(num col = 0; col < numCols; col++) {
            if (row == numRows-1 && col % 2 == 1) {
              continue;
            } else {
              if (hexes[row][col].isIntersect(pt)) {
                if (hexes[row][col].isSelected) {
                  didMoveShip = true;
                  selectedShip.moveTo(row, col);
                  selectHex(row, col);
                }
              }
            }
          }
        }
      }
      
      if (!didMoveShip && selectedShip != null && !selectedShip.isMoving) {
        if (selectedShip != null)
          selectedShip.isSelected = false;
        unselectAllHex();
      }
    }
  });
}


// HEX FUNCTIONS
void unselectAllHex() {
  for(num row = 0; row < numRows; row++) {
    for(num col = 0; col < numCols; col++) {
      if (row == numRows-1 && col % 2 == 1) {
        continue;
      } else {
        hexes[row][col].isSelected = false;
      }
    }
  }
}

void selectHex(num selRow, num selCol) {
  unselectAllHex();
    
  hexes[selRow][selCol].isSelected = true;
  try { hexes[selRow][selCol-2].isSelected = true; } catch(e) {}
  try { hexes[selRow][selCol-1].isSelected = true; } catch(e) {}
  try { hexes[selRow][selCol+1].isSelected = true; } catch(e) {}
  try { hexes[selRow][selCol+2].isSelected = true; } catch(e) {}
  
  if (hexes[selRow][selCol].hexID % 2 == 1) {
    try { hexes[selRow+1][selCol-1].isSelected = true; } catch(e) {}
    try { hexes[selRow+1][selCol+1].isSelected = true; } catch(e) {}
  } else {
    try { hexes[selRow-1][selCol-1].isSelected = true; } catch(e) {}
    try { hexes[selRow-1][selCol+1].isSelected = true; } catch(e) {}
  }
}


// DRAWING FUNCTIONS
void draw(int time) {
  if (renderTime != null) {
    showFps((1000 / (time - renderTime)).round());
  }

  renderTime = time;

  var context = canvas.context2d;

  drawBackground(context);
  drawBackground(context);

  for(num row = 0; row < numRows; row++) {
    for(num col = 0; col < numCols; col++) {
      if (row == numRows-1 && col % 2 == 1) {
        continue;
      } else {
        hexes[row][col].draw(context);
        hexesP2[row][col].draw(context);
      }
    }
  }
  
  for (Ship s in shipsP1) {
    s.draw(context);
  }
  
  requestRedraw();
}

void drawBackground(CanvasRenderingContext2D context) {
  context.fillStyle = "white";
  context.rect(0, 0, context.canvas.width, context.canvas.height);
  context.fill();
}

void requestRedraw() {
  window.requestAnimationFrame(draw);
}







//---------------------------------------------------------------------------------------------------------------------
void showFps(num fps) {
  if (fpsAverage == null) {
    fpsAverage = fps;
  }

  fpsAverage = fps * 0.05 + fpsAverage * 0.95;

  query("#notes").text = "${fpsAverage.round().toInt()} fps";
}