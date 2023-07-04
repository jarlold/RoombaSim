
Roomba chumly;
Wall chair;

ArrayList<Wall> walls;
NeuralNetwork n;
ArrayList<Roomba> roombas;

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
 
 
 
void setup() {
  
   //randomSeed(42+1);
   size(800, 600); 
   walls = new ArrayList<Wall>();
   roombas = new ArrayList<Roomba>();
   
   walls.add(new Wall(100, 200, 200, 200));
   
   walls.add(new Wall(-10, -10, 10, height + 10));
   walls.add(new Wall(-10, -10, width + 10, 10));
   walls.add(new Wall(width, - 10, 10, height + 10));
   walls.add(new Wall(0, height , width + 10, 10));

    
    RoombaGenerator rb = new RoombaGenerator(3, 12, walls);
    
   roombas.add(rb.generate_random_roomba());
   roombas.add(rb.generate_random_roomba());
   roombas.add(rb.generate_random_roomba());
   roombas.add(rb.generate_random_roomba());
   roombas.add(rb.generate_random_roomba());
   roombas.add(rb.generate_random_roomba());
   roombas.add(rb.generate_random_roomba());
  }
  
  

void activate_chumly() {
  
     for (Roomba chumly : roombas) {
       chumly.draw();
  
       chumly.forward();
       for (Wall i : walls)
         i.draw();
         /*
         print(chumly.x);
         print(", ");
         print(chumly.y);
         print("\n"); */
     }
}
  
  

void draw() {
     background(255);

   //n.draw(200, 200, 15);
   activate_chumly();
  // print_vector(chumly.get_input_vector());
}
  
  
