NicheBreeder nb;

void setup() {
  size(800, 600);
  nb = new NicheBreeder();
  nb.start();
}

void draw() {
  background(20);
  nb.draw();
}


void keyPressed() {
  if (key == 61) {
    nb.render_delay += 1;
    print("\nSlowing down the simulation.\n");
  }
  
  if (key == 45) {
     nb.render_delay = 0;
     print("\nEntering fast-forward mode.\n");
  }
}
