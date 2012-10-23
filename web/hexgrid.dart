#library('hexgrid');

#import('dart:html');
#import('dart:math', prefix:"Math");
#import('package:vector_math/vector_math_browser.dart');


#source("hex.dart");
#source("ship.dart");
#source("planetarybody.dart");
#source("missile.dart");

//Variables
CanvasElement canvas;

double fpsAverage;
num renderTime;

num numRows = 7;
num numCols = 10;

List<List<Hex>> hexes;
List<List<Hex>> hexesP2;
List<Ship> shipsP1;
List<PlanetaryBody> planets;
List<Missile> missiles;

Ship selectedShip;

bool isAttacking;
vec2 attackVector;
//---------------------------------------------------------------------------------------------------------------------
void main() {
  canvas = query("#container");
  
  hexes = [];
  hexesP2 = [];
  shipsP1 = [];
  planets = [];
  missiles = [];
  
  num hexSize = 3;
  num yOffset = 0;
  
  isAttacking = false;

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
    
  // Initialize the planets and start the simulation.
    num minX = canvas.width / 4;
    num maxX = minX * 3;
    
    var random = new Math.Random();

    for(num i = 0; i < random.nextInt(5) + 1; i++){
      num newX = (maxX - minX) * random.nextDouble() + minX;
      num newY = canvas.height * random.nextDouble();
      
      vec2 pt = new vec2(newX, newY);
      planets.add(new PlanetaryBody("Sun", "#ff2", random.nextInt(20), pt));
    }
    
    requestRedraw();
  });
  
  
  canvas.on.doubleClick.add((MouseEvent event) {
    event.preventDefault();
    vec2 pt = new vec2(event.clientX - canvas.offsetLeft, event.clientY - canvas.offsetTop);
    
    for (Ship s in shipsP1) {
      
      if(s.isIntersect(pt)) {
        if (selectedShip != null)
          selectedShip.isSelected = false;
        
        s.isSelected = true;
        selectedShip = s;
        isAttacking = true;
        
        unselectAllHex();
        break;
      }
    }
  });
  
  canvas.on.mouseMove.add((MouseEvent event) {
    if (isAttacking) {
      attackVector = new vec2(event.clientX - canvas.offsetLeft, event.clientY - canvas.offsetTop);
      selectedShip.destDirection = Math.atan2(selectedShip.pos.y - attackVector.y, selectedShip.pos.x - attackVector.x);
    }
  });
  
  canvas.on.mouseUp.add((MouseEvent event) {
    event.preventDefault();
    vec2 pt = new vec2(event.clientX - canvas.offsetLeft, event.clientY - canvas.offsetTop);
    
    if (isAttacking) {
      vec2 vel = selectedShip.pos - pt;
      vel.normalize();
      vel *= 5;
      missiles.add(new Missile(new vec2(selectedShip.pos.x, selectedShip.pos.y), vel));
      
      isAttacking = false;
      if (selectedShip != null) {
        selectedShip.destDirection = 0.0;
        selectedShip.isSelected = false;
      }
    } else {
    
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

  drawHex(context);

  if (isAttacking)
    if (attackVector != null)
      drawShootPath(Math.atan2(attackVector.y - selectedShip.pos.y, attackVector.x - selectedShip.pos.x), 5.0, selectedShip.pos, context);
  
  drawShips(context);
  
  drawMissiles(context);
  
  drawPlanets(context);
  requestRedraw();
}

void drawPlanets(CanvasRenderingContext2D context) {
  for (PlanetaryBody p in planets) {
    p.draw(context);
  }
}

void drawBackground(CanvasRenderingContext2D context) {
  context.fillStyle = "white";
  context.rect(0, 0, context.canvas.width, context.canvas.height);
  context.fill();
}

void drawHex(CanvasRenderingContext2D context) {
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
}

void drawShips(CanvasRenderingContext2D context) { 
  for (Ship s in shipsP1) {
    s.draw(context);
  }
}

void drawMissiles(CanvasRenderingContext2D context) {
  num i = 0;
  for (Missile m in missiles) {
    for (PlanetaryBody p in planets) {   
      vec2 dist = p.pos - m.pos;

      if (dist.length <= p.bodySize) {
        m.velocity.x = 0;
        m.velocity.y = 0;
      } else if (dist.length <= p.bodySize * 5) {
      
        num force = 750 / dist.length2;
 
        // Normalize dist
        dist.normalize();

        vec2 newVel = new vec2(dist.x * force, dist.y * force);
  
        m.velocity = m.velocity + newVel;
        
        // clamp velocity
        clamp(m.velocity.x, -5, 5);
        clamp(m.velocity.y, -5, 5);
      }
    }
    
    m.draw(context);
    if (m.pos.x > canvas.width || m.pos.x < 0 || m.pos.y > canvas.height + 50 || m.pos.y < -50) {
      missiles.removeAt(i);
    } else {
      i++;
    }
  }
}

void drawShootPath(double _angle, double _speed, vec2 pos, CanvasRenderingContext2D context) {
  double g = 0.0;

  double deltaTime = 10.0/60.0;
  double vx = Math.cos(_angle) * _speed - g * deltaTime;
  double vy = Math.sin(_angle) * _speed - g * deltaTime; 

  num x = pos.x;
  num y = pos.y;
  double currentTime = deltaTime;
  double totalTime = 100.0;

  vec2 prevP = new vec2(0, 0);
  num edgeDistance = 0;
  
  while (currentTime < totalTime) {
    x -= (vx * deltaTime);
    y -= (vy * deltaTime);
    currentTime +=deltaTime;
    
    vec2 newPt = new vec2(x,y);
    vec2 newVel = new vec2(0,0);
    for (PlanetaryBody p in planets) {   
      vec2 dist = p.pos - newPt;

      if (dist.length <= p.bodySize) {
        vx = 0.0;
        vy = 0.0;
      } else if (dist.length <= p.bodySize * 5) {
        num force = 750 / dist.length2;
        
        // Normalize dist
        dist.normalize();
        vec2 newVel = new vec2(dist.x * force, dist.y * force);
        
        // clamp velocity
        clamp(newVel.x, -5, 5);
        clamp(newVel.y, -5, 5);
        
        vx -= newVel.x * deltaTime;
        vy -= newVel.y * deltaTime;
      }
    }

    if((prevP - new vec2(x,y)).length > edgeDistance) {
      
      context.lineWidth = 1;
      context.strokeStyle = "black";
      context.beginPath();
      context.arc(x, y, 1.0, 0, Math.PI * 2, false);
      context.fill();
      context.closePath();
      context.stroke();
      
      prevP = new vec2(x, y);
      edgeDistance += 2;
    }
  }
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