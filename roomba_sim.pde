NicheBreeder rb ;
Roomba player_roomba;
ArrayList<Wall> walls;
void setup() {
   randomSeed(42+1);
   size(800, 600); 

   // If we crash, don't bleach my eyeballs
   background(0);
   walls = get_first_room();
   
   Dust[] d = new Dust[0];
   
   // Start by trying to breed one niche, in the background using threading
   rb = new NicheBreeder(get_rooms(), true);
   rb.start();
}
void draw() {
  background(40);
  
  //Draw the dust
  for (Dust d : rb.dusts) d.draw();
  
  // Draw the walls
  if (rb.walls != null)
     for (Wall w : rb.walls) w.draw();
  
  // Draw the roombas
  if (rb.currently_testing) {
    try{
      for (Roomba r: rb.roombas_being_tested) {
         r.draw();
      }
    } catch (Exception e) {
      print("\n -- There was some sort of error drawing roombas, we're just gonna ignore it. --\n");
    }
  }
}


void keyPressed() {
  if (key == 61) 
    rb.simulation_speed /= 2;


  if (key == 45) {
    rb.simulation_speed *= 2;
    if (rb.simulation_speed < 0.1)
      rb.simulation_speed = 1;
  }

}
  
