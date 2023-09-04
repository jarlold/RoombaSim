
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
   
   
}
  
  
void draw() {
}
  
  
