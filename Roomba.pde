class Roomba {
  final float MAX_ROOMBA_TURN_SPEED = radians(15);
  float v = 4;
  float x, y;
  float radius = 20;
  color c;
  
  // Ya boy the neural network
  NeuralNetwork instincts;
  
  // Coordinates of all the dust the Roomba has eaten
  ArrayList<Dust> dusts_eaten = new ArrayList<>();
  
  // Wall objects
  ArrayList<Wall> walls;
  Dust[] dusts;
  
  // Metrics that the roomba will keep track of, some of these go to the neural network
  float bearing = 0;
  int num_collisions = 0;
  int ticks = 0;

  
  public Roomba (float x, float y, NeuralNetwork instincts, ArrayList<Wall> walls, Dust[] dusts) {
    this.x = x;
    this.y = y;
    this.instincts = instincts;
    this.c = color((int) random(120, 255),(int) random(120, 255),(int) random(120, 255));
    this.walls = walls;
    this.dusts = dusts;
  }
  
  public void draw() {
    fill(c);
    circle(this.x, this.y, this.radius*2);
    fill(255);
    circle(this.x + (this.radius-this.radius/2)*cos(this.bearing), this.y + (this.radius-this.radius/2)*sin(this.bearing), this.radius/2);
    fill(0);
    text(this.dusts_eaten.size(), this.x-5, this.y);
  }
  
  private float get_bearing_adjustement() {
    double[] input = {num_collisions, this.ticks/NicheBreeder.simulation_steps, this.bearing, sin(this.ticks/10)};
    double[] output = this.instincts.forward(input);
    return radians((float) output[0] ) * MAX_ROOMBA_TURN_SPEED;
  }
  
  public void tick() {
    ticks++;
    this.turn(get_bearing_adjustement());
    
    boolean did_collide = false;
    
    //TODO: This can be sped up significantly, somehow
    // Add the X velocity, unless it bumps into a wall
    this.x += v*cos(this.bearing);
    if (is_colliding()) {
      did_collide = true;
      this.x -= v*cos(this.bearing);
    }
    
    // Add the Y velocity, unless it bumps into a wall
    this.y += v*sin(this.bearing);
    if (is_colliding()) {
      did_collide = true;
      this.y -= v*sin(this.bearing);
    }
    
    // Keep track of the number of collisions
    if (did_collide) num_collisions += 1;
    
    // Keep track of any dust it bumps into
    check_for_dust();
  }
  
  private boolean is_colliding() {
    for (Wall w: walls)
      if (w.collides(this)) return true;
    return false;
  }
  
  private void check_for_dust() {
    // TODO: This can be sped up A LOT by removing the Dust class, and instead
    // computing the distance of the roomba to the nearest grid intersection
    // as long as the grid size is larger than roomba size.
    for (Dust d : dusts) {
      if (d.collides(this) & !dusts_eaten.contains(d)) {
        this.dusts_eaten.add(d);
      }
    }
  }
  
  public void turn(float amount) {
    //if (abs(amount) > MAX_ROOMBA_TURN_SPEED)
    //  amount = MAX_ROOMBA_TURN_SPEED * abs(amount)/amount;
    this.bearing += amount;
  }
  
}
