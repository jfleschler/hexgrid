//#library('hexgrid');

#import('dart:html');
#import('dart:math', prefix:"Math");
#import('package:vector_math/vector_math_browser.dart');

#source("hex.dart");
#source("ship.dart");
#source("planetarybody.dart");
#source("missile.dart");
#source("card.dart");
#source("asteroid.dart");

//Variables
CanvasElement canvas;
CanvasElement deckCanvas;

double fpsAverage;
num renderTime;

num numRows = 7;
num numCols = 10;

List<List<Hex>> hexes;
List<List<Hex>> hexesP2;
List<Ship> shipsP1;
List<Ship> shipsP2;
List<PlanetaryBody> planets;
List<Asteroid> asteroids;
List<Missile> missiles;
List<Card> cardDeck;



Ship selectedShip;
Card selectedCard;

bool isAttacking;
bool didSelectCard;
vec2 attackVector;
//---------------------------------------------------------------------------------------------------------------------
void main() {
  canvas = query("#container");
  deckCanvas = query("#deck");
  
  hexes = [];
  hexesP2 = [];
  shipsP1 = [];
  shipsP2 = [];
  planets = [];
  asteroids = [];
  missiles = [];
  cardDeck = [];
  
  num hexSize = 3;
  num yOffset = 0;
  
  isAttacking = false;
  didSelectCard = false;
  
  selectedCard = null;
  selectedShip = null;
  
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
  
  shipsP1.add(new Ship(3, 0, 3, true));
  shipsP1.add(new Ship(2, 0, 3, true));
  
  
  var random = new Math.Random();
  shipsP2.add(new Ship(random.nextInt(numRows), random.nextInt(numCols), 3, false));
  shipsP2.add(new Ship(random.nextInt(numRows), random.nextInt(numCols), 3, false));
  shipsP2.add(new Ship(random.nextInt(numRows), random.nextInt(numCols), 3, false));
  shipsP2.add(new Ship(random.nextInt(numRows), random.nextInt(numCols), 3, false));
  
  // Initialize the planets and start the simulation.
  num minX = canvas.width / 4;
  num maxX = minX * 3;
  
  random = new Math.Random();

  num numPlanets = random.nextInt(5);
  for(num i = 0; i < numPlanets + 1; i++){
    num newX = (maxX - minX) * random.nextDouble() + minX;
    num newY = canvas.height * random.nextDouble();
    
    vec2 pt = new vec2(newX, newY);
    planets.add(new PlanetaryBody("Sun", "#ff2", random.nextInt(20), pt));
  }
  
  num numAsteroids = random.nextInt(15);
  for(num i = 0; i < numAsteroids + 1; i++){
    num newX = (maxX - minX) * random.nextDouble() + minX;
    num newY = canvas.height * random.nextDouble();
    
    vec2 pt = new vec2(newX, newY);
    asteroids.add(new Asteroid(pt, random.nextInt(2)));
  }
  
  
  // Add some cards to the deck
  cardDeck.add(new Card("ship"));
  cardDeck.add(new Card("ship"));
  cardDeck.add(new Card("ship"));
  
  requestRedraw();
  
  // EVENT HANDLERS
  deckCanvas.on.mouseUp.add((MouseEvent event) {
    event.preventDefault();
    vec2 pt = new vec2(event.clientX - deckCanvas.offsetLeft, event.clientY - deckCanvas.offsetTop);
    didSelectCard = false;
    for (Card c in cardDeck) {
      if (c.isIntersect(pt)) {
        didSelectCard = true;
        c.isSelected = true;
        selectedCard = c;
        
        if (c.cardType == "ship") {
          selectSpawnHex();
        }
        
      } else {
        c.isSelected = false;
      }
    }
    
    if (selectedShip != null) {
      selectedShip.destDirection = 0.0;
      selectedShip.isSelected = false;
      selectedShip = null;
      isAttacking = false;
    }
    
    if (!didSelectCard) {
      selectedCard = null;
      unselectAllHex();
    }
  });
  
  canvas.on.doubleClick.add((MouseEvent event) {
    event.preventDefault();
    vec2 pt = new vec2(event.clientX - canvas.offsetLeft, event.clientY - canvas.offsetTop);
    
    if (didSelectCard)
      return;
    
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
      selectedShip.destDirection = Math.atan2(attackVector.y - selectedShip.pos.y, attackVector.x - selectedShip.pos.x);
    }
  });
  
  canvas.on.mouseUp.add((MouseEvent event) {
    event.preventDefault();
    vec2 pt = new vec2(event.clientX - canvas.offsetLeft, event.clientY - canvas.offsetTop);
    
    if (isAttacking) {
      vec2 vel = pt - selectedShip.pos;
      vel.normalize();
      vel *= 5;
      missiles.add(new Missile(new vec2(selectedShip.pos.x, selectedShip.pos.y), vel));
      
      isAttacking = false;
      if (selectedShip != null) {
        selectedShip.destDirection = 0.0;
        selectedShip.isSelected = false;
      }
    } else if (didSelectCard) {
      bool cardUsed = false;
      
      for (num i = 0; i < 7; i++) {
        if (hexes[i][0].isIntersect(pt)) {
          if (hexes[i][0].isSelected) {
            shipsP1.add(new Ship(i, 0, 3, true));
            didSelectCard = false;
            cardUsed = true;
            unselectAllHex();
            break;
          }
        }
      }
      
      if (cardUsed) {
        selectedCard.isSelected = false;
        
        num i = 0;
        for (Card c in cardDeck) {
          if (c == selectedCard) {
            break;
          }
          i++;
        }
        cardDeck.removeAt(i);
      } else {
        didSelectCard = false;
        selectedCard.isSelected = false;
        selectedCard = null;
        unselectAllHex();
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


void selectSpawnHex() {
  unselectAllHex();
  
  for (num i = 0; i < 7; i++) {
    hexes[i][0].isSelected = true;
    for (Ship s in shipsP1) {
      if (s.isIntersect(hexes[i][0].pos)) {
        hexes[i][0].isSelected = false;
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
      drawShootPath(Math.atan2(selectedShip.pos.y - attackVector.y, selectedShip.pos.x - attackVector.x), 5.0, selectedShip.pos, context);
  
  drawShips(context);
  drawMissiles(context);
  drawPlanets(context);
  
  var deckContext = deckCanvas.context2d;
  
  drawBackground(deckContext);
  drawCardDeck(deckContext);
  
  requestRedraw();
}

void drawPlanets(CanvasRenderingContext2D context) {
  for (Asteroid a in asteroids) {
    a.draw(context);
    
    for (Asteroid a2 in asteroids) {
      vec2 dist = a2.pos - a.pos;
      if (a != a2 && dist.length <= a.bodySize + a2.bodySize) {
        vec2 revDist = a.pos - a2.pos;
        a2.vel = dist.normalize() * new vec2(0.2,0.2); // * new vec2(2,2);
        a.vel = revDist.normalize() * new vec2(0.2,0.2);
      }
    }
    
    for (Ship s in shipsP1) {
      if (s.isIntersect(a.pos))
        s.takeDamage(100.0);
    }
    for (Ship s in shipsP2) {
      if (s.isIntersect(a.pos))
        s.takeDamage(100.0);
    }
  }
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
  num i = 0;
  for (Ship s in shipsP1) {
    if(s.shipHealth <= 0.0) {
      shipsP1.removeAt(i);
    } else {    
      s.draw(context);
      i++;
    }
  }
  
  i = 0;
  for (Ship s in shipsP2) {
    if(s.shipHealth <= 0.0) {
      shipsP2.removeAt(i);
    } else {    
      s.draw(context);
      i++;
    }
  }
}

void drawMissiles(CanvasRenderingContext2D context) {
  num i = 0;
  for (Missile m in missiles) {
    for (PlanetaryBody p in planets) {   
      vec2 dist = p.pos - m.pos;

      if (dist.length <= p.bodySize) {
        m.velocity.x = 0.0;
        m.velocity.y = 0.0;
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
    
    for (Asteroid a in asteroids) {
      if (a.isIntersect(m.pos)) {
        missiles.removeAt(i);
        a.vel += m.velocity.normalize();
        
      }
    }
    
    for (Ship s in shipsP1) {
      if (s.isIntersect(m.pos) && s != selectedShip) {
        s.takeDamage(20.0);
        missiles.removeAt(i);
      }
    }
    
    for (Ship s in shipsP2) {
      if (s.isIntersect(m.pos) && s != selectedShip) {
        s.takeDamage(20.0);
        missiles.removeAt(i);
      }
    }
    
    if (m.pos.x > canvas.width || m.pos.x < 0 || m.pos.y > canvas.height + 50 || m.pos.y < -50) {
      missiles.removeAt(i);
    } else {
      i++;
    }
  }
}

void drawCardDeck(CanvasRenderingContext2D context) {
  num posX = 50;
  for (Card c in cardDeck) {
    c.draw(context, new vec2(posX,25));
    posX += 60;
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
  double totalTime = 1000.0;

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