ArrayList<Wall> walls;

NicheBreeder rb ;

// Stuff used for our local visualization
ArrayList<Roomba> roombas;
int frames = 0;
int visualization_length = 10000;
boolean currently_rendering_visualization = false;

void setup() {
   randomSeed(42);
   size(800, 600); 
   // Add some furniture to our simulation
   walls = new ArrayList<Wall>();   
   walls.add(new Wall(100, 200, 200, 200));
   walls.add(new Wall(450, 250, 50, 50));
   walls.add(new Wall(-10, -10, 10, height + 10));
   walls.add(new Wall(-10, -10, width + 10, 10));
   walls.add(new Wall(width, - 10, 10, height + 10));
   walls.add(new Wall(0, height , width + 10, 10));
   

   // Then we'll evolve some roombas
   rb = new NicheBreeder(walls, 0.1f);
   rb.initialize_genetic_algorithm();
   rb.fast_forward(1000);
   visualize_generation(rb.current_generation);
}

void visualize_generation(ArrayList<NeuralNetwork> solutions) {
   frames = 0;
   roombas = new ArrayList<Roomba>();
   for (NeuralNetwork instincts : solutions) 
     roombas.add( new Roomba(400, 300, 40, rb.walls, rb.dusts, ControlMode.INSTINCT, instincts) );
   currently_rendering_visualization = true;
}

  
void draw() {
  
  if (keyPressed)
    visualize_generation(rb.current_generation);
  
  if (! currently_rendering_visualization ) return;
  background(255);
  
  // Draw our walls
  for (Wall wall : walls)
    wall.draw();
  
  // Draw dust particles
  for (Dust d : rb.dusts)
    d.draw();
  
  // Draw and tick our roombas
  for (Roomba chumly : roombas) {
    chumly.draw();
    chumly.forward();
  }
  
  
  // Until the simulation ends, then erase them all :c
  frames++;
  if (frames >= visualization_length) {
    roombas = new ArrayList<Roomba>();
    currently_rendering_visualization = false;
  }
}
  
  
