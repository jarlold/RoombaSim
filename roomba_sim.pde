ArrayList<Wall> walls;
RoombaBreeder rb ;
 
void setup() {
   randomSeed(42);
   size(800, 600); 
   walls = new ArrayList<Wall>();   
   walls.add(new Wall(100, 200, 200, 200));
   walls.add(new Wall(-10, -10, 10, height + 10));
   walls.add(new Wall(-10, -10, width + 10, 10));
   walls.add(new Wall(width, - 10, 10, height + 10));
   walls.add(new Wall(0, height , width + 10, 10));

   rb = new RoombaBreeder(walls, 0.1f);
   rb.initialize_genetic_algorithm();
   
   for (int i = 0; i < 10; i ++) {
     rb.genetic_algorithm_cycle();
     print(rb.best_score);
   }
   
   
}

  
void draw() {
}
  
  
