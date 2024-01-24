ArrayList<Wall> walls;
NicheBreeder rb ;
Roomba player_roomba;

void setup() {
   randomSeed(42+1+1);
   size(800, 600); 
   
   // Add some furniture to our simulation
   walls = new ArrayList<Wall>();   
   walls.add(new Wall(0, 200, 200, 200));
   walls.add(new Wall(200, 200, 200, 30));
   walls.add(new Wall(600, 200, 200, 30));
   walls.add(new Wall(0, 200+270, 50, 50));
   walls.add(new Wall(150, 200+270, 50, 50));
   walls.add(new Wall(150, 0, 50, 130));
   
   // Just the borders
   walls.add(new Wall(-10, -10, 10, height + 10));
   walls.add(new Wall(-10, -10, width + 10, 10));
   walls.add(new Wall(width, - 10, 10, height + 10));
   walls.add(new Wall(0, height , width + 10, 10));

   
   background(0);
   Dust[] d = {};
   player_roomba = new Roomba(400, 300, 40, walls, d, ControlMode.MOUSE, null);
   rb = new NicheBreeder(walls, true);
   rb.start();
}

void draw() {
  background(125);
  
  //Draw the dust
  for (Dust d : rb.dusts) d.draw();
  
  // Draw the walls
  for (Wall w : walls) w.draw();
  
  /*
  player_roomba.draw();
  player_roomba.forward();
  */
  
  // Draw the roombas
  if (rb.visible) {
    for (Roomba r: rb.roombas_being_tested) {
      r.draw();
    }
  }
}
  
  
