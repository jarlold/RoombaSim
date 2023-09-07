class Dust {
  float x;
  float y;
  float size = 5;
  ArrayList<Roomba> eaten_by;
  int pulse_ticks = 0;
  boolean pulsing = false;
  
  public Dust(float x, float y) {
    this.x = x;
    this.y = y;
    eaten_by = new ArrayList<Roomba>();
  }
  
  public void clear_history() {
    eaten_by = new ArrayList<Roomba>();
  }
  
  public boolean collides_with(Roomba r) {
    float our_radius = (r.size + size)/2;
    return !eaten_by.contains(r) & abs(r.x - x) <= our_radius & abs(r.y - y) <= our_radius; 
  }
  
  public boolean try_to_eat(Roomba r) {
    if (collides_with(r)) {
      eaten_by.add(r);
      pulsing = true;
      return true;
    } else {
      return false;
    }
  }
  
  public void draw() {
    fill(color(255));
    if (pulse_ticks > 40) {
      pulsing = false;
      pulse_ticks = 0;
      fill(color(255));
    } else if(pulsing) {
      pulse_ticks++;
      fill(color(255, 0, 0));
    }
    
    circle(x, y, size);
    fill(color(255));
  }
  
}
