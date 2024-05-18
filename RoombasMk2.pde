NicheBreeder nb;

void setup() {
  size(800, 600);
  ArrayList<Wall> walls = new ArrayList<Wall>();
  walls.add(new Wall(300-1, 205, 100, 100));
  walls.add(new Wall(-20, 0, 20, height));
  walls.add(new Wall(width, 0, 20, height));
  walls.add(new Wall(0, height, width, 20));
  walls.add(new Wall(0, -20, width, 20));
  
  nb = new NicheBreeder(walls);
  nb.start();
}

void draw() {
  background(20);
  nb.draw();
}


void keyPressed() {
  if (key == 61) {
    nb.render_delay += 1;
    print("\nEntering inspection mode.\n");
  }
  
  if (key == 45) {
     nb.render_delay = 0;
     print("\nEntering fast-forward mode.\n");
  }
}
