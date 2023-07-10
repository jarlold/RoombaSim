
Roomba chumly;
Wall chair;
ArrayList<Wall> walls;
NeuralNetwork n;
ArrayList<Roomba> roombas;
int frames = 0 ;
final int NEW_GEN_EVERY = 4000;
RoombaBreeder rb ;
 
void setup() {  
   randomSeed(42+1);
   size(800, 600); 
   walls = new ArrayList<Wall>();   
   walls.add(new Wall(100, 200, 200, 200));
   walls.add(new Wall(-10, -10, 10, height + 10));
   walls.add(new Wall(-10, -10, width + 10, 10));
   walls.add(new Wall(width, - 10, 10, height + 10));
   walls.add(new Wall(0, height , width + 10, 10));

    
   rb = new RoombaBreeder(walls, 0.1f);
   roombas = rb.generate_random_generation(10);
}
  
  
void print_matrix(float[][] m) {
   for (float[] row : m) {
     for (float val : row) {
       print(val);
       print(" ");
     }
     print("\n");
   }
}


void print_vector(float[] row) {
     for (float val : row) {
       print(val);
       print(" ");
     }
     print("\n");
}
 

void activate_chumly() {
     for (Roomba chumly : roombas) {
       chumly.draw();
  
       chumly.forward();
       for (Wall i : walls)
         i.draw();
     }
}

void create_new_generation() {
       roombas = rb.generate_next_generation(roombas);
       System.gc();
}
  
  

void draw() {
    background(255);
    activate_chumly();
    frames ++;
    if (frames != 0 && frames % NEW_GEN_EVERY == 0) {
       frames = 0;      
       create_new_generation();
    }
    textAlign(CENTER);
    text(str(roombas.size()) + "  " + str(frames) + "/" + str(NEW_GEN_EVERY), width/2,  height - 30);
    textAlign(LEFT);
}
  
  
