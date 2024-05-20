class Roomba {
  final float MAX_ROOMBA_TURN_SPEED = radians(15);
  float v = 4;
  float x, y;
  float radius = 20;
  color c;
  
  // Ya boy the neural network
  NeuralNetwork instincts;
  
  // Coordinates of all the dust the Roomba has eaten
  boolean[][] bool_dusts = new boolean[1 + (int)width/40][1 + (int)height/40];
  public int bool_dusts_eaten = 0;

  // Wall objects
  ArrayList<Wall> walls;
  
  // Metrics that the roomba will keep track of, some of these go to the neural network
  float bearing = 0;
  int num_collisions = 0;
  int ticks = 0;

  
  public Roomba (float x, float y, NeuralNetwork instincts, ArrayList<Wall> walls) {
    this.x = x;
    this.y = y;
    this.instincts = instincts;
    this.c = color((int) random(120, 255),(int) random(120, 255),(int) random(120, 255));
    this.walls = walls;
  }
  
  public void draw() {
    fill(c);
    circle(this.x, this.y, this.radius*2);
    fill(255);
    circle(this.x + (this.radius-this.radius/2)*cos(this.bearing), this.y + (this.radius-this.radius/2)*sin(this.bearing), this.radius/2);
    fill(0);
    text(this.bool_dusts_eaten, this.x-5, this.y);
    
    //for (int i = 0; i < bool_dusts.length; i++) {
    //  for (int j = 0; j < bool_dusts[0].length; j++) {
    //    if (bool_dusts[i][j]) {
    //      fill(255, 125, 125);
    //      circle(i*40, j*40, 10);
    //    }
    //  }
    //}
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
    if (did_collide) {
       num_collisions += 1;
    }
    
    // Keep track of any dust it bumps into
    check_for_dust();
  }
  
  private boolean is_colliding() {
    for (Wall w: walls)
      if (w.collides(this)) return true;
    return false;
  }
  
  private void check_for_dust() {
    // This isn't a perfect simulation but it is fast.
    // It can be made better by accounting for the radius of the roomba - the rounded distance
    // (right now the roombas pick up a square area of dust, but thats ok by my books)
    int bool_dust_x = round( (this.x) / 40);
    int bool_dust_y = round((int) (this.y)/ 40);
    if (!bool_dusts[bool_dust_x][bool_dust_y]) {
      bool_dusts_eaten++;
      bool_dusts[bool_dust_x][bool_dust_y] = true;
    }
  }
  
  public void turn(float amount) {
    //if (abs(amount) > MAX_ROOMBA_TURN_SPEED)
    //  amount = MAX_ROOMBA_TURN_SPEED * abs(amount)/amount;
    this.bearing += amount;
  }
  
}
